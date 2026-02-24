#!/usr/bin/env bash
# ============================================================================
# Batuta.Dots — Bidirectional Skill Sync Script
# ============================================================================
# Syncs skills between the BatutaClaude hub (source of truth) and
# BatutaAntigravity, as well as importing project-local skills back
# into the hub.
#
# WHY bidirectional: Skills are authored in BatutaClaude/ (the hub) and
# replicated to BatutaAntigravity/ for cross-platform use. But developers
# also create skills locally in projects (inside .agent/skills/ or
# .claude/skills/). This script lets those project-born skills flow back
# into the hub so they become available ecosystem-wide.
#
# Usage:
#   ./infra/sync.sh --to-antigravity     # Hub -> BatutaAntigravity/skills/
#   ./infra/sync.sh --from-project PATH  # Project -> Hub (interactive)
#   ./infra/sync.sh --all                # Both directions
#   ./infra/sync.sh --help               # Show help
#
# Platform: Windows (Git Bash / MSYS2 / MINGW) and native Unix
# ============================================================================

set -e

# ============================================================================
# Colors
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# ============================================================================
# Path Resolution (Windows / Git Bash / MSYS / native Unix)
# ============================================================================

resolve_home() {
    if [[ -n "$USERPROFILE" && ("$OSTYPE" == msys* || "$OSTYPE" == mingw* || "$OSTYPE" == cygwin*) ]]; then
        local win_home
        win_home=$(echo "$USERPROFILE" | sed 's|\\|/|g')
        if [[ "$win_home" =~ ^([A-Za-z]): ]]; then
            local drive_letter
            drive_letter=$(echo "${BASH_REMATCH[1]}" | tr '[:upper:]' '[:lower:]')
            win_home="/${drive_letter}${win_home:2}"
        fi
        echo "$win_home"
    else
        echo "$HOME"
    fi
}

HOME_DIR="$(resolve_home)"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ============================================================================
# Utility Functions
# ============================================================================

log_info()    { printf "${CYAN}[INFO]${NC} %s\n" "$1"; }
log_success() { printf "${GREEN}[OK]${NC} %s\n" "$1"; }
log_warning() { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
log_error()   { printf "${RED}[ERROR]${NC} %s\n" "$1"; }

log_header() {
    printf "\n${CYAN}${BOLD}================================================================${NC}\n"
    printf "${CYAN}${BOLD}  %s${NC}\n" "$1"
    printf "${CYAN}${BOLD}================================================================${NC}\n\n"
}

# ============================================================================
# Sync Hub -> BatutaAntigravity (--to-antigravity)
# ============================================================================
# WHY copy instead of symlink: BatutaAntigravity/ may be distributed
# independently (e.g., as a standalone zip or installed via a package
# manager). Symlinks would break outside the monorepo. Copies ensure
# the skills are self-contained.

sync_to_antigravity() {
    local skills_src="$REPO_ROOT/BatutaClaude/skills"
    local skills_dst="$REPO_ROOT/BatutaAntigravity/skills"

    log_header "Sync: Hub -> BatutaAntigravity"
    log_info "Scanning BatutaClaude/skills/ for antigravity-compatible skills..."

    if [[ ! -d "$skills_src" ]]; then
        log_error "Source skills directory not found: $skills_src"
        return 1
    fi

    mkdir -p "$skills_dst"

    local count=0
    local skipped=0
    for skill_dir in "$skills_src"/*/; do
        [[ ! -d "$skill_dir" ]] && continue
        local skill_md="$skill_dir/SKILL.md"
        [[ ! -f "$skill_md" ]] && continue

        # WHY grep frontmatter: SKILL.md is the single source of truth for
        # platform compatibility. No separate registry to keep in sync.
        if ! grep -q "platforms:.*antigravity" "$skill_md" 2>/dev/null; then
            skipped=$((skipped + 1))
            continue
        fi

        local skill_name
        skill_name=$(basename "$skill_dir")

        mkdir -p "$skills_dst/$skill_name"

        # Copy SKILL.md
        local dest_file="$skills_dst/$skill_name/SKILL.md"
        if [[ -f "$dest_file" ]]; then
            chmod u+w "$dest_file" 2>/dev/null || true
        fi
        cp -f "$skill_md" "$dest_file"

        # Copy assets directory if present
        if [[ -d "$skill_dir/assets" ]]; then
            chmod -R u+w "$skills_dst/$skill_name/assets" 2>/dev/null || true
            cp -rf "$skill_dir/assets" "$skills_dst/$skill_name/"
        fi

        log_info "  -> Synced $skill_name"
        count=$((count + 1))
    done

    if [[ $count -eq 0 ]]; then
        log_warning "No antigravity-compatible skills found ($skipped skills skipped)"
        log_info "To make a skill available, add 'platforms: [claude, antigravity]' to its SKILL.md frontmatter"
    else
        log_success "Synced $count skills to BatutaAntigravity/skills/ ($skipped skipped)"
    fi
}

# ============================================================================
# Sync Project -> Hub (--from-project PATH)
# ============================================================================
# WHY interactive confirmation: importing skills into the hub is a
# deliberate action. Skills born in a project may be project-specific
# (e.g., a compliance rule for one client). The user must decide which
# ones are generic enough to promote to the ecosystem.

sync_from_project() {
    local project_path="$1"

    if [[ -z "$project_path" ]]; then
        log_error "--from-project requires a project directory path"
        return 1
    fi

    # Resolve relative paths
    if [[ ! "$project_path" = /* && ! "$project_path" =~ ^[A-Za-z]: ]]; then
        project_path="$(pwd)/$project_path"
    fi

    # Normalize trailing slashes
    project_path="${project_path%/}"
    project_path="${project_path%/.}"

    if [[ ! -d "$project_path" ]]; then
        log_error "Project directory does not exist: $project_path"
        return 1
    fi

    log_header "Sync: Project -> Hub"
    log_info "Scanning project: $project_path"

    local hub_skills="$REPO_ROOT/BatutaClaude/skills"
    local new_skills=()

    # WHY scan both .agent/skills/ and .claude/skills/: projects may use
    # Antigravity (.agent/) or Claude Code (.claude/) or both. We want to
    # discover skills from either platform that aren't in the hub yet.
    local scan_dirs=(
        "$project_path/.agent/skills"
        "$project_path/.claude/skills"
    )

    for scan_dir in "${scan_dirs[@]}"; do
        if [[ ! -d "$scan_dir" ]]; then
            log_info "Directory not found (skipping): $scan_dir"
            continue
        fi

        log_info "Scanning: $scan_dir"

        for skill_dir in "$scan_dir"/*/; do
            [[ ! -d "$skill_dir" ]] && continue
            local skill_md="$skill_dir/SKILL.md"
            [[ ! -f "$skill_md" ]] && continue

            local skill_name
            skill_name=$(basename "$skill_dir")

            # Check if this skill already exists in the hub
            if [[ -d "$hub_skills/$skill_name" && -f "$hub_skills/$skill_name/SKILL.md" ]]; then
                log_info "  -> $skill_name already in hub (skipping)"
                continue
            fi

            new_skills+=("$skill_dir")
            log_info "  -> NEW: $skill_name (from $(basename "$(dirname "$scan_dir")")/skills/)"
        done
    done

    if [[ ${#new_skills[@]} -eq 0 ]]; then
        log_success "No new skills found in project. Hub is up to date."
        return 0
    fi

    echo ""
    log_info "Found ${#new_skills[@]} new skill(s) not in the hub:"
    echo ""

    for i in "${!new_skills[@]}"; do
        local skill_name
        skill_name=$(basename "${new_skills[$i]}")
        local skill_md="${new_skills[$i]}/SKILL.md"

        # Extract description from frontmatter for context
        local description=""
        if command -v sed &>/dev/null; then
            # WHY extract description: helps the user decide whether a
            # project-local skill is worth promoting to the ecosystem.
            description=$(sed -n '/^description:/,/^[a-z]/{ /^description:/s/^description: *//p; }' "$skill_md" 2>/dev/null | head -1)
        fi

        printf "  ${CYAN}%d)${NC} %s" "$((i + 1))" "$skill_name"
        if [[ -n "$description" ]]; then
            printf " — %s" "$description"
        fi
        echo ""
    done

    echo ""
    printf "Copy these skills to the hub? [y/N/numbers e.g. '1 3']: "
    read -r response

    if [[ -z "$response" || "$response" == "N" || "$response" == "n" ]]; then
        log_info "No skills imported."
        return 0
    fi

    local indices_to_copy=()

    if [[ "$response" == "y" || "$response" == "Y" || "$response" == "yes" ]]; then
        # Copy all
        for i in "${!new_skills[@]}"; do
            indices_to_copy+=("$i")
        done
    else
        # Parse specific numbers
        for num in $response; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [[ $num -ge 1 ]] && [[ $num -le ${#new_skills[@]} ]]; then
                indices_to_copy+=("$((num - 1))")
            else
                log_warning "Ignoring invalid selection: $num"
            fi
        done
    fi

    if [[ ${#indices_to_copy[@]} -eq 0 ]]; then
        log_info "No valid selections. No skills imported."
        return 0
    fi

    local copied=0
    for idx in "${indices_to_copy[@]}"; do
        local skill_dir="${new_skills[$idx]}"
        local skill_name
        skill_name=$(basename "$skill_dir")

        mkdir -p "$hub_skills/$skill_name"
        cp -f "$skill_dir/SKILL.md" "$hub_skills/$skill_name/SKILL.md"

        if [[ -d "$skill_dir/assets" ]]; then
            cp -rf "$skill_dir/assets" "$hub_skills/$skill_name/"
        fi

        log_success "  -> Imported $skill_name to BatutaClaude/skills/"
        copied=$((copied + 1))
    done

    echo ""
    log_success "Imported $copied skill(s) to the hub"
    log_info "Run './infra/setup.sh --all' to propagate to Claude Code"
    log_info "Run './infra/sync.sh --to-antigravity' to propagate to Antigravity"
}

# ============================================================================
# Sync All (both directions)
# ============================================================================
# WHY --all runs to-antigravity but requires --from-project for the
# reverse: syncing TO antigravity is safe (hub is source of truth).
# Syncing FROM a project is interactive and needs a specific path, so
# --all only handles the automated direction.

sync_all() {
    local project_path="$1"

    log_header "Batuta.Dots — Full Bidirectional Sync"

    sync_to_antigravity

    echo ""

    if [[ -n "$project_path" ]]; then
        sync_from_project "$project_path"
    else
        log_info "No --from-project path provided. Skipping project -> hub sync."
        log_info "To import project skills, run: ./infra/sync.sh --from-project <path>"
    fi

    echo ""
    log_success "Sync complete!"
}

# ============================================================================
# Help
# ============================================================================

show_help() {
    cat << 'EOF'
Batuta.Dots — Bidirectional Skill Sync
========================================

Syncs skills between the BatutaClaude hub (source of truth) and
BatutaAntigravity, and imports project-local skills back into the hub.

Usage: ./infra/sync.sh [OPTIONS]

Sync Directions:
  --to-antigravity          Hub -> BatutaAntigravity/skills/
                              Copies skills with 'platforms:.*antigravity'
                              from BatutaClaude/skills/ to BatutaAntigravity/skills/.

  --from-project PATH       Project -> Hub (interactive)
                              Scans .agent/skills/ and .claude/skills/ in the
                              given project for skills not present in BatutaClaude/skills/.
                              Lists new skills and asks which to import.

  --all [--from-project PATH]  Run both directions
                              Always runs --to-antigravity.
                              Runs --from-project only if PATH is provided.

  --help, -h                Show this help message

Skill Filtering:
  Only skills whose SKILL.md frontmatter contains 'platforms:.*antigravity'
  are synced to BatutaAntigravity. To mark a skill for cross-platform use:

    ---
    name: my-skill
    platforms: [claude, antigravity]
    ...
    ---

Examples:
  ./infra/sync.sh --to-antigravity                      # Hub -> Antigravity
  ./infra/sync.sh --from-project ~/my-app               # Import from project
  ./infra/sync.sh --all --from-project ~/my-app          # Both directions
  ./infra/sync.sh --all                                  # Hub -> Antigravity only

Related:
  ./infra/setup.sh                              # Claude Code setup
  ./BatutaAntigravity/setup-antigravity.sh      # Antigravity setup
  ./infra/replicate-platform.sh                 # Other platforms

Platform: Windows (Git Bash / MSYS2 / MINGW64) and native Unix
EOF
}

# ============================================================================
# CLI Argument Parsing
# ============================================================================

main() {
    cd "$REPO_ROOT"

    # WHY pre-resolve project path: same pattern as setup.sh. Relative paths
    # must be resolved before cd to REPO_ROOT, otherwise "." would point to
    # the repo root instead of the user's current directory.
    local resolved_project_path=""
    local has_from_project=false
    local action=""

    # Parse all arguments first
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --to-antigravity)
                action="to-antigravity"
                shift
                ;;
            --from-project)
                has_from_project=true
                shift
                if [[ -n "$1" && ! "$1" == --* ]]; then
                    local raw_path="$1"
                    if [[ ! "$raw_path" = /* && ! "$raw_path" =~ ^[A-Za-z]: ]]; then
                        resolved_project_path="$(pwd)/$raw_path"
                    else
                        resolved_project_path="$raw_path"
                    fi
                    shift
                else
                    log_error "--from-project requires a path argument"
                    exit 1
                fi
                # WHY set action only if not already set by --all:
                # --all + --from-project should run sync_all, not just from-project
                if [[ -z "$action" ]]; then
                    action="from-project"
                fi
                ;;
            --all)
                action="all"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo ""
                show_help
                exit 1
                ;;
        esac
    done

    if [[ -z "$action" ]]; then
        show_help
        exit 0
    fi

    case "$action" in
        to-antigravity)
            sync_to_antigravity
            ;;
        from-project)
            sync_from_project "$resolved_project_path"
            ;;
        all)
            sync_all "$resolved_project_path"
            ;;
    esac

    echo ""
    log_success "Done!"
}

main "$@"
