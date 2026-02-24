#!/usr/bin/env bash
# =============================================================================
# O.R.T.A. Hook: TaskCompleted
# =============================================================================
# Runs when a task is being marked as complete.
# Acts as a quality gate — exit code 2 rejects completion with feedback.
#
# Input: JSON via stdin from Claude Code hooks system
#   { "task_id": "...", "task_subject": "...", "teammate_name": "...",
#     "team_name": "...", "cwd": "...", ... }
#
# Exit codes:
#   0 = approve task completion
#   2 = reject completion, stderr feedback sent to teammate
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

TASK_ID=$(json_val task_id "unknown")
TASK_SUBJECT=$(json_val task_subject "")
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

# Log task completion event
if [[ -n "$BATUTA_DIR" && -f "$BATUTA_DIR/prompt-log.jsonl" ]]; then
    echo "{\"ts\":\"$TIMESTAMP\",\"type\":\"team\",\"event\":\"task_completed\",\"task_id\":\"$TASK_ID\",\"task_subject\":\"$TASK_SUBJECT\",\"teammate\":\"$TEAMMATE_NAME\",\"team\":\"$TEAM_NAME\"}" >> "$BATUTA_DIR/prompt-log.jsonl"
fi

# Quality gate checks could be added here:
# - Check if Scope Rule was followed (files in correct locations)
# - Check if tests exist for new code
# - Check if SDD artifacts are present
#
# To reject: echo "feedback message" >&2 && exit 2
#
# For now, approve all completions. Quality gates will be
# refined based on real usage patterns via /batuta:analyze-prompts.

exit 0
