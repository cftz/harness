#!/bin/bash
# Add an issue to a cycle
# Usage: add_issue_to_cycle.sh ISSUE_ID CYCLE_ID
#
# Required:
#   ISSUE_ID - Issue identifier (e.g., TA-123) or UUID
#   CYCLE_ID - Cycle UUID
#
# Environment:
#   LINEAR_API_KEY - Required. Linear API key for authentication.
#
# Output:
#   On success: JSON with update result
#   On failure: Error message to stderr, exit 1

set -euo pipefail

ISSUE_ID="${1:-}"
CYCLE_ID="${2:-}"

if [[ -z "$ISSUE_ID" ]]; then
  echo "Error: ISSUE_ID is required" >&2
  exit 1
fi

if [[ -z "$CYCLE_ID" ]]; then
  echo "Error: CYCLE_ID is required" >&2
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

# GraphQL mutation to update issue with cycle
MUTATION='mutation AddIssueToCycle($id: String!, $cycleId: String!) {
  issueUpdate(id: $id, input: { cycleId: $cycleId }) {
    success
    issue {
      id
      identifier
      title
      cycle {
        id
        name
        number
      }
    }
  }
}'

# Build variables
VARIABLES="{\"id\": \"$ISSUE_ID\", \"cycleId\": \"$CYCLE_ID\"}"

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
  echo "Error: Failed to add issue to cycle" >&2
  exit 1
fi

# Output result
echo "$RESPONSE" | jq '.data.issueUpdate'
