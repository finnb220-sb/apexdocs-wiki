#!/bin/bash

# Attempt to get the Git repository root
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

# Check if the command was successful
if [ $? -ne 0 ]; then
    echo "Error: This script must be run inside a Git repository."
    exit 1
fi

# Optionally, change to the Git root directory
cd "$GIT_ROOT" || exit

# List dependencies from sfdx-project.json using node
node "$GIT_ROOT/scripts/listDependencies.js"