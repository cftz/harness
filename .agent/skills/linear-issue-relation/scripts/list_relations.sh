#!/bin/bash
# List relations for a Linear issue
# Usage: list_relations.sh ISSUE_ID
#
# Required:
#   ISSUE_ID - Issue UUID or identifier (e.g., TA-123)
#
# Environment:
#   LINEAR_API_KEY - Required. Linear API key for authentication.
#
# Output:
#   On success: JSON array of relations
#   On failure: Error message to stderr, exit 1

set -euo pipefail

ISSUE_ID="${1:-}"

if [[ -z "$ISSUE_ID" ]]; then
  echo "Error: ISSUE_ID is required" >&2
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

# GraphQL query - get issue with its relations
QUERY='query IssueRelations($id: String!) {
  issue(id: $id) {
    id
    identifier
    title
    relations {
      nodes {
        id
        type
        issue {
          id
          identifier
          title
        }
        relatedIssue {
          id
          identifier
          title
        }
      }
    }
    inverseRelations {
      nodes {
        id
        type
        issue {
          id
          identifier
          title
        }
        relatedIssue {
          id
          identifier
          title
        }
      }
    }
  }
}'

# Build variables
VARIABLES="{\"id\": \"$ISSUE_ID\"}"

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

# Combine relations and inverseRelations into single array
echo "$RESPONSE" | jq '[.data.issue.relations.nodes[], .data.issue.inverseRelations.nodes[]]'
