#!/bin/bash
# Create a Linear issue relation
# Usage: create_relation.sh ISSUE_ID RELATED_ISSUE_ID TYPE
#
# Required:
#   ISSUE_ID         - The issue that has the relation (UUID or identifier)
#   RELATED_ISSUE_ID - The related issue (UUID or identifier)
#   TYPE             - Relation type: blocks, duplicate, related, similar
#
# Environment:
#   LINEAR_API_KEY - Required. Linear API key for authentication.
#
# Output:
#   On success: JSON with created relation
#   On failure: Error message to stderr, exit 1

set -euo pipefail

ISSUE_ID="${1:-}"
RELATED_ISSUE_ID="${2:-}"
TYPE="${3:-}"

if [[ -z "$ISSUE_ID" ]]; then
  echo "Error: ISSUE_ID is required" >&2
  exit 1
fi

if [[ -z "$RELATED_ISSUE_ID" ]]; then
  echo "Error: RELATED_ISSUE_ID is required" >&2
  exit 1
fi

if [[ -z "$TYPE" ]]; then
  echo "Error: TYPE is required (blocks, duplicate, related, similar)" >&2
  exit 1
fi

if [[ -z "${LINEAR_API_KEY:-}" ]]; then
  echo "Error: LINEAR_API_KEY environment variable is required" >&2
  exit 1
fi

# Validate type
if [[ ! "$TYPE" =~ ^(blocks|duplicate|related|similar)$ ]]; then
  echo "Error: TYPE must be one of: blocks, duplicate, related, similar" >&2
  exit 1
fi

# JSON escaping helper
escape_json() {
  python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))"
}

# GraphQL mutation
MUTATION='mutation IssueRelationCreate($input: IssueRelationCreateInput!) {
  issueRelationCreate(input: $input) {
    success
    issueRelation {
      id
      type
      issue {
        id
        identifier
        title
      }
      relatedIssue {
        id
        identifier
        title
      }
    }
  }
}'

# Build variables
VARIABLES="{\"input\": {\"issueId\": \"$ISSUE_ID\", \"relatedIssueId\": \"$RELATED_ISSUE_ID\", \"type\": \"$TYPE\"}}"

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

# Check success
if echo "$RESPONSE" | jq -e '.data.issueRelationCreate.success == false' > /dev/null 2>&1; then
  echo "Error: Failed to create relation" >&2
  exit 1
fi

# Output created relation
echo "$RESPONSE" | jq '.data.issueRelationCreate.issueRelation'
