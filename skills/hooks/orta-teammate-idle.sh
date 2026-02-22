#!/usr/bin/env bash
# =============================================================================
# O.R.T.A. Hook: TeammateIdle
# =============================================================================
# Runs when a teammate finishes and goes idle.
# Centralizes logging to avoid multi-writer conflicts on prompt-log.jsonl.
#
# Usage (called by Claude Code hooks system):
#   bash orta-teammate-idle.sh "$TEAMMATE_NAME" "$TEAM_NAME"
#
# Exit codes:
#   0 = acknowledge idle, let teammate stop
#   2 = send feedback, keep teammate working
# =============================================================================

set -euo pipefail

TEAMMATE_NAME="${1:-unknown}"
TEAM_NAME="${2:-default}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Find project's .batuta/ directory
BATUTA_DIR=""
if [[ -d ".batuta" ]]; then
    BATUTA_DIR=".batuta"
elif [[ -d "$(git rev-parse --show-toplevel 2>/dev/null)/.batuta" ]]; then
    BATUTA_DIR="$(git rev-parse --show-toplevel)/.batuta"
fi

# Log teammate completion event
if [[ -n "$BATUTA_DIR" && -f "$BATUTA_DIR/prompt-log.jsonl" ]]; then
    cat >> "$BATUTA_DIR/prompt-log.jsonl" << EOF
{"ts":"$TIMESTAMP","type":"team","event":"teammate_idle","teammate":"$TEAMMATE_NAME","team":"$TEAM_NAME"}
EOF
fi

# Exit 0 = let teammate stop normally
exit 0
