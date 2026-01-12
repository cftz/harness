#!/bin/bash
# Create a comment on a Linear issue
# Usage: create_comment.sh ISSUE_ID BODY
#
# Required:
#   ISSUE_ID - Issue UUID or identifier (e.g., TA-123)
#   BODY     - Comment content (markdown)
#
# Environment:
#   LINEAR_API_KEY - Required. Linear API key for authentication.
#
# Output:
#   On success: JSON with comment id and body
#   On failure: Error message to stderr, exit 1

set -euo pipefail

ISSUE_ID="${1:-}"
BODY="${2:-}"

if [[ -z "$ISSUE_ID" ]]; then
  echo "Error: ISSUE_ID is required" >&2
  exit 1
fi

if [[ -z "$BODY" ]]; then
  echo "Error: BODY is required" >&2
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

ESCAPED_BODY=$(echo -n "$BODY" | escape_json)

# Build input object
INPUT="{\"issueId\": \"$ISSUE_ID\", \"body\": $ESCAPED_BODY}"

# GraphQL mutation
QUERY='mutation CommentCreate($input: CommentCreateInput!) { commentCreate(input: $input) { success comment { id body url } } }'

# Make API request
RESPONSE=$(curl -s -X POST \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  --data "{\"query\": $(echo -n "$QUERY" | escape_json), \"variables\": {\"input\": $INPUT}}" \
  https://api.linear.app/graphql)

# Check for errors
if echo "$RESPONSE" | jq -e '.errors' > /dev/null 2>&1; then
  echo "Error: $(echo "$RESPONSE" | jq -r '.errors[0].message')" >&2
  exit 1
fi

# Check success
SUCCESS=$(echo "$RESPONSE" | jq -r '.data.commentCreate.success')
if [[ "$SUCCESS" != "true" ]]; then
  echo "Error: Comment creation failed" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

# Output comment info
echo "$RESPONSE" | jq '.data.commentCreate.comment'
