/**
 * This file serves as the jest configuration file for GitHub actions libraries that are written in TypeScript.
 * In the bright shining future, (winter 24) Salesforce will enable us to write LWC in typescript
 * and Typescript / Jest have established conventions for org-wide configuration this file is defined here
 * to provide a separation of github-actions tests and any future lwc tests.
 * @type {path.PlatformPath | path}
 */
// Use the node built-in for path
const path = require('path');

// Export the configuration object
module.exports = {
    testEnvironment: 'node', // use Node as the js engine
    rootDir: path.resolve(__dirname, 'lib'), // set the root directory to the lib folder
    extensionsToTreatAsEsm: ['.ts', '.mts'], // treat .ts and .mts files as ES 2016+ modules, not commonJS
    moduleNameMapper: {
        '^(\\.{1,2}/.*)\\.m?js$': '$1',
    },
    transform: {
        '^.+\\.m?[tj]sx?$': ['ts-jest', {
            useESM: true,
            tsconfig: path.resolve(__dirname, 'lib/tsconfig.json')
        }],
    },
    moduleFileExtensions: ['js', 'mjs', 'ts', 'mts', 'jsx', 'tsx', 'json', 'node'],
    testMatch: [ // All of our tests will be in the lib folder or subfolder and end in mts, mjs, or ts.
                 // We support naming the files *.test.[mts, ts, mjs] or *.tests.[mts, ts, mjs]
        '**/*.test.m[jt]s',
        '**/*.tests.m[jt]s',
        '**/*.test.ts',
    ]
};
