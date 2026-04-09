#!/usr/bin/env bash
# =============================================================================
# O.R.T.A. Hook: SubagentStop
# =============================================================================
# Runs when a sub-agent (spawned via Task tool) finishes its work.
# Appends the sub-agent's final report to .batuta/team-history.md so that:
#
#   1. The main agent can consult it before spawning a new sub-agent on the
#      same topic (avoid duplicate research / context pollution).
#   2. The SessionStart hook can inject the tail of team-history.md for
#      continuity across compactions.
#   3. Knowledge accumulated by sub-agents (GOTCHAS, FINDINGS) survives beyond
#      their transcript lifetime.
#
# Why this exists: sub-agents have no visible thinking blocks in the main
# agent's transcript. Their final message (FINDINGS / FAILURES / DECISIONS /
# GOTCHAS per the CLAUDE.md output protocol) is the only durable trace of
# their reasoning. Without this hook, every sub-agent's knowledge dies with
# its subprocess.
#
# Input: JSON via stdin from Claude Code hooks system
#   { "session_id": "...", "cwd": "...", "agent_id": "...",
#     "agent_type": "Explore|Plan|<custom>", "last_assistant_message": "..." }
#
# Exit codes:
#   0 = allow subagent stop (always — this hook is append-only, non-blocking)
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
AGENT_TYPE=$(json_val agent_type "unknown")
AGENT_ID=$(json_val agent_id "unknown")
LAST_MSG=$(json_val last_assistant_message "")

# Find project's .batuta/ directory (same logic as session-save.sh)
BATUTA_DIR=""
if [[ -d "$CWD/.batuta" ]]; then
    BATUTA_DIR="$CWD/.batuta"
elif [[ -n "${CLAUDE_PROJECT_DIR:-}" && -d "$CLAUDE_PROJECT_DIR/.batuta" ]]; then
    BATUTA_DIR="$CLAUDE_PROJECT_DIR/.batuta"
fi

# If no .batuta directory or no message, nothing to persist
if [[ -z "$BATUTA_DIR" ]] || [[ -z "$LAST_MSG" ]]; then
    exit 0
fi

HISTORY_FILE="$BATUTA_DIR/team-history.md"
TS_NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")

# =============================================================================
# Append entry to team-history.md
# =============================================================================
# Format: one entry per sub-agent run, prefixed by a delimiter that makes
# retention pruning trivial (awk on the delimiter line).
#
# WHY markdown not JSONL: team-history.md is read by the agent directly
# (injected by SessionStart), so markdown is the most ergonomic format.
# JSONL would require parsing for display.
# =============================================================================
{
    echo ""
    echo "---"
    echo "## ${TS_NOW} — ${AGENT_TYPE} (${AGENT_ID})"
    echo ""
    echo "${LAST_MSG}"
} >> "$HISTORY_FILE"

# =============================================================================
# Retention: keep last 50 sub-agent entries
# =============================================================================
# Count entries by counting "## <ISO-timestamp> — " headings, then keep only
# the most recent 50. Uses awk with state machine to avoid mid-entry cuts.
# =============================================================================
if [[ -f "$HISTORY_FILE" ]]; then
    ENTRY_COUNT=$(grep -cE '^## [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z' "$HISTORY_FILE" 2>/dev/null || echo 0)
    if [[ "$ENTRY_COUNT" -gt 50 ]]; then
        # Keep last 50: find the line number of the 51st-from-last entry header
        # and truncate everything before it.
        SKIP=$((ENTRY_COUNT - 50))
        KEEP_FROM=$(grep -nE '^## [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z' "$HISTORY_FILE" 2>/dev/null | sed -n "${SKIP}p" | cut -d: -f1)
        if [[ -n "$KEEP_FROM" ]]; then
            # Step back one line to include the --- delimiter above the entry
            KEEP_FROM=$((KEEP_FROM > 1 ? KEEP_FROM - 1 : 1))
            {
                echo "# Team History"
                echo ""
                echo "Sub-agent reports (FINDINGS / FAILURES / DECISIONS / GOTCHAS) appended by the SubagentStop hook. Retention: last 50 entries. Older entries pruned automatically."
                tail -n +"$KEEP_FROM" "$HISTORY_FILE"
            } > "$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
        fi
    fi
fi

exit 0
