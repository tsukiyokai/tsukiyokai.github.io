#!/usr/bin/env bash
# Sync pinned GitHub repos to local JSON for Zola templates
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$REPO_ROOT/static/repos.json"
USER="tsukiyokai"

gh api graphql -f query="
{ user(login: \"$USER\") {
    pinnedItems(first: 6, types: REPOSITORY) {
      nodes { ... on Repository {
        name description url
        primaryLanguage { name color }
        stargazerCount forkCount
        updatedAt
        repositoryTopics(first: 5) { nodes { topic { name } } }
      }}
    }
  }
}" --jq '[.data.user.pinnedItems.nodes[] | {
  name, description, url,
  language:      (.primaryLanguage.name  // null),
  language_color:(.primaryLanguage.color // null),
  stars:         .stargazerCount,
  forks:         .forkCount,
  updated:       .updatedAt,
  topics:        [.repositoryTopics.nodes[].topic.name]
}]' > "$OUT"

echo "synced $(python3 -c "import json; print(len(json.load(open('$OUT'))))" ) pinned repos to $OUT"
