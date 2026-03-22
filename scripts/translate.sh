#!/usr/bin/env bash
# Translate zh markdown files to en using claude -p
# Usage: ./scripts/translate.sh [file.md ...]
#   No args = translate all stale/missing .en.md files
set -euo pipefail

CONTENT_DIR="$(cd "$(dirname "$0")/../content" && pwd)"

PROMPT='You are a professional translator. Translate this Chinese markdown blog post to English.

Rules:
- Translate the TOML frontmatter values (title, description) but keep the keys and structure
- Keep all markdown formatting, code blocks, HTML comments, links intact
- Keep proper nouns, technical terms, and citations in their original form
- Keep LaTeX, inline code, and code blocks untouched
- Produce natural, publication-quality English prose, not mechanical translation
- Do NOT add any explanation or commentary, output ONLY the translated markdown'

needs_translate() {
    local src="$1"
    local dst="${src%.md}.en.md"
    [[ ! -f "$dst" ]] && return 0
    [[ "$src" -nt "$dst" ]] && return 0
    return 1
}

translate_file() {
    local src="$1"
    local dst="${src%.md}.en.md"
    local rel="${src#$CONTENT_DIR/}"
    printf "translating: %s\n" "$rel"
    claude -p "$PROMPT" --output-format text < "$src" > "$dst"
    printf "      done: %s\n" "${dst#$CONTENT_DIR/}"
}

# ==== Main ====

files=()
if [[ $# -gt 0 ]]; then
    files=("$@")
else
    while IFS= read -r -d '' f; do
        # skip _index files (section indices, already created manually)
        [[ "$(basename "$f")" == _index.md ]] && continue
        # skip files that are themselves translations
        [[ "$f" == *.en.md ]] && continue
        needs_translate "$f" && files+=("$f")
    done < <(find "$CONTENT_DIR" -name '*.md' -not -name '*.en.md' -print0)
fi

if [[ ${#files[@]} -eq 0 ]]; then
    echo "nothing to translate"
    exit 0
fi

printf "found %d file(s) to translate\n\n" "${#files[@]}"
for f in "${files[@]}"; do
    translate_file "$f"
done
echo ""
echo "all translations complete"
