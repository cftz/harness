#!/bin/bash
# Update a Linear issue
# Usage: update_issue.sh ISSUE_ID [STATE_ID] [TITLE] [DESCRIPTION] [ASSIGNEE_ID] [LABEL_IDS] [ADD_LABEL_IDS] [PRIORITY] [PROJECT_ID]
#
# Required:
#   ISSUE_ID - Issue UUID or identifier (e.g., TA-123)
#
# Optional:
#   STATE_ID      - New workflow state ID
#   TITLE         - New title
#   DESCRIPTION   - New description (markdown)
#   ASSIGNEE_ID   - Assignee user ID (empty string to unassign)
#   LABEL_IDS     - Comma-separated label IDs (replaces all labels)
#   ADD_LABEL_IDS - Comma-separated label IDs to add
#   PRIORITY      - Priority (0=None, 1=Urgent, 2=High, 3=Normal, 4=Low)
#   PROJECT_ID    - Project ID
#
# Environment:
#   LINEAR_API_KEY - Required. Linear API key for authentication.
#
# Output:
#   On success: JSON with updated issue
#   On failure: Error message to stderr, exit 1

set -euo pipefail

ISSUE_ID="${1:-}"
STATE_ID="${2:-}"
TITLE="${3:-}"
DESCRIPTION="${4:-}"
ASSIGNEE_ID="${5:-}"
LABEL_IDS="${6:-}"
ADD_LABEL_IDS="${7:-}"
PRIORITY="${8:-}"
PROJECT_ID="${9:-}"

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

# Build input object
build_input() {
  local input=""
  local has_field=false

  if [[ -n "$STATE_ID" ]]; then
    input="\"stateId\": \"$STATE_ID\""
    has_field=true
  fi

  if [[ -n "$TITLE" ]]; then
    [[ "$has_field" == "true" ]] && input="$input, "
    local escaped_title
    escaped_title=$(echo -n "$TITLE" | escape_json)
    input="${input}\"title\": $escaped_title"
    has_field=true
  fi

  if [[ -n "$DESCRIPTION" ]]; then
    [[ "$has_field" == "true" ]] && input="$input, "
    local escaped_desc
    escaped_desc=$(echo -n "$DESCRIPTION" | escape_json)
    input="${input}\"description\": $escaped_desc"
    has_field=true
  fi

  if [[ -n "$ASSIGNEE_ID" ]]; then
    [[ "$has_field" == "true" ]] && input="$input, "
    if [[ "$ASSIGNEE_ID" == "null" || "$ASSIGNEE_ID" == "" ]]; then
      input="${input}\"assigneeId\": null"
    else
      input="${input}\"assigneeId\": \"$ASSIGNEE_ID\""
    fi
    has_field=true
  fi

  if [[ -n "$LABEL_IDS" ]]; then
    [[ "$has_field" == "true" ]] && input="$input, "
    # Convert comma-separated to JSON array
    local label_array
    label_array=$(echo "$LABEL_IDS" | tr ',' '\n' | jq -R . | jq -s .)
    input="${input}\"labelIds\": $label_array"
    has_field=true
  fi

  if [[ -n "$ADD_LABEL_IDS" ]]; then
    [[ "$has_field" == "true" ]] && input="$input, "
    # Convert comma-separated to JSON array
    local label_array
    label_array=$(echo "$ADD_LABEL_IDS" | tr ',' '\n' | jq -R . | jq -s .)
    input="${input}\"addedLabelIds\": $label_array"
    has_field=true
  fi

  if [[ -n "$PRIORITY" ]]; then
    [[ "$has_field" == "true" ]] && input="$input, "
    input="${input}\"priority\": $PRIORITY"
    has_field=true
  fi

  if [[ -n "$PROJECT_ID" ]]; then
    [[ "$has_field" == "true" ]] && input="$input, "
    input="${input}\"projectId\": \"$PROJECT_ID\""
    has_field=true
  fi

  if [[ "$has_field" == "false" ]]; then
    echo "Error: At least one field to update is required" >&2
    exit 1
  fi

  echo "{$input}"
}

INPUT=$(build_input)

# GraphQL mutation
MUTATION='mutation IssueUpdate($id: String!, $input: IssueUpdateInput!) {
  issueUpdate(id: $id, input: $input) {
    success
    issue {
      id
      identifier
      title
      url
      state { id name }
      team { id key name }
      project { id name }
      assignee { id name email }
      labels { nodes { id name color } }
      priority
      priorityLabel
    }
  }
}'

# Build variables
VARIABLES="{\"id\": \"$ISSUE_ID\", \"input\": $INPUT}"

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
if echo "$RESPONSE" | jq -e '.data.issueUpdate.success == false' > /dev/null 2>&1; then
  echo "Error: Failed to update issue" >&2
  exit 1
fi

# Output updated issue
echo "$RESPONSE" | jq '.data.issueUpdate.issue'
