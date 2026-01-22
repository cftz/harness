#!/bin/bash
# Transition a Jira issue to a new status
# Usage: transition_issue.sh ISSUE_KEY TRANSITION_ID
#
# Required:
#   ISSUE_KEY     - Issue key (e.g., PROJ-123)
#   TRANSITION_ID - Transition ID (from get_transitions.sh)
#
# Environment:
#   JIRA_API_TOKEN - Required. Jira API token for authentication.
#   JIRA_EMAIL     - Required. Email for Basic Auth.
#   JIRA_URL  - Required. Jira instance URL (e.g., https://company.atlassian.net)
#
# Output:
#   On success: JSON with issue key and new status
#   On failure: Error message to stderr, exit 1

set -euo pipefail

ISSUE_KEY="${1:-}"
TRANSITION_ID="${2:-}"

if [[ -z "$ISSUE_KEY" ]]; then
  echo "Error: ISSUE_KEY is required" >&2
  exit 1
fi

if [[ -z "$TRANSITION_ID" ]]; then
  echo "Error: TRANSITION_ID is required" >&2
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

# Build request body
REQUEST_BODY="{\"transition\": {\"id\": \"$TRANSITION_ID\"}}"

# Make API request
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Authorization: Basic $(echo -n "$JIRA_EMAIL:$JIRA_API_TOKEN" | base64)" \
  -H "Content-Type: application/json" \
  --data "$REQUEST_BODY" \
  "${JIRA_URL}/rest/api/3/issue/${ISSUE_KEY}/transitions")

# Extract HTTP status code and body
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

# Check for errors (204 = success with no content)
if [[ "$HTTP_CODE" -ne 204 ]]; then
  ERROR_MSG=$(echo "$BODY" | jq -r '.errorMessages[0] // "Unknown error"' 2>/dev/null || echo "HTTP $HTTP_CODE")
  echo "Error: $ERROR_MSG" >&2
  exit 1
fi

# Output success
echo "{\"key\": \"$ISSUE_KEY\", \"transitioned\": true}"
