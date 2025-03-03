import { exec } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';
// @ts-ignore
import semver from 'semver';
// import { getOctokit } from '@actions/github';
// import { getInput } from '@actions/core';
import * as core from '@actions/core';
import * as github from '@actions/github';
import { Context } from '@actions/github/lib/context';
import { ExecOptions } from '@actions/exec';



interface ActionParameters {
    github: typeof github;
    context: Context;
    core: typeof core;
    exec: (commandLine: string, args?: string[], options?: ExecOptions) => Promise<number>;
    wikiRepoToken: string;
    targetBranch: string;
}

export class ApexDocWikiManager {
    private github: any;
    private context: any;
    private useShellExecution: boolean;
    private wikiRepoToken: string;
    private targetBranch: string;
    private ROOT_WORK_DIR = '/home/runner/work/va-teams/va-teams/';


    constructor(github: any, context: any, wikiRepoToken: string, targetBranch: string, useShellExecution: boolean = true) {
        this.github = github;
        this.context = context;
        this.wikiRepoToken = wikiRepoToken;
        this.targetBranch = targetBranch;
        this.useShellExecution = useShellExecution;
    }

    async generateAndPublishDocs(): Promise<void> {
        console.log('=====> calling generateApexDocs()');
        await this.generateApexDocs();
        // console.log('=====> calling getReleaseBranches()');
        // const releases = await this.getReleaseBranches();
        // Kevin - releases is empty - I do not know why but I also do not think we need to get release branches.
        // we should be able to get the target branch from the context argument
        // core.info('======> releases = ' + JSON.stringify(releases));
        // todo: get list of branches from repo using graphQl, not hard-coded.
        console.log('=====> calling generateHomeMd()');
        let releases: string[] = [
            '1.16',
            '1.15',
            '1.14'];
        await this.generateHomeMd(releases);
        console.log('=====> calling commitToWiki()');
        await this.commitToWiki(releases);
        console.log('=====> calling updateHeadersInAllFiles()');
        await this.updateHeadersInAllFiles(releases);
    }

    private async generateApexDocs(): Promise<void> {
        if (this.useShellExecution) {
            await this.generateApexDocsViaShell();
        } else {
            await this.generateApexDocsViaLibrary();
        }
    }

    private async generateApexDocsViaShell(): Promise<void> {
        return new Promise((resolve, reject) => {
            // let srcDir = '/home/runner/work/va-teams/va-teams/';
            // Default Target Directory is ./docs
            exec(
                `npx @cparra/apexdocs -p global public protected -s ${this.ROOT_WORK_DIR}`,
                // 'npx @cparra/apexdocs -c apexdocs-config.json',
                { maxBuffer: 1024 * 1024 * 100 }, // 100MB buffer
                (error, stdout, stderr) => {
                    if (error) {
                        console.error(`Error executing ApexDocs: ${error}`);
                        reject(error);
                    } else {
                        console.log(`ApexDocs output: ${stdout}`);
                        resolve();
                    }
                }
            );
        });
    }

    private async generateApexDocsViaLibrary(): Promise<void> {
        // TODO: ApexDocs's Author and I have been having an ongoing conversation about how to use his work as a library
        // TODO: rather than requiring shell execution. This is a placeholder for now.
        console.log('Direct library usage not implemented yet');
    }

    private async getReleaseBranches(): Promise<string[]> {
        core.info('======> this.context.repo.repo = ' + this.context.repo.repo );
        const { data: branches } = await this.github.rest.repos.listBranches({
            owner: this.context.repo.owner,
            repo: this.context.repo.repo,
        });
        // const octokit = new Octokit({
        //     auth: 'YOUR-TOKEN'
        // })
        // core.info('======> getting wiki branches from repo ' + `${this.context.repo.repo}` + '.wiki');

        // const { data: wikiBranches } =  await this.github.rest.repos.listBranches({
        //         auth: `${this.wikiRepoToken}`,
        //         owner: this.context.repo.owner,
        //         repo: `${this.context.repo.repo}/wiki`
        // });

        // this.github.auth = `${this.wikiRepoToken}` ;
        // const {data: wikiBranches } = await this.github.request(`GET /repos/{owner}/{repo}.wiki/branches`, {
        //     owner:  this.context.repo.owner,
        //     repo: `${this.context.repo.repo}.wiki`
        // });
        // core.info('======> wikiBranches = ' + JSON.stringify(wikiBranches));

        return branches
            .filter((branch: any) => branch.name.startsWith('release/'))
            .map((branch: any) => branch.name.replace('release/', ''))
            .sort((a: string, b: string) =>  semver.rcompare(a, b));
    }

    // private async gitWikiContent() : Promise<RepoContent> {
    //     this.connectToWikiRepo();
    //     const repoName = this.context.repo.repo + '.wiki';
    //     const owner = this.context.repo.owner;
    //
    //     let result: RepoContent;
    //     let branchesQuery = `
    //         query {
    //             repository(owner:"department-of-veterans-affairs",
    //                 name:"va-teams") {
    //                 refs(first: 10,
    //                     query:"release/"
    //                 refPrefix: "refs/heads/"
    //                 orderBy:{
    //                     field:TAG_COMMIT_DATE,
    //                         direction:DESC
    //                 }) {
    //                     nodes {
    //                         name
    //                     }
    //                 }
    //         }`;
    //
    //     const variables = {
    //         owner: owner,
    //         repoName: repoName
    //     };
    //
    //     try {
    //         result = await this.github.graphql(branchesQuery, variables) as any as ReleaseData;
    //     } catch (error) {
    //         console.error("Error fetching release branches for wiki via GraphQL:", error);
    //         throw error;  // Rethrow
    //     }
    //     return result;
    // }

    private async generateHomeMd(releases: string[]): Promise<void> {
        let content = '# ApexDocs\n\n## Versions\n\n';
        // todo: make sure we are correctly parsing releases
        // Kevin - releases are empty so it tries to create content in ... releases/undefined/Home
        core.info('======> releases = ' + JSON.stringify(releases));
        releases.forEach((release, index) => {
            const label = index === 0 ? `Current (${release})` : release;
            content += `- [${label}](#/wiki/releases/${release}/Home)\n`;
        });

        content += '\n\n';

        try {
            // Kevin - this will not work - you cannot use it to retrieve content from the wiki repo.
            // todo: Replace with call to graphQl to get content of wiki repo
            const { data: existingHome } = await this.github.rest.repos.getContent({
                owner: this.context.repo.owner,
                repo: `${this.context.repo.repo}.wiki`,
                path: 'Home.md',
            });
console.log('=====> existingHome = %o', existingHome);
            if ('content' in existingHome) {
                const existingContent = Buffer.from(existingHome.content, 'base64').toString('utf-8');
                const existingContentWithoutHeader = existingContent.split('\n\n').slice(2).join('\n\n');
                content += existingContentWithoutHeader;
            }
        } catch (error) {
            console.log('No existing Home.md found. Creating a new one.');
        }
        console.log('======> Writing content %o to Home.md', content);
        fs.writeFileSync('Home.md', content);
    }

    private async commitToWiki(releases: string[]): Promise<void> {
        const currentRelease = releases[0];
        core.info('=====> currentRelease = ' + currentRelease);
        const wikiRepo = `${this.context.repo.repo}.wiki`;
        core.info('=====> wikiRepo = ' + wikiRepo);
        const repoOwner = `${this.context.repo.owner}`;
        const wikiRepoUrl = `https://${this.wikiRepoToken}@github.com/${repoOwner}/${wikiRepo}.git`;
        // Kevin - I added this to connect to Wiki Repo (I have to set the token to WIKI TOKEN (passed in from yml)
        this.connectToWikiRepo();
        // // git remote set-url upstream-branch https://<token>@github.com/<username>/<repo>
        // await new Promise<void>((resolve, reject) => {
        //     exec(`git remote set-url origin ${wikiRepoUrl}`, (error) => {
        //         if (error) reject(error);
        //         else resolve();
        //     });
        // });

        await new Promise<void>((resolve, reject) => {
            // exec(`git clone https://github.com/${repoOwner}/${wikiRepo}.git`, (error) => {
            exec(`git clone ${wikiRepoUrl}`, (error) => {
                    if (error) reject(error);
                    else resolve();
                });
            }
        );

        // import { readdir } from 'node:fs/promises';

        let releasesDir = '/home/runner/work/va-teams/va-teams/va-teams.wiki/releases';
        let targetReleaseDir = `${releasesDir}/${currentRelease}`;
        if (fs.existsSync(releasesDir)) {
            if (fs.existsSync(targetReleaseDir)) {
                core.info('=======> Target directory ' + targetReleaseDir + ' exists!');
            } else {
                core.info('=======> Target directory ' + targetReleaseDir + ' does NOT exist - creating it.');
                fs.mkdirSync(targetReleaseDir, {recursive: true});
            }
        } else {
            core.info(`======> creating directory ${targetReleaseDir}`);
            fs.mkdirSync(targetReleaseDir, {recursive: true});
        }
        try {
            const files = fs.readdirSync(targetReleaseDir);
            core.info(`======> Contents of ${targetReleaseDir}`);
            for (const file of files) {
                core.info(file);
            }
        } catch (err: any) {
            core.error('======> ERROR: ' + err);
        }
        fs.readdirSync(`${this.ROOT_WORK_DIR}`)
        await new Promise<void>((resolve, reject) => {
            exec(`cd ${this.ROOT_WORK_DIR};cp -R docs/* ${wikiRepo}/releases/${currentRelease}/`, (error) => {
                if (error) reject(error);
                else resolve();
            });
        });

        await new Promise<void>((resolve, reject) => {
            core.info('=======> pushing content to wikiRepo.');
            const results = exec(`
                cd ${wikiRepo}
                git config user.name "GitHub Action"
                git config user.email "action@github.com"
                git status .
                git add .
                git commit -m "Update ApexDocs for ${currentRelease}"
                git push
            `, (error) => {
                if (error) {
                    core.error(`=====> ERROR updating wiki repo: ${error}`);
                    reject(error);
                } else {
                    core.info(`=====> SUCCESS updating wiki repo`);
                    resolve();
                }
            });
            core.info('=====> results = ' + JSON.stringify(results));
        });
    }

    private async updateHeadersInAllFiles(releases: string[]): Promise<void> {
        const wikiRepo = `${this.context.repo.repo}.wiki`;

        for (const release of releases) {
            const releaseDir = path.join(wikiRepo, 'releases', release);
            if (!fs.existsSync(releaseDir)) {
                // need to first create release directory
                core.info(`=======> Creating ${releaseDir}`);
                fs.mkdirSync(releaseDir, {recursive:true});
            }
            const files = fs.readdirSync(releaseDir);

            for (const file of files) {
                if (file.endsWith('.md')) {
                    const filePath = path.join(releaseDir, file);
                    let content = fs.readFileSync(filePath, 'utf-8');
                    // console.log('Read Contents: ' + content);
                    // console.log('contents onces split: ' + content.includes('\n') ? content.split('\n').slice(1).join('\n') : content);
                    const header = this.generateFileHeader(file, releases, release);
                    const parsedContents = content.includes('\n') ? content.split('\n').slice(1).join('\n') : content;
                    const newContent = header + parsedContents;
                        //content.split('\n').slice(1).join('\n');
                    // console.log('Writing contents: ' + newContent);
                    fs.writeFileSync(filePath, newContent);
                }
            }
        }
    }

    private async connectToWikiRepo() : Promise<void> {
        const wikiRepo = `${this.context.repo.repo}.wiki`;
        const repoOwner = `${this.context.repo.owner}`;
        const wikiRepoUrl = `https://${this.wikiRepoToken}@github.com/${repoOwner}/${wikiRepo}.git`;
        // git remote set-url upstream-branch https://<token>@github.com/<username>/<repo>
        return new Promise<void>((resolve, reject) => {
            exec(`git remote set-url origin ${wikiRepoUrl}`, (error) => {
                if (error) reject(error);
                else resolve();
            });
        });
    }
    
    private generateFileHeader(fileName: string, releases: string[], currentRelease: string): string {
        let header = '# Version Links\n\n';
        releases.forEach((release) => {
            const label = release === currentRelease ? `Current (${release})` : release;
            header += `- [${label}](#/wiki/releases/${release}/${fileName})\n`;
        });
        return header + '\n\n';
    }
}

export default async ({
                          github,
                          context,
                          core,
                          exec,
                          wikiRepoToken,
                          targetBranch
                      }: ActionParameters) => {
    try {
        core.info('=====> dirName = ' + __dirname);
        const manager = new ApexDocWikiManager(github, context, wikiRepoToken, targetBranch);
        core.info('=====> calling generateAndPublishDocs!');
        await manager.generateAndPublishDocs();
    }
    catch (error) {
        core.error('====> Error = ' + error);
    }
};

interface RepoContent {
    data: {
        repository: {
            refs: {
                nodes: [
                    {
                        name: string
                    }
                ]
            }
        }
    }
}
