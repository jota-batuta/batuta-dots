#!/usr/bin/env bash
# ============================================================================
# Batuta.Dots — Platform Replication Script
# ============================================================================
# This script generates instruction files for OTHER AI coding assistants
# from CLAUDE.md. Use this when you want to extend batuta-dots beyond
# Claude Code to Gemini, Copilot, Codex, or OpenCode.
#
# The main setup.sh is Claude-only. This script is the bridge to
# replicate what you build in Claude Code to any other platform.
#
# Usage:
#   ./infra/replicate-platform.sh --gemini     # Generate GEMINI.md
#   ./infra/replicate-platform.sh --copilot    # Generate .github/copilot-instructions.md
#   ./infra/replicate-platform.sh --codex      # Generate CODEX.md
#   ./infra/replicate-platform.sh --opencode   # Sync to OpenCode config
#   ./infra/replicate-platform.sh --all        # All of the above
#   ./infra/replicate-platform.sh --help       # Show help
#
# Platform: Windows (Git Bash / MSYS2 / MINGW) and native Unix
# ============================================================================

set -euo pipefail

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
# Path Resolution
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
# Generation Functions
# ============================================================================

generate_gemini() {
    local agents_file="$REPO_ROOT/CLAUDE.md"
    local output_file="$REPO_ROOT/GEMINI.md"

    log_info "Generating GEMINI.md from CLAUDE.md"

    if [[ ! -f "$agents_file" ]]; then
        log_error "CLAUDE.md not found at $agents_file"
        return 1
    fi

    cat > "$output_file" << 'HEADER'
# Gemini CLI Instructions

> **Auto-generated from CLAUDE.md** - Do not edit directly.
> Run `./infra/replicate-platform.sh --gemini` to regenerate.

HEADER

    cat "$agents_file" >> "$output_file"
    log_success "Created $output_file"
}

generate_codex() {
    local agents_file="$REPO_ROOT/CLAUDE.md"
    local output_file="$REPO_ROOT/CODEX.md"

    log_info "Generating CODEX.md from CLAUDE.md"

    if [[ ! -f "$agents_file" ]]; then
        log_error "CLAUDE.md not found at $agents_file"
        return 1
    fi

    cat > "$output_file" << 'HEADER'
# OpenAI Codex Instructions

> **Auto-generated from CLAUDE.md** - Do not edit directly.
> Run `./infra/replicate-platform.sh --codex` to regenerate.

HEADER

    cat "$agents_file" >> "$output_file"
    log_success "Created $output_file"
}

generate_copilot() {
    local agents_file="$REPO_ROOT/CLAUDE.md"
    local copilot_dir="$REPO_ROOT/.github"
    local output_file="$copilot_dir/copilot-instructions.md"

    log_info "Generating .github/copilot-instructions.md from CLAUDE.md"

    if [[ ! -f "$agents_file" ]]; then
        log_error "CLAUDE.md not found at $agents_file"
        return 1
    fi

    mkdir -p "$copilot_dir"

    cat > "$output_file" << 'HEADER'
# GitHub Copilot Instructions

> **Auto-generated from CLAUDE.md** - Do not edit directly.
> Run `./infra/replicate-platform.sh --copilot` to regenerate.

HEADER

    cat "$agents_file" >> "$output_file"
    log_success "Created $output_file"
}

sync_opencode() {
    local opencode_user_dir="$HOME_DIR/.config/opencode/skill"
    local skills_src="$REPO_ROOT/BatutaClaude/skills"

    log_info "Syncing skills to OpenCode config..."

    if [[ ! -d "$skills_src" ]]; then
        log_error "Source skills directory not found: $skills_src"
        return 1
    fi

    mkdir -p "$opencode_user_dir"

    if [[ -f "$REPO_ROOT/CLAUDE.md" ]]; then
        cp "$REPO_ROOT/CLAUDE.md" "$opencode_user_dir/CLAUDE.md"
        log_info "  -> Copied CLAUDE.md to OpenCode user config"
    fi

    local count=0
    for skill_dir in "$skills_src"/*/; do
        [[ ! -d "$skill_dir" ]] && continue
        local skill_name
        skill_name=$(basename "$skill_dir")

        if [[ -f "$skill_dir/SKILL.md" ]]; then
            mkdir -p "$opencode_user_dir/$skill_name"
            cp -f "$skill_dir/SKILL.md" "$opencode_user_dir/$skill_name/SKILL.md"

            if [[ -d "$skill_dir/assets" ]]; then
                cp -rf "$skill_dir/assets" "$opencode_user_dir/$skill_name/"
            fi

            log_info "  -> Copied $skill_name"
            count=$((count + 1))
        fi
    done

    if [[ $count -eq 0 ]]; then
        log_warning "No skills found in $skills_src"
    else
        log_success "Synced $count skills to OpenCode (~/.config/opencode/)"
    fi
}

sync_antigravity() {
    log_info "Syncing Antigravity via infra/sync.sh --to-antigravity"

    local sync_script="$REPO_ROOT/infra/sync.sh"
    if [[ -f "$sync_script" ]]; then
        bash "$sync_script" --to-antigravity
    else
        log_error "infra/sync.sh not found. Run from batuta-dots root."
        return 1
    fi
}

generate_all() {
    log_header "Replicating to All Platforms"

    generate_gemini
    generate_codex
    generate_copilot
    sync_opencode
    echo ""
    sync_antigravity

    echo ""
    log_success "All platforms replicated!"
}

# ============================================================================
# Help
# ============================================================================

show_help() {
    cat << 'EOF'
Batuta.Dots — Platform Replication Script
==========================================

Replicates CLAUDE.md and skills to non-Claude AI coding assistants.
The main setup.sh is Claude-only. Use this script to extend to other platforms.

Usage: ./infra/replicate-platform.sh [OPTIONS]

Generation Options:
  --gemini        Generate GEMINI.md from CLAUDE.md (deprecated — use --antigravity)
  --antigravity   Sync Antigravity-compatible skills to BatutaAntigravity/
                    Uses dedicated GEMINI.md with full CTO brain adapted for Antigravity.
  --copilot       Generate .github/copilot-instructions.md from CLAUDE.md
  --codex         Generate CODEX.md from CLAUDE.md
  --opencode      Sync skills to OpenCode config (~/.config/opencode/)
  --all           Generate all of the above at once
  --help, -h      Show this help message

Examples:
  ./infra/replicate-platform.sh --antigravity  # Antigravity (recommended)
  ./infra/replicate-platform.sh --all          # Everything
EOF
}

# ============================================================================
# CLI Argument Parsing
# ============================================================================

parse_args() {
    case "$1" in
        --gemini)
            log_warning "--gemini is deprecated. GEMINI.md for Gemini CLI is a verbatim copy."
            log_info "For Antigravity, use --antigravity (dedicated GEMINI.md + filtered skills)."
            generate_gemini
            ;;
        --antigravity) sync_antigravity ;;
        --copilot)   generate_copilot ;;
        --codex)     generate_codex ;;
        --opencode)  sync_opencode ;;
        --all)       generate_all ;;
        --help|-h)   show_help; exit 0 ;;
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
    cd "$REPO_ROOT"

    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi

    parse_args "$@"
    echo ""
    log_success "Done!"
}

main "$@"
