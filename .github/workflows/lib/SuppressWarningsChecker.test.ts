import SuppressWarningsChecker from './SuppressWarningsChecker.ts';
import { Context } from '@actions/github/lib/context';
import { jest } from '@jest/globals';

const emptyInput = { data : []};

// Mocking the GitHub and Context directly in the test file
jest.mock('@actions/github', () => ({
    GitHub: jest.fn(() => ({
        rest: {
            pulls: {
                listFiles: jest.fn().mockResolvedValue(emptyInput),
                createReview: jest.fn(),
                listReviews: jest.fn().mockResolvedValue(emptyInput),
            },
            repos: {
                getContent: jest.fn().mockResolvedValue({
                    data: { content: Buffer.from('some file content').toString('base64') },
                }),
            },
            teams: {
                listMembersInOrg: jest.fn().mockResolvedValue({
                    data: [{ login: 'member1' }],
                }),
            },
        },
    })),
}));

describe('SuppressWarningsChecker', () => {
    let checker: SuppressWarningsChecker;
    let mockGithub: any;
    let mockContext: Context;

    beforeEach(() => {
        const { GitHub } = require('@actions/github');
        mockGithub = new GitHub();
        mockContext = new Context();
        // Redefine 'repo' property
        Object.defineProperty(mockContext, 'repo', {
            value: { owner: 'owner', repo: 'repo' },
            writable: true,
            configurable: true
        });

        mockContext.payload = {
            pull_request: {
                number: 123,
                head: { sha: 'abc123' },
            },
        };
        checker = new SuppressWarningsChecker(mockGithub, mockContext);
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    it('should create an instance without throwing', () => {
        expect(checker).toBeDefined();
    });

    describe('checkPullRequest', () => {
        it('should return true when there are no violations', async () => {
            // Mocking listFiles to return an empty array (no files to check)
            mockGithub.rest.pulls.listFiles.mockResolvedValue({ data: [] });

            // Expect the method to resolve to true, allowing the CI to proceed
            await expect(checker.checkPullRequest()).resolves.toBe(true);
        });

        it('should throw an error if pull request number is undefined', async () => {
            // Setting up the context so that pull_request number is undefined
            mockContext.payload.pull_request = undefined;

            // Expect the method to throw an error
            await expect(checker.checkPullRequest()).rejects.toThrow('Pull request number is undefined');
        });

        it('should return false and create reviews if violations are found', async () => {
            // Mocking listFiles to return a specific file that ends with .cls (considered by our regex)
            mockGithub.rest.pulls.listFiles.mockResolvedValue({
                data: [{ filename: 'Test.cls', patch: '+@SuppressWarnings()', blob_url: '' }]
            });

            // Mocking getContent to return a base64 encoded content
            mockGithub.rest.repos.getContent.mockResolvedValue({
                data: { content: Buffer.from('@SuppressWarnings()').toString('base64') }
            });

            // Simulate the creation of review comments due to violations
            mockGithub.rest.pulls.createReview.mockResolvedValue({});

            // Important: Ensure that listReviews returns no approved reviews
            mockGithub.rest.pulls.listReviews.mockResolvedValue({
                data: [{ state: 'CHANGES_REQUESTED', user: { login: 'reviewer_username' } }] // Simulate a situation where changes are requested, not approved
            });

            // Execute the method and expect false as the PR should not proceed
            const result = await checker.checkPullRequest();
            expect(result).toBe(false);
            expect(mockGithub.rest.pulls.createReview).toHaveBeenCalled();
        });


        // Indirect tests of private methods through the public methods.
        // Rant: Typescript needs a @testVisible annotation.
        it('should process a pull request with valid files and no violations successfully', async () => {
            // Mocking listFiles to return files only with specified extensions
            mockGithub.rest.pulls.listFiles.mockResolvedValue({
                data: [
                    { filename: 'ValidFile.cls', status: 'modified', additions: 1, deletions: 0, changes: 1, blob_url: '', raw_url: '', contents_url: '' }
                ]
            });

            // Mocking getContent to return content that does not contain suppress warnings
            mockGithub.rest.repos.getContent.mockResolvedValue({
                data: { content: Buffer.from('public class ValidFile {}').toString('base64') }
            });

            // Execute the public method which indirectly tests getChangedFiles
            const result = await checker.checkPullRequest();
            expect(result).toBe(true);
        });

        it('should handle errors when the GitHub API fails to list files', async () => {
            // Mocking listFiles to throw an error
            mockGithub.rest.pulls.listFiles.mockRejectedValue(new Error('Failed to fetch files'));

            // Expect the public method to throw, indicating the handling of this error
            await expect(checker.checkPullRequest()).rejects.toThrow('Failed to fetch files');
        });

        it('should complete the check without finding any violations', async () => {
            // Setup API mocks for listFiles and getContent without suppress warnings
            mockGithub.rest.pulls.listFiles.mockResolvedValue({
                data: [
                    { filename: 'CleanCode.cls', status: 'modified', additions: 1, deletions: 0, changes: 1, blob_url: '', raw_url: '', contents_url: '' }
                ]
            });
            mockGithub.rest.repos.getContent.mockResolvedValue({
                data: { content: Buffer.from('public class CleanCode {}').toString('base64') }
            });

            // Execute and expect no review creation
            const result = await checker.checkPullRequest();
            expect(result).toBe(true);
            expect(mockGithub.rest.pulls.createReview).not.toHaveBeenCalled();
        });

        it('should identify suppress warnings violations and request changes', async () => {
            // Mock listFiles to return a file that should have violations
            mockGithub.rest.pulls.listFiles.mockResolvedValue({
                data: [{ filename: 'Test.cls', patch: '+@SuppressWarnings()', sha: '123', status: 'modified', additions: 1, deletions: 0, changes: 1, blob_url: '', raw_url: '', contents_url: '' }]
            });

            // Mock getContent to return a base64 encoded content that contains the suppressWarnings annotation
            mockGithub.rest.repos.getContent.mockResolvedValue({
                data: { content: Buffer.from('@SuppressWarnings()').toString('base64') }
            });

            // Simulate the creation of review comments due to violations
            mockGithub.rest.pulls.createReview.mockResolvedValue({});

            // Ensure that listReviews returns reviews that reflect the unresolved status
            mockGithub.rest.pulls.listReviews.mockResolvedValue({
                data: [{ state: 'CHANGES_REQUESTED', user: { login: 'reviewer_username' } }]
            });

            // Execute the method
            const result = await checker.checkPullRequest();

            // Expect the method to resolve to false, indicating that PR cannot proceed
            expect(result).toBe(false);
            expect(mockGithub.rest.pulls.createReview).toHaveBeenCalled();

            // Check if the appropriate review comment was created
            expect(mockGithub.rest.pulls.createReview).toHaveBeenCalledWith(expect.objectContaining({
                comments: [{
                    body: expect.stringContaining('The use of @suppressWarnings() requires justification'),
                    path: 'Test.cls',
                    line: 1
                }],
                commit_id: 'abc123',
                event: 'REQUEST_CHANGES',
                owner: 'owner',
                pull_number: 123,
                repo: 'repo'
            }));
        });

    });

    it('should request changes through reviews when suppress warnings violations are found', async () => {
        // Mocking listFiles and getContent to return a file that violates rules
        mockGithub.rest.pulls.listFiles.mockResolvedValue({
            data: [
                { filename: 'FileWithWarnings.cls', status: 'modified', additions: 1, deletions: 0, changes: 1, blob_url: '', raw_url: '', contents_url: '', patch: '+@SuppressWarnings()'}
            ]
        });
        mockGithub.rest.repos.getContent.mockResolvedValue({
            data: { content: Buffer.from('@SuppressWarnings()').toString('base64') }
        });

        // Mock createReview to simulate review creation
        mockGithub.rest.pulls.createReview.mockResolvedValue({});
        // Ensure that listReviews returns reviews that reflect the unresolved status
        mockGithub.rest.pulls.listReviews.mockResolvedValue({
            data: [{ state: 'CHANGES_REQUESTED', user: { login: 'reviewer_username' } }]
        });

        // Execute the public method which indirectly tests createReviews
        const result = await checker.checkPullRequest();
        expect(result).toBe(false);
        expect(mockGithub.rest.pulls.createReview).toHaveBeenCalled();
    });

    it('should handle errors during the review creation process', async () => {
        // Setup mocks to find a violation
        mockGithub.rest.pulls.listFiles.mockResolvedValue({
            data: [
                { filename: 'FileWithIssues.cls', status: 'modified', additions: 1, deletions: 0, changes: 1, blob_url: '', raw_url: '', contents_url: '', patch: '+@SuppressWarnings()' }
            ]
        });
        mockGithub.rest.repos.getContent.mockResolvedValue({
            data: { content: Buffer.from('@SuppressWarnings()').toString('base64') }
        });

        // Mock createReview to throw an error
        mockGithub.rest.pulls.createReview.mockRejectedValue(new Error('Review creation failed'));

        // Expect the method to throw, indicating handling of this error
        await expect(checker.checkPullRequest()).rejects.toThrow('Review creation failed');
    });

    it('should approve the pull request when all required approvals are present', async () => {
        // Setup review listing to show an approved review from an authorized user
        mockGithub.rest.pulls.listReviews.mockResolvedValue({
            data: [
                { user: { login: 'approved_user' }, state: 'APPROVED' }
            ]
        });

        // Mock team member listing to include the approving user
        mockGithub.rest.teams.listMembersInOrg.mockResolvedValue({
            data: [{ login: 'approved_user' }]
        });

        // Assuming your class fetches and checks team members in checkReviewResolution or a related method
        const result = await checker.checkPullRequest();  // Assuming this method calls checkReviewResolution internally for final decision
        expect(result).toBe(true);
    });


    it('should reject the pull request when no appropriate approvals are found', async () => {
        // Setup review listing to show reviews that don't meet approval criteria
        mockGithub.rest.pulls.listReviews.mockResolvedValue({
            data: [
                { user: { login: 'unapproved_user' }, state: 'COMMENTED' }
            ]
        });

        // Mock team member listing to not include the reviewer as an approving member
        mockGithub.rest.teams.listMembersInOrg.mockResolvedValue({
            data: [{ login: 'some_other_member' }]
        });

        // Execute and expect the public method to resolve to false
        const result = await checker.checkPullRequest();  // Assuming this method checks final approvals internally
        expect(result).toBe(false);
    });



});