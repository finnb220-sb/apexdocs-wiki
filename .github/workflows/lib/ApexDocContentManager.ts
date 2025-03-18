import { exec } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';
// @ts-ignore
import semver from 'semver';
import * as core from '@actions/core';
import * as github from '@actions/github'; // https://github.com/actions/toolkit/tree/main/packages/github
import { Context } from '@actions/github/lib/context';
import { ExecOptions } from '@actions/exec';

interface ActionParameters {
    github: typeof github;
    context: Context;
    core: typeof core;
    exec: (commandLine: string, args?: string[], options?: ExecOptions) => Promise<number>;
    targetBranch: string;
}

export class ApexDocContentManager {
    private github: any;
    private context: any;
    private targetBranch: string;
    private ROOT_WORK_DIR = '/home/runner/work/finnb220-sb/apexdocs-wiki/'; // working directory for repo owner & repo path
    private rootDir: string;

    constructor(github: any, context: any, targetBranch: string) {
        this.github = github;
        this.context = context;
        this.targetBranch = targetBranch;
        this.rootDir = '/home/runner/work/' + this.context.repo.owner + '/' + this.context.repo.repo;
        console.log('=======> rootDir = ' +  this.rootDir);
    }

    async publishDocs(): Promise<void> {
        console.log('=====> calling getReleaseBranches()');
        const releases = await this.getReleaseBranches();
        core.info('======> releases = ' + JSON.stringify(releases));
        console.log('=====> calling updateReleasesInSidebar()');
        await this.updateReleasesInSidebar(releases);
        console.log('=====> calling commitContent()');
        await this.commitContent(releases);
        // console.log('=====> calling updateHeadersInAllFiles()');
        // await this.updateHeadersInAllFiles(releases);
    }

    private async generateApexDocs(): Promise<void> {
        await this.generateApexDocsViaShell();
    }

    private async generateApexDocsViaShell(): Promise<void> {
        return new Promise((resolve, reject) => {
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

    private async getReleaseBranches(): Promise<string[]> {
        core.info('======> this.context.repo.repo = ' + this.context.repo.repo );
        core.info('======> this.context.repo.owner = ' + this.context.repo.owner );
        const { data: branches } = await this.github.rest.repos.listBranches({
            owner: this.context.repo.owner,
            repo: this.context.repo.repo,
        });
        core.info('======>All branches = ' + JSON.stringify(branches) );

        // Pages REST API https://api.github.com/repos/OWNER/REPO/pages
        const token = core.getInput('github-token');
        const { data: pages } = await this.github.request(`GET /repos/{owner}/{repo}/pages`, {
                owner:  this.context.repo.owner,
                repo: `${this.context.repo.repo}`
        });
        core.info('======> pages = ' + JSON.stringify(pages));
        core.info('======> pages branch = ' + pages.source.branch + ', path = ' + pages.source.path);
        let filteredBranches = branches.filter((branch: any) => branch.name.startsWith('release/'));
        core.info('======> filtered branches = ' + JSON.stringify(filteredBranches));
        let mapBranches = filteredBranches.map((branch: any) => branch.name.replace('release/', ''));
        core.info('======> map of branches = ' + JSON.stringify(mapBranches));
        let sortedBranches = mapBranches.sort((a: string, b: string) =>  semver.rcompare(a, b));
        core.info('======> sorted branches = ' + JSON.stringify(sortedBranches));

        return sortedBranches;
        // return branches
        //     .filter((branch: any) => branch.name.startsWith('release/'))
        //     .map((branch: any) => branch.name.replace('release/', ''))
        //     .sort((a: string, b: string) =>  semver.rcompare(a, b));
    }

    private async updateReleasesInSidebar(releases: string[]): Promise<void> {
        let content = 'sidebar:[{text: \'Contents\',items: [{text: \'Home\', link: \'/index\' },{text: \'Releases\',items: [';
        const placeholder = 'POPULATE_ME';
        const link = '/guide/';
        // text: 'Contents', items: [
        // {text: 'Home', link: '/index' },
        // {text: 'Releases',
        //     items: [
        //     {text: 'Latest Release', link:'/guide'},
        //     {text: 'Release 1.0', link:'/guide/v1.0'}
        // ]}]}]';
        core.info('======> releases = ' + JSON.stringify(releases));
        releases.forEach((release, index) => {
            // if we are processing the first release in the list, then it is the latest as they in descending numeric order
            const item = index === 0 ? `text: \'Latest Release (${release})\', link:\'${link}\'` :
                `text: \'Release ${release}\', link:\'${link}/v${release}\'` ;
            console.log('=====> Adding item to content ' + item);
            content += `{ ${item} },\n`;
        });
        console.log('=====> after forEach loop, content = ' + content);
        content = content.substring(0, content.lastIndexOf(',\n'));
        console.log('=====> after removal of trailing comma & newline, content = ' + content);
        content += ']';
        content += '\n\n';
        console.log('======> Final sidebar content is ' + content);
        // try {
            const { data: existingConfig } = await this.github.rest.repos.getContent({
                owner: this.context.repo.owner,
                repo: this.context.repo.repo,
                path: '/apexdocs/.vitepress/config.mts',
            });
            console.log('=====> existingConfig = %o', existingHome);
        //     if ('content' in existingHome) {
        //         const existingContent = Buffer.from(existingHome.content, 'base64').toString('utf-8');
        //         const existingContentWithoutHeader = existingContent.split('\n\n').slice(2).join('\n\n');
        //         content += existingContentWithoutHeader;
        //     }
        // } catch (error) {
        //     console.log('No existing Home.md found. Creating a new one.');
        // }
        // console.log('======> Writing content %o to Home.md', content);
        // fs.writeFileSync('Home.md', content);
    }

    private async commitContent(releases: string[]): Promise<void> {
        const currentRelease = releases[0];
        core.info('=====> currentRelease = ' + currentRelease);
        const repo = `${this.context.repo.repo}`;
        core.info('=====> repo = ' + JSON.stringify(this.context.repo));
        const repoOwner = `${this.context.repo.owner}`;
        // const wikiRepoUrl = `https://${this.wikiRepoToken}@github.com/${repoOwner}/${wikiRepo}.git`;
        // Kevin - I added this to connect to Wiki Repo (I have to set the token to WIKI TOKEN (passed in from yml)
        // this.connectToWikiRepo();
        // // git remote set-url upstream-branch https://<token>@github.com/<username>/<repo>
        // await new Promise<void>((resolve, reject) => {
        //     exec(`git remote set-url origin ${wikiRepoUrl}`, (error) => {
        //         if (error) reject(error);
        //         else resolve();
        //     });
        // });

        // await new Promise<void>((resolve, reject) => {
        //         // exec(`git clone https://github.com/${repoOwner}/${wikiRepo}.git`, (error) => {
        //         exec(`git clone ${wikiRepoUrl}`, (error) => {
        //             if (error) reject(error);
        //             else resolve();
        //         });
        //     }
        // );

        // import { readdir } from 'node:fs/promises';
        // let releasesDir = '/home/runner/work/va-teams/va-teams/va-teams.wiki/releases';
        // let targetReleaseDir = `${releasesDir}/${currentRelease}`;
        // if (fs.existsSync(releasesDir)) {
        //     if (fs.existsSync(targetReleaseDir)) {
        //         core.info('=======> Target directory ' + targetReleaseDir + ' exists!');
        //     } else {
        //         core.info('=======> Target directory ' + targetReleaseDir + ' does NOT exist - creating it.');
        //         fs.mkdirSync(targetReleaseDir, {recursive: true});
        //     }
        // } else {
        //     core.info(`======> creating directory ${targetReleaseDir}`);
        //     fs.mkdirSync(targetReleaseDir, {recursive: true});
        // }
        // try {
        //     const files = fs.readdirSync(targetReleaseDir);
        //     core.info(`======> Contents of ${targetReleaseDir}`);
        //     for (const file of files) {
        //         core.info(file);
        //     }
        // } catch (err: any) {
        //     core.error('======> ERROR: ' + err);
        // }
        // fs.readdirSync(`${this.ROOT_WORK_DIR}`)
        // await new Promise<void>((resolve, reject) => {
        //     exec(`cd ${this.ROOT_WORK_DIR};cp -R docs/* ${wikiRepo}/releases/${currentRelease}/`, (error) => {
        //         if (error) reject(error);
        //         else resolve();
        //     });
        // });
        //
        // await new Promise<void>((resolve, reject) => {
        //     core.info('=======> pushing content to github pages.');
        //     const results = exec(`
        //         git config user.name "GitHub Action"
        //         git config user.email "action@github.com"
        //         git status .
        //         git add .
        //         git commit -m "Update ApexDocs for ${currentRelease}"
        //         git push
        //     `, (error) => {
        //         if (error) {
        //             core.error(`=====> ERROR updating ApexDoc content: ${error}`);
        //             reject(error);
        //         } else {
        //             core.info(`=====> SUCCESS updating ApexDoc content`);
        //             resolve();
        //         }
        //     });
        //     core.info('=====> results = ' + JSON.stringify(results));
        // });
    }

    private async updateHeadersInAllFiles(releases: string[]): Promise<void> {
        // const wikiRepo = `${this.context.repo.repo}.wiki`;
        //
        // for (const release of releases) {
        //     const releaseDir = path.join(wikiRepo, 'releases', release);
        //     if (!fs.existsSync(releaseDir)) {
        //         // need to first create release directory
        //         core.info(`=======> Creating ${releaseDir}`);
        //         fs.mkdirSync(releaseDir, {recursive:true});
        //     }
        //     const files = fs.readdirSync(releaseDir);
        //
        //     for (const file of files) {
        //         if (file.endsWith('.md')) {
        //             const filePath = path.join(releaseDir, file);
        //             let content = fs.readFileSync(filePath, 'utf-8');
        //             // console.log('Read Contents: ' + content);
        //             // console.log('contents onces split: ' + content.includes('\n') ? content.split('\n').slice(1).join('\n') : content);
        //             const header = this.generateFileHeader(file, releases, release);
        //             const parsedContents = content.includes('\n') ? content.split('\n').slice(1).join('\n') : content;
        //             const newContent = header + parsedContents;
        //             //content.split('\n').slice(1).join('\n');
        //             // console.log('Writing contents: ' + newContent);
        //             fs.writeFileSync(filePath, newContent);
        //         }
        //     }
        // }
    }

    private generateFileHeader(fileName: string, releases: string[], currentRelease: string): string {
        // let header = '# Version Links\n\n';
        // releases.forEach((release) => {
        //     const label = release === currentRelease ? `Current (${release})` : release;
        //     header += `- [${label}](#/wiki/releases/${release}/${fileName})\n`;
        // });
        // return header + '\n\n';
        return '';
    }
}

export default async ({
                          github,
                          context,
                          core,
                          targetBranch
                      }: ActionParameters) => {
    try {
        core.info('=====> dirName = ' + __dirname);
        const manager = new ApexDocContentManager(github, context, targetBranch);
        core.info('=====> calling publishDocs!');
        await manager.publishDocs();
        // core.info('=====> calling generateAndPublishDocs!');
        // await manager.generateAndPublishDocs();
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
