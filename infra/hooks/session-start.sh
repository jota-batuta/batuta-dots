#!/usr/bin/env bash
# =============================================================================
# O.R.T.A. Hook: SessionStart
# =============================================================================
# Runs at the beginning of every Claude Code session.
# Reads .batuta/session.md and injects it as additionalContext so Claude
# automatically restores project state without relying on compliance.
#
# Input: JSON via stdin from Claude Code hooks system
#   { "session_id": "...", "cwd": "...", ... }
#
# Output: JSON on stdout with additionalContext (if session.md exists)
#   { "hookSpecificOutput": { "hookEventName": "SessionStart", "additionalContext": "..." } }
#
# Exit codes:
#   0 = success (stdout added as context)
#   1 = non-blocking error (logged, session continues)
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

json_escape() {
    case "$_JSON_CMD" in
        jq)      jq -Rs '.' ;;
        python3) python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" ;;
        python)  python -c "import sys,json; print(json.dumps(sys.stdin.read()))" ;;
        *)       sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | tr '\n' '\\' | sed 's/\\/\\n/g; s/^/"/; s/$/"/' ;;
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

# If no .batuta directory or no session.md, exit silently
if [[ -z "$BATUTA_DIR" || ! -f "$BATUTA_DIR/session.md" ]]; then
    exit 0
fi

# Read session.md content
SESSION_CONTENT=$(<"$BATUTA_DIR/session.md")

# Check freshness (warn if >7 days since last update)
FRESHNESS_WARNING=""
LAST_UPDATE=$(grep -oP 'Last updated.*?: \K\d{4}-\d{2}-\d{2}' "$BATUTA_DIR/session.md" 2>/dev/null || true)
if [[ -n "$LAST_UPDATE" ]]; then
    LAST_EPOCH=$(date -d "$LAST_UPDATE" +%s 2>/dev/null || echo "0")
    NOW_EPOCH=$(date +%s)
    if [[ "$LAST_EPOCH" -gt 0 ]]; then
        DAYS_AGO=$(( (NOW_EPOCH - LAST_EPOCH) / 86400 ))
        if [[ "$DAYS_AGO" -gt 7 ]]; then
            FRESHNESS_WARNING="

Warning: $DAYS_AGO days since last session update. Consider running /batuta-update."
        fi
    fi
fi

# Check ecosystem.json for version drift
ECOSYSTEM_WARNING=""
if [[ -f "$BATUTA_DIR/ecosystem.json" ]]; then
    # WHY: Compare local batuta_version with batuta-dots to detect stale installs
    LOCAL_VERSION=""
    case "$_JSON_CMD" in
        jq)      LOCAL_VERSION=$(jq -r '.batuta_version // ""' "$BATUTA_DIR/ecosystem.json" 2>/dev/null) ;;
        python3) LOCAL_VERSION=$(python3 -c "import json; d=json.load(open('$BATUTA_DIR/ecosystem.json')); print(d.get('batuta_version',''))" 2>/dev/null) ;;
        python)  LOCAL_VERSION=$(python -c "import json; d=json.load(open('$BATUTA_DIR/ecosystem.json')); print(d.get('batuta_version',''))" 2>/dev/null) ;;
    esac

    # WHY: Check batuta-dots VERSION file if accessible (user may have it cloned)
    BATUTA_DOTS_LOCATIONS=("$HOME/batuta-dots" "/tmp/batuta-dots")
    for bd_path in "${BATUTA_DOTS_LOCATIONS[@]}"; do
        if [[ -f "$bd_path/VERSION" ]]; then
            HUB_VERSION=$(<"$bd_path/VERSION")
            if [[ -n "$LOCAL_VERSION" && -n "$HUB_VERSION" && "$LOCAL_VERSION" != "$HUB_VERSION" ]]; then
                ECOSYSTEM_WARNING="

Note: Local Batuta version ($LOCAL_VERSION) differs from hub ($HUB_VERSION). Run /batuta-update to sync."
            fi
            break
        fi
    done
fi

# Build context string
CONTEXT="## Batuta Session Context (auto-injected)

$SESSION_CONTENT$FRESHNESS_WARNING$ECOSYSTEM_WARNING"

# Escape for JSON output
CONTEXT_ESCAPED=$(echo "$CONTEXT" | json_escape)

# Output JSON with additionalContext
echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":$CONTEXT_ESCAPED}}"

exit 0
