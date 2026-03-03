#!/usr/bin/env bash
# =============================================================================
# O.R.T.A. Hook: SessionStart
# =============================================================================
# Runs at the beginning of every Claude Code session.
#
# 1. Discovers all installed skills dynamically (no hardcoded lists)
# 2. Reads .batuta/session.md for project state restoration
# 3. Checks freshness and version drift
# 4. Injects everything as additionalContext
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

# =============================================================================
# Dynamic Skill Discovery
# =============================================================================
# Scans installed SKILL.md files, extracts name + scope from YAML frontmatter,
# groups by scope, and generates a formatted inventory.
# Project-local skills (~/.claude/skills/) take priority over global.
# =============================================================================
discover_skills() {
    declare -A scope_skills scope_counts seen_skills
    local total=0

    # 3-way skill resolution: provisioned > manual > global-only
    local search_dirs=()
    if [[ -f "$CWD/.claude/skills/.provisions.json" ]]; then
        # PROVISIONED: Project was provisioned by sdd-init Step 3.8.
        # Use ONLY project-scoped skills — global already filtered during provisioning.
        # WHY: Provisioning deliberately selected relevant skills. Scanning global
        # would re-add the noise that provisioning removed.
        search_dirs+=("$CWD/.claude/skills")
    elif [[ -d "$CWD/.claude/skills" ]]; then
        # MANUAL: Project has .claude/skills/ but no provisions manifest.
        # Scan both local and global (backward compatible with pre-v11.3 behavior).
        search_dirs+=("$CWD/.claude/skills")
        [[ -d "$HOME/.claude/skills" ]] && search_dirs+=("$HOME/.claude/skills")
    else
        # NO LOCAL: No project skills. Use global library (backward compatible).
        [[ -d "$HOME/.claude/skills" ]] && search_dirs+=("$HOME/.claude/skills")
    fi

    [[ ${#search_dirs[@]} -eq 0 ]] && return

    for skills_dir in "${search_dirs[@]}"; do
        for skill_file in "$skills_dir"/*/SKILL.md; do
            [[ -f "$skill_file" ]] || continue

            # Extract name and scope from YAML frontmatter using awk
            local parsed
            parsed=$(awk '
                BEGIN { fm=0; name=""; scope="" }
                /^---[[:space:]]*$/ { fm++; next }
                fm==1 && /^name:/ {
                    name=$0; sub(/^name:[[:space:]]*/, "", name)
                    gsub(/["'"'"']+/, "", name)
                    gsub(/[[:space:]]+$/, "", name)
                }
                fm==1 && /^[[:space:]]+scope:/ {
                    scope=$0; sub(/.*\[/, "", scope); sub(/\].*/, "", scope)
                    sub(/,.*/, "", scope)
                    gsub(/[[:space:]]+/, "", scope)
                }
                fm>=2 { exit }
                END { if (name!="") print (scope!="" ? scope : "other") "|" name }
            ' "$skill_file" 2>/dev/null) || continue

            [[ -z "$parsed" ]] && continue

            local scope="${parsed%%|*}"
            local name="${parsed#*|}"

            # Deduplicate: project-local wins (processed first)
            [[ -n "${seen_skills[$name]:-}" ]] && continue
            seen_skills[$name]=1

            if [[ -n "${scope_skills[$scope]:-}" ]]; then
                scope_skills[$scope]="${scope_skills[$scope]}, $name"
            else
                scope_skills[$scope]="$name"
            fi
            scope_counts[$scope]=$(( ${scope_counts[$scope]:-0} + 1 ))
            total=$((total + 1))
        done
    done

    [[ "$total" -eq 0 ]] && return

    local num_scopes=${#scope_skills[@]}
    echo "## Batuta Skill Inventory (auto-discovered)"
    echo ""
    echo "Found $total skills across $num_scopes scopes:"

    # Consistent order: pipeline, infra, observability, then others alphabetically
    local -a ordered_scopes=()
    for s in pipeline infra observability; do
        [[ -n "${scope_skills[$s]:-}" ]] && ordered_scopes+=("$s")
    done
    for s in $(printf '%s\n' "${!scope_skills[@]}" | sort); do
        case "$s" in pipeline|infra|observability) ;; *) ordered_scopes+=("$s") ;; esac
    done

    for s in "${ordered_scopes[@]}"; do
        echo "- $s (${scope_counts[$s]}): ${scope_skills[$s]}"
    done
}

SKILL_INVENTORY=$(discover_skills)

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

# If nothing to inject, exit silently
if [[ -z "$SKILL_INVENTORY" && -z "$SESSION_CONTENT" ]]; then
    exit 0
fi

# Check freshness (warn if >7 days since last session update)
FRESHNESS_WARNING=""
if [[ -n "$SESSION_CONTENT" ]]; then
    # Extract ISO date from session.md (supports "date: YYYY-MM-DD" in frontmatter)
    LAST_UPDATE=$(grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' "$BATUTA_DIR/session.md" 2>/dev/null | head -1 || true)
    if [[ -n "$LAST_UPDATE" ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS (BSD date)
            LAST_EPOCH=$(date -j -f "%Y-%m-%d" "$LAST_UPDATE" "+%s" 2>/dev/null || echo "0")
        else
            # Linux (GNU date)
            LAST_EPOCH=$(date -d "$LAST_UPDATE" +%s 2>/dev/null || echo "0")
        fi
        NOW_EPOCH=$(date +%s)
        if [[ "$LAST_EPOCH" -gt 0 ]]; then
            DAYS_AGO=$(( (NOW_EPOCH - LAST_EPOCH) / 86400 ))
            if [[ "$DAYS_AGO" -gt 7 ]]; then
                FRESHNESS_WARNING="

Warning: $DAYS_AGO days since last session update. Consider running /batuta-update."
            fi
        fi
    fi
fi

# Check ecosystem.json for version drift
ECOSYSTEM_WARNING=""
if [[ -n "$BATUTA_DIR" && -f "$BATUTA_DIR/ecosystem.json" ]]; then
    # WHY: Compare local batuta_version with batuta-dots to detect stale installs
    LOCAL_VERSION=""
    case "$_JSON_CMD" in
        jq)      LOCAL_VERSION=$(jq -r '.batuta_version // ""' "$BATUTA_DIR/ecosystem.json" 2>/dev/null) ;;
        python3) LOCAL_VERSION=$(python3 -c "import json; d=json.load(open('$BATUTA_DIR/ecosystem.json')); print(d.get('batuta_version',''))" 2>/dev/null) ;;
        python)  LOCAL_VERSION=$(python -c "import json; d=json.load(open('$BATUTA_DIR/ecosystem.json')); print(d.get('batuta_version',''))" 2>/dev/null) ;;
    esac

    # WHY: Check batuta-dots VERSION file.
    # Priority: (1) batuta-config.json explicit path, (2) relative to script,
    # (3) well-known paths. After installation, hooks live in ~/.claude/hooks/
    # (not inside batuta-dots), so the relative path often fails.
    BATUTA_DOTS_LOCATIONS=()

    # (1) Read from batuta-config.json if it exists
    BATUTA_CONFIG="$HOME/.claude/batuta-config.json"
    if [[ -f "$BATUTA_CONFIG" ]]; then
        CONFIGURED_PATH=""
        # WORKAROUND: Python on Windows can't resolve MSYS2 paths like /c/Users/...,
        # so use os.path.expanduser('~') instead of passing $HOME from bash.
        case "$_JSON_CMD" in
            jq)      CONFIGURED_PATH=$(jq -r '.batuta_claude_path // ""' "$BATUTA_CONFIG" 2>/dev/null) ;;
            python3) CONFIGURED_PATH=$(python3 -c "import json,os; d=json.load(open(os.path.expanduser('~/.claude/batuta-config.json'))); print(d.get('batuta_claude_path',''))" 2>/dev/null) ;;
            python)  CONFIGURED_PATH=$(python -c "import json,os; d=json.load(open(os.path.expanduser('~/.claude/batuta-config.json'))); print(d.get('batuta_claude_path',''))" 2>/dev/null) ;;
        esac
        [[ -n "$CONFIGURED_PATH" ]] && BATUTA_DOTS_LOCATIONS+=("$CONFIGURED_PATH")
    fi

    # (2) Relative to script (works when running from inside batuta-dots repo)
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
    BATUTA_DOTS_LOCATIONS+=("$REPO_ROOT/BatutaClaude")

    # (3) Well-known fallback paths
    BATUTA_DOTS_LOCATIONS+=("$HOME/.claude" "$HOME/batuta-dots" "/tmp/batuta-dots")

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

# Build context string from available parts
CONTEXT=""

if [[ -n "$SKILL_INVENTORY" ]]; then
    CONTEXT="$SKILL_INVENTORY"
fi

if [[ -n "$SESSION_CONTENT" ]]; then
    [[ -n "$CONTEXT" ]] && CONTEXT="$CONTEXT

"
    CONTEXT="${CONTEXT}## Batuta Session Context (auto-injected)

$SESSION_CONTENT$FRESHNESS_WARNING$ECOSYSTEM_WARNING"
fi

# Escape for JSON output
CONTEXT_ESCAPED=$(echo "$CONTEXT" | json_escape)

# Output JSON with additionalContext
echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":$CONTEXT_ESCAPED}}"

exit 0
