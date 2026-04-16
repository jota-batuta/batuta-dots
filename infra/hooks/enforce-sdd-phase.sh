#!/usr/bin/env bash
# =============================================================================
# Enforcement Hook: SDD Phase Gate (PreToolUse)
# =============================================================================
# Blocks Write/Edit on SOURCE CODE files unless an SDD phase is active.
#
# WHY: E2E test (NutriAndrea v1) showed agent writes code directly without
# invoking sdd-apply. agent-skills achieves 6/6 gate compliance with 60 lines
# of CLAUDE.md. batuta-dots needs ENFORCEMENT, not just education.
#
# WHAT IT BLOCKS: .ts/.tsx/.js/.jsx/.py/.go/.rs/.vue/.svelte etc.
# WHAT IT ALLOWS: .sh/.md/.json/.yaml/.css/.html, test files, configs, docs
#
# EXIT CODES:
#   0 = allow    2 = BLOCK (reason via stderr)
# =============================================================================

set -euo pipefail

INPUT=$(cat)

# Parse tool info
if command -v jq &>/dev/null; then
    TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
elif command -v python3 &>/dev/null; then
    TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))")
    FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))")
else
    exit 0
fi

# Only intercept Write and Edit
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
    exit 0
fi

# ONLY block known source code extensions. Everything else is allowed.
# WHY: blocking .sh, .md, VERSION, Makefile etc. breaks hub development.
IS_SOURCE=false
case "$FILE_PATH" in
    *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs)
        IS_SOURCE=true ;;
    *.py|*.pyx)
        IS_SOURCE=true ;;
    *.go|*.rs|*.rb|*.php|*.java|*.kt|*.swift|*.c|*.cpp|*.h|*.hpp)
        IS_SOURCE=true ;;
    *.vue|*.svelte)
        IS_SOURCE=true ;;
esac

# Test files are source but come FIRST in TDD — always allowed
case "$FILE_PATH" in
    *".test."*|*".spec."*|*"__tests__/"*|*"/tests/"*|*"/test/"*)
        IS_SOURCE=false ;;
esac

# Not a source file — allow (configs, docs, scripts, manifests, etc.)
if [[ "$IS_SOURCE" == "false" ]]; then
    exit 0
fi

# Find project root (look for .batuta/ directory)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-}"
if [[ -z "$PROJECT_DIR" ]]; then
    CHECK_DIR=$(dirname "$FILE_PATH" 2>/dev/null || echo ".")
    for _ in $(seq 1 10); do
        if [[ -d "$CHECK_DIR/.batuta" ]]; then
            PROJECT_DIR="$CHECK_DIR"
            break
        fi
        CHECK_DIR=$(dirname "$CHECK_DIR")
    done
fi

# No .batuta/ found — not a Batuta project, allow
if [[ -z "$PROJECT_DIR" ]]; then
    exit 0
fi

STATE_FILE="$PROJECT_DIR/.batuta/sdd-state.json"

# Check if SDD state exists
if [[ ! -f "$STATE_FILE" ]]; then
    echo "BLOCKED: No active SDD phase. Invoke /sdd-apply before writing source code." >&2
    exit 2
fi

# Parse phase
if command -v jq &>/dev/null; then
    PHASE=$(jq -r '.phase // ""' "$STATE_FILE" 2>/dev/null)
elif command -v python3 &>/dev/null; then
    PHASE=$(python3 -c "import json; print(json.load(open('$STATE_FILE')).get('phase',''))" 2>/dev/null)
else
    exit 0
fi

# Allow if phase is active
case "$PHASE" in
    apply|build|fix|verify|sprint|init|explore|design)
        exit 0
        ;;
    ""|none|idle)
        echo "BLOCKED: SDD phase is '$PHASE'. Invoke /sdd-apply to start BUILD phase first." >&2
        exit 2
        ;;
    *)
        exit 0  # Unknown phase — fail open
        ;;
esac
