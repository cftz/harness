#!/bin/bash
# List Jira issues using JQL
# Usage: list_issues.sh JQL [LIMIT]
#
# Required:
#   JQL - JQL query string (e.g., "project = PROJ AND status = 'To Do'")
#
# Optional:
#   LIMIT - Maximum results (default: 50)
#
# Environment:
#   JIRA_API_TOKEN - Required. Jira API token for authentication.
#   JIRA_EMAIL     - Required. Email for Basic Auth.
#   JIRA_URL  - Required. Jira instance URL (e.g., https://company.atlassian.net)
#
# Output:
#   On success: JSON with issue list
#   On failure: Error message to stderr, exit 1

set -euo pipefail

JQL="${1:-}"
LIMIT="${2:-50}"

if [[ -z "$JQL" ]]; then
  echo "Error: JQL is required" >&2
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

# Build request body
ESCAPED_JQL=$(echo -n "$JQL" | escape_json)
REQUEST_BODY="{\"jql\": $ESCAPED_JQL, \"maxResults\": $LIMIT, \"fields\": [\"summary\", \"status\", \"issuetype\", \"assignee\", \"components\", \"labels\", \"parent\"]}"

# Make API request
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Authorization: Basic $(echo -n "$JIRA_EMAIL:$JIRA_API_TOKEN" | base64)" \
  -H "Content-Type: application/json" \
  --data "$REQUEST_BODY" \
  "${JIRA_URL}/rest/api/3/search")

# Extract HTTP status code and body
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

# Check for errors
if [[ "$HTTP_CODE" -ne 200 ]]; then
  ERROR_MSG=$(echo "$BODY" | jq -r '.errorMessages[0] // .errors | to_entries[0].value // "Unknown error"' 2>/dev/null || echo "HTTP $HTTP_CODE")
  echo "Error: $ERROR_MSG" >&2
  exit 1
fi

# Output issues with normalized structure
echo "$BODY" | jq '{
  total: .total,
  issues: [.issues[] | {
    key: .key,
    summary: .fields.summary,
    status: .fields.status.name,
    issuetype: {
      id: .fields.issuetype.id,
      name: .fields.issuetype.name,
      subtask: .fields.issuetype.subtask
    },
    assignee: (if .fields.assignee then {
      accountId: .fields.assignee.accountId,
      displayName: .fields.assignee.displayName
    } else null end),
    parent: (if .fields.parent then {key: .fields.parent.key} else null end)
  }]
}'
