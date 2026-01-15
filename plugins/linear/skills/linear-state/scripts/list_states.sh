#!/bin/bash
# List Linear workflow states for a team
# Usage: list_states.sh [TEAM_ID] [ISSUE_ID] [NAME]
#
# Parameters:
#   TEAM_ID  - Team UUID (optional if ISSUE_ID provided)
#   ISSUE_ID - Issue identifier to infer team from (optional if TEAM_ID provided)
#   NAME     - Filter by state name (optional)
#
# Environment:
#   LINEAR_API_KEY - Required. Linear API key for authentication.
#
# Output:
#   On success: JSON array of states with id, name, type, position
#   On failure: Error message to stderr, exit 1

set -euo pipefail

TEAM_ID="${1:-}"
ISSUE_ID="${2:-}"
NAME="${3:-}"

if [[ -z "${LINEAR_API_KEY:-}" ]]; then
  echo "Error: LINEAR_API_KEY environment variable is required" >&2
  exit 1
fi

# JSON escaping helper
escape_json() {
  python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))"
}

# If ISSUE_ID is provided but not TEAM_ID, fetch the team from the issue
if [[ -z "$TEAM_ID" && -n "$ISSUE_ID" ]]; then
  ISSUE_QUERY='query Issue($id: String!) { issue(id: $id) { team { id } } }'

  ISSUE_RESPONSE=$(curl -s -X POST \
    -H "Authorization: $LINEAR_API_KEY" \
    -H "Content-Type: application/json" \
    --data "{\"query\": $(echo -n "$ISSUE_QUERY" | escape_json), \"variables\": {\"id\": \"$ISSUE_ID\"}}" \
    https://api.linear.app/graphql)

  # Check for errors
  if echo "$ISSUE_RESPONSE" | jq -e '.errors' > /dev/null 2>&1; then
    echo "Error: $(echo "$ISSUE_RESPONSE" | jq -r '.errors[0].message')" >&2
    exit 1
  fi

  # Check if issue exists
  if echo "$ISSUE_RESPONSE" | jq -e '.data.issue == null' > /dev/null 2>&1; then
    echo "Error: Issue not found: $ISSUE_ID" >&2
    exit 1
  fi

  TEAM_ID=$(echo "$ISSUE_RESPONSE" | jq -r '.data.issue.team.id')
fi

# Validate we have a team ID now
if [[ -z "$TEAM_ID" ]]; then
  echo "Error: Either TEAM_ID or ISSUE_ID is required" >&2
  exit 1
fi

# GraphQL query for team workflow states
QUERY='query TeamStates($teamId: String!) {
  team(id: $teamId) {
    states {
      nodes {
        id
        name
        type
        position
      }
    }
  }
}'

# Make API request
RESPONSE=$(curl -s -X POST \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  --data "{\"query\": $(echo -n "$QUERY" | escape_json), \"variables\": {\"teamId\": \"$TEAM_ID\"}}" \
  https://api.linear.app/graphql)

# Check for errors
if echo "$RESPONSE" | jq -e '.errors' > /dev/null 2>&1; then
  echo "Error: $(echo "$RESPONSE" | jq -r '.errors[0].message')" >&2
  exit 1
fi

# Check if team exists
if echo "$RESPONSE" | jq -e '.data.team == null' > /dev/null 2>&1; then
  echo "Error: Team not found: $TEAM_ID" >&2
  exit 1
fi

# Extract and optionally filter states
if [[ -n "$NAME" ]]; then
  # Filter by name (case-sensitive exact match)
  echo "$RESPONSE" | jq --arg name "$NAME" '.data.team.states.nodes | map(select(.name == $name)) | sort_by(.position)'
else
  # Return all states sorted by position
  echo "$RESPONSE" | jq '.data.team.states.nodes | sort_by(.position)'
fi
