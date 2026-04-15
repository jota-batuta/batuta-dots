#!/usr/bin/env bash
# simplify-ignore.sh — check if a file is in the SIMPLIFY-IGNORE list
# Usage: bash simplify-ignore.sh <file-path>
# Returns:
#   exit 0 = file should be IGNORED (do not simplify)
#   exit 1 = OK to simplify
#   exit 2 = usage error

set -euo pipefail

# WORKAROUND: Locate SIMPLIFY-IGNORE.md by checking common install paths.
# BATUTA_CLAUDE_DIR can be set explicitly; otherwise try script-relative then global.
IGNORE_FILE=""
if [[ -n "${BATUTA_CLAUDE_DIR:-}" && -f "$BATUTA_CLAUDE_DIR/SIMPLIFY-IGNORE.md" ]]; then
    IGNORE_FILE="$BATUTA_CLAUDE_DIR/SIMPLIFY-IGNORE.md"
elif [[ -f "$(dirname "${BASH_SOURCE[0]}")/../SIMPLIFY-IGNORE.md" ]]; then
    IGNORE_FILE="$(dirname "${BASH_SOURCE[0]}")/../SIMPLIFY-IGNORE.md"
elif [[ -f "$HOME/.claude/SIMPLIFY-IGNORE.md" ]]; then
    IGNORE_FILE="$HOME/.claude/SIMPLIFY-IGNORE.md"
fi

FILE_PATH="${1:-}"

if [[ -z "$FILE_PATH" ]]; then
    echo "Usage: $0 <file-path>" >&2
    exit 2
fi

# No ignore file = safe to simplify
if [[ -z "$IGNORE_FILE" || ! -f "$IGNORE_FILE" ]]; then
    exit 1
fi

# Extract patterns: lines starting with "- `" — extract content inside backticks
patterns=$(grep -E '^- `[^`]+`' "$IGNORE_FILE" | sed -E 's/^- `([^`]+)`.*$/\1/')

while IFS= read -r pattern; do
    [[ -z "$pattern" ]] && continue
    # Glob match using shell's case
    case "$FILE_PATH" in
        $pattern) exit 0 ;;  # matched — IGNORE
    esac
done <<< "$patterns"

exit 1  # OK to simplify
