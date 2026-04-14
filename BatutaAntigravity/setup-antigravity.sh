#!/usr/bin/env bash
# ============================================================================
# Batuta.Dots — Antigravity Setup Script
# ============================================================================
# Sets up the Batuta ecosystem for Google's Antigravity IDE.
# Copies GEMINI.md and syncs cross-platform skills that declare
# `platforms:.*antigravity` in their SKILL.md frontmatter.
#
# WHY this exists as a separate script from infra/setup.sh:
#   Antigravity has a different directory structure (~/.gemini/ for global,
#   .agent/skills/ for workspace) and different entry-point file (GEMINI.md).
#   Keeping it separate avoids bloating the Claude setup script with
#   conditional logic for every platform.
#
# IMPORTANT: This script distinguishes between two directories:
#   REPO_ROOT   — where batuta-dots lives (source of skills and GEMINI.md)
#   PROJECT_DIR — the user's project (target for workspace installs)
#   These are NEVER the same directory (unless running inside batuta-dots itself).
#
# Usage:
#   ./BatutaAntigravity/setup-antigravity.sh                    # Interactive menu
#   ./BatutaAntigravity/setup-antigravity.sh --global           # Skills + GEMINI.md to ~/.gemini/
#   ./BatutaAntigravity/setup-antigravity.sh --workspace        # Skills + GEMINI.md to project (cwd)
#   ./BatutaAntigravity/setup-antigravity.sh --all              # Global + workspace (cwd)
#   ./BatutaAntigravity/setup-antigravity.sh --update <path>    # Full refresh for existing project
#   ./BatutaAntigravity/setup-antigravity.sh --help             # Show help
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

# ============================================================================
# Detect batuta-dots location
# ============================================================================
# WHY three fallback locations: Users may clone batuta-dots to ~/batuta-dots
# (recommended), /tmp/batuta-dots (ephemeral/CI), or this script may be run
# from within the repo itself. We check all three before giving up.

detect_repo_root() {
    # 1. If this script lives inside the repo, use that
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local candidate="$(cd "$script_dir/.." && pwd)"
    if [[ -d "$candidate/BatutaAntigravity" && -d "$candidate/BatutaClaude" ]]; then
        echo "$candidate"
        return 0
    fi

    # 2. Check ~/batuta-dots
    if [[ -d "$HOME_DIR/batuta-dots/BatutaAntigravity" ]]; then
        echo "$HOME_DIR/batuta-dots"
        return 0
    fi

    # 3. Check /tmp/batuta-dots (CI / ephemeral)
    if [[ -d "/tmp/batuta-dots/BatutaAntigravity" ]]; then
        echo "/tmp/batuta-dots"
        return 0
    fi

    # 4. Clone from GitHub as last resort
    log_warning "batuta-dots not found locally. Cloning from GitHub..."
    if command -v git &>/dev/null; then
        git clone --depth 1 https://github.com/jota-batuta/batuta-dots.git "$HOME_DIR/batuta-dots" 2>/dev/null || {
            log_error "Failed to clone batuta-dots. Please clone manually to ~/batuta-dots"
            return 1
        }
        echo "$HOME_DIR/batuta-dots"
        return 0
    else
        log_error "git not found and batuta-dots not in ~/batuta-dots or /tmp/batuta-dots"
        return 1
    fi
}

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
# Copy GEMINI.md to global location (~/.gemini/GEMINI.md)
# ============================================================================
# WHY global: Antigravity reads GEMINI.md from ~/.gemini/GEMINI.md as its
# system-level instructions. Without this, the agent has no Batuta personality.

copy_gemini_md_global() {
    # BUSINESS RULE: BatutaAntigravity/GEMINI.md is the tracked canonical source
    # (root GEMINI.md is gitignored — symmetric with Claude side's BatutaClaude/CLAUDE.md).
    local source_file="$REPO_ROOT/BatutaAntigravity/GEMINI.md"
    local global_dir="$HOME_DIR/.gemini"
    local output_file="$global_dir/GEMINI.md"

    log_info "Copying GEMINI.md to ~/.gemini/GEMINI.md (global)"

    if [[ ! -f "$source_file" ]]; then
        log_error "BatutaAntigravity/GEMINI.md not found at $source_file"
        return 1
    fi

    mkdir -p "$global_dir"
    cp -f "$source_file" "$output_file"
    log_success "Created $output_file"
}

# ============================================================================
# Copy GEMINI.md to project root
# ============================================================================
# WHY project-level: project GEMINI.md can override the global one with
# project-specific instructions. Both are useful.

copy_gemini_md_project() {
    # BUSINESS RULE: BatutaAntigravity/GEMINI.md is the tracked canonical source.
    local source_file="$REPO_ROOT/BatutaAntigravity/GEMINI.md"
    local output_file="$PROJECT_DIR/GEMINI.md"
    local override_file="$PROJECT_DIR/.gemini/GEMINI.md"

    log_info "Copying GEMINI.md to project root (hub layer)"

    if [[ ! -f "$source_file" ]]; then
        log_error "BatutaAntigravity/GEMINI.md not found at $source_file"
        return 1
    fi

    # WHY two-layer config: root GEMINI.md = hub layer (overwritten on update),
    # .gemini/GEMINI.md = project layer (never touched by setup).
    # Gemini reads both; project layer takes precedence.
    if [[ -f "$output_file" ]] && grep -q "^## Project Customizations" "$output_file" 2>/dev/null; then
        if [[ ! -f "$override_file" ]]; then
            mkdir -p "$PROJECT_DIR/.gemini"
            sed -n '/^## Project Customizations/,$p' "$output_file" > "$override_file"
            log_success "Migrated project customizations to .gemini/GEMINI.md"
        fi
    fi

    cp -f "$source_file" "$output_file"
    log_success "Created $output_file (hub layer)"
}

# ============================================================================
# Filter skills by platform: antigravity
# ============================================================================
# WHY grep frontmatter instead of a config file: SKILL.md is the single source
# of truth for each skill's metadata. A separate registry would drift out of
# sync. Scanning frontmatter keeps the skill self-describing.

get_antigravity_skills() {
    local skills_dir="$1"
    local matched_skills=()

    for skill_dir in "$skills_dir"/*/; do
        [[ ! -d "$skill_dir" ]] && continue
        local skill_md="$skill_dir/SKILL.md"
        [[ ! -f "$skill_md" ]] && continue

        # Check if SKILL.md frontmatter declares antigravity as a platform
        if grep -q "platforms:.*antigravity" "$skill_md" 2>/dev/null; then
            matched_skills+=("$skill_dir")
        fi
    done

    # WHY printf instead of echo: handles skill names with spaces or special
    # characters safely, and produces one-per-line output for the caller.
    printf '%s\n' "${matched_skills[@]}"
}

# ============================================================================
# Install skills to a target directory
# ============================================================================

install_skills_to() {
    local target_dir="$1"
    local label="$2"
    local skills_src="$REPO_ROOT/BatutaClaude/skills"

    log_info "Syncing antigravity-compatible skills to $label ($target_dir)"

    if [[ ! -d "$skills_src" ]]; then
        log_error "Source skills directory not found: $skills_src"
        return 1
    fi

    mkdir -p "$target_dir"

    local count=0
    for skill_dir in "$skills_src"/*/; do
        [[ ! -d "$skill_dir" ]] && continue
        local skill_md="$skill_dir/SKILL.md"
        [[ ! -f "$skill_md" ]] && continue

        # Only copy skills that declare antigravity platform support
        if ! grep -q "platforms:.*antigravity" "$skill_md" 2>/dev/null; then
            continue
        fi

        local skill_name
        skill_name=$(basename "$skill_dir")

        mkdir -p "$target_dir/$skill_name"

        # Copy SKILL.md (ensure writable in case of previous read-only copy)
        local dest_file="$target_dir/$skill_name/SKILL.md"
        if [[ -f "$dest_file" ]]; then
            chmod u+w "$dest_file" 2>/dev/null || true
        fi
        cp -f "$skill_md" "$dest_file"

        # Copy assets directory if it exists
        if [[ -d "$skill_dir/assets" ]]; then
            chmod -R u+w "$target_dir/$skill_name/assets" 2>/dev/null || true
            cp -rf "$skill_dir/assets" "$target_dir/$skill_name/"
        fi

        log_info "  -> Copied $skill_name"
        count=$((count + 1))
    done

    # Also copy any skills already in BatutaAntigravity/skills/ (platform-native)
    local antigravity_skills="$REPO_ROOT/BatutaAntigravity/skills"
    if [[ -d "$antigravity_skills" ]]; then
        for skill_dir in "$antigravity_skills"/*/; do
            [[ ! -d "$skill_dir" ]] && continue
            local skill_name
            skill_name=$(basename "$skill_dir")

            # WHY skip duplicates: if a skill was already copied from BatutaClaude,
            # the BatutaClaude version is canonical. Antigravity-native skills only
            # get copied if they don't exist in the hub.
            if [[ -d "$target_dir/$skill_name" ]]; then
                log_info "  -> Skipping $skill_name (already copied from hub)"
                continue
            fi

            if [[ -f "$skill_dir/SKILL.md" ]]; then
                mkdir -p "$target_dir/$skill_name"
                cp -f "$skill_dir/SKILL.md" "$target_dir/$skill_name/SKILL.md"
                if [[ -d "$skill_dir/assets" ]]; then
                    cp -rf "$skill_dir/assets" "$target_dir/$skill_name/"
                fi
                log_info "  -> Copied $skill_name (antigravity-native)"
                count=$((count + 1))
            fi
        done
    fi

    if [[ $count -eq 0 ]]; then
        log_warning "No antigravity-compatible skills found"
        log_info "Skills need 'platforms:.*antigravity' in their SKILL.md frontmatter"
    else
        log_success "Synced $count skills to $label"
    fi
}

# ============================================================================
# Install to global (~/.gemini/)
# ============================================================================
# WHY GEMINI.md + skills together: the global install must include the entry
# point (GEMINI.md) alongside the skills it references. Installing skills
# without the entry point leaves Antigravity without Batuta instructions.

install_global() {
    copy_gemini_md_global
    local global_dir="$HOME_DIR/.gemini/antigravity/skills"
    install_skills_to "$global_dir" "~/.gemini/antigravity/skills/ (global)"
}

# ============================================================================
# Install to workspace (PROJECT_DIR/.agent/skills/)
# ============================================================================
# WHY PROJECT_DIR not REPO_ROOT: workspace skills belong in the user's project,
# not inside batuta-dots. REPO_ROOT is the source, PROJECT_DIR is the target.

install_workspace() {
    copy_gemini_md_project
    local workspace_dir="$PROJECT_DIR/.agent/skills"
    install_skills_to "$workspace_dir" ".agent/skills/ (workspace)"
}

# ============================================================================
# Create .batuta/ directory with session template and ecosystem config
# ============================================================================
# WHY .batuta/ in the project root: this is the Batuta ecosystem's local state
# directory, shared across all platforms (Claude, Antigravity, Copilot). It
# holds session continuity data and ecosystem metadata.

create_batuta_dir() {
    local batuta_dir="$PROJECT_DIR/.batuta"
    mkdir -p "$batuta_dir"

    # Session template
    if [[ ! -f "$batuta_dir/session.md" ]]; then
        local project_name
        project_name=$(basename "$PROJECT_DIR")
        cat > "$batuta_dir/session.md" << SESSIONEOF
# Session — $project_name

## Project
- **Name**: $project_name
- **Type**: (pending detection)
- **Description**: (pending)
- **Status**: New project
- **Platform**: Antigravity

## Current State
- SDD Phase: not started
- No active changes

## Decisions
- (none yet)

## Conventions
- Scope Rule enforced (features/{name}/{type}/)
- SDD pipeline mandatory for all new features

## Next Steps
- Run /sdd-init to detect project type and bootstrap SDD
SESSIONEOF
        log_success "Created $batuta_dir/session.md"
    else
        log_info "session.md already exists, skipping"
    fi

    # Ecosystem config
    if [[ ! -f "$batuta_dir/ecosystem.json" ]]; then
        cat > "$batuta_dir/ecosystem.json" << 'ECOEOF'
{
  "platform": "antigravity",
  "version": "1.0",
  "hub": "batuta-dots",
  "skills_source": "BatutaClaude/skills",
  "entry_point": "GEMINI.md",
  "sync": {
    "filter": "platforms:.*antigravity",
    "global_target": "~/.gemini/antigravity/skills/",
    "workspace_target": ".agent/skills/"
  }
}
ECOEOF
        log_success "Created $batuta_dir/ecosystem.json"
    else
        log_info "ecosystem.json already exists, skipping"
    fi
}

# ============================================================================
# All: Global + Workspace + .batuta/
# ============================================================================

do_all() {
    log_header "Batuta.Dots — Full Antigravity Setup"
    log_info "Source: $REPO_ROOT"
    log_info "Project: $PROJECT_DIR"

    # WHY this order: global first (entry point + skills available everywhere),
    # then workspace (project-local overrides), then .batuta/ (local state).
    install_global
    echo ""
    install_workspace
    echo ""
    create_batuta_dir

    echo ""
    log_success "Antigravity fully configured!"
    log_info "Next: open Antigravity in your project and start with /sdd-init"
}

# ============================================================================
# Update: Global + Project in one shot (--update <path>)
# ============================================================================
# WHY: Running --global + --workspace separately is high friction.
# This combines all steps so /batuta-update and manual updates are one command.
# Unlike --all, --update always overwrites GEMINI.md and skills (no skip).

update_all() {
    log_header "Batuta.Dots — Antigravity Update"
    log_info "Source: $REPO_ROOT"
    log_info "Project: $PROJECT_DIR"

    # 1. Global refresh
    install_global
    echo ""

    # 2. Project refresh
    install_workspace
    echo ""

    # 3. Ensure .batuta/ exists (creates only if missing)
    create_batuta_dir

    echo ""
    log_success "Antigravity updated!"
}

# ============================================================================
# Interactive Menu
# ============================================================================

show_menu() {
    log_header "Batuta.Dots — Antigravity Setup"

    echo "This script configures Antigravity IDE with the Batuta ecosystem."
    echo "GEMINI.md is the entry point. Skills are filtered by platform compatibility."
    echo ""
    echo "  Source:  $REPO_ROOT"
    echo "  Project: $PROJECT_DIR"
    echo ""
    printf "  ${CYAN}1)${NC} Install globally (GEMINI.md + skills to ~/.gemini/)\n"
    printf "  ${CYAN}2)${NC} Install to workspace (GEMINI.md + skills to project)\n"
    printf "  ${CYAN}3)${NC} Full setup (global + workspace + .batuta/)\n"
    printf "  ${CYAN}4)${NC} Create .batuta/ directory only\n"
    printf "  ${CYAN}5)${NC} Help\n"
    printf "  ${CYAN}0)${NC} Exit\n"
    echo ""
    printf "Enter choice [0-5]: "
}

handle_menu_choice() {
    case "$1" in
        1) install_global ;;
        2) install_workspace ;;
        3) do_all ;;
        4) create_batuta_dir ;;
        5) show_help ;;
        0) log_info "Exiting..."; exit 0 ;;
        *) log_error "Invalid choice: $1"; return 1 ;;
    esac
}

interactive_menu() {
    show_menu
    read -r choice
    handle_menu_choice "$choice"
}

# ============================================================================
# Help
# ============================================================================

show_help() {
    cat << 'EOF'
Batuta.Dots — Antigravity Setup
================================

Configures Antigravity IDE with the Batuta AI ecosystem.
GEMINI.md is the entry point. Skills are filtered by platform compatibility.

Usage: ./BatutaAntigravity/setup-antigravity.sh [OPTIONS]

Options:
  --global      Install GEMINI.md + skills to ~/.gemini/ (global)
                  Available across all Antigravity projects.
                  Only skills with 'platforms:.*antigravity' in SKILL.md are copied.
  --workspace   Install GEMINI.md + skills to current directory (project-local)
                  Skills go to .agent/skills/ (committed to repo).
  --all         Full setup: global + workspace + .batuta/
                  Recommended for first-time setup. Uses cwd as project.
  --update <path>
                  Full refresh: global + workspace + .batuta/ for an existing
                  project. Overwrites GEMINI.md and skills with latest versions.
  --help, -h    Show this help message

Interactive Mode:
  Run without arguments for a numbered menu

Skill Filtering:
  Only skills whose SKILL.md frontmatter contains 'platforms:.*antigravity'
  are copied. To make a skill available in Antigravity, add to its frontmatter:
    platforms: [claude, antigravity]

Examples:
  cd /my/project
  ./BatutaAntigravity/setup-antigravity.sh --all              # Full first-time setup
  ./BatutaAntigravity/setup-antigravity.sh --global           # Global only
  ./BatutaAntigravity/setup-antigravity.sh --workspace        # Project only
  ./BatutaAntigravity/setup-antigravity.sh --update /my/app   # Update existing project

Related:
  ./infra/setup.sh                    # Claude Code setup
  ./infra/replicate-platform.sh       # Other platforms (Copilot, Codex, OpenCode)
  ./infra/sync.sh                     # Bidirectional skill sync

Platform: Windows (Git Bash / MSYS2 / MINGW64) and native Unix
EOF
}

# ============================================================================
# CLI Argument Parsing
# ============================================================================

parse_args() {
    case "$1" in
        --global)     install_global ;;
        --workspace)  install_workspace ;;
        --all)        do_all ;;
        --update)
            # PROJECT_DIR already resolved in main()
            update_all
            ;;
        --help|-h)    show_help; exit 0 ;;
        *)
            log_error "Unknown option: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# ============================================================================
# Main
# ============================================================================

main() {
    # IMPORTANT: Save caller's directory BEFORE detecting repo root.
    # CALLER_DIR is where the user ran the script from (their project).
    # REPO_ROOT is where batuta-dots lives (the source of skills/GEMINI.md).
    # These are different directories and must not be confused.
    CALLER_DIR="$(pwd)"

    REPO_ROOT="$(detect_repo_root)" || {
        log_error "Could not locate batuta-dots repository"
        exit 1
    }

    # Resolve PROJECT_DIR from arguments before cd
    # WHY resolve before cd: relative paths like "." or "../my-app" must be
    # resolved against CALLER_DIR, not REPO_ROOT.
    PROJECT_DIR="$CALLER_DIR"
    if [[ "$1" == "--update" && -n "$2" ]]; then
        local raw_path="$2"
        if [[ "$raw_path" = /* || "$raw_path" =~ ^[A-Za-z]: ]]; then
            # Absolute path — use as-is
            PROJECT_DIR="$raw_path"
        else
            # Relative path — resolve against caller's directory
            PROJECT_DIR="$(cd "$CALLER_DIR" && cd "$raw_path" && pwd)"
        fi
    fi

    cd "$REPO_ROOT"
    log_info "Using batuta-dots at: $REPO_ROOT"

    if [[ $# -eq 0 ]]; then
        interactive_menu
    else
        parse_args "$@"
    fi

    echo ""
    log_success "Done!"
}

main "$@"
