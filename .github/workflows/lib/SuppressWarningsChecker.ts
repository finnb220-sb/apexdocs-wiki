import { Context } from '@actions/github/lib/context';
import { GitHub } from '@actions/github/lib/utils';

interface FileContent {
    content: string;
}

interface PullRequestFile {
    filename: string;
    patch?: string;  // Make patch optional
    sha: string;
    status: 'added' | 'removed' | 'modified' | 'renamed' | 'copied' | 'changed' | 'unchanged';
    additions: number;
    deletions: number;
    changes: number;
    blob_url: string;
    raw_url: string;
    contents_url: string;
    previous_filename?: string;
}

interface Violation {
    file: string;
    line: number;
}

export default class SuppressWarningsChecker {
    private github: InstanceType<typeof GitHub>;
    private context: Context;
    private suppressWarningsRegex: RegExp = /@suppresswarnings\(/i;
    private fileExtensions: string[];
    private slugOfTheApprovingTeam: string;
    private approvingTeamMembers: string[] | null;

    constructor(github: InstanceType<typeof GitHub>, context: Context) {
        this.github = github;
        this.context = context;
        // this.suppressWarningsRegex =
        this.fileExtensions = ['.trigger', '.cls'];
        this.slugOfTheApprovingTeam = 'depeche-code'; // Update this with your actual team slug
        this.approvingTeamMembers = null;
    }

    async checkPullRequest(): Promise<boolean> {
        const { owner, repo } = this.context.repo;
        const pullNumber = this.context.payload.pull_request?.number;

        if (!pullNumber) {
            throw new Error('Pull request number is undefined');
        }

        const files = await this.getChangedFiles(owner, repo, pullNumber);
        const violations = await this.findViolations(files);

        if (violations.length > 0) {
            await this.createReviews(violations, owner, repo, pullNumber);
            // After creating reviews, check for resolution of all reviews
            return await this.checkReviewResolution();  // Check if the review conditions are now satisfied
        } else {
            // If no new violations, still need to check if existing reviews have resolved appropriately
            return await this.checkReviewResolution();
        }

    }

    private async getChangedFiles(owner: string, repo: string, pullNumber: number): Promise<PullRequestFile[]> {
        const { data: files } = await this.github.rest.pulls.listFiles({
            owner,
            repo,
            pull_number: pullNumber,
        });

        return files.filter(file =>
            this.fileExtensions.some(ext => file.filename.endsWith(ext))
        );
    }

    private async findViolations(files: PullRequestFile[]): Promise<Violation[]> {
        const violations: Violation[] = [];

        for (const file of files) {
            const { data: content } = await this.github.rest.repos.getContent({
                owner: this.context.repo.owner,
                repo: this.context.repo.repo,
                path: file.filename,
                ref: this.context.payload.pull_request?.head.sha,
            }) as { data: FileContent };

            const decodedContent = Buffer.from(content.content, 'base64').toString('utf-8');
            const lines = decodedContent.split('\n');

            if (file.patch) {
                file.patch.split('\n').forEach(line => {
                    if (line.startsWith('+') && this.suppressWarningsRegex.test(line)) {
                        const lineNumber = this.findLineNumber(lines, line.slice(1).trim());
                        if (lineNumber !== -1) {
                            violations.push({ file: file.filename, line: lineNumber });
                        }
                    }
                });
            }
        }

        return violations;
    }

    private findLineNumber(lines: string[], searchLine: string): number {
        return lines.findIndex(line => line.trim() === searchLine) + 1;
    }

    private async createReviews(violations: Violation[], owner: string, repo: string, pullNumber: number): Promise<void> {
        for (const violation of violations) {
            await this.github.rest.pulls.createReview({
                owner,
                repo,
                pull_number: pullNumber,
                commit_id: this.context.payload.pull_request?.head.sha,
                event: 'REQUEST_CHANGES',
                comments: [{
                    path: violation.file,
                    line: violation.line,
                    body: 'The use of @suppressWarnings() requires justification. Please provide a comment explaining why this suppression is necessary.',
                }],
            });
        }
    }

    async checkReviewResolution(): Promise<boolean> {
        const { owner, repo } = this.context.repo;
        const pullNumber = this.context.payload.pull_request?.number;

        if (!pullNumber) {
            throw new Error('Pull request number is undefined');
        }

        const { data: reviews } = await this.github.rest.pulls.listReviews({
            owner,
            repo,
            pull_number: pullNumber,
        });

        if(reviews.length === 0) {
            return true;
        }

        for (const review of reviews) {
            if (!review || !review.user) continue; // guard against null values
            if (await this.isMemberOfApprovingTeam(review.user.login) && review.state === 'APPROVED') {
                return true;
            }
        }

        return false;
    }

    private async isMemberOfApprovingTeam(username: string): Promise<boolean> {
        if (!this.approvingTeamMembers) {
            await this.fetchApprovingTeamsMembers();
        }
        return this.approvingTeamMembers?.includes(username.toLowerCase()) ?? false;
    }

    private async fetchApprovingTeamsMembers(): Promise<void> {
        try {
            const { data: members } = await this.github.rest.teams.listMembersInOrg({
                org: this.context.repo.owner,
                team_slug: this.slugOfTheApprovingTeam,
                per_page: 100
            });

            this.approvingTeamMembers = members.map(member => member.login.toLowerCase());
        } catch (error) {
            console.error('Error fetching Depeche Code team members:', error);
            this.approvingTeamMembers = [];
        }
    }
}