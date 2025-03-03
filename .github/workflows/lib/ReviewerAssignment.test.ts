import { jest } from '@jest/globals';
import { Context } from '@actions/github/lib/context';
import { GitHub } from '@actions/github/lib/utils';
import { RestEndpointMethodTypes } from '@octokit/plugin-rest-endpoint-methods';
import { ActionConfiguration, ReviewCount } from './ReviewerAssignment.types.ts';
import ReviewerAssignment from './ReviewerAssignment.ts';
// @ts-ignore
import nock from 'nock';
import helper from './ReviewerAssignment.helpers.ts';

// Mock the GitHub client
jest.mock('@actions/github');

describe('ReviewerAssignment', () => {
    let reviewerAssignment: ReviewerAssignment;
    let mockGitHub: jest.Mocked<InstanceType<typeof GitHub>>;
    let mockContext: Context;
    let mockConfig: ActionConfiguration;

    beforeEach(() => {
        // Set up mock GitHub client
        mockGitHub = helper.buildGithubMock();

        // Set up mock context
        mockContext = helper.buildGithubMockContext('testUser');

        // Set up mock config
        mockConfig = helper.buildMockActionConfig()

        reviewerAssignment = new ReviewerAssignment(mockGitHub, mockContext, mockConfig);

        // Mock the GraphQL API call for getTeamMembersForListOfTeamNames
        const graphqlResponse = helper.buildMockGraphQLResponseForTeamMembers();
        mockGitHub.graphql.mockResolvedValue(graphqlResponse);
        nock.disableNetConnect();
    });

    afterEach(() => {
        nock.cleanAll();
        jest.resetAllMocks();
        nock.enableNetConnect();
    });

    test('assignReviewers throws when PR is null' , async () => {
        const reviewerAssignment = new ReviewerAssignment(mockGitHub, helper.buildInvalidGithubMockContext(), mockConfig);

        await expect(reviewerAssignment.assignReviewers()).rejects.toThrow('No pull request found in the payload');
    });

    test('assignReviewers throws when PR is in draft status' , async () => {
        const reviewerAssignment = new ReviewerAssignment(mockGitHub, helper.buildDraftGithubMockContext(), mockConfig);

        await expect(reviewerAssignment.assignReviewers()).rejects.toThrow('No pull request found in the payload');
    });

    test('assignReviewers', async () => {
        // Mock the queryGraphQLForReviewLoad method
        const queryGraphQLForReviewLoadResult = helper.graphQLResponseForReviewLoad;
        jest.spyOn(reviewerAssignment, 'queryGraphQLForReviewLoad').mockResolvedValue(queryGraphQLForReviewLoadResult);

        // Mock the requestReviewers response
        (mockGitHub.rest.pulls.requestReviewers as jest.MockedFunction<typeof mockGitHub.rest.pulls.requestReviewers>)
            .mockResolvedValue({ status: 201 } as RestEndpointMethodTypes['pulls']['requestReviewers']['response']);

        await reviewerAssignment.assignReviewers();

        // Verify that requestReviewers was called with the correct parameters
        expect(mockGitHub.rest.pulls.requestReviewers).toHaveBeenCalledWith({
            owner: 'testOwner',
            repo: 'testRepo',
            pull_number: 1,
            reviewers: ['bfinngoaldc', 'justinstroudbah', 'rstewartVA'],
        });

        // Verify that addLabels was called with the correct parameters
        expect(mockGitHub.rest.issues.addLabels).toHaveBeenCalledWith({
            owner: 'testOwner',
            repo: 'testRepo',
            issue_number: 1,
            labels: ['Assigned'],
        });
    });

    test('getPrimaryReviewer when primary reviewer is unassignable', async () => {
        const reviewerAssignment = new ReviewerAssignment(mockGitHub, helper.buildGithubMockContext('unassignableUser'), mockConfig);
        // Mock the fetchReviewLoadsForReviewingTeam method to return available reviewers
        const reviewLoad = [
            { username: 'availableReviewer1', count: 0 },
            { username: 'availableReviewer2', count: 1 },
        ] as ReviewCount[];
        jest.spyOn(reviewerAssignment, 'fetchReviewLoadsForReviewingTeam').mockResolvedValue(reviewLoad);

        // Call the getPrimaryReviewer method
        const primaryReviewer = await reviewerAssignment.getPrimaryReviewer('team7');

        // Verify the correct primary reviewer is returned
        expect(primaryReviewer).toBe('availableReviewer1');

        // Verify that fetchReviewLoadsForReviewingTeam was called with the correct parameters
        expect(reviewerAssignment.fetchReviewLoadsForReviewingTeam).toHaveBeenCalledWith('codefriar');

        await reviewerAssignment.assignReviewers();

        // Verify that github.rest.pulls.requestReviewers was called with the correct parameters
        expect(mockGitHub.rest.pulls.requestReviewers).toHaveBeenCalledWith({
            owner: 'testOwner',
            repo: 'testRepo',
            pull_number: 1,
            reviewers: ['availableReviewer1', 'availableReviewer2', 'malmanger'],
        });

    });

    test('getPrimaryReviewer throws error when no primary reviewer found', async () => {
        // Call the getPrimaryReviewer method with an unknown team
        await expect(reviewerAssignment.getPrimaryReviewer('unknownTeam')).rejects.toThrow('No primary reviewer found for the team: unknownTeam');
    });

    test('getPrimaryReviewer throws error when no primary reviewers found', async () => {
        // our negative tests have to use a new instance of the ReviewerAssignment class
        const reviewerAssignment = new ReviewerAssignment(mockGitHub, helper.buildGithubMockContext('unassignableUser3'), mockConfig);

        // Call the getPrimaryReviewer method and expect it to throw an error
        await expect(reviewerAssignment.getPrimaryReviewer('team8')).rejects.toThrow('No primary reviewer found for the team: team8');
    });

    test('getPrimaryReviewer throws when a primary reviewer is found, but is temporarily unassignable', async () => {
        const reviewerAssignment = new ReviewerAssignment(mockGitHub, helper.buildGithubMockContext('unassignableUser'), mockConfig);

        const reviewLoad = [] as ReviewCount[];
        jest.spyOn(reviewerAssignment, 'fetchReviewLoadsForReviewingTeam').mockResolvedValue(reviewLoad);


        // Call the getPrimaryReviewer method
        await expect(reviewerAssignment.getPrimaryReviewer('team7')).rejects.toThrow('Primary reviewer codefriar is temporarily unassignable and no secondary reviewer was found');
    });

    test('queryGraphQLForReviewLoad - positive case', async () => {
        // Mock the first GraphQL response using Nock
        const firstGraphqlResponse = {
            data: helper.buildMockGraphQLResponseForTeamMembers()
        };

        // Mock the second GraphQL response using Nock
        const secondGraphqlResponse = {
            data: {
                repository: {
                    pullRequests: {
                        nodes: [
                            {
                                reviewRequests: {
                                    totalCount: 2,
                                    nodes: [
                                        { requestedReviewer: { login: 'reviewer3' } },
                                        { requestedReviewer: { login: 'reviewer4' } }
                                    ]
                                }
                            }
                        ]
                    }
                }
            }
        };

        // Intercept the first GraphQL request and respond with the first mock data
        nock('https://api.github.com')
            .post('/graphql')
            .reply(200, firstGraphqlResponse);

        // Intercept the second GraphQL request and respond with the second mock data
        nock('https://api.github.com')
            .post('/graphql')
            .reply(200, secondGraphqlResponse);

        // Call the method
        await reviewerAssignment.queryGraphQLForReviewLoad();

        // Verify the result
        // expect(result).toEqual(firstGraphqlResponse.data);

        // Verify that the graphql method was called with the correct parameters for the first call
        expect(mockGitHub.graphql).toHaveBeenCalledWith(
            expect.any(String),
            {
                owner: 'testOwner',
                repoName: 'testRepo',
                prNumber: 1
            }
        );

        // Verify that the graphql method was called with the correct parameters for the second call
        expect(mockGitHub.graphql).toHaveBeenCalledWith(
            expect.any(String),
            {
                owner: 'testOwner',
                repoName: 'testRepo',
                prNumber: 1
            }
        );
    });

    test('queryGraphQLForReviewLoad - throws error when PR number is missing', async () => {
        // Modify the context to remove the pull request number
        mockContext.payload.pull_request = undefined;

        // Call the method and expect it to throw an error
        await expect(reviewerAssignment.queryGraphQLForReviewLoad()).rejects.toThrow('No pull request number found in context. Unable to use GraphQL to pull team members for load calculation');
    });

    test('queryGraphQLForReviewLoad - handles GraphQL error', async () => {
        // Intercept the GraphQL request and respond with an error
        mockGitHub.graphql.mockRejectedValue(new Error('GraphQL error'));
        // nock('https://api.github.com')
        //     .post('/graphql')
        //     .replyWithError('GraphQL error');

        // Spy on console.error to verify error logging
        const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation(() => {});

        // Call the method and expect it to throw the same error
        await expect(reviewerAssignment.queryGraphQLForReviewLoad()).rejects.toThrow('GraphQL error');

        // Verify that the error was logged to the console
        expect(consoleErrorSpy).toHaveBeenCalledWith("Error fetching review data via GraphQL:", expect.any(Error));

        // Restore the original console.error implementation
        consoleErrorSpy.mockRestore();
    });

    test('fetchReviewLoadsForReviewingTeam - uses cache to prevent multiple GraphQL calls', async () => {
        // Mock the graphql method to return a predefined response
        const queryGraphQLForReviewLoadResult = helper.graphQLResponseForReviewLoad;

        mockGitHub.graphql.mockResolvedValue(queryGraphQLForReviewLoadResult);

        // Call the method for the first time
        const primaryReviewer = 'primaryReviewer';
        const reviewLoadFirstCall = await reviewerAssignment.fetchReviewLoadsForReviewingTeam(primaryReviewer);

        // Call the method for the second time
        const reviewLoadSecondCall = await reviewerAssignment.fetchReviewLoadsForReviewingTeam(primaryReviewer);

        // Verify that the graphql method was called only once
        expect(mockGitHub.graphql).toHaveBeenCalledTimes(1);

        // Verify that the results of both calls are the same
        expect(reviewLoadFirstCall).toEqual(reviewLoadSecondCall);

        // Verify that the cache contains the expected data
        const cacheKey = `${mockContext.repo.owner}/${mockContext.repo.repo}`;
        expect(reviewerAssignment.reviewLoadCache.has(cacheKey)).toBe(true);
        expect(reviewerAssignment.reviewLoadCache.get(cacheKey)).toEqual(reviewLoadFirstCall);
    });

});