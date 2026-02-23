#!/usr/bin/env bash
# =============================================================================
# O.R.T.A. Hook: TeammateIdle
# =============================================================================
# Runs when a teammate finishes and goes idle.
# Centralizes logging to avoid multi-writer conflicts on prompt-log.jsonl.
#
# Input: JSON via stdin from Claude Code hooks system
#   { "teammate_name": "...", "team_name": "...", "cwd": "...", ... }
#
# Exit codes:
#   0 = acknowledge idle, let teammate stop
#   2 = send feedback via stderr, keep teammate working
# =============================================================================

set -euo pipefail

# Read JSON from stdin (Claude Code hooks protocol)
INPUT=$(cat)

# Detect JSON parser once (jq > python3 > python > none)
_JSON_CMD=""
if jq --version >/dev/null 2>&1; then _JSON_CMD="jq"
elif python3 --version >/dev/null 2>&1; then _JSON_CMD="python3"
elif python --version >/dev/null 2>&1; then _JSON_CMD="python"
fi

json_val() {
    local field="$1" default="$2"
    case "$_JSON_CMD" in
        jq)      echo "$INPUT" | jq -r ".$field // \"$default\"" ;;
        python3) echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('$field','$default'))" ;;
        python)  echo "$INPUT" | python -c "import sys,json; d=json.load(sys.stdin); print(d.get('$field','$default'))" ;;
        *)       echo "$default" ;;
    esac
}

TEAMMATE_NAME=$(json_val teammate_name "unknown")
TEAM_NAME=$(json_val team_name "default")
CWD=$(json_val cwd ".")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Find project's .batuta/ directory
BATUTA_DIR=""
if [[ -d "$CWD/.batuta" ]]; then
    BATUTA_DIR="$CWD/.batuta"
elif [[ -n "${CLAUDE_PROJECT_DIR:-}" && -d "$CLAUDE_PROJECT_DIR/.batuta" ]]; then
    BATUTA_DIR="$CLAUDE_PROJECT_DIR/.batuta"
fi

# Log teammate idle event
if [[ -n "$BATUTA_DIR" && -f "$BATUTA_DIR/prompt-log.jsonl" ]]; then
    echo "{\"ts\":\"$TIMESTAMP\",\"type\":\"team\",\"event\":\"teammate_idle\",\"teammate\":\"$TEAMMATE_NAME\",\"team\":\"$TEAM_NAME\"}" >> "$BATUTA_DIR/prompt-log.jsonl"
fi

# Exit 0 = let teammate stop normally
exit 0
