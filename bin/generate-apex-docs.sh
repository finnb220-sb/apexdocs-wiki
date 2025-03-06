#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH/..

APEXDOC_DIR="${GITHUB_WORKSPACE}/docs"
VITEPRESS_APEXDOC_DIR="${GITHUB_WORKSPACE}/apexdocs"
APEXDOC_ROOT_URL="https://finnb220-sb.github.io/apexdocs-wiki/docs/"

# Remove old docs
echo "Removing old version..." && \
rm -rf $APEXDOC_DIR && \

# Generate Apex doc files
echo "Generating Apex doc files..." && \
mkdir -pv $APEXDOC_DIR && \
"${GITHUB_WORKSPACE}/node_modules/.bin/apexdocs" markdown -p global public private protected namespaceaccessible -s "${GITHUB_WORKSPACE}/force-app/main/default/classes" -t "${APEXDOC_DIR}" --includeMetadata && \

# Flatten directory structure
# TODO: Do we want to flatten directory structure? Revisit
#echo "Flattening directory structure..." && \
#find "$APEXDOC_DIR/"* -mindepth 1 -type f -exec mv -i '{}' $APEXDOC_DIR ';' && \

# Remove empty folders
echo "Removing empty folders..." && \
find "$APEXDOC_DIR/"* -type d -empty -delete &&

echo "Copying markdown to $VITEPRESS_APEXDOC_DIR directory" &&
cp -r "$APEXDOC_DIR/"* $VITEPRESS_APEXDOC_DIR
# Move index.md to root directory & update all links
# find will print content of each md file to stdout which is stdin for xargs
# xargs will take that input and parse it using sed utility
# sed will
#echo "Replacing relative links"
#
#directory="$APEXDOC_DIR"
#
#if [ ! -d "$APEXDOC_DIR" ]; then
#  echo "Error: Directory '$APEXDOC_DIR' not found."
#  exit 1
#fi
#
#for file in "$APEXDOC_DIR"/*; do
#  if [ -f "$file" ]; then
#    echo "Processing file: $file"
#    # Add your commands to process the file here
#    # For example, to print the file content:
#    # cat "$file"
#  fi
#done
#find "$APEXDOC_DIR" -type f -name "*.md" -print0 | xargs -0 sed -i "" -E "s@]\(\.\/(.*)\.md@](/docs/\1@g)" && \
#find "$APEXDOC_DIR" -type f -name "*.md" -print0 | xargs -0 sed -i "" -E "s@\]\(\.\.\/.*\/(.*)\.md@](/docs/\1@g)"
#find "$APEXDOC_DIR" -type f -name "*.md" -print0 | xargs -0 sed -i "" -E "s@]\(\.\/(.*)\.md@]($APEXDOC_ROOT_URL/\1@g" && \
#find "$APEXDOC_DIR" -type f -name "*.md" -print0 | xargs -0 sed -i "" -E "s@\]\(\.\.\/.*\/(.*)\.md@]($APEXDOC_ROOT_URL/\1@g"
# [BatchJobBase](BatchJobBase.md)
#MD_SUFFIX=".md";
#\[[a-zA-Z]+\]\([a-zA-Z]+\.md\)";
#"\[[a-zA-Z]\]";
#find "$APEXDOC_DIR" -type f -print0 | while IFS= read -r -d $'\0' file; do
#  echo "Searching for $MD_SUFFIX in $file";
#  if grep "$MD_SUFFIX" "$file"; then
#    echo "Found '$MD_SUFFIX' in file: $file - going to add docs to path for navigation..."
#    sed -i.bkup "s/[a-zA-Z]+\.md/\/docs\/BatchJobBase\.md/" "$file"
#  fi
#done
