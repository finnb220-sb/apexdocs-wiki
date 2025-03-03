import { Context } from '@actions/github/lib/context';
import { GitHub } from '@actions/github/lib/utils';
import {
    ReviewCount,
    ActionConfiguration, PullRequestData
} from './ReviewerAssignment.types';

/**
 * This clas is designed to provide the logic to dynamically lookup teams and team members.
 *
 *
 *  Note: This makes extensive use of Github Actions *Variables* -- not secrets. This is because the data is not sensitive.
 *  You can access github actions variables by navigating to
 *  Settings ->
 *      Security (on left hand nav) ->
 *      Secrets and Variables ->
 *      Actions ->
 *      Variables (Center of screen, as a tab).
 *
 * The logic / algorithm for this is as follows:
 * Given:
 *  That GitHub teams have been created, with members in them that represent individual development teams.
 *  - For instance: a GitHub Team (a feature of GitHub) called "depeche-code" exists with members codefriar, bfinngoaldc, etc.
 *  - For instance: a GitHub Team called "the-cure" exists with members PastranaDigital, BobTheBuilder, etc.
 *
 *  A GitHub Action variables have been setup like this:
 *  - CODE_REVIEWING_TEAM_NAME: "depeche-code" (This is the team name of the team that is responsible for code reviews)
 *  - VA_TEAMS_LIST_CSV: "sprint-jedis, the-a-team, the-alchemists, team-4, team-5, team-sus" (This is a comma separated list of all the teams that this action should consider for code reviews)
 *  - PRIMARY_REVIEWER_MAPPING_JSON: '{"sprint-jedis":"bfinngoaldc","the-a-team":"codefriar","the-alchemists":"justinstroudbah","team-4":"initdotd","team-5":"PastranaDigital","team-sus":"codefriar"}' (This is a JSON object that maps team names to the primary reviewer for that team)
 *  - TEMPORARILY_UNASSIGNABLE_USERS_CSV: "codefriar-unavailable" (This is a CSV list of usernames that are temporarily unassignable, think vacation)
 *  - SOLUTION_ARCHITECT_TEAM_MAPPING_JSON: '{"sprint-jedis":"codefriar","the-a-team":"codefriar","the-alchemists":"codefriar","team-4":"codefriar","team-5":"codefriar","team-sus":"codefriar"}' (This is a JSON object that maps team names to the solution architect for that team)
 *
 * When:
 *  A PR is created or marked ready-for-review
 *
 * Then:
 *  The team name of the author is determined.
 *  The primary reviewer is determined by looking up the author's team in the mapping.
 *  The secondary reviewer is determined by looking up the reviewer with the least number of open reviews who is not the primary reviewer.
 *  The solution architect reviewer is determined by looking up the author's team in the solution architect mapping.
 *  It assigns the reviewers.
 *  It adds a label to the PR indicating it is Assigned.
 */
class ReviewerAssignment {
    // GitHub is our instance of the Octokit GitHub API client used to interact with the GitHub API. This is dependency injected.
    private github: InstanceType<typeof GitHub>;
    // context is the GitHub context object that is passed in from the GitHub Action. This is dependency injected.
    private context: Context;
    // config is the configuration object for the action. This is dependency injected.
    private config: ActionConfiguration;
    // teamMap is a map of team names to an array of team members. This is populated by the getTeamMembersForListOfTeamNames method.
    // private teamMap = new Map<string, string[]>();
    // temporarilyUnAssignableUsers is a set of usernames that are temporarily unAssignable. This is populated by the config.
    private readonly temporarilyUnAssignableUsers: Set<string>;
    // reviewLoadCache is a cache of the review load data. This is used to prevent multiple calls to the GitHub API.
    public reviewLoadCache: Map<string, ReviewCount[]> = new Map(); // Caching the results
    // primaryReviewerMapping is a map of team names to primary reviewers. This is populated by the config.
    private primaryReviewerMapping: Map<string, string>;
    // solutionArchitectMapping is a map of team names to solution architects. This is populated by the config.
    private solutionArchitectMapping: Map<string, string>;
    // vahcTeamMapping is a map of team names to team members. This is populated by the config. // VAHC reviewers.
    private readonly vahcTeamMapping: Map<string, string[]>;

    /**
     * Constructor for the ReviewerAssignment class.
     * @param github The GitHub API client (octokit) instance.
     * @param context The GitHub context object.
     * @param config The configuration object for the action.
     */
    constructor(github: InstanceType<typeof GitHub>, context: Context, config: ActionConfiguration) {
        this.github = github;
        this.context = context;
        this.config = config;
        // The GitHub variable stores these mappings in JSON format. We convert them to a Map<string, string> for easier lookup.
        this.primaryReviewerMapping = config.primaryReviewerMapping;
        this.solutionArchitectMapping = this.jsonToMap(config.solutionArchitectTeamMapping || '{}');
        // The temporarilyUnAssignableUsers is a CSV list of usernames. We convert it to a Set<string> for easier lookup.
        this.temporarilyUnAssignableUsers = new Set(config.temporarilyUnassignableUsersCsv.split(',').map(user => user.trim()));
        this.vahcTeamMapping = this.convertToMap(config.vahcTeamMapping);
    }

    /**
     * Converts a JSON string to a Map<string, string>.
     * @param jsonString
     * @private
     */
    private jsonToMap(jsonString: string): Map<string, string> {
        const parsedString = JSON.parse(jsonString);
        return new Map<string, string>(Object.entries(parsedString));
    }

    /**
     * Converts a JSON string to a Map<string, string[]>.
     * @param jsonData
     * @private
     */
    convertToMap(jsonData: string): Map<string, string[]> {
        const data: Record<string, string[]> = JSON.parse(jsonData);
        const result = new Map<string, string[]>();

        for (const [teamName, members] of Object.entries(data)) {
            result.set(teamName, members);
        }

        return result;
    }

    /**
     * Assigns reviewers to the pull request.
     * The primary reviewer is always the reviewer from the PrimaryReviewersTeam who is assigned to the author's team.
     * I.E.: If the author is in the "Backend" team, the primary reviewer is the reviewer assigned the "Backend" team.
     * The secondary reviewer is assigned based on the reviewer's load. The reviewer from the PrimaryReviewersTeam
     * with the least number of open codeReviews is assigned as the secondary reviewer.
     */
    public async assignReviewers() {
        // Ensure we're in a pull request context and that we can positively identify the pull request
        const pr = this.context.payload.pull_request;
        if (!pr || pr?.draft) {
            console.log('No PR object present or PR is a draft. Skipping reviewer assignment.');
            throw new Error('No pull request found in the payload');
        }

        // I loathe having this much in a try/catch block, but it's necessary to catch and log errors.
        try {
            // Fetch the team members for the list of teams. We do this once and cache the result.
            // this.teamMap = await this.getTeamMembersForListOfTeamNames(this.config.fullTeamsList);
            // Identify the team the author belongs to
            const prAuthorsTeam = await this.getAuthorTeam(pr.user.login);
            // Identify the primary reviewer for the author's team. If the author is in the temporary unAssignable list, find a new one.
            const primaryReviewer = await this.getPrimaryReviewer(prAuthorsTeam);
            // Identify the secondary reviewer for the author's team. The secondary reviewer is the reviewer with the least number of open reviews.
            const secondReviewer = await this.getSecondaryReviewer(primaryReviewer);
            // Identify the solution architect reviewer for the author's team.
            const solutionArchitectReviewer = await this.getSolutionArchitectReviewer(prAuthorsTeam);
            const reviewers = [primaryReviewer, secondReviewer, solutionArchitectReviewer];
            // Assign the reviewers to the pull request
            const reviewerRequest = await this.github.rest.pulls.requestReviewers({
                ...this.context.repo,
                pull_number: pr.number,
                reviewers: reviewers,
            });

            // Get the current assignees on the pull request
            const { data: pullRequest } = await this.github.rest.pulls.get({
                ...this.context.repo,
                pull_number: this.context.issue.number,
            });

            // Merge current assignees with new ones
            if(pullRequest.assignees) {
                const newAssignees = [
                    ...new Set([
                        ...pullRequest.assignees.map(assignee => assignee.login),
                        ...reviewers,
                    ]),
                ];

                // Add the assignees to the pull request using the issues API
                await this.github.rest.issues.addAssignees({
                    ...this.context.repo,
                    issue_number: this.context.issue.number, // issue_number is used to reference the PR
                    assignees: newAssignees,
                });
            }


            // Assuming we were able to assign the reviewers, add the assigned label to the PR
            if (reviewerRequest?.status === 201) {
                console.log(`Reviewers assigned to PR #${pr.number}`);
                await this.addLabelToPR('Assigned');
            }

        } catch (error: any) {
            // Error handling block where we post a comment on the PR
            const errorMessage = `Failed to assign reviewers due to: ${error.message}`;
            await this.github.rest.issues.createComment({
                ...this.context.repo,
                issue_number: pr.number,
                body: errorMessage,
            });
        }
    }

    /**
     * Method is responsible for querying GitHub for the review load data.
     */
    public async queryGraphQLForReviewLoad(): Promise<PullRequestData> {
        const prNumber = this.context.payload.pull_request?.number;
        const repoName = this.context.repo.repo;
        const owner = this.context.repo.owner;

        let result: PullRequestData;
        if (!prNumber) {
            throw new Error('No pull request number found in context. Unable to use GraphQL to pull team members for load calculation');
        }

        const query = `
            query GetAllReviewAssignments($owner: String!, $repoName: String!) {
              repository(owner: $owner, name: $repoName) {
                pullRequests(first: 100, states: [OPEN]) {
                  nodes {
                    reviewRequests(first: 100) {
                      totalCount
                      nodes {
                        requestedReviewer {
                          ... on User {
                            login
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
        `;

        const variables = {
            owner: owner,
            repoName: repoName,
            prNumber: prNumber
        };

        try {
            result = await this.github.graphql(query, variables) as any as PullRequestData;
        } catch (error) {
            console.error("Error fetching review data via GraphQL:", error);
            throw error;  // Rethrow
        }
        return result;
    }


    /**
     * Method is responsible for querying GitHub and building a list of ReviewCount objects.
     * Each ReviewCount object represents a tuple of username and the number of reviews assigned to that user.
     */
    public async fetchReviewLoadsForReviewingTeam(primaryReviewer:string): Promise<ReviewCount[]> {
        const repoName = this.context.repo.repo;
        const owner = this.context.repo.owner;
        const cacheKey = `${owner}/${repoName}`;

        // Use cache if available
        if (this.reviewLoadCache.has(cacheKey)) {
            return this.reviewLoadCache.get(cacheKey) || [];
        }

        try {
            const result = await this.queryGraphQLForReviewLoad();
            const reviewCounts: Map<string, number> = new Map();
            // Process each pull request's review requests
            result.repository.pullRequests.nodes.forEach((pr: any) => {
                pr.reviewRequests.nodes.forEach((request: any) => {
                    const login = request.requestedReviewer?.login;
                    if (login) {
                        reviewCounts.set(login, (reviewCounts.get(login) || 0) + 1);
                    }
                });
            });

            // Convert the map to an array of ReviewCount
            let reviewCountArray: ReviewCount[] = Array.from(reviewCounts, ([username, count]): ReviewCount => ({ username, count }));
            let possibleReviewers: Set<string> = this.possibleSecondReviewers(primaryReviewer);

            reviewCountArray = reviewCountArray.filter(reviewer => possibleReviewers.has(reviewer.username));
            // Sort the array by count in ascending order
            reviewCountArray.sort((a, b) => a.count - b.count);
            // Cache the sorted results
            this.reviewLoadCache.set(cacheKey, reviewCountArray);

            return reviewCountArray;
        } catch (error) {
            console.error("Error fetching review data via GraphQL:", error);
            throw error;  // Rethrow or handle as appropriate for your use case
        }
    }

    /**
     * responsible for generating a list of possible secondary reviewers.
     * This list is generated by taking the members of the primary reviewers team and removing the primary reviewer, and any temporarily unassignable users.
     * @param primaryReviewer
     * @private
     */
    private possibleSecondReviewers(primaryReviewer: string): Set<string> {
        const unassignableSet = new Set(this.temporarilyUnAssignableUsers);
        const teamReviewers = new Set(Array.from(this.primaryReviewerMapping.values()));
        let possiblePRReviewers : Set<string> = this.difference(teamReviewers, unassignableSet);
        possiblePRReviewers.delete(primaryReviewer);
        return possiblePRReviewers;
    }

    /**
     * Returns the difference between two sets. - POLYFILL -
     * @param setA left side
     * @param setB right side
     * @private
     */
    private difference<T>(setA: Set<T>, setB: Set<T>): Set<T> {
        const differenceSet = new Set<T>(setA);
        for (const elem of setB) {
            differenceSet.delete(elem);
        }
        return differenceSet;
    }

    /**
     * returns the team slug for the given username.
     * I.E.: codefriar -> depeche-code
     * @param username String, the username to look up the team for.
     * @private
     */
    private async getAuthorTeam(username: string): Promise<string> {
        for (const [teamSlug, members] of this.vahcTeamMapping.entries()) {
            if (members.includes(username)) {
                return teamSlug; // Return the team slug when the username is found in the members list.
            }
        }
        console.log(`No team found for the username: ${username}`);
        throw new Error(`No team found for the username: ${username}`);
    }

    /**
     * Returns the primary reviewer for the given team.
     * The primary reviewer is the reviewer from the PrimaryReviewersTeam who is assigned to the author's team.
     * The team is given, the primary reviewer is looked up from the config.PrimaryReviewerMapping.
     * @param incomingTeamName String, the team name to look up the primary reviewer for.
     * @private
     */
    public async getPrimaryReviewer(incomingTeamName: string): Promise<string> {
        const defaultPrimary = this.primaryReviewerMapping.get(incomingTeamName);
        if(!defaultPrimary) {
            throw new Error(`No primary reviewer found for the team: ${incomingTeamName}`);
        }
        if (this.temporarilyUnAssignableUsers.has(defaultPrimary)) {
            // If the default primary reviewer is unAssignable, find a new one
            const reviewLoad = await this.fetchReviewLoadsForReviewingTeam(defaultPrimary);
            const availableReviewers = reviewLoad.filter(reviewer => !this.temporarilyUnAssignableUsers.has(reviewer.username));
            if (availableReviewers.length > 0) {
                return availableReviewers[0].username; // Return the one with the fewest assigned reviews
            }
            throw new Error(`Primary reviewer ${defaultPrimary} is temporarily unassignable and no secondary reviewer was found`);
        }
        return defaultPrimary;
    }

    /**
     * Returns the secondary reviewer for a Pr. The secondary reviewer is the reviewer from the PrimaryReviewersTeam
     * with the least number of open codeReviews who is not the primary reviewer.
     * @param primaryReviewer String, the primary reviewer for the PR. This user is excluded from the list of potential secondary reviewers.
     * @private
     */
    public async getSecondaryReviewer(primaryReviewer: string): Promise<string> {
        const reviewLoad = await this.fetchReviewLoadsForReviewingTeam(primaryReviewer);
        const secondary = reviewLoad.find(review => review.username !== primaryReviewer);
        if (!secondary) {
            throw new Error("No suitable secondary reviewer found.");
        }
        return secondary.username;
    }

    /**
     * responsible for looking up the solution architect reviewer for the given team.
     * @param incomingTeamName String, the team name to look up the solution architect for.
     * @private
     */
    private async getSolutionArchitectReviewer(incomingTeamName: string): Promise<string> {
        if(!this.solutionArchitectMapping.has(incomingTeamName)) {
            throw new Error(`No solution architect found for the team: ${incomingTeamName}`);
        }
        const defaultSolutionArchitect = this.solutionArchitectMapping.get(incomingTeamName);
        if(!defaultSolutionArchitect) {
            throw new Error(`No solution architect found for the team: ${incomingTeamName}`);
        }
        return defaultSolutionArchitect;
    }


    /**
     * Adds a label to the current pull request.
     * @param label The label to add to the pull request.
     */
    private async addLabelToPR(label: string): Promise<void> {
        const pr = this.context.payload.pull_request;
        if (!pr) {
            console.error('No pull request found in context.');
            return;
        }

        try {
            await this.github.rest.issues.addLabels({
                owner: this.context.repo.owner,
                repo: this.context.repo.repo,
                issue_number: pr.number,
                labels: [label]
            });
            console.log(`Label "${label}" added to pull request #${pr.number}`);
        } catch (error) {
            throw new Error(`Failed to add labels`);
        }
    }
}

export default ReviewerAssignment;