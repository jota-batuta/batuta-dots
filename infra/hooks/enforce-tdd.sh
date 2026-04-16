#!/usr/bin/env bash
# =============================================================================
# Enforcement Hook: TDD — Test Before Code (PostToolUse)
# =============================================================================
# After a source file is written, checks if a corresponding test file exists.
# If not, injects a WARNING (not a block) reminding Claude to write tests first.
#
# WHY: NutriAndrea E2E test produced 0 tests. agent-skills produced 12.
# TDD is rule #5 in CLAUDE.md but was completely ignored.
#
# WHY PostToolUse (not PreToolUse): Blocking writes without tests would also
# block the test file itself if you write it after the source. Instead, we
# WARN after source writes and let Claude self-correct. The PreToolUse hook
# (enforce-sdd-phase) already ensures code is written within an SDD phase.
#
# OUTPUT: JSON with additionalContext warning if no test found.
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

# Only check Write and Edit on source files
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
    exit 0
fi

# Skip non-source files
case "$FILE_PATH" in
    *".test."*|*".spec."*|*"__tests__/"*|*"/tests/"*|*"/test/"*)
        exit 0  # This IS a test file — good
        ;;
    *".md"|*".json"|*".yaml"|*".yml"|*".toml"|*".css"|*".scss")
        exit 0  # Config/docs — no test needed
        ;;
    *"openspec/"*|*".batuta/"*|*".claude/"*|*"node_modules/"*)
        exit 0
        ;;
    *".gitignore"|*"Dockerfile"*|*"docker-compose"*|*".env"*)
        exit 0
        ;;
esac

# Only check .ts, .tsx, .js, .jsx, .py source files
case "$FILE_PATH" in
    *.ts|*.tsx|*.js|*.jsx|*.py)
        ;;  # Continue checking
    *)
        exit 0  # Not a source file we track
        ;;
esac

# Derive possible test file paths
BASENAME=$(basename "$FILE_PATH")
DIRNAME=$(dirname "$FILE_PATH")
EXT="${BASENAME##*.}"
NAME="${BASENAME%.*}"

# Remove .d from .d.ts files
NAME="${NAME%.d}"

# Skip if file is a type definition
case "$BASENAME" in
    *.d.ts|*.d.tsx)
        exit 0
        ;;
esac

# Check common test locations
TEST_EXISTS=false

# Pattern 1: same dir with .test. extension
[[ -f "$DIRNAME/$NAME.test.$EXT" ]] && TEST_EXISTS=true
[[ -f "$DIRNAME/$NAME.spec.$EXT" ]] && TEST_EXISTS=true

# Pattern 2: __tests__/ sibling directory
[[ -f "$DIRNAME/__tests__/$NAME.test.$EXT" ]] && TEST_EXISTS=true
[[ -f "$DIRNAME/__tests__/$NAME.$EXT" ]] && TEST_EXISTS=true

# Pattern 3: tests/ at project root
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
[[ -f "$PROJECT_DIR/__tests__/$NAME.test.$EXT" ]] && TEST_EXISTS=true
[[ -f "$PROJECT_DIR/tests/$NAME.test.$EXT" ]] && TEST_EXISTS=true
[[ -f "$PROJECT_DIR/test/$NAME.test.$EXT" ]] && TEST_EXISTS=true

# Pattern 4: Python test_ prefix
if [[ "$EXT" == "py" ]]; then
    [[ -f "$DIRNAME/test_$NAME.py" ]] && TEST_EXISTS=true
    [[ -f "$PROJECT_DIR/tests/test_$NAME.py" ]] && TEST_EXISTS=true
fi

if [[ "$TEST_EXISTS" == "false" ]]; then
    # Output warning as additionalContext (PostToolUse can inject context)
    WARNING="TDD WARNING: You just wrote source code ($BASENAME) but no corresponding test file exists. CLAUDE.md Rule 5: 'Tests before code — every feature starts with a failing test.' Write the test NOW before continuing with more source code."

    if command -v jq &>/dev/null; then
        ESCAPED=$(echo "$WARNING" | jq -Rs '.')
        echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PostToolUse\",\"additionalContext\":$ESCAPED}}"
    else
        echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PostToolUse\",\"additionalContext\":\"$WARNING\"}}"
    fi
fi

exit 0
