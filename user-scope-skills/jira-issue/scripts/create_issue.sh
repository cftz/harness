#!/bin/bash
# Create a Jira issue using issueType ID (not name)
# Usage: create_issue.sh PROJECT ISSUE_TYPE_ID TITLE [DESCRIPTION] [ASSIGNEE] [COMPONENT] [PARENT] [LABELS]
#
# Required:
#   PROJECT       - Project key (e.g., PROJ)
#   ISSUE_TYPE_ID - Issue type ID (e.g., 10002). NOT the name!
#   TITLE         - Issue summary
#
# Optional:
#   DESCRIPTION - Issue description (markdown)
#   ASSIGNEE    - Assignee account ID (NOT email)
#   COMPONENT   - Component name
#   PARENT      - Parent issue key for sub-tasks
#   LABELS      - Comma-separated label names
#
# Environment:
#   JIRA_API_TOKEN - Required. Jira API token for authentication.
#   JIRA_EMAIL     - Required. Email for Basic Auth.
#   JIRA_URL       - Required. Jira instance URL (e.g., https://company.atlassian.net)
#
# Output:
#   On success: JSON with created issue
#   On failure: Error message to stderr, exit 1

set -euo pipefail

PROJECT="${1:-}"
ISSUE_TYPE_ID="${2:-}"
TITLE="${3:-}"
DESCRIPTION="${4:-}"
ASSIGNEE="${5:-}"
COMPONENT="${6:-}"
PARENT="${7:-}"
LABELS="${8:-}"

if [[ -z "$PROJECT" ]]; then
  echo "Error: PROJECT is required" >&2
  exit 1
fi

if [[ -z "$ISSUE_TYPE_ID" ]]; then
  echo "Error: ISSUE_TYPE_ID is required" >&2
  exit 1
fi

if [[ -z "$TITLE" ]]; then
  echo "Error: TITLE is required" >&2
  exit 1
fi

if [[ -z "${JIRA_API_TOKEN:-}" ]]; then
  echo "Error: JIRA_API_TOKEN environment variable is required" >&2
  exit 1
fi

if [[ -z "${JIRA_EMAIL:-}" ]]; then
  echo "Error: JIRA_EMAIL environment variable is required" >&2
  exit 1
fi

if [[ -z "${JIRA_URL:-}" ]]; then
  echo "Error: JIRA_URL environment variable is required" >&2
  exit 1
fi

# JSON escaping helper
escape_json() {
  python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))"
}

# Build fields object
build_fields() {
  local escaped_title
  escaped_title=$(echo -n "$TITLE" | escape_json)

  # Start with required fields - use issuetype.id instead of name!
  local fields="\"project\": {\"key\": \"$PROJECT\"}, \"issuetype\": {\"id\": \"$ISSUE_TYPE_ID\"}, \"summary\": $escaped_title"

  if [[ -n "$DESCRIPTION" ]]; then
    # Convert markdown to Atlassian Document Format (ADF)
    # For simplicity, use plain text paragraph
    local escaped_desc
    escaped_desc=$(echo -n "$DESCRIPTION" | escape_json)
    fields="$fields, \"description\": {\"type\": \"doc\", \"version\": 1, \"content\": [{\"type\": \"paragraph\", \"content\": [{\"type\": \"text\", \"text\": $escaped_desc}]}]}"
  fi

  if [[ -n "$ASSIGNEE" ]]; then
    # Use accountId, NOT email
    fields="$fields, \"assignee\": {\"accountId\": \"$ASSIGNEE\"}"
  fi

  if [[ -n "$COMPONENT" ]]; then
    # Components use name, not id
    local escaped_comp
    escaped_comp=$(echo -n "$COMPONENT" | escape_json)
    fields="$fields, \"components\": [{\"name\": $escaped_comp}]"
  fi

  if [[ -n "$PARENT" ]]; then
    # Parent for sub-tasks
    fields="$fields, \"parent\": {\"key\": \"$PARENT\"}"
  fi

  if [[ -n "$LABELS" ]]; then
    # Convert comma-separated to JSON array
    local label_array
    label_array=$(echo "$LABELS" | tr ',' '\n' | jq -R . | jq -s .)
    fields="$fields, \"labels\": $label_array"
  fi

  echo "{$fields}"
}

FIELDS=$(build_fields)
REQUEST_BODY="{\"fields\": $FIELDS}"

# Make API request
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Authorization: Basic $(echo -n "$JIRA_EMAIL:$JIRA_API_TOKEN" | base64)" \
  -H "Content-Type: application/json" \
  --data "$REQUEST_BODY" \
  "${JIRA_URL}/rest/api/3/issue")

# Extract HTTP status code and body
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

# Check for errors
if [[ "$HTTP_CODE" -ne 201 ]]; then
  ERROR_MSG=$(echo "$BODY" | jq -r '.errorMessages[0] // (.errors | to_entries[0] | "\(.key): \(.value)") // "Unknown error"' 2>/dev/null || echo "HTTP $HTTP_CODE")
  echo "Error: $ERROR_MSG" >&2
  echo "Request body: $REQUEST_BODY" >&2
  exit 1
fi

# Output created issue
ISSUE_KEY=$(echo "$BODY" | jq -r '.key')
ISSUE_ID=$(echo "$BODY" | jq -r '.id')
ISSUE_URL="${JIRA_URL}/browse/${ISSUE_KEY}"

echo "$BODY" | jq --arg url "$ISSUE_URL" '{
  key: .key,
  id: .id,
  url: $url
}'
