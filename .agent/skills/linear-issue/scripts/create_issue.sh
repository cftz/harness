#!/bin/bash
# Create a Linear issue
# Usage: create_issue.sh TITLE TEAM_ID [DESCRIPTION] [PROJECT_ID] [ASSIGNEE_ID] [LABEL_IDS] [PARENT_ID] [PRIORITY] [STATE_ID]
#
# Required:
#   TITLE   - Issue title
#   TEAM_ID - Team ID
#
# Optional:
#   DESCRIPTION - Issue description (markdown)
#   PROJECT_ID  - Project ID
#   ASSIGNEE_ID - Assignee user ID
#   LABEL_IDS   - Comma-separated label IDs
#   PARENT_ID   - Parent issue ID for sub-issues
#   PRIORITY    - Priority (0=None, 1=Urgent, 2=High, 3=Normal, 4=Low)
#   STATE_ID    - Initial workflow state ID
#
# Environment:
#   LINEAR_API_KEY - Required. Linear API key for authentication.
#
# Output:
#   On success: JSON with created issue
#   On failure: Error message to stderr, exit 1

set -euo pipefail

TITLE="${1:-}"
TEAM_ID="${2:-}"
DESCRIPTION="${3:-}"
PROJECT_ID="${4:-}"
ASSIGNEE_ID="${5:-}"
LABEL_IDS="${6:-}"
PARENT_ID="${7:-}"
PRIORITY="${8:-}"
STATE_ID="${9:-}"

if [[ -z "$TITLE" ]]; then
  echo "Error: TITLE is required" >&2
  exit 1
fi

if [[ -z "$TEAM_ID" ]]; then
  echo "Error: TEAM_ID is required" >&2
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
  local escaped_title
  escaped_title=$(echo -n "$TITLE" | escape_json)
  local input="\"title\": $escaped_title, \"teamId\": \"$TEAM_ID\""

  if [[ -n "$DESCRIPTION" ]]; then
    local escaped_desc
    escaped_desc=$(echo -n "$DESCRIPTION" | escape_json)
    input="$input, \"description\": $escaped_desc"
  fi

  if [[ -n "$PROJECT_ID" ]]; then
    input="$input, \"projectId\": \"$PROJECT_ID\""
  fi

  if [[ -n "$ASSIGNEE_ID" ]]; then
    input="$input, \"assigneeId\": \"$ASSIGNEE_ID\""
  fi

  if [[ -n "$LABEL_IDS" ]]; then
    # Convert comma-separated to JSON array
    local label_array
    label_array=$(echo "$LABEL_IDS" | tr ',' '\n' | jq -R . | jq -s .)
    input="$input, \"labelIds\": $label_array"
  fi

  if [[ -n "$PARENT_ID" ]]; then
    input="$input, \"parentId\": \"$PARENT_ID\""
  fi

  if [[ -n "$PRIORITY" ]]; then
    input="$input, \"priority\": $PRIORITY"
  fi

  if [[ -n "$STATE_ID" ]]; then
    input="$input, \"stateId\": \"$STATE_ID\""
  fi

  echo "{$input}"
}

INPUT=$(build_input)

# GraphQL mutation
MUTATION='mutation IssueCreate($input: IssueCreateInput!) {
  issueCreate(input: $input) {
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
      parent { id identifier title }
    }
  }
}'

# Build variables
VARIABLES="{\"input\": $INPUT}"

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
if echo "$RESPONSE" | jq -e '.data.issueCreate.success == false' > /dev/null 2>&1; then
  echo "Error: Failed to create issue" >&2
  exit 1
fi

# Output created issue
echo "$RESPONSE" | jq '.data.issueCreate.issue'
