#!/bin/bash
# Update a Jira issue
# Usage: update_issue.sh ISSUE_KEY FIELDS_JSON
#
# Required:
#   ISSUE_KEY   - Issue key (e.g., PROJ-123)
#   FIELDS_JSON - JSON object with fields to update
#
# Environment:
#   JIRA_API_TOKEN - Required. Jira API token for authentication.
#   JIRA_EMAIL     - Required. Email for Basic Auth.
#   JIRA_URL  - Required. Jira instance URL (e.g., https://company.atlassian.net)
#
# Output:
#   On success: JSON with updated issue key
#   On failure: Error message to stderr, exit 1

set -euo pipefail

ISSUE_KEY="${1:-}"
FIELDS_JSON="${2:-}"

if [[ -z "$ISSUE_KEY" ]]; then
  echo "Error: ISSUE_KEY is required" >&2
  exit 1
fi

if [[ -z "$FIELDS_JSON" ]]; then
  echo "Error: FIELDS_JSON is required" >&2
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
REQUEST_BODY="{\"fields\": $FIELDS_JSON}"

# Make API request
RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT \
  -H "Authorization: Basic $(echo -n "$JIRA_EMAIL:$JIRA_API_TOKEN" | base64)" \
  -H "Content-Type: application/json" \
  --data "$REQUEST_BODY" \
  "${JIRA_URL}/rest/api/3/issue/${ISSUE_KEY}")

# Extract HTTP status code and body
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

# Check for errors (204 = success with no content)
if [[ "$HTTP_CODE" -ne 204 && "$HTTP_CODE" -ne 200 ]]; then
  ERROR_MSG=$(echo "$BODY" | jq -r '.errorMessages[0] // .errors | to_entries[0].value // "Unknown error"' 2>/dev/null || echo "HTTP $HTTP_CODE")
  echo "Error: $ERROR_MSG" >&2
  exit 1
fi

# Output success
echo "{\"key\": \"$ISSUE_KEY\", \"updated\": true}"
