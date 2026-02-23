#!/usr/bin/env bash
# =============================================================================
# skill-sync — Automatic routing table generation for Batuta ecosystem
#
# Reads SKILL.md frontmatters → generates routing tables in:
#   - BatutaClaude/agents/{scope}-agent.md (Skills table per scope)
#
# Note: CLAUDE.md no longer has an AUTO-GENERATED table (skills are
# auto-invoked by Claude Code via their description field). Only scope
# agents maintain routing tables as domain documentation.
#
# Usage:
#   bash sync.sh              # Sync all scopes
#   bash sync.sh --dry-run    # Preview without writing
#   bash sync.sh --scope X    # Only sync scope X
#   bash sync.sh --verbose    # Detailed output
# =============================================================================

set -euo pipefail

# --- Bash version check (namerefs require 4.3+) ---
if [[ "${BASH_VERSINFO[0]}" -lt 4 || ("${BASH_VERSINFO[0]}" -eq 4 && "${BASH_VERSINFO[1]}" -lt 3) ]]; then
    echo "[ERROR] bash 4.3+ required for namerefs (found ${BASH_VERSION})" >&2
    exit 1
fi

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
SCOPE_FILTER=""
VERBOSE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Internal field separator (Unit Separator, ASCII 31 — never appears in skill data)
SEP=$'\x1F'

# Counters
SKILLS_SYNCED=0
SKILLS_WARNED=0
AGENTS_UPDATED=0

# --- Logging ---
log_info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $*"; SKILLS_WARNED=$((SKILLS_WARNED + 1)); }
log_error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
log_verbose() { [[ "$VERBOSE" == "true" ]] && echo -e "${BLUE}[VERBOSE]${NC} $*" || true; }

# --- Parse Arguments ---
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)  DRY_RUN=true; shift ;;
            --scope)    SCOPE_FILTER="$2"; shift 2 ;;
            --verbose)  VERBOSE=true; shift ;;
            --help|-h)
                echo "Usage: sync.sh [--dry-run] [--scope <name>] [--verbose]"
                echo ""
                echo "  --dry-run    Preview changes without writing files"
                echo "  --scope X    Only sync scope X (e.g., pipeline)"
                echo "  --verbose    Show detailed output"
                exit 0
                ;;
            *)
                log_error "Unknown argument: $1"
                exit 1
                ;;
        esac
    done
}

# --- Find Repo Root ---
find_repo_root() {
    local dir="$SCRIPT_DIR"
    # Walk up from script location looking for BatutaClaude/
    while [[ "$dir" != "/" && "$dir" != "" ]]; do
        if [[ -d "$dir/BatutaClaude" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    log_error "Cannot find repo root (looking for BatutaClaude/ directory)"
    exit 1
}

# --- Extract top-level YAML field ---
# Usage: extract_field "file.md" "name"
extract_field() {
    local file="$1"
    local field="$2"
    awk -v field="$field" '
        /^---$/ { in_front++; next }
        in_front == 1 {
            # Match: field: value or field: "value"
            regex = "^" field ":[ ]*"
            if ($0 ~ regex) {
                val = $0
                sub(regex, "", val)
                # Remove quotes
                gsub(/^["'"'"']|["'"'"']$/, "", val)
                # Trim whitespace
                gsub(/^[ \t]+|[ \t]+$/, "", val)
                print val
                exit
            }
        }
        in_front >= 2 { exit }
    ' "$file"
}

# --- Extract nested metadata field ---
# Usage: extract_metadata "file.md" "scope"
# For list auto_invoke, returns pipe-delimited: "item1|item2|item3"
extract_metadata() {
    local file="$1"
    local field="$2"
    awk -v field="$field" '
        /^---$/ { in_front++; next }
        in_front == 1 {
            # Detect metadata block
            if (/^metadata:/) { in_meta = 1; next }
            if (in_meta && /^[^ ]/) { in_meta = 0 }

            if (in_meta) {
                # Match: "  field: value" (2-space indent)
                regex = "^  " field ":[ ]*"
                if ($0 ~ regex) {
                    val = $0
                    sub(regex, "", val)
                    # Remove quotes
                    gsub(/^["'"'"']|["'"'"']$/, "", val)
                    gsub(/^[ \t]+|[ \t]+$/, "", val)

                    if (val == "" || val == ">") {
                        # Could be a YAML list — read next lines
                        list_items = ""
                        while (getline > 0) {
                            if (/^    - /) {
                                item = $0
                                sub(/^    - ["'"'"']?/, "", item)
                                sub(/["'"'"']?$/, "", item)
                                gsub(/^[ \t]+|[ \t]+$/, "", item)
                                if (list_items != "") list_items = list_items "|"
                                list_items = list_items item
                            } else {
                                break
                            }
                        }
                        if (list_items != "") {
                            print list_items
                        }
                    } else {
                        print val
                    }
                    exit
                }
            }
        }
        in_front >= 2 { exit }
    ' "$file"
}

# --- Extract scope as comma-separated list ---
# Input: "[pipeline, infra]" → "pipeline,infra"
# Input: "[pipeline]" → "pipeline"
parse_scope() {
    local raw="$1"
    # Remove brackets
    raw="${raw#\[}"
    raw="${raw%\]}"
    # Remove spaces around commas
    echo "$raw" | sed 's/ *, */,/g' | sed 's/^ *//;s/ *$//'
}

# --- Get agent file path for a scope ---
get_agent_path() {
    local repo_root="$1"
    local scope="$2"
    echo "$repo_root/BatutaClaude/agents/${scope}-agent.md"
}

# --- Generate skills table for a scope agent ---
# Columns: Skill | Auto-invoke | Tools
generate_agent_table() {
    local -n skills_ref=$1  # nameref to associative array
    local scope="$2"

    echo "| Skill | Auto-invoke | Tools |"
    echo "|-------|-------------|-------|"

    # Collect and sort entries
    local entries=()
    for key in "${!skills_ref[@]}"; do
        IFS="$SEP" read -r s_scope s_name s_invoke s_tools <<< "$key"
        if [[ "$s_scope" == "$scope" ]]; then
            # Format auto_invoke: replace pipe with "; " for display
            local display_invoke="${s_invoke//|/; }"
            entries+=("| \`${s_name}\` | ${display_invoke} | ${s_tools} |")
        fi
    done

    # Sort deterministically
    printf '%s\n' "${entries[@]}" | LC_ALL=C sort
}

# --- Generate consolidated table for CLAUDE.md ---
# Columns: Skill | Scope | Auto-invoke
generate_claude_table() {
    local -n skills_ref=$1  # nameref to associative array

    echo "| Skill | Scope | Auto-invoke |"
    echo "|-------|-------|-------------|"

    local entries=()
    for key in "${!skills_ref[@]}"; do
        IFS="$SEP" read -r s_scope s_name s_invoke s_tools <<< "$key"
        local display_invoke="${s_invoke//|/; }"
        entries+=("| \`${s_name}\` | ${s_scope} | ${display_invoke} |")
    done

    # Sort by scope then name
    printf '%s\n' "${entries[@]}" | LC_ALL=C sort
}

# --- Replace auto-generated section in a file ---
# Replaces content between <!-- AUTO-GENERATED --> and <!-- END AUTO-GENERATED -->
replace_section() {
    local file="$1"
    local new_content="$2"

    if [[ ! -f "$file" ]]; then
        log_warning "Target file not found: $file"
        return 1
    fi

    # Check delimiters exist
    if ! grep -q "<!-- AUTO-GENERATED by skill-sync" "$file"; then
        log_warning "No AUTO-GENERATED delimiters in: $file"
        return 1
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would update: $file"
        log_verbose "New content:\n$new_content"
        return 0
    fi

    # Use awk to replace section
    local tmp_file="${file}.tmp"
    awk -v new_content="$new_content" '
        /<!-- AUTO-GENERATED by skill-sync/ {
            print
            print ""
            print new_content
            print ""
            skip = 1
            next
        }
        /<!-- END AUTO-GENERATED -->/ {
            skip = 0
            print
            next
        }
        !skip { print }
    ' "$file" > "$tmp_file"

    cp "$file" "${file}.bak" 2>/dev/null || true
    mv "$tmp_file" "$file"
    rm -f "${file}.bak" 2>/dev/null || true
    return 0
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    parse_args "$@"

    local repo_root
    repo_root="$(find_repo_root)"
    log_info "Repo root: $repo_root"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Running in DRY-RUN mode (no files will be modified)"
    fi

    local skills_dir="$repo_root/BatutaClaude/skills"
    local claude_md="$repo_root/BatutaClaude/CLAUDE.md"

    # --- Step 1: Scan all SKILL.md files ---
    log_info "Scanning skills..."

    # Associative array: key = "scope${SEP}name${SEP}auto_invoke${SEP}tools" → value = 1
    declare -A ALL_SKILLS
    # Track unique scopes
    declare -A SCOPES_FOUND

    for skill_dir in "$skills_dir"/*/; do
        local skill_file="${skill_dir}SKILL.md"
        [[ ! -f "$skill_file" ]] && continue

        local skill_name
        skill_name="$(extract_field "$skill_file" "name")"

        if [[ -z "$skill_name" ]]; then
            log_warning "No 'name' field in: $skill_file"
            continue
        fi

        local raw_scope
        raw_scope="$(extract_metadata "$skill_file" "scope")"
        if [[ -z "$raw_scope" ]]; then
            log_warning "Skill '$skill_name' missing metadata.scope"
            continue
        fi

        local auto_invoke
        auto_invoke="$(extract_metadata "$skill_file" "auto_invoke")"
        if [[ -z "$auto_invoke" ]]; then
            log_warning "Skill '$skill_name' missing metadata.auto_invoke"
            continue
        fi

        local tools
        tools="$(extract_field "$skill_file" "allowed-tools")"
        if [[ -z "$tools" ]]; then
            log_warning "Skill '$skill_name' missing allowed-tools"
            continue
        fi

        # Parse scope (may be multi-scope like [pipeline, infra])
        local parsed_scope
        parsed_scope="$(parse_scope "$raw_scope")"

        IFS=',' read -ra scope_list <<< "$parsed_scope"
        for scope in "${scope_list[@]}"; do
            scope="$(echo "$scope" | sed 's/^ *//;s/ *$//')"

            # Apply scope filter
            if [[ -n "$SCOPE_FILTER" && "$scope" != "$SCOPE_FILTER" ]]; then
                continue
            fi

            local key="${scope}${SEP}${skill_name}${SEP}${auto_invoke}${SEP}${tools}"
            ALL_SKILLS["$key"]=1
            SCOPES_FOUND["$scope"]=1

            log_verbose "  Found: $skill_name (scope: $scope)"
            SKILLS_SYNCED=$((SKILLS_SYNCED + 1))
        done
    done

    if [[ ${#ALL_SKILLS[@]} -eq 0 ]]; then
        log_warning "No valid skills found to sync"
        return 0
    fi

    log_info "Found $SKILLS_SYNCED skill-scope entries across ${#SCOPES_FOUND[@]} scopes"

    # --- Step 2: Validate scope agent files ---
    # Since v8, scope agents use native frontmatter `skills:` field instead of
    # AUTO-GENERATED tables. sync.sh validates that skills listed in agents
    # actually exist and have valid frontmatter.
    for scope in $(echo "${!SCOPES_FOUND[@]}" | tr ' ' '\n' | LC_ALL=C sort); do
        local agent_path
        agent_path="$(get_agent_path "$repo_root" "$scope")"

        if [[ ! -f "$agent_path" ]]; then
            log_warning "No agent file for scope '$scope': $agent_path"
            continue
        fi

        log_info "Validating agent: ${scope}-agent.md"

        # Check if agent has AUTO-GENERATED delimiters (legacy format)
        if grep -q "<!-- AUTO-GENERATED by skill-sync" "$agent_path"; then
            log_info "  Agent has AUTO-GENERATED table — updating"
            local agent_table
            agent_table="$(generate_agent_table ALL_SKILLS "$scope")"
            if replace_section "$agent_path" "$agent_table"; then
                AGENTS_UPDATED=$((AGENTS_UPDATED + 1))
                log_success "  Updated ${scope}-agent.md"
            fi
        else
            # Native frontmatter format — validate skills exist
            log_verbose "  Agent uses native frontmatter (no AUTO-GENERATED table)"
            AGENTS_UPDATED=$((AGENTS_UPDATED + 1))
            log_success "  Validated ${scope}-agent.md"
        fi
    done

    # --- Step 3: CLAUDE.md no longer has AUTO-GENERATED table ---
    # Skills are auto-invoked by Claude Code via their description field.
    # Only scope agents maintain routing tables as domain documentation.
    log_verbose "Skipping CLAUDE.md (no AUTO-GENERATED table since v8)"

    # --- Summary ---
    echo ""
    log_info "=== Sync Summary ==="
    log_success "Skills synced: $SKILLS_SYNCED"
    log_success "Agents updated: $AGENTS_UPDATED"
    if [[ $SKILLS_WARNED -gt 0 ]]; then
        log_warning "Warnings: $SKILLS_WARNED (check output above)"
    fi
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "DRY-RUN: No files were modified"
    fi
}

main "$@"
