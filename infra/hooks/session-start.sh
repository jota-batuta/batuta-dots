#!/usr/bin/env bash
# =============================================================================
# O.R.T.A. Hook: SessionStart (v15 — simplified)
# =============================================================================
# Runs at the beginning of every Claude Code session.
#
# Injects two files as additionalContext:
#   1. session.md   — single source of truth for project state
#   2. CHECKPOINT.md — anti-compaction operational state from last session
#
# Removed in v15 (previously handled here):
#   - Skill/agent inventory generation (now via .provisions.json at provisioning time)
#   - team-history.md injection (available on-demand, not critical at start)
#   - Freshness warnings (session.md updates every interaction now)
#   - Ecosystem version drift checks (moved to /batuta-update command)
#
# Input: JSON via stdin from Claude Code hooks system
#   { "session_id": "...", "cwd": "...", ... }
#
# Output: JSON on stdout with additionalContext
#   { "hookSpecificOutput": { "hookEventName": "SessionStart", "additionalContext": "..." } }
#
# Exit codes:
#   0 = success (stdout added as context)
#   1 = non-blocking error (logged, session continues)
# =============================================================================

set -euo pipefail

# WORKAROUND: This hook uses $HOME directly (not resolve_home()) because hooks
# always run in Git Bash context where $HOME is already /c/Users/<user>.
# The resolve_home() function in setup.sh/sync.sh handles edge cases for scripts
# that may be invoked from different shell contexts.

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
        *)       sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | tr '\n' '\\' | sed 's/\\/\\\\n/g; s/^/"/; s/$/"/' ;;
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

# Read session.md if it exists
SESSION_CONTENT=""
if [[ -n "$BATUTA_DIR" && -f "$BATUTA_DIR/session.md" ]]; then
    SESSION_CONTENT=$(<"$BATUTA_DIR/session.md")
fi

# Read CHECKPOINT.md if it exists (operational state from last session stop)
# WHY: CHECKPOINT.md captures intra-session state that compaction destroys.
# Written by the Stop hook on every exit — injecting it here enables automatic
# recovery without requiring the agent to remember to look for it.
CHECKPOINT_CONTENT=""
if [[ -n "$BATUTA_DIR" && -f "$BATUTA_DIR/CHECKPOINT.md" ]]; then
    CHECKPOINT_CONTENT=$(<"$BATUTA_DIR/CHECKPOINT.md")
fi

# If nothing to inject, exit silently
if [[ -z "$SESSION_CONTENT" && -z "$CHECKPOINT_CONTENT" ]]; then
    exit 0
fi

# Build context string from available parts
CONTEXT=""

if [[ -n "$SESSION_CONTENT" ]]; then
    CONTEXT="## Batuta Session Context (auto-injected)

$SESSION_CONTENT"
fi

if [[ -n "$CHECKPOINT_CONTENT" ]]; then
    [[ -n "$CONTEXT" ]] && CONTEXT="$CONTEXT

"
    CONTEXT="${CONTEXT}## Operational Checkpoint (auto-injected — last session state)
Read this to restore operational context after compaction or resume.

$CHECKPOINT_CONTENT"
fi

# Escape for JSON output
CONTEXT_ESCAPED=$(echo "$CONTEXT" | json_escape)

# Output JSON with additionalContext
echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":$CONTEXT_ESCAPED}}"

exit 0
