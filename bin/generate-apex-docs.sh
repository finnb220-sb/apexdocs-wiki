#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH/..

HOME_PAGE="${GITHUB_WORKSPACE}/index.md"
APEXDOC_GUIDE_DIR="${GITHUB_WORKSPACE}/apexdocs/guide"

# Remove old docs
echo "Removing old version..." && \
rm -rf $APEXDOC_GUIDE_DIR && \

# Generate Apex doc files
echo "Generating Apex doc files..." && \
mkdir -pv $APEXDOC_GUIDE_DIR && \
"${GITHUB_WORKSPACE}/node_modules/.bin/apexdocs" markdown -p global public private protected namespaceaccessible -s "${GITHUB_WORKSPACE}/force-app/main/default/classes" -t "${APEXDOC_GUIDE_DIR}" --includeMetadata && \

# Remove empty folders
echo "Removing empty folders..." && \
find "$APEXDOC_GUIDE_DIR/"* -type d -empty -delete 
