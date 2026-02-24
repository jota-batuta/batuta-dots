#!/usr/bin/env bash
# =============================================================================
# O.R.T.A. Hook: Stop
# =============================================================================
# Runs when Claude Code session is ending.
# Provides context to Claude about saving session state via prompt hook.
# This is a lightweight reminder — the actual session.md update is done by
# Claude (the prompt hook type handles the LLM evaluation).
#
# Note: This script serves as a command hook backup. The primary mechanism
# is the "prompt" type hook in settings.json which asks Claude to evaluate
# whether session.md needs updating before stopping.
#
# Input: JSON via stdin from Claude Code hooks system
#   { "session_id": "...", "cwd": "...", "last_assistant_message": "...", ... }
#
# Exit codes:
#   0 = allow stop
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

CWD=$(json_val cwd ".")

# Find project's .batuta/ directory
BATUTA_DIR=""
if [[ -d "$CWD/.batuta" ]]; then
    BATUTA_DIR="$CWD/.batuta"
elif [[ -n "${CLAUDE_PROJECT_DIR:-}" && -d "$CLAUDE_PROJECT_DIR/.batuta" ]]; then
    BATUTA_DIR="$CLAUDE_PROJECT_DIR/.batuta"
fi

# If no .batuta directory, nothing to do
if [[ -z "$BATUTA_DIR" ]]; then
    exit 0
fi

# Log session end event if prompt-log.jsonl exists
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION_ID=$(json_val session_id "unknown")

if [[ -f "$BATUTA_DIR/prompt-log.jsonl" ]]; then
    echo "{\"ts\":\"$TIMESTAMP\",\"type\":\"prompt\",\"event\":\"session_end\",\"session_id\":\"$SESSION_ID\"}" >> "$BATUTA_DIR/prompt-log.jsonl"
fi

# Allow stop — the prompt hook in settings.json handles the LLM evaluation
exit 0
