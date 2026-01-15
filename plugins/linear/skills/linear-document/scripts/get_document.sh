#!/bin/bash
# Get a Linear document by ID
# Usage: get_document.sh DOCUMENT_ID
#
# Required:
#   DOCUMENT_ID - Document UUID or slugId
#
# Environment:
#   LINEAR_API_KEY - Required. Linear API key for authentication.
#
# Output:
#   On success: JSON with document details
#   On failure: Error message to stderr, exit 1

set -euo pipefail

DOCUMENT_ID="${1:-}"

if [[ -z "$DOCUMENT_ID" ]]; then
  echo "Error: DOCUMENT_ID is required" >&2
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
QUERY='query Document($id: String!) { document(id: $id) { id slugId title content url issue { id identifier title } project { id name } } }'

# Make API request
RESPONSE=$(curl -s -X POST \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  --data "{\"query\": $(echo -n "$QUERY" | escape_json), \"variables\": {\"id\": \"$DOCUMENT_ID\"}}" \
  https://api.linear.app/graphql)

# Check for errors
if echo "$RESPONSE" | jq -e '.errors' > /dev/null 2>&1; then
  echo "Error: $(echo "$RESPONSE" | jq -r '.errors[0].message')" >&2
  exit 1
fi

# Check if document exists
if echo "$RESPONSE" | jq -e '.data.document == null' > /dev/null 2>&1; then
  echo "Error: Document not found" >&2
  exit 1
fi

# Output document
echo "$RESPONSE" | jq '.data.document'
