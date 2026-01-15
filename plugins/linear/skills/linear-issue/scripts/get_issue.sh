#!/bin/bash
# Get a Linear issue by ID or identifier
# Usage: get_issue.sh ISSUE_ID
#
# Required:
#   ISSUE_ID - Issue UUID or identifier (e.g., TA-123)
#
# Environment:
#   LINEAR_API_KEY - Required. Linear API key for authentication.
#
# Output:
#   On success: JSON with issue details
#   On failure: Error message to stderr, exit 1

set -euo pipefail

ISSUE_ID="${1:-}"

if [[ -z "$ISSUE_ID" ]]; then
  echo "Error: ISSUE_ID is required" >&2
  exit 1
fi

if [[ -z "${LINEAR_API_KEY:-}" ]]; then
  echo "Error: LINEAR_API_KEY environment variable is required" >&2
  exit 1
fi

# JSON escaping helper
escape_json() {
  python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))"
}

# GraphQL query
QUERY='query Issue($id: String!) {
  issue(id: $id) {
    id
    identifier
    title
    description
    url
    state { id name }
    team { id key name }
    project { id name }
    assignee { id name email }
    labels { nodes { id name color } }
    priority
    priorityLabel
    parent { id identifier title }
    createdAt
    updatedAt
  }
}'

# Make API request
RESPONSE=$(curl -s -X POST \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  --data "{\"query\": $(echo -n "$QUERY" | escape_json), \"variables\": {\"id\": \"$ISSUE_ID\"}}" \
  https://api.linear.app/graphql)

# Check for errors
if echo "$RESPONSE" | jq -e '.errors' > /dev/null 2>&1; then
  echo "Error: $(echo "$RESPONSE" | jq -r '.errors[0].message')" >&2
  exit 1
fi

# Check if issue exists
if echo "$RESPONSE" | jq -e '.data.issue == null' > /dev/null 2>&1; then
  echo "Error: Issue not found" >&2
  exit 1
fi

# Output issue
echo "$RESPONSE" | jq '.data.issue'
