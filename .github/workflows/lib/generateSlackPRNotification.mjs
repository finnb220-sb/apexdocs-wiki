import axios from 'axios';
import moment from 'moment-timezone';

export default class GenerateSlackPRNotification {
    /**
     * @description: These variables are auto-authorized, and available to us through the use of github-script in the workflow .yml file.
     * We pass them into the constructor here, to allow this JS to, for instance, make authenticated API calls to GitHub.
     */
    github;
    context;
    slackWebhookUrl;
    approvers;

    /**
     *
     * @param github - The authenticated GitHub API client from github-script context that gives us authenticated api access.
     * @param context - this is the context object from github-script that gives us access to the event context. ie: why this is running.
     * @param incomingSlackWebhookUrl - The incoming webhook URL for the Slack channel we want to post to. This is a secret.
     * @param approvedListOfPRApprovers - The list of approved PR approvers. This is an Actions variable.
     */
    constructor(github, context, incomingSlackWebhookUrl, approvedListOfPRApprovers) {
        this.github = github;
        this.context = context;
        this.slackWebhookUrl = incomingSlackWebhookUrl;
        this.approvers = approvedListOfPRApprovers.split(',').map(approver => approver.toLowerCase().trim());
    }

    /**
     * @description: This function checks if the current time is within "regular" business hours spanning the continental United States.
     *  Specifically, if the current time is between 7:45 AM Eastern Time and 6:00 PM Pacific Time.
     * @returns {boolean} true if the current time is within business hours, false otherwise.
     */
    isTheCurrentTimeWithinBusinessHours() {
        if(this.context.eventName === 'pull_request'){
            return true;
        }
        const easternTime = moment().tz("America/New_York");
        const pacificTime = moment().tz("America/Los_Angeles");

        const easternStart = moment(easternTime).hour(7).minute(45).second(0);
        const pacificEnd = moment(pacificTime).hour(18).minute(0).second(0);

        const nowEastern = moment(easternTime);
        const nowPacific = moment(pacificTime);

        return nowEastern.isBetween(easternStart, moment(easternStart).hour(23).minute(59)) &&
            nowPacific.isBetween(moment(pacificTime).hour(0).minute(0), pacificEnd);
    }

    /**
     * @description: This function checks if an interaction is done by an approved approver interaction.
     * @param interaction
     * @returns {*|boolean}
     */
    isApproverInteraction(interaction) {
        if(interaction.user.login.includes('[')){
            return false;
        }

        return this.approvers.includes(interaction.user.login) &&
            (interaction.state === 'APPROVED' || interaction.state === 'CHANGES_REQUESTED') &&
            !interaction.body.startsWith('<!-- coverage-table-comment -->') &&
            !interaction.body.startsWith('### Code Coverage');
    }

    /**
     * @description: This function fetches all open PRs in the repo, and then fetches the reviews and comments for each PR.
     * @returns {Promise<Awaited<unknown>[]>} - An array of objects, each containing the relevant data for a PR.
     */
    async fetchPRs() {
        const owner = this.context.repo.owner;
        const repo = this.context.repo.repo;

        try {
            const prs = await this.getAllPrs(owner,repo);
            const nonDraftPRs = await prs.data.filter(pr => !pr.draft);

            const pullRequestData = await Promise.all(nonDraftPRs.map(async (pr) => {
                // fetch the reviews for each pr
                const reviews = await this.getReviewsForPr(owner, repo, pr);

                // fetch count of approvals for each pr
                const approvalsCount = this.getCountOfApprovalsForPr(reviews);

                // fetch the comments for each this pr
                const { data: comments } = await this.getCommentsForPr(owner, repo, pr);

                // Fetch the number of files in the PR
                const { data: files } = await this.getFileCountForPr(owner, repo, pr);


                const approversInteractions = new Set();
                let reviewNotesCount = 0;

                [...reviews.data, ...comments].forEach(interaction => {
                    if (this.isApproverInteraction(interaction)) {
                        approversInteractions.add(interaction.user.login);
                        if (interaction.state === 'CHANGES_REQUESTED') {
                            reviewNotesCount++;
                        }
                    }
                });

                let impactScore = GenerateSlackPRNotification.generateImpactScore(approvalsCount, reviewNotesCount, files);

                const isDeclarativeOnly = !files.some(file => file.filename.endsWith('.cls') || file.filename.endsWith('.trigger') || file.filename.endsWith('.js'));

                return {
                    number: pr.number,
                    name: pr.title,
                    // Count approvals by approvers
                    approvals: reviews.data.filter(review =>
                        this.isApproverInteraction(review) && review.state === 'APPROVED'
                    ).length,
                    approversNames: Array.from(approversInteractions).join(', '),
                    age: Math.floor((new Date() - new Date(pr.updated_at)) / (1000 * 60 * 60)),  // Age in hours
                    link: pr.html_url,
                    // Check for any 'CHANGES_REQUESTED' reviews by approvers
                    review_notes: reviews.data.some(review =>
                        this.isApproverInteraction(review) && review.state === 'CHANGES_REQUESTED'
                    ),
                    file_count: files.length, // Number of files in the PR
                    impactScore: impactScore,  // Add the importance score
                    declarativeOnly: isDeclarativeOnly
                };
            }));
            pullRequestData.sort((a, b) => b.impactScore - a.impactScore);
            return pullRequestData;
        } catch (error) {
            console.error(`Failed to fetch PRs: ${error.stack}`);
        }
    }

    /**
     * @description: This function counts the number of approvals for a PR.
     * @param reviews - The reviews for a PR.
     * @returns number - The number of approvals for the PR.
     */
    getCountOfApprovalsForPr(reviews) {
        return reviews.data.filter(review =>
            this.isApproverInteraction(review) && review.state === 'APPROVED'
        ).length;
    }

    /**
     * @description: This function fetches the files in a PR.
     * @param owner - The owner of the repo.
     * @param repo - The repo name.
     * @param pr - The PR object.
     * @returns {Promise<*>} number - The number of files in the PR.
     */
    async getFileCountForPr(owner, repo, pr) {
        return await this.github.rest.pulls.listFiles({
            owner: owner,
            repo: repo,
            pull_number: pr.number
        });
    }

    /**
     * @description: This function fetches the comments for a PR.
     * @param owner - The owner of the repo.
     * @param repo - The repo name.
     * @param pr - The PR object.
     * @returns {Promise<*>} [comments] - The comments for the PR.
     */
    async getCommentsForPr(owner, repo, pr) {
        return await this.github.rest.issues.listComments({
            owner: owner,
            repo: repo,
            issue_number: pr.number
        });
    }

    /**
     * @description: This function fetches the reviews for a PR.
     * @param owner - The owner of the repo.
     * @param repo - The repo name.
     * @param pr - The PR object.
     * @returns {Promise<*>} [reviews] - The reviews for the PR.
     */
    async getReviewsForPr(owner, repo, pr) {
        return this.github.rest.pulls.listReviews({
            owner: owner,
            repo: repo,
            pull_number: pr.number
        });
    }

    /**
     * @description: This function fetches all open PRs in the repo.
     * @param owner - The owner of the repo.
     * @param repo - The repo name.
     * @returns {Promise<*>} [prs] - The open PRs in the repo.
     */
    async getAllPrs(owner, repo) {
        return await this.github.rest.pulls.list({
            owner: owner,
            repo: repo,
            state: 'open'
        });
    }

    /**
     * @description: This function generates an impact score for a PR.
     * The impact score is a synthetic score used to sort the PRs. The goal is to provide a way to identify which PRs we should work first.
     * Previously, they were simply ordered by PR#, but this doesn't take into account the state the PR is in, etc.
     * So we calculate the impact score based on the following:
     *  - Number of approvals: Each approval adds 10 points
     *  - Number of review notes: Each review note subtracts 5 points
     *  - Number of files: Each file adds 1/5th point
     *
     * The back-of-the-napkin weights I used are as follows:
     *  - If the PR already has one approval, it should be higher in the list.
     *  - If it has reviews but outstanding changes requested it should be lower than those with one or more reviews but whose requested changes have been addressed.
     *  - It should take into account the size of the PR based on the number of files affected.
     * @param approvalsCount
     * @param reviewNotesCount
     * @param files
     * @returns {number}
     */
    static generateImpactScore(approvalsCount, reviewNotesCount, files) {
        let impactScore = approvalsCount * 10;
        impactScore -= reviewNotesCount * 5;
        impactScore += Math.floor(files.length / 5);
        return impactScore;
    }

    /**
     * @description: This function sends the PR data to Slack using a block kit based message.
     * It handles the Slack API limits (50 blocks per message) by batching the blocks into multiple messages.
     * @param pullRequestData - The PR data to send to Slack.
     * @returns {Promise<void>}
     */
    async sendToSlack(pullRequestData) {
        console.debug(`Sending ${pullRequestData.length} PRs to Slack.`);
        try {
            const maxBlocksPerMessage = 50; // Slack's limit
            let currentBlocks = [{
                "type": "header",
                "text": {"type": "plain_text", "text": "Open PRs Status"}
            }];

            for (const pr of pullRequestData) {
                // Calculate the number of blocks this PR will add
                const prBlocks = [
                    {
                        "type": "section",
                        "text": {
                            "type": "mrkdwn",
                            "text": `<${pr.link}| *PR* #${pr.number} - ${pr.name}>`
                        },
                    },
                    {
                        "type": "section",
                        "fields": [
                            {"type": "mrkdwn", "text": pr.approvals > 0 || pr.approversNames ? `${'✅'.repeat(pr.approvals)} Approved by: ${pr.approversNames}` : '🚨 REVIEWS NEEDED'},
                            {"type": "mrkdwn", "text": `*Last modified:* ${pr.age} hours ago`},
                            {"type": "mrkdwn", "text": `*Files Changed:* ${pr.file_count}`},
                            {"type": "mrkdwn", "text": pr.review_notes ? '🔴 Changes requested' : '✅ Review comments resolved'},
                            {"type": "mrkdwn", "text": `*Importance Score:* ${pr.impactScore}`},
                            {"type": "mrkdwn", "text": pr.declarativeOnly ? '🔴 Declarative Only' : '✅ Includes Apex'}
                        ]
                    },
                    {
                        "type": "divider"
                    }
                ];
                currentBlocks.push(...prBlocks);

                // Check if adding this PR's blocks would exceed the limit
                if (currentBlocks.length + prBlocks.length > maxBlocksPerMessage) {
                    // Send current blocks as they are within the limit
                    console.log(`Sending a batch of ${currentBlocks.length} blocks to Slack.`);
                    await axios.post(this.slackWebhookUrl, {blocks: currentBlocks});
                    // Start a new set of blocks for the next message
                    currentBlocks = [{ "type": "header", "text": {"type": "plain_text", "text": "Continued PRs Status"}}];
                }
            }
            if (currentBlocks.length > 1) { // More than just the initial header
                console.log(`Sending the final batch of ${currentBlocks.length} blocks to Slack.`);
                await axios.post(this.slackWebhookUrl, {blocks: currentBlocks});
            }

        } catch (error) {
            console.error(`Failed to send to Slack: ${error}`);
            if (error.response) {
                // Log the full response from the server
                console.error('Error Status:', error.response.status);
                console.error('Error Headers:', error.response.headers);
                console.error('Error Data:', error.response.data);
            } else if (error.request) {
                // The request was made but no response was received
                console.error('Error Request:', error.request);
            } else {
                // Something happened in setting up the request that triggered an Error
                console.error('Error Message:', error.message);
            }
        }
    }

    /**
     * @description: This function is the main entry point for the class.
     * @returns {Promise<void>} - A promise that resolves when the Slack notification has been sent.
     */
    async buildAndSendSlackNotificationOfPRStatus(){
        if (!this.isTheCurrentTimeWithinBusinessHours()) {
            return;
        }

        const pullRequestData = await this.fetchPRs();
        await this.sendToSlack(pullRequestData);
    }
}