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
    local total=0 skipped=0

    # 3-way skill resolution: provisioned > manual > global-only
    local search_dirs=()
    if [[ -f "$CWD/.claude/skills/.provisions.json" ]]; then
        # PROVISIONED: Project was provisioned by sdd-init Step 3.8.
        # Use ONLY project-scoped skills — global already filtered during provisioning.
        # WHY: Provisioning deliberately selected relevant skills. Scanning global
        # would re-add the noise that provisioning removed.
        search_dirs+=("$CWD/.claude/skills")
        # WORKAROUND: If sdd-init ran before setup.sh --sync, ~/.claude/skills/ was empty
        # and .provisions.json was written with skills:[]. The local dir has 0 SKILL.md files.
        # In that case, add global as fallback so the agent isn't permanently blind.
        # WHY: setup.sh --project does not run sync_claude(). A user who ran --project first
        # will have an empty global library, triggering this silent failure path.
        local _lc
        _lc=$(find "$CWD/.claude/skills" -name "SKILL.md" 2>/dev/null | wc -l)
        if [[ "$_lc" -eq 0 ]] && [[ -d "$HOME/.claude/skills" ]]; then
            search_dirs+=("$HOME/.claude/skills")
        fi
        unset _lc
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

            # Extract name and ALL scopes from YAML frontmatter using awk.
            # Emits one line per scope ("scope|name") so multi-scope skills
            # (e.g. scope: [pipeline, infra]) appear in all relevant groups.
            # FIX: Previous version used sub(/,.*/, "", scope) which truncated to
            # only the first scope — skills like sdd-apply, security-audit were invisible
            # to the infra scope even though they declared it.
            local skill_lines
            skill_lines=$(awk '
                BEGIN { fm=0; name=""; scope="" }
                /^---[[:space:]]*$/ { fm++; next }
                fm==1 && /^name:/ {
                    name=$0; sub(/^name:[[:space:]]*/, "", name)
                    gsub(/["'"'"']+/, "", name)
                    gsub(/[[:space:]]+$/, "", name)
                }
                fm==1 && /^[[:space:]]+scope:/ {
                    scope=$0; sub(/.*\[/, "", scope); sub(/\].*/, "", scope)
                    gsub(/[[:space:]]+/, "", scope)
                }
                fm>=2 { exit }
                END {
                    if (name=="") exit
                    if (scope=="") { print "other|" name; exit }
                    n = split(scope, scopes, ",")
                    for (i=1; i<=n; i++) {
                        s = scopes[i]
                        gsub(/[[:space:]]/, "", s)
                        if (s != "") print s "|" name
                    }
                }
            ' "$skill_file" 2>/dev/null) || continue

            [[ -z "$skill_lines" ]] && { skipped=$((skipped + 1)); continue; }

            # Extract skill name from first line (all lines share the same name)
            local name
            name=$(printf '%s\n' "$skill_lines" | head -1 | cut -d'|' -f2)
            [[ -z "$name" ]] && { skipped=$((skipped + 1)); continue; }

            # Deduplicate: project-local wins (processed first)
            [[ -n "${seen_skills[$name]:-}" ]] && continue
            seen_skills[$name]=1
            total=$((total + 1))

            # Register skill in each scope it declared
            while IFS='|' read -r scope_entry _; do
                [[ -z "$scope_entry" ]] && continue
                if [[ -n "${scope_skills[$scope_entry]:-}" ]]; then
                    scope_skills[$scope_entry]="${scope_skills[$scope_entry]}, $name"
                else
                    scope_skills[$scope_entry]="$name"
                fi
                scope_counts[$scope_entry]=$(( ${scope_counts[$scope_entry]:-0} + 1 ))
            done <<< "$skill_lines"
        done
    done

    if [[ "$total" -eq 0 ]]; then
        # Emit visible warning instead of silent exit — skills dirs exist but no valid SKILL.md found.
        # WHY: Silent exit caused agents to start with no skills, thinking none were installed,
        # when the real cause was malformed frontmatter. Visible warning enables diagnosis.
        if [[ ${#search_dirs[@]} -gt 0 ]]; then
            echo "## Batuta Skill Inventory (auto-discovered)"
            echo ""
            echo "Warning: No skills found in: ${search_dirs[*]}"
            echo "Possible causes: (1) setup.sh --sync not run yet, (2) malformed SKILL.md frontmatter."
            echo "Run: bash \$(batuta-dots-path)/infra/setup.sh --sync"
            [[ "$skipped" -gt 0 ]] && echo "Skipped: $skipped SKILL.md files with malformed or missing frontmatter."
        fi
        return
    fi

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

    # Report skipped skills so malformed frontmatter is diagnosable
    [[ "$skipped" -gt 0 ]] && echo "(Note: $skipped SKILL.md file(s) skipped — missing or malformed frontmatter)"
}

# =============================================================================
# Dynamic Agent Discovery
# =============================================================================
# Scans installed agent .md files, extracts name + first line of description
# from YAML frontmatter. Project-local agents (.claude/agents/) take priority
# over global (~/.claude/agents/). Same deduplication logic as discover_skills.
# =============================================================================
discover_agents() {
    declare -A seen_agents
    local -a agent_entries
    local total=0

    # Priority: project-local first, then global
    local search_dirs=()
    [[ -d "$CWD/.claude/agents" ]] && search_dirs+=("$CWD/.claude/agents")
    [[ -d "$HOME/.claude/agents" ]] && search_dirs+=("$HOME/.claude/agents")

    [[ ${#search_dirs[@]} -eq 0 ]] && return

    for agents_dir in "${search_dirs[@]}"; do
        for agent_file in "$agents_dir"/*.md; do
            [[ -f "$agent_file" ]] || continue

            # Extract name and first line of description from YAML frontmatter.
            # Handles both inline description and block scalar (description: >).
            local info
            info=$(awk '
                BEGIN { fm=0; name=""; desc=""; in_desc=0 }
                /^---[[:space:]]*$/ { fm++; if(fm>=2) exit; next }
                fm==1 && /^name:/ {
                    name=$0; sub(/^name:[[:space:]]*/, "", name)
                    gsub(/["'"'"']+/, "", name)
                    gsub(/[[:space:]]+$/, "", name)
                }
                fm==1 && /^description:/ {
                    in_desc=1
                    tmp=$0; sub(/^description:[[:space:]]*>?[[:space:]]*/, "", tmp)
                    gsub(/[[:space:]]+$/, "", tmp)
                    if (tmp != "" && tmp != ">") { desc=tmp; in_desc=0 }
                    next
                }
                fm==1 && in_desc==1 && /^[[:space:]]/ {
                    tmp=$0; gsub(/^[[:space:]]+/, "", tmp)
                    gsub(/[[:space:]]+$/, "", tmp)
                    if (tmp != "") { desc=tmp; in_desc=0 }
                    next
                }
                fm==1 && in_desc==1 && /^[^[:space:]]/ { in_desc=0 }
                END { if (name != "") print name "|" desc }
            ' "$agent_file" 2>/dev/null) || continue

            [[ -z "$info" ]] && continue

            local name
            name=$(printf '%s\n' "$info" | cut -d'|' -f1)
            [[ -z "$name" ]] && continue

            # Deduplicate: project-local wins (processed first)
            [[ -n "${seen_agents[$name]:-}" ]] && continue
            seen_agents[$name]=1
            total=$((total + 1))

            local desc
            desc=$(printf '%s\n' "$info" | cut -d'|' -f2-)

            agent_entries+=("- ${name}: ${desc}")
        done
    done

    [[ "$total" -eq 0 ]] && return

    echo "## Batuta Agent Inventory (auto-discovered)"
    echo ""
    echo "Found $total agents. Spawn via Task tool (subagent_type: \"agent-name\"):"
    for entry in "${agent_entries[@]}"; do
        echo "$entry"
    done
}

SKILL_INVENTORY=$(discover_skills)
AGENT_INVENTORY=$(discover_agents)

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

# Read tail of team-history.md if it exists (sub-agent reports)
# WHY: The SubagentStop hook appends each sub-agent's final report here.
# Injecting the last few entries at session start gives the main agent
# visibility into what sub-agents discovered in prior turns — prevents
# re-spawning them on already-answered questions. Tail only: full history
# can grow to ~50 entries which is too large for context injection.
TEAM_HISTORY_CONTENT=""
if [[ -n "$BATUTA_DIR" && -f "$BATUTA_DIR/team-history.md" ]]; then
    # Inject last 3 entries (delimited by "---"). Each entry is typically
    # ~30 lines, so 3 entries ≈ 90 lines — a reasonable context budget.
    TEAM_HISTORY_CONTENT=$(awk '
        BEGIN { count = 0 }
        /^---[[:space:]]*$/ { count++ }
        { lines[NR] = $0 }
        END {
            # Find the line number of the 4th-from-last "---" (or start of file)
            target = count - 3
            if (target < 1) target = 0
            found = 0
            for (i = 1; i <= NR; i++) {
                if (lines[i] ~ /^---[[:space:]]*$/) {
                    found++
                    if (found > target) {
                        for (j = i; j <= NR; j++) print lines[j]
                        exit
                    }
                }
            }
        }
    ' "$BATUTA_DIR/team-history.md" 2>/dev/null || true)
fi

# If nothing to inject, exit silently
if [[ -z "$SKILL_INVENTORY" && -z "$AGENT_INVENTORY" && -z "$SESSION_CONTENT" && -z "$CHECKPOINT_CONTENT" && -z "$TEAM_HISTORY_CONTENT" ]]; then
    exit 0
fi

# Check freshness (warn if >7 days since last session update)
FRESHNESS_WARNING=""
if [[ -n "$SESSION_CONTENT" ]]; then
    # Extract date from specific structured fields first (avoids false matches on historical dates
    # embedded in session content). Falls back to generic ISO match if no structured field found.
    # FIX: Generic "first ISO date" was fragile — a project description with "launched 2025-01-15"
    # would be picked up instead of the actual session update date.
    LAST_UPDATE=$(grep -oE '^(date|Updated): [0-9]{4}-[0-9]{2}-[0-9]{2}' "$BATUTA_DIR/session.md" 2>/dev/null \
        | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1 || true)
    if [[ -z "$LAST_UPDATE" ]]; then
        # Fallback: any ISO date in the file (less reliable — structured fields preferred)
        LAST_UPDATE=$(grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' "$BATUTA_DIR/session.md" 2>/dev/null | head -1 || true)
    fi
    if [[ -n "$LAST_UPDATE" ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS (BSD date)
            LAST_EPOCH=$(date -j -f "%Y-%m-%d" "$LAST_UPDATE" "+%s" 2>/dev/null || echo "0")
        else
            # Linux and Windows/Git Bash (GNU date — supports -d flag on all three).
            # WORKAROUND: Windows OSTYPE is "msys" or "mingw32", not "linux". Both correctly
            # fall here because Git Bash ships GNU coreutils with -d support. Do NOT add a
            # separate Windows branch — it would duplicate this line and risk divergence.
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

if [[ -n "$AGENT_INVENTORY" ]]; then
    [[ -n "$CONTEXT" ]] && CONTEXT="$CONTEXT

"
    CONTEXT="${CONTEXT}${AGENT_INVENTORY}"
fi

if [[ -n "$SESSION_CONTENT" ]]; then
    [[ -n "$CONTEXT" ]] && CONTEXT="$CONTEXT

"
    CONTEXT="${CONTEXT}## Batuta Session Context (auto-injected)

$SESSION_CONTENT$FRESHNESS_WARNING$ECOSYSTEM_WARNING"
fi

if [[ -n "$CHECKPOINT_CONTENT" ]]; then
    [[ -n "$CONTEXT" ]] && CONTEXT="$CONTEXT

"
    CONTEXT="${CONTEXT}## Operational Checkpoint (auto-injected — last session state)
Read this to restore operational context after compaction or resume.

$CHECKPOINT_CONTENT"
fi

if [[ -n "$TEAM_HISTORY_CONTENT" ]]; then
    [[ -n "$CONTEXT" ]] && CONTEXT="$CONTEXT

"
    CONTEXT="${CONTEXT}## Team History Tail (auto-injected — last 3 sub-agent reports)
Consult this before spawning a new sub-agent on a topic that may already be covered.

$TEAM_HISTORY_CONTENT"
fi

# Escape for JSON output
CONTEXT_ESCAPED=$(echo "$CONTEXT" | json_escape)

# Output JSON with additionalContext
echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":$CONTEXT_ESCAPED}}"

exit 0
