export interface TeamMember {
    login: string;
}

export interface TeamMembers {
    nodes: TeamMember[];
}

export interface User {
    login: string;
}

export interface Team {
    members: TeamMembers;
}

export interface Organization {
    [key: string]: Team;
}

export interface GraphQlResponse {
    organization?: Organization;
    repository?: Repository;
}

export interface ActionConfiguration {
    primaryReviewerTeamName: string;
    fullTeamsList: string;
    primaryReviewerMapping: Map<string, string>;
    temporarilyUnassignableUsersCsv: string;
    solutionArchitectTeamMapping?: string;
    vahcTeamMapping: string;
}

export interface ReviewCount {
    username: string;
    count: number;
}

export type GetPrimaryReviewerFunction = (incomingTeamName: string) => Promise<string>;
export type GetSecondaryReviewerFunction = (incomingTeamName: string) => Promise<string>;

export interface PullRequestData {
    repository: {
        pullRequests: {
            nodes: Array<{
                reviewRequests: {
                    totalCount: number;
                    nodes: Array<{
                        requestedReviewer: {
                            login?: string;
                        };
                    }>;
                };
            }>;
        };
    };
}

/**
 * Note: the following type references a GitHub repository, not a 'repository' in the sense of a data-access pattern.
 */
export type Repository = {
    pullRequests: {
        nodes: PullRequestNode[];
    };
};

export type ReviewAssignment = {
    login: string; // Assuming login is always present for requested reviewers
};

export type PullRequestNode = {
    reviewRequests: {
        totalCount: number;
        nodes: {
            requestedReviewer: ReviewAssignment | null;
        }[];
    };
};