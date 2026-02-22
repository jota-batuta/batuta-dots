#!/usr/bin/env bash
# =============================================================================
# O.R.T.A. Hook: TaskCompleted
# =============================================================================
# Runs when a task is being marked as complete.
# Acts as a quality gate — exit code 2 rejects completion with feedback.
#
# Usage (called by Claude Code hooks system):
#   bash orta-task-gate.sh "$TASK_ID" "$TEAM_NAME"
#
# Exit codes:
#   0 = approve task completion
#   2 = reject completion, send feedback to teammate
# =============================================================================

set -euo pipefail

TASK_ID="${1:-unknown}"
TEAM_NAME="${2:-default}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Find project's .batuta/ directory
BATUTA_DIR=""
if [[ -d ".batuta" ]]; then
    BATUTA_DIR=".batuta"
elif [[ -d "$(git rev-parse --show-toplevel 2>/dev/null)/.batuta" ]]; then
    BATUTA_DIR="$(git rev-parse --show-toplevel)/.batuta"
fi

# Log task completion event
if [[ -n "$BATUTA_DIR" && -f "$BATUTA_DIR/prompt-log.jsonl" ]]; then
    cat >> "$BATUTA_DIR/prompt-log.jsonl" << EOF
{"ts":"$TIMESTAMP","type":"team","event":"task_completed","task_id":"$TASK_ID","team":"$TEAM_NAME"}
EOF
fi

# Quality gate checks could be added here:
# - Check if Scope Rule was followed (files in correct locations)
# - Check if tests exist for new code
# - Check if SDD artifacts are present
#
# For now, approve all completions. Quality gates will be
# refined based on real usage patterns via /batuta:analyze-prompts.

exit 0
