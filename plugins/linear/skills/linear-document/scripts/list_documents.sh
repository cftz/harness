#!/bin/bash
# List Linear documents
# Usage: list_documents.sh [ISSUE_ID]
#
# Optional:
#   ISSUE_ID - Filter documents by issue ID (returns documents attached to this issue)
#
# Environment:
#   LINEAR_API_KEY - Required. Linear API key for authentication.
#
# Output:
#   On success: JSON array of documents
#   On failure: Error message to stderr, exit 1

set -euo pipefail

ISSUE_ID="${1:-}"

if [[ -z "${LINEAR_API_KEY:-}" ]]; then
  echo "Error: LINEAR_API_KEY environment variable is required" >&2
  exit 1
fi

# JSON escaping helper
escape_json() {
  python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))"
}

# GraphQL query - if ISSUE_ID provided, get documents from issue
if [[ -n "$ISSUE_ID" ]]; then
  QUERY='query IssueDocuments($id: String!) { issue(id: $id) { documents { nodes { id slugId title url } } } }'

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

  # Output documents
  echo "$RESPONSE" | jq '.data.issue.documents.nodes'
else
  QUERY='query Documents { documents { nodes { id slugId title url issue { id identifier } } } }'

  RESPONSE=$(curl -s -X POST \
    -H "Authorization: $LINEAR_API_KEY" \
    -H "Content-Type: application/json" \
    --data "{\"query\": $(echo -n "$QUERY" | escape_json)}" \
    https://api.linear.app/graphql)

  # Check for errors
  if echo "$RESPONSE" | jq -e '.errors' > /dev/null 2>&1; then
    echo "Error: $(echo "$RESPONSE" | jq -r '.errors[0].message')" >&2
    exit 1
  fi

  # Output documents
  echo "$RESPONSE" | jq '.data.documents.nodes'
fi
