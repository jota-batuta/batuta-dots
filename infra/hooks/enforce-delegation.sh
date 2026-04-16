#!/usr/bin/env bash
# =============================================================================
# Enforcement Hook: Agent Delegation Check (PostToolUse)
# =============================================================================
# After Write/Edit on source code, checks if the current context includes
# an active agent contract. If the main agent is writing code directly
# (no agent delegation), injects a warning.
#
# WHY: NutriAndrea E2E showed the main agent implemented everything directly.
# Only delegated in Phase 2 AFTER user demanded it. CLAUDE.md Rule 4:
# "Main agent orchestrates — it does NOT write production code."
#
# MECHANISM: agent-hiring writes .batuta/team.json when an agent is contracted.
# This hook checks if any agent is ACTIVE for the current sprint.
# If no active contracts exist, it warns Claude to delegate.
#
# NOTE: This is a SOFT enforcement (warning, not block) because:
# 1. The main agent needs to write SOME files (configs, scripts, etc.)
# 2. We can't distinguish main agent from subagent in hooks reliably
# 3. The PreToolUse sdd-phase hook already blocks unstructured writes
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

# Skip non-production source files
case "$FILE_PATH" in
    *".test."*|*".spec."*|*"__tests__/"*|*".md"|*".json"|*".yaml"|*".yml")
        exit 0
        ;;
    *"openspec/"*|*".batuta/"*|*".claude/"*|*"node_modules/"*)
        exit 0
        ;;
    *".gitignore"|*"Dockerfile"*|*"docker-compose"*|*".env"*)
        exit 0
        ;;
esac

# Find project root
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

TEAM_FILE="$PROJECT_DIR/.batuta/team.json"

# If team.json doesn't exist, warn but don't block
if [[ ! -f "$TEAM_FILE" ]]; then
    WARNING="DELEGATION REMINDER: No agent contracts found (.batuta/team.json missing). CLAUDE.md Rule 4: 'Delegate to agents — main agent orchestrates, does NOT write production code.' Consider hiring an agent via /agent-hiring before implementing."

    if command -v jq &>/dev/null; then
        ESCAPED=$(echo "$WARNING" | jq -Rs '.')
        echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PostToolUse\",\"additionalContext\":$ESCAPED}}"
    fi
    exit 0
fi

# Check if any agent is ACTIVE (not just available)
if command -v jq &>/dev/null; then
    ACTIVE_COUNT=$(jq -r '.active_contracts | length // 0' "$TEAM_FILE" 2>/dev/null || echo "0")
else
    ACTIVE_COUNT=$(python3 -c "import json; d=json.load(open('$TEAM_FILE')); print(len(d.get('active_contracts',[])))" 2>/dev/null || echo "0")
fi

if [[ "$ACTIVE_COUNT" == "0" ]]; then
    WARNING="DELEGATION WARNING: You are writing source code but no agents are contracted for this sprint. CLAUDE.md Rule 4 requires delegation. Hire an agent with /agent-hiring or invoke the Skill tool with 'agent-hiring' before writing production code."

    if command -v jq &>/dev/null; then
        ESCAPED=$(echo "$WARNING" | jq -Rs '.')
        echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PostToolUse\",\"additionalContext\":$ESCAPED}}"
    fi
fi

exit 0
