#!/bin/bash

# Constants for the repository owner and name
OWNER="department-of-veterans-affairs"
REPO="va-teams"

# GraphQL query, fetching all review requests
GRAPHQL_QUERY="query(\$owner: String!, \$repoName: String!) { repository(owner: \$owner, name: \$repoName) { pullRequests(first: 100, states: [OPEN]) { nodes { reviewRequests(first: 100) { nodes { requestedReviewer { ... on User { login } } } } } } } }"

# Execute GraphQL query using GitHub CLI
QUERY_RESULT=$(gh api graphql --paginate -f query="$GRAPHQL_QUERY" -f owner="$OWNER" -f repoName="$REPO")

# Use jq to parse the query result and count review assignments per user
echo "$QUERY_RESULT" | jq '
  [.. | .requestedReviewer? | select(.login) | .login] | group_by(.) | map({(.[0]): length}) | add
'
