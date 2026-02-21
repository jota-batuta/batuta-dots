#!/usr/bin/env bash
# ============================================================================
# Batuta.Dots — Claude Code Setup Script
# ============================================================================
# This script manages AGENTS.md → CLAUDE.md generation and skill syncing
# for Claude Code. This is the ONLY AI tool managed by this script.
#
# For other platforms (Gemini, Copilot, Codex, OpenCode), use:
#   ./skills/replicate-platform.sh --all
#
# Usage:
#   ./skills/setup.sh              # Interactive menu
#   ./skills/setup.sh --claude     # Generate CLAUDE.md
#   ./skills/setup.sh --sync       # Sync skills to ~/.claude/skills/
#   ./skills/setup.sh --all        # Generate + Sync
#   ./skills/setup.sh --verify     # Verify generated files
#   ./skills/setup.sh --help       # Show this help
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
# Generate CLAUDE.md
# ============================================================================

generate_claude() {
    local agents_file="$REPO_ROOT/AGENTS.md"
    local personality_file="$REPO_ROOT/BatutaClaude/CLAUDE.md"
    local output_file="$REPO_ROOT/CLAUDE.md"

    log_info "Generating CLAUDE.md from BatutaClaude/CLAUDE.md + AGENTS.md"

    if [[ ! -f "$agents_file" ]]; then
        log_error "AGENTS.md not found at $agents_file"
        return 1
    fi

    cat > "$output_file" << 'HEADER'
# Claude Code Instructions

> **Auto-generated from AGENTS.md** - Do not edit directly.
> Run `./skills/setup.sh --claude` to regenerate.

HEADER

    if [[ -f "$personality_file" ]]; then
        cat "$personality_file" >> "$output_file"
        printf "\n\n---\n\n" >> "$output_file"
        log_info "  Included BatutaClaude/CLAUDE.md personality"
    else
        log_warning "  BatutaClaude/CLAUDE.md not found, skipping personality header"
    fi

    cat "$agents_file" >> "$output_file"

    log_success "Created $output_file"
}

# ============================================================================
# Sync Skills to ~/.claude/skills/
# ============================================================================

sync_claude() {
    local claude_dir="$HOME_DIR/.claude/skills"
    local skills_src="$REPO_ROOT/BatutaClaude/skills"

    log_info "Syncing skills to ~/.claude/skills/ ..."

    if [[ ! -d "$skills_src" ]]; then
        log_error "Source skills directory not found: $skills_src"
        return 1
    fi

    mkdir -p "$claude_dir"

    local count=0
    for skill_dir in "$skills_src"/*/; do
        [[ ! -d "$skill_dir" ]] && continue
        local skill_name
        skill_name=$(basename "$skill_dir")

        if [[ -f "$skill_dir/SKILL.md" ]]; then
            mkdir -p "$claude_dir/$skill_name"

            local dest_file="$claude_dir/$skill_name/SKILL.md"
            if [[ -f "$dest_file" ]]; then
                chmod u+w "$dest_file" 2>/dev/null || true
            fi
            cp -f "$skill_dir/SKILL.md" "$dest_file"

            if [[ -d "$skill_dir/assets" ]]; then
                chmod -R u+w "$claude_dir/$skill_name/assets" 2>/dev/null || true
                cp -rf "$skill_dir/assets" "$claude_dir/$skill_name/"
            fi

            log_info "  -> Copied $skill_name"
            count=$((count + 1))
        fi
    done

    if [[ $count -eq 0 ]]; then
        log_warning "No skills found in $skills_src"
    else
        log_success "Synced $count skills to ~/.claude/skills/"
    fi

    # Sync commands (slash commands)
    local commands_src="$REPO_ROOT/BatutaClaude/commands"
    local commands_dir="$HOME_DIR/.claude/commands"

    if [[ -d "$commands_src" ]]; then
        mkdir -p "$commands_dir"
        local cmd_count=0
        for cmd_file in "$commands_src"/*.md; do
            [[ ! -f "$cmd_file" ]] && continue
            local cmd_name=$(basename "$cmd_file")
            cp -f "$cmd_file" "$commands_dir/$cmd_name"
            log_info "  -> Command: $cmd_name"
            cmd_count=$((cmd_count + 1))
        done
        if [[ $cmd_count -gt 0 ]]; then
            log_success "Synced $cmd_count commands to ~/.claude/commands/"
        fi
    fi
}

# ============================================================================
# All: Generate + Sync
# ============================================================================

do_all() {
    log_header "Batuta.Dots — Full Setup (Claude Code)"

    generate_claude
    echo ""
    sync_claude

    echo ""
    log_success "Claude Code fully configured!"
}

# ============================================================================
# Verify
# ============================================================================

verify() {
    log_header "Verifying Claude Code Setup"

    local agents_file="$REPO_ROOT/AGENTS.md"
    local errors=0

    if [[ ! -f "$agents_file" ]]; then
        log_error "AGENTS.md not found - cannot verify"
        return 1
    fi

    local check_string="Single Source of Truth"
    local claude_file="$REPO_ROOT/CLAUDE.md"

    # Check CLAUDE.md
    if [[ ! -f "$claude_file" ]]; then
        log_warning "CLAUDE.md does not exist (run --claude or --all first)"
        errors=$((errors + 1))
    else
        if grep -q "Auto-generated from AGENTS.md" "$claude_file" 2>/dev/null; then
            log_success "CLAUDE.md has auto-generation header"
        else
            log_error "CLAUDE.md is missing auto-generation header"
            errors=$((errors + 1))
        fi

        if grep -q "$check_string" "$claude_file" 2>/dev/null; then
            log_success "CLAUDE.md contains AGENTS.md content"
        else
            log_error "CLAUDE.md does not contain AGENTS.md content"
            errors=$((errors + 1))
        fi

        if grep -q "Personality" "$claude_file" 2>/dev/null || \
           grep -q "Rules" "$claude_file" 2>/dev/null; then
            log_success "CLAUDE.md includes personality content"
        else
            log_warning "CLAUDE.md may be missing personality content"
        fi
    fi

    # Check skills sync
    local claude_skills="$HOME_DIR/.claude/skills"
    if [[ -d "$claude_skills" ]]; then
        local skill_count=0
        for d in "$claude_skills"/*/; do
            [[ -d "$d" ]] && skill_count=$((skill_count + 1))
        done
        if [[ $skill_count -gt 0 ]]; then
            log_success "$skill_count skills synced to ~/.claude/skills/"
        else
            log_warning "~/.claude/skills/ exists but no skills found"
        fi
    else
        log_warning "~/.claude/skills/ does not exist (run --sync or --all first)"
    fi

    # Check scope-rule skill
    if [[ -f "$REPO_ROOT/BatutaClaude/skills/scope-rule/SKILL.md" ]]; then
        log_success "scope-rule skill present"
    else
        log_error "scope-rule skill missing"
        errors=$((errors + 1))
    fi

    echo ""
    if [[ $errors -eq 0 ]]; then
        log_success "All verifications passed!"
    else
        log_error "$errors verification(s) failed"
        return 1
    fi
}

# ============================================================================
# Interactive Menu
# ============================================================================

show_menu() {
    log_header "Batuta.Dots — Claude Code Setup"

    echo "This script configures Claude Code with the Batuta ecosystem."
    echo "AGENTS.md is the single source of truth."
    echo ""
    printf "  ${CYAN}1)${NC} Generate CLAUDE.md (personality + AGENTS.md)\n"
    printf "  ${CYAN}2)${NC} Sync skills to ~/.claude/skills/\n"
    printf "  ${CYAN}3)${NC} Both (generate + sync)\n"
    printf "  ${CYAN}4)${NC} Verify setup\n"
    printf "  ${CYAN}5)${NC} Help\n"
    printf "  ${CYAN}0)${NC} Exit\n"
    echo ""
    echo "  Need other platforms? Run: ./skills/replicate-platform.sh --help"
    echo ""
    printf "Enter choice [0-5]: "
}

handle_menu_choice() {
    case "$1" in
        1) generate_claude ;;
        2) sync_claude ;;
        3) do_all ;;
        4) verify ;;
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
Batuta.Dots — Claude Code Setup
=================================

Configures Claude Code with the Batuta AI ecosystem.
AGENTS.md is the single source of truth.

Usage: ./skills/setup.sh [OPTIONS]

Options:
  --claude      Generate CLAUDE.md
                  Combines BatutaClaude/CLAUDE.md personality header
                  with AGENTS.md content into a single root CLAUDE.md
  --sync        Sync skills to ~/.claude/skills/
                  Copies all SKILL.md files and assets so Claude Code
                  can auto-load them based on context detection
  --all         Generate CLAUDE.md + sync skills (recommended)
  --verify      Check that CLAUDE.md and skills are properly configured
  --help, -h    Show this help message

Interactive Mode:
  Run without arguments for a numbered menu

Other Platforms:
  To replicate to Gemini, Copilot, Codex, or OpenCode:
  ./skills/replicate-platform.sh --all

Examples:
  ./skills/setup.sh --all          # Full setup (recommended)
  ./skills/setup.sh --verify       # Check everything is correct
  ./skills/setup.sh                # Interactive menu

Platform: Windows (Git Bash / MSYS2 / MINGW64) and native Unix
EOF
}

# ============================================================================
# CLI Argument Parsing
# ============================================================================

parse_args() {
    case "$1" in
        --claude)   generate_claude ;;
        --sync)     sync_claude ;;
        --all)      do_all ;;
        --verify)   verify ;;
        --help|-h)  show_help; exit 0 ;;
        # Legacy flags — redirect to replicate-platform.sh
        --gemini|--copilot|--codex|--sync-opencode|--sync-all)
            log_warning "Multi-platform flags moved to replicate-platform.sh"
            log_info "Run: ./skills/replicate-platform.sh $1"
            exit 0
            ;;
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
        interactive_menu
    else
        parse_args "$@"
    fi

    echo ""
    log_success "Done!"
}

main "$@"
