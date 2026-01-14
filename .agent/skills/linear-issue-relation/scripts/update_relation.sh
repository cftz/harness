#!/bin/bash
# Update a Linear issue relation
# Usage: update_relation.sh ID [ISSUE_ID] [RELATED_ISSUE_ID] [TYPE]
#
# Required:
#   ID - The UUID of the relation to update
#
# Optional:
#   ISSUE_ID         - New source issue (UUID or identifier)
#   RELATED_ISSUE_ID - New related issue (UUID or identifier)
#   TYPE             - New relation type: blocks, duplicate, related, similar
#
# Environment:
#   LINEAR_API_KEY - Required. Linear API key for authentication.
#
# Output:
#   On success: JSON with updated relation
#   On failure: Error message to stderr, exit 1

set -euo pipefail

ID="${1:-}"
ISSUE_ID="${2:-}"
RELATED_ISSUE_ID="${3:-}"
TYPE="${4:-}"

if [[ -z "$ID" ]]; then
  echo "Error: ID is required" >&2
  exit 1
fi

if [[ -z "${LINEAR_API_KEY:-}" ]]; then
  echo "Error: LINEAR_API_KEY environment variable is required" >&2
  exit 1
fi

# Validate type if provided
if [[ -n "$TYPE" ]] && [[ ! "$TYPE" =~ ^(blocks|duplicate|related|similar)$ ]]; then
  echo "Error: TYPE must be one of: blocks, duplicate, related, similar" >&2
  exit 1
fi

# JSON escaping helper
escape_json() {
  python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))"
}

# Build input object
build_input() {
  local input=""
  local first=true

  if [[ -n "$ISSUE_ID" ]]; then
    input="\"issueId\": \"$ISSUE_ID\""
    first=false
  fi

  if [[ -n "$RELATED_ISSUE_ID" ]]; then
    if [[ "$first" == "false" ]]; then
      input="$input, "
    fi
    input="${input}\"relatedIssueId\": \"$RELATED_ISSUE_ID\""
    first=false
  fi

  if [[ -n "$TYPE" ]]; then
    if [[ "$first" == "false" ]]; then
      input="$input, "
    fi
    input="${input}\"type\": \"$TYPE\""
  fi

  echo "{$input}"
}

INPUT=$(build_input)

# Check if any updates provided
if [[ "$INPUT" == "{}" ]]; then
  echo "Error: At least one of ISSUE_ID, RELATED_ISSUE_ID, or TYPE must be provided" >&2
  exit 1
fi

# GraphQL mutation
MUTATION='mutation IssueRelationUpdate($id: String!, $input: IssueRelationUpdateInput!) {
  issueRelationUpdate(id: $id, input: $input) {
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
VARIABLES="{\"id\": \"$ID\", \"input\": $INPUT}"

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
if echo "$RESPONSE" | jq -e '.data.issueRelationUpdate.success == false' > /dev/null 2>&1; then
  echo "Error: Failed to update relation" >&2
  exit 1
fi

# Output updated relation
echo "$RESPONSE" | jq '.data.issueRelationUpdate.issueRelation'
