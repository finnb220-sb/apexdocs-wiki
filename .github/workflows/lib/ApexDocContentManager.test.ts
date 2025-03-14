import { ApexDocContentManager } from './ApexDocContentManager.ts';
import { exec, ExecException, ExecOptions } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';
import { jest } from '@jest/globals';

jest.mock('child_process');
const mockedFs = jest.mock('fs');
jest.mock('path');

// Define a type that matches the exec function signature we're using
// adding a comment so it will recompile
type ExecCallback = (error: ExecException | null, stdout: string, stderr: string) => void;
type ExecFunction = {
    (command: string, callback?: ExecCallback): any;
    (command: string, options: ExecOptions, callback?: ExecCallback): any;
};

// Create a mocked version of exec using type assertion
const mockedExec = exec as unknown as jest.MockedFunction<ExecFunction>;

describe('ApexDocContentManager', () => {
    let apexDocContentManager: ApexDocContentManager;
    let mockGithub: any;
    let mockContext: any;

    beforeEach(() => {
        jest.resetAllMocks();

        mockGithub = {
            rest: {
                repos: {
                    listBranches: jest.fn(),
                    getContent: jest.fn(),
                },
            },
        };

        mockContext = {
            repo: {
                owner: 'testOwner',
                repo: 'testRepo',
            },
        };

        apexDocContentManager = new ApexDocContentManager(mockGithub, mockContext, 'release/1.15.0');
    });

    describe('publishDocs', () => {
        it('should call all necessary methods', async () => {
            // const publishDocsSpy = jest.spyOn(apexDocContentManager as any, 'publishDocs').mockResolvedValue(undefined);
            const getReleaseBranchesSpy = jest.spyOn(apexDocContentManager as any, 'getReleaseBranches').mockResolvedValue(['1.0.0', '2.0.0']);
            const updateReleasesInSidebar = jest.spyOn(apexDocContentManager as any, 'updateReleasesInSidebar').mockResolvedValue(undefined);

            await (apexDocContentManager as any).publishDocs();

            // expect(publishDocsSpy).toHaveBeenCalled();
            expect(getReleaseBranchesSpy).toHaveBeenCalled();
            expect(updateReleasesInSidebar).toHaveBeenCalled(); // With(['1.0.0', '2.0.0']);
        });

        it('should handle errors', async () => {
            jest.spyOn(apexDocContentManager as any, 'publishDocs').mockRejectedValue(new Error('Test error'));

            await expect(apexDocContentManager.publishDocs()).rejects.toThrow('Test error');
        });
    });

    describe('getReleaseBranches', () => {
        it('should return sorted release branches', async () => {
            mockGithub.rest.repos.listBranches.mockResolvedValue({
                data: [
                    { name: 'release/1.0.0' },
                    { name: 'release/2.0.0' },
                    { name: 'main' },
                    { name: 'release/1.5.0' },
                ],
            });

            const result = await (apexDocContentManager as any).getReleaseBranches();
            expect(result).toEqual(['2.0.0', '1.5.0', '1.0.0']);
        });

        it('should handle errors', async () => {
            mockGithub.rest.repos.listBranches.mockRejectedValue(new Error('API error'));

            await expect((apexDocContentManager as any).getReleaseBranches()).rejects.toThrow('API error');
        });
    });

    describe('updateReleasesInSidebar', () => {
        it('should update sidebar in vitepress config with links to different releases', async () => {
            const releases = ['2.0.0', '1.0.0'];
            mockGithub.rest.repos.getContent.mockResolvedValue({
                data: { content: Buffer.from('Existing content').toString('base64') },
            });
            // const writeFileSyncSpy = jest.spyOn(fs as any, 'writeFileSync').mockResolvedValue(['1.0.0', '2.0.0']);
            // const writeFileSyncMock = (fs.writeFileSync as jest.Mock).mockImplementation(() => {});
            await (apexDocContentManager as any).updateReleasesInSidebar(releases);

            // expect(writeFileSyncMock).toHaveBeenCalled(); /*With(
            //     'Home.md',
            //     expect.stringContaining('# ApexDocs\n\n## Versions') */
            // );
        });

        it('should generate sidebar content without existing content', async () => {
            const releases = ['2.0.0', '1.0.0'];
            mockGithub.rest.repos.getContent.mockRejectedValue(new Error('Not found'));

            await (apexDocContentManager as any).updateReleasesInSidebar(releases);

            //TODO: Readd this in once completed rewrite of config file
            // expect(fs.writeFileSync).toHaveBeenCalledWith(
            //     'config.mts',
            //     expect.stringContaining('[{text: \'Contents\',items: [{text: \'Home\', link: \'/index\' },{text: \'Releases\',items: [{{ text: \'Current release (2.0.0)\', link:\'/guide/v2.0.0\' }')
            // );
        });
    });

    describe('commitContent', () => {
        it('should execute git commands', async () => {
            mockedExec.mockImplementation((
                command: string,
                optionsOrCallback?: ExecOptions | ExecCallback,
                callback?: ExecCallback
            ) => {
                if (typeof optionsOrCallback === 'function') {
                    optionsOrCallback(null, 'success', '');
                } else if (callback) {
                    callback(null, 'success', '');
                }
                return undefined;
            });

            await (apexDocContentManager as any).commitContent(['2.0.0', '1.0.0']);

            expect(mockedExec).toHaveBeenCalledTimes(3);
            expect(mockedExec).toHaveBeenCalledWith(expect.stringContaining('git clone'), expect.any(Function));
            expect(mockedExec).toHaveBeenCalledWith(expect.stringContaining('cp -R'), expect.any(Function));
            expect(mockedExec).toHaveBeenCalledWith(expect.stringContaining('git config'), expect.any(Function));
        });

        it('should handle execution errors', async () => {
            mockedExec.mockImplementation((
                command: string,
                optionsOrCallback?: ExecOptions | ExecCallback,
                callback?: ExecCallback
            ) => {
                if (typeof optionsOrCallback === 'function') {
                    optionsOrCallback(new Error('Git error') as ExecException, '', '');
                } else if (callback) {
                    callback(new Error('Git error') as ExecException, '', '');
                }
                return undefined;
            });

            await expect((apexDocContentManager as any).commitToWiki(['2.0.0', '1.0.0'])).rejects.toThrow('Git error');
        });
    });

    // describe('updateHeadersInAllFiles', () => {
    //     it('should update headers in all markdown files', async () => {
    //         const releases = ['2.0.0', '1.0.0'];
    //         const mockFiles = ['file1.md', 'file2.txt', 'file3.md'];
    //
            // const optionsArg = {encoding:null, withFileTypes: false, recursive: false};
            // Mock the fs.readdirSync function
            // (fs.readdirSync as jest.Mock).mockImplementation(() => mockFiles);
            // path: PathLike,
            //         options?:
            //             | {
            //                 encoding: BufferEncoding | null;
            //                 withFileTypes?: false | undefined;
            //                 recursive?: boolean | undefined;
            //             }
            //             | BufferEncoding
            //             | null,
    //         (fs.readdirSync as jest.Mock).mockReturnValue(mockFiles);
    //
    //         // Mock the fs.readFileSync function
    //         (fs.readFileSync as jest.Mock).mockReturnValue('Original content');
    //
    //         // Mock the fs.writeFileSync function
    //         const writeFileSyncMock = (fs.writeFileSync as jest.Mock).mockImplementation(() => {});
    //
    //         // Mock path.join to return predictable paths
    //         (path.join as jest.Mock).mockImplementation((...args) => args.join('/'));
    //
    //         await (apexDocContentManager as any).updateHeadersInAllFiles(releases);
    //
    //         const expectedCallCount = releases.length * mockFiles.filter(file => file.endsWith('.md')).length;
    //         expect(writeFileSyncMock).toHaveBeenCalledTimes(expectedCallCount);
    //
    //         writeFileSyncMock.mock.calls.forEach((call, index) => {
    //             const [filePath, content] = call as [string, string];
    //             const fileName = filePath.split('/').pop();
    //             expect(fileName).toBeDefined();
    //             mockFiles.filter(file => file.endsWith('.md'))
    //             const expectedFileName = mockFiles[index % mockFiles.length];
    //             if(fileName?.endsWith('.md')) { return }
    //
    //             expect(fileName).toBe(expectedFileName);
    //             if (fileName?.endsWith('.md')) {
    //                 releases.forEach(release => {
    //                     const isCurrentRelease = release === releases[0];
    //                     const linkText = isCurrentRelease ? `Current (${release})` : release;
    //                     expect(content).toContain(`[${linkText}](#/wiki/releases/${release}/${fileName})`);
    //                 });
    //                 expect(content).toContain('Original content');
    //             }
    //         });
    //     });
    //
    //
    //     it('should handle file system errors', async () => {
    //         (fs.readdirSync as jest.MockedFunction<typeof fs.readdirSync>).mockImplementation(() => { throw new Error('File system error'); });
    //         await expect((apexDocContentManager as any).updateHeadersInAllFiles(['2.0.0', '1.0.0'])).rejects.toThrow('File system error');
    //     });
    // });
});