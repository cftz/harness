#!/bin/bash
# Get active cycle for a team
# Usage: get_active_cycle.sh TEAM_ID
#
# Required:
#   TEAM_ID - Team UUID
#
# Environment:
#   LINEAR_API_KEY - Required. Linear API key for authentication.
#
# Output:
#   On success: JSON with active cycle or null
#   On failure: Error message to stderr, exit 1

set -euo pipefail

TEAM_ID="${1:-}"

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

# GraphQL query to get active cycle for team
QUERY='query GetActiveCycle($teamId: String!) {
  team(id: $teamId) {
    activeCycle {
      id
      name
      number
      startsAt
      endsAt
    }
  }
}'

# Build variables
VARIABLES="{\"teamId\": \"$TEAM_ID\"}"

# Make API request
RESPONSE=$(curl -s -X POST \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  --data "{\"query\": $(echo -n "$QUERY" | escape_json), \"variables\": $VARIABLES}" \
  https://api.linear.app/graphql)

# Check for errors
if echo "$RESPONSE" | jq -e '.errors' > /dev/null 2>&1; then
  echo "Error: $(echo "$RESPONSE" | jq -r '.errors[0].message')" >&2
  exit 1
fi

# Output active cycle (may be null)
echo "$RESPONSE" | jq '.data.team.activeCycle'
