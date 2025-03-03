#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH/..

APEXDOC_DIR="${GITHUB_WORKSPACE}/documentation/ApexDoc"

# Remove old docs
echo "Removing old version..." && \
rm -rf $APEXDOC_DIR && \

# Generate Apex doc files
echo "Generating Apex doc files..." && \
mkdir -pv $APEXDOC_DIR && \
"${GITHUB_WORKSPACE}/node_modules/.bin/apexdocs" markdown -p global public private protected namespaceaccessible -s "${GITHUB_WORKSPACE}/force-app/main/default/classes" -t "${APEXDOC_DIR}" && \

# Flatten directory structure
#echo "Flattening directory structure..." && \
find "$APEXDOC_DIR/"* -mindepth 1 -type f -exec mv -i '{}' $APEXDOC_DIR ';' && \

# Remove empty folders
echo "Removing empty folders..." && \
find "$APEXDOC_DIR/"* -type d -empty -delete && \

# Remove first three line with layout header
echo "Removing first three lines with layout header..." && \
find "$APEXDOC_DIR" -type f -name "*.md" -print0 | xargs -0 sed -i "1,3d"
