const fs = require('fs');

// Function to print the dependency tree
function printDependencyTree(dependencies, indent = '') {
    dependencies.forEach((dependency, index) => {
        const isLast = index === dependencies.length - 1;
        const prefix = isLast ? '└─ ' : '├─ ';
        const newIndent = indent + (isLast ? '   ' : '│  ');

        console.log(`${indent}${prefix}${dependency.package} ${dependency.versionNumber}`);

        if (dependency.dependencies && dependency.dependencies.length > 0) {
            printDependencyTree(dependency.dependencies, newIndent);
        }
    });
}

// Function to parse and display the release version and dependencies
function parseReleaseAndDependencies(filePath) {
    // Read the JSON file
    fs.readFile(filePath, 'utf8', (err, data) => {
        if (err) {
            console.error(`Error reading file: ${err}`);
            return;
        }

        // Parse the JSON data
        let jsonData;
        try {
            jsonData = JSON.parse(data);
        } catch (parseErr) {
            console.error(`Error parsing JSON: ${parseErr}`);
            return;
        }

        // Extract and print the release version
        if (jsonData.packageDirectories && jsonData.packageDirectories.length > 0) {
            const firstPackageDirectory = jsonData.packageDirectories[0];
            if (firstPackageDirectory.versionNumber) {
                console.log(`Release ${firstPackageDirectory.versionNumber}`);
            } else {
                console.log('No release version found.');
            }

            // Extract and print dependencies as a tree structure
            printDependencyTree(firstPackageDirectory.dependencies);
        } else {
            console.log('No package directories or dependencies found.');
        }
    });
}

// Get the file path from the command line arguments
const filePath = 'sfdx-project.json';
parseReleaseAndDependencies(filePath);
