#!/bin/bash
# Search Linear documents
# Usage: search_documents.sh QUERY
#
# Required:
#   QUERY - Search term
#
# Environment:
#   LINEAR_API_KEY - Required. Linear API key for authentication.
#
# Output:
#   On success: JSON array of matching documents
#   On failure: Error message to stderr, exit 1

set -euo pipefail

SEARCH_TERM="${1:-}"

if [[ -z "$SEARCH_TERM" ]]; then
  echo "Error: QUERY is required" >&2
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
QUERY='query SearchDocuments($term: String!) { searchDocuments(term: $term) { nodes { id slugId title content url } } }'

# Make API request
RESPONSE=$(curl -s -X POST \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  --data "{\"query\": $(echo -n "$QUERY" | escape_json), \"variables\": {\"term\": \"$SEARCH_TERM\"}}" \
  https://api.linear.app/graphql)

# Check for errors
if echo "$RESPONSE" | jq -e '.errors' > /dev/null 2>&1; then
  echo "Error: $(echo "$RESPONSE" | jq -r '.errors[0].message')" >&2
  exit 1
fi

# Output documents
echo "$RESPONSE" | jq '.data.searchDocuments.nodes'
