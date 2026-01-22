#!/bin/bash
# Get a Jira issue by key
# Usage: get_issue.sh ISSUE_KEY
#
# Required:
#   ISSUE_KEY - Issue key (e.g., PROJ-123)
#
# Environment:
#   JIRA_API_TOKEN - Required. Jira API token for authentication.
#   JIRA_EMAIL     - Required. Email for Basic Auth.
#   JIRA_URL  - Required. Jira instance URL (e.g., https://company.atlassian.net)
#
# Output:
#   On success: JSON with issue details
#   On failure: Error message to stderr, exit 1

set -euo pipefail

ISSUE_KEY="${1:-}"

if [[ -z "$ISSUE_KEY" ]]; then
  echo "Error: ISSUE_KEY is required" >&2
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

# Make API request
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET \
  -H "Authorization: Basic $(echo -n "$JIRA_EMAIL:$JIRA_API_TOKEN" | base64)" \
  -H "Content-Type: application/json" \
  "${JIRA_URL}/rest/api/3/issue/${ISSUE_KEY}?expand=names")

# Extract HTTP status code and body
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

# Check for errors
if [[ "$HTTP_CODE" -ne 200 ]]; then
  ERROR_MSG=$(echo "$BODY" | jq -r '.errorMessages[0] // .errors | to_entries[0].value // "Unknown error"' 2>/dev/null || echo "HTTP $HTTP_CODE")
  echo "Error: $ERROR_MSG" >&2
  exit 1
fi

# Output issue with normalized structure
echo "$BODY" | jq '{
  key: .key,
  id: .id,
  summary: .fields.summary,
  description: .fields.description,
  status: .fields.status.name,
  assignee: (if .fields.assignee then {
    accountId: .fields.assignee.accountId,
    displayName: .fields.assignee.displayName,
    emailAddress: .fields.assignee.emailAddress
  } else null end),
  issuetype: {
    id: .fields.issuetype.id,
    name: .fields.issuetype.name,
    subtask: .fields.issuetype.subtask
  },
  components: [.fields.components[]? | {id: .id, name: .name}],
  labels: .fields.labels,
  parent: (if .fields.parent then {key: .fields.parent.key} else null end),
  url: "\(.self | split("/rest/")[0])/browse/\(.key)"
}'
