#!/bin/bash
# List Linear issues with optional filters
# Usage: list_issues.sh [TEAM_ID] [PROJECT_ID] [STATE] [ASSIGNEE_ID] [PARENT_ID] [FIRST]
#
# Optional:
#   TEAM_ID     - Filter by team ID
#   PROJECT_ID  - Filter by project ID
#   STATE       - Filter by state name (e.g., "Todo", "In Progress")
#   ASSIGNEE_ID - Filter by assignee user ID
#   PARENT_ID   - Filter by parent issue ID (returns sub-issues)
#   FIRST       - Limit results (default: 50)
#
# Environment:
#   LINEAR_API_KEY - Required. Linear API key for authentication.
#
# Output:
#   On success: JSON array of issues
#   On failure: Error message to stderr, exit 1

set -euo pipefail

TEAM_ID="${1:-}"
PROJECT_ID="${2:-}"
STATE="${3:-}"
ASSIGNEE_ID="${4:-}"
PARENT_ID="${5:-}"
FIRST="${6:-50}"

if [[ -z "${LINEAR_API_KEY:-}" ]]; then
  echo "Error: LINEAR_API_KEY environment variable is required" >&2
  exit 1
fi

# JSON escaping helper
escape_json() {
  python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))"
}

# Build filter object
build_filter() {
  local filter=""
  local has_filter=false

  if [[ -n "$TEAM_ID" ]]; then
    filter="\"team\": {\"id\": {\"eq\": \"$TEAM_ID\"}}"
    has_filter=true
  fi

  if [[ -n "$PROJECT_ID" ]]; then
    [[ "$has_filter" == "true" ]] && filter="$filter, "
    filter="${filter}\"project\": {\"id\": {\"eq\": \"$PROJECT_ID\"}}"
    has_filter=true
  fi

  if [[ -n "$STATE" ]]; then
    [[ "$has_filter" == "true" ]] && filter="$filter, "
    filter="${filter}\"state\": {\"name\": {\"eq\": \"$STATE\"}}"
    has_filter=true
  fi

  if [[ -n "$ASSIGNEE_ID" ]]; then
    [[ "$has_filter" == "true" ]] && filter="$filter, "
    filter="${filter}\"assignee\": {\"id\": {\"eq\": \"$ASSIGNEE_ID\"}}"
    has_filter=true
  fi

  if [[ -n "$PARENT_ID" ]]; then
    [[ "$has_filter" == "true" ]] && filter="$filter, "
    filter="${filter}\"parent\": {\"id\": {\"eq\": \"$PARENT_ID\"}}"
    has_filter=true
  fi

  if [[ "$has_filter" == "true" ]]; then
    echo "{$filter}"
  else
    echo "null"
  fi
}

FILTER=$(build_filter)

# GraphQL query
QUERY='query Issues($filter: IssueFilter, $first: Int) {
  issues(filter: $filter, first: $first) {
    nodes {
      id
      identifier
      title
      state { id name }
      team { id key name }
      project { id name }
      assignee { id name }
      priority
      priorityLabel
      url
      createdAt
    }
  }
}'

# Build variables
VARIABLES="{\"first\": $FIRST"
if [[ "$FILTER" != "null" ]]; then
  VARIABLES="$VARIABLES, \"filter\": $FILTER"
fi
VARIABLES="$VARIABLES}"

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

# Output issues
echo "$RESPONSE" | jq '.data.issues.nodes'
