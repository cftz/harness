#!/bin/bash
# Delete a Linear issue relation
# Usage: delete_relation.sh ID
#
# Required:
#   ID - The UUID of the relation to delete
#
# Environment:
#   LINEAR_API_KEY - Required. Linear API key for authentication.
#
# Output:
#   On success: JSON with success status
#   On failure: Error message to stderr, exit 1

set -euo pipefail

ID="${1:-}"

if [[ -z "$ID" ]]; then
  echo "Error: ID is required" >&2
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

# GraphQL mutation
MUTATION='mutation IssueRelationDelete($id: String!) {
  issueRelationDelete(id: $id) {
    success
  }
}'

# Build variables
VARIABLES="{\"id\": \"$ID\"}"

# Make API request
RESPONSE=$(curl -s -X POST \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  --data "{\"query\": $(echo -n "$MUTATION" | escape_json), \"variables\": $VARIABLES}" \
  https://api.linear.app/graphql)

# Check for errors
if echo "$RESPONSE" | jq -e '.errors' > /dev/null 2>&1; then
  echo "Error: $(echo "$RESPONSE" | jq -r '.errors[0].message')" >&2
  exit 1
fi

# Output result
echo "$RESPONSE" | jq '.data.issueRelationDelete'
