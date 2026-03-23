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

# Append daily activity sparkline (last 90 days)
python3 -c "
import json, subprocess

repos = json.load(open('$OUT'))
for repo in repos:
    r = subprocess.run(
        ['gh', 'api', f'repos/$USER/{repo[\"name\"]}/stats/commit_activity'],
        capture_output=True, text=True)
    if r.returncode == 0:
        data = json.loads(r.stdout)
        days = [d for w in data for d in w['days']][-90:]
    else:
        days = [0] * 90

    if not days:
        days = [0] * 90
    mx = max(days) or 1
    n = len(days)
    # SVG viewBox: width=n-1, height=100. Bars from baseline at 100 going up.
    bars = []
    for i, v in enumerate(days):
        if v > 0:
            h = max(v * 85 // mx, 5)  # min 5% height for visibility
            bars.append(f'<rect x=\"{i}\" y=\"{100-h}\" width=\"1\" height=\"{h}\"/>')
    repo['spark_bars'] = ''.join(bars)
    repo['spark_width'] = n

json.dump(repos, open('$OUT', 'w'))
"

echo "synced $(python3 -c "import json; print(len(json.load(open('$OUT'))))" ) pinned repos to $OUT"
