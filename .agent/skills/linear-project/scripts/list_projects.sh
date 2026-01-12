#!/bin/bash
# List Linear projects
# Usage: list_projects.sh [TEAM_ID]
#
# Optional:
#   TEAM_ID - Filter projects by team ID
#
# Environment:
#   LINEAR_API_KEY - Required. Linear API key for authentication.
#
# Output:
#   On success: JSON array of projects with id, name, slugId
#   On failure: Error message to stderr, exit 1

set -euo pipefail

TEAM_ID="${1:-}"

if [[ -z "${LINEAR_API_KEY:-}" ]]; then
  echo "Error: LINEAR_API_KEY environment variable is required" >&2
  exit 1
fi

# JSON escaping helper
escape_json() {
  python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))"
}

# GraphQL query - filter by team if provided
if [[ -n "$TEAM_ID" ]]; then
  QUERY='query Projects($teamId: ID) { projects(filter: { accessibleTeams: { id: { eq: $teamId } } }) { nodes { id name slugId teams { nodes { id name } } } } }'
  VARIABLES="{\"teamId\": \"$TEAM_ID\"}"
else
  QUERY='query Projects { projects { nodes { id name slugId teams { nodes { id name } } } } }'
  VARIABLES="{}"
fi

# Make API request
RESPONSE=$(curl -s -X POST \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  --data "{\"query\": $(echo -n "$QUERY" | escape_json), \"variables\": $VARIABLES}" \
  https://api.linear.app/graphql)

# Check for errors
if echo "$RESPONSE" | jq -e '.errors' > /dev/null 2>&1; then
  echo "Error: $(echo "$RESPONSE" | jq -r '.errors[0].message')" >&2
  exit 1
fi

# Output projects
echo "$RESPONSE" | jq '.data.projects.nodes'
