#!/usr/bin/env bash
# Sync pinned GitHub repos to local JSON for Zola templates
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$REPO_ROOT/static/repos.json"
USER="tsukiyokai"

# Fetch pinned repos
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

# Append weekly activity sparkline (52 weeks via participation API)
python3 -c "
import json, subprocess

repos = json.load(open('$OUT'))
for repo in repos:
    r = subprocess.run(
        ['gh', 'api', f'repos/$USER/{repo[\"name\"]}/stats/participation'],
        capture_output=True, text=True)
    weeks = [0] * 52
    if r.returncode == 0:
        data = json.loads(r.stdout)
        if isinstance(data, dict) and 'all' in data:
            weeks = data['all']

    mx = max(weeks) or 1
    n = len(weeks)
    bars = []
    for i, v in enumerate(weeks):
        if v > 0:
            h = max(v * 85 // mx, 5)
            bars.append(f'<rect x=\"{i}\" y=\"{100-h}\" width=\"1\" height=\"{h}\"/>')
    repo['spark_bars'] = ''.join(bars)
    repo['spark_width'] = n

json.dump(repos, open('$OUT', 'w'))
"

echo "synced $(python3 -c "import json; print(len(json.load(open('$OUT'))))" ) pinned repos to $OUT"
