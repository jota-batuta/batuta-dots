#!/usr/bin/env bash
# ============================================================================
# Batuta.Dots AI Skills Setup Script
# ============================================================================
# This script synchronizes AGENTS.md to tool-specific instruction files.
# AGENTS.md is the single source of truth - edits propagate to all tools.
#
# For Claude specifically, CLAUDE.md personality (BatutaClaude/CLAUDE.md) is
# prepended as a header, then AGENTS.md content is appended.
#
# Usage:
#   ./skills/setup.sh              # Interactive menu
#   ./skills/setup.sh --all        # Generate all formats
#   ./skills/setup.sh --claude     # Generate CLAUDE.md only
#   ./skills/setup.sh --gemini     # Generate GEMINI.md only
#   ./skills/setup.sh --copilot    # Generate .github/copilot-instructions.md
#   ./skills/setup.sh --codex      # Generate CODEX.md only
#   ./skills/setup.sh --sync-claude   # Sync skills to ~/.claude/skills/
#   ./skills/setup.sh --sync-opencode # Sync skills to OpenCode config
#   ./skills/setup.sh --sync-all      # Sync to all user configs
#   ./skills/setup.sh --verify     # Verify generated files
#   ./skills/setup.sh --help       # Show this help
#
# Platform: Designed for Windows (Git Bash / MSYS2 / MINGW) and native Unix
# ============================================================================

set -e

# ============================================================================
# Colors
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# ============================================================================
# Path Resolution (Windows / Git Bash / MSYS / native Unix)
# ============================================================================

resolve_home() {
    # On MINGW/MSYS (Git Bash for Windows), $HOME usually points to
    # /c/Users/<name> which is fine, but some tools expect the Windows path.
    # We normalise to the Git-Bash-style path so mkdir / cp work correctly.
    if [[ -n "$USERPROFILE" && ("$OSTYPE" == msys* || "$OSTYPE" == mingw* || "$OSTYPE" == cygwin*) ]]; then
        # Convert Windows backslashes to forward slashes for bash
        local win_home
        win_home=$(echo "$USERPROFILE" | sed 's|\\|/|g')
        # If it starts with a drive letter like C:, convert to /c
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

# Script directory resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ============================================================================
# Utility Functions
# ============================================================================

log_info() {
    printf "${CYAN}[INFO]${NC} %s\n" "$1"
}

log_success() {
    printf "${GREEN}[OK]${NC} %s\n" "$1"
}

log_warning() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

log_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

log_header() {
    printf "\n${CYAN}${BOLD}================================================================${NC}\n"
    printf "${CYAN}${BOLD}  %s${NC}\n" "$1"
    printf "${CYAN}${BOLD}================================================================${NC}\n\n"
}

# ============================================================================
# Generation Functions
# ============================================================================

# Generate CLAUDE.md from BatutaClaude/CLAUDE.md personality + AGENTS.md content
generate_claude() {
    local agents_file="$REPO_ROOT/AGENTS.md"
    local personality_file="$REPO_ROOT/BatutaClaude/CLAUDE.md"
    local output_file="$REPO_ROOT/CLAUDE.md"

    log_info "Generating CLAUDE.md from BatutaClaude/CLAUDE.md + AGENTS.md"

    if [[ ! -f "$agents_file" ]]; then
        log_error "AGENTS.md not found at $agents_file"
        return 1
    fi

    # Start with auto-generation header
    cat > "$output_file" << 'HEADER'
# Claude Code Instructions

> **Auto-generated from AGENTS.md** - Do not edit directly.
> Run `./skills/setup.sh --claude` to regenerate.

HEADER

    # If personality file exists, prepend it
    if [[ -f "$personality_file" ]]; then
        cat "$personality_file" >> "$output_file"
        printf "\n\n---\n\n" >> "$output_file"
        log_info "  Included BatutaClaude/CLAUDE.md personality"
    else
        log_warning "  BatutaClaude/CLAUDE.md not found, skipping personality header"
    fi

    # Append AGENTS.md content
    cat "$agents_file" >> "$output_file"

    log_success "Created $output_file"
}

# Generate GEMINI.md from AGENTS.md
generate_gemini() {
    local agents_file="$REPO_ROOT/AGENTS.md"
    local output_file="$REPO_ROOT/GEMINI.md"

    log_info "Generating GEMINI.md from AGENTS.md"

    if [[ ! -f "$agents_file" ]]; then
        log_error "AGENTS.md not found at $agents_file"
        return 1
    fi

    cat > "$output_file" << 'HEADER'
# Gemini CLI Instructions

> **Auto-generated from AGENTS.md** - Do not edit directly.
> Run `./skills/setup.sh --gemini` to regenerate.

HEADER

    cat "$agents_file" >> "$output_file"

    log_success "Created $output_file"
}

# Generate CODEX.md from AGENTS.md
generate_codex() {
    local agents_file="$REPO_ROOT/AGENTS.md"
    local output_file="$REPO_ROOT/CODEX.md"

    log_info "Generating CODEX.md from AGENTS.md"

    if [[ ! -f "$agents_file" ]]; then
        log_error "AGENTS.md not found at $agents_file"
        return 1
    fi

    cat > "$output_file" << 'HEADER'
# OpenAI Codex Instructions

> **Auto-generated from AGENTS.md** - Do not edit directly.
> Run `./skills/setup.sh --codex` to regenerate.

HEADER

    cat "$agents_file" >> "$output_file"

    log_success "Created $output_file"
}

# Generate .github/copilot-instructions.md from AGENTS.md
generate_copilot() {
    local agents_file="$REPO_ROOT/AGENTS.md"
    local copilot_dir="$REPO_ROOT/.github"
    local output_file="$copilot_dir/copilot-instructions.md"

    log_info "Generating .github/copilot-instructions.md from AGENTS.md"

    if [[ ! -f "$agents_file" ]]; then
        log_error "AGENTS.md not found at $agents_file"
        return 1
    fi

    mkdir -p "$copilot_dir"

    cat > "$output_file" << 'HEADER'
# GitHub Copilot Instructions

> **Auto-generated from AGENTS.md** - Do not edit directly.
> Run `./skills/setup.sh --copilot` to regenerate.

HEADER

    cat "$agents_file" >> "$output_file"

    log_success "Created $output_file"
}

# Generate all formats from AGENTS.md
generate_all() {
    log_header "Generating All Formats"

    generate_claude
    generate_gemini
    generate_codex
    generate_copilot

    echo ""
    log_success "All formats generated!"
}

# ============================================================================
# Sync Functions
# ============================================================================

# Sync BatutaClaude/skills/* to ~/.claude/skills/
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

            # Remove existing file if read-only, then copy
            local dest_file="$claude_dir/$skill_name/SKILL.md"
            if [[ -f "$dest_file" ]]; then
                chmod u+w "$dest_file" 2>/dev/null || true
            fi
            cp -f "$skill_dir/SKILL.md" "$dest_file"

            # Copy assets if they exist
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
}

# Sync BatutaClaude/skills/* to BatutaOpenCode/skill/ AND ~/.config/opencode/skill/
sync_opencode() {
    local opencode_user_dir="$HOME_DIR/.config/opencode/skill"
    local opencode_repo_dir="$REPO_ROOT/BatutaOpenCode/skill"
    local skills_src="$REPO_ROOT/BatutaClaude/skills"

    log_info "Syncing skills to OpenCode config..."

    if [[ ! -d "$skills_src" ]]; then
        log_error "Source skills directory not found: $skills_src"
        return 1
    fi

    # Create both target directories
    mkdir -p "$opencode_user_dir"
    mkdir -p "$opencode_repo_dir"

    # Copy AGENTS.md as the main instruction file to both locations
    if [[ -f "$REPO_ROOT/AGENTS.md" ]]; then
        cp "$REPO_ROOT/AGENTS.md" "$opencode_user_dir/AGENTS.md"
        cp "$REPO_ROOT/AGENTS.md" "$opencode_repo_dir/AGENTS.md"
        log_info "  -> Copied AGENTS.md to OpenCode (user + repo)"
    fi

    # Copy individual skills to both locations
    local count=0
    for skill_dir in "$skills_src"/*/; do
        [[ ! -d "$skill_dir" ]] && continue
        local skill_name
        skill_name=$(basename "$skill_dir")

        if [[ -f "$skill_dir/SKILL.md" ]]; then
            # User config
            mkdir -p "$opencode_user_dir/$skill_name"
            cp -f "$skill_dir/SKILL.md" "$opencode_user_dir/$skill_name/SKILL.md"

            # Repo-local
            mkdir -p "$opencode_repo_dir/$skill_name"
            cp -f "$skill_dir/SKILL.md" "$opencode_repo_dir/$skill_name/SKILL.md"

            # Copy assets if they exist
            if [[ -d "$skill_dir/assets" ]]; then
                cp -rf "$skill_dir/assets" "$opencode_user_dir/$skill_name/"
                cp -rf "$skill_dir/assets" "$opencode_repo_dir/$skill_name/"
            fi

            log_info "  -> Copied $skill_name"
            count=$((count + 1))
        fi
    done

    if [[ $count -eq 0 ]]; then
        log_warning "No skills found in $skills_src"
    else
        log_success "Synced $count skills to OpenCode (user config + BatutaOpenCode/)"
    fi
}

# Sync to all user configs (Claude + OpenCode)
sync_all() {
    log_header "Syncing to All User Configs"

    sync_claude
    echo ""
    sync_opencode

    echo ""
    log_success "All syncs complete!"
}

# ============================================================================
# Verify Function
# ============================================================================

verify() {
    log_header "Verifying Generated Files"

    local agents_file="$REPO_ROOT/AGENTS.md"
    local errors=0

    if [[ ! -f "$agents_file" ]]; then
        log_error "AGENTS.md not found - cannot verify"
        return 1
    fi

    # Extract a recognizable line from AGENTS.md to check presence in generated files
    # Use the first heading or the "Single Source of Truth" line
    local check_string="Single Source of Truth"

    # Check each generated file
    local files_to_check=(
        "$REPO_ROOT/CLAUDE.md"
        "$REPO_ROOT/GEMINI.md"
        "$REPO_ROOT/CODEX.md"
        "$REPO_ROOT/.github/copilot-instructions.md"
    )
    local labels=(
        "CLAUDE.md"
        "GEMINI.md"
        "CODEX.md"
        ".github/copilot-instructions.md"
    )

    for i in "${!files_to_check[@]}"; do
        local file="${files_to_check[$i]}"
        local label="${labels[$i]}"

        if [[ ! -f "$file" ]]; then
            log_warning "$label does not exist (run --all first)"
            errors=$((errors + 1))
            continue
        fi

        if grep -q "Auto-generated from AGENTS.md" "$file" 2>/dev/null; then
            log_success "$label has auto-generation header"
        else
            log_error "$label is missing auto-generation header"
            errors=$((errors + 1))
        fi

        if grep -q "$check_string" "$file" 2>/dev/null; then
            log_success "$label contains AGENTS.md content"
        else
            log_error "$label does not contain AGENTS.md content"
            errors=$((errors + 1))
        fi
    done

    # Specific check: CLAUDE.md should contain personality from BatutaClaude/CLAUDE.md
    if [[ -f "$REPO_ROOT/CLAUDE.md" && -f "$REPO_ROOT/BatutaClaude/CLAUDE.md" ]]; then
        if grep -q "Personality" "$REPO_ROOT/CLAUDE.md" 2>/dev/null || \
           grep -q "Rules" "$REPO_ROOT/CLAUDE.md" 2>/dev/null; then
            log_success "CLAUDE.md includes personality content"
        else
            log_warning "CLAUDE.md may be missing personality content from BatutaClaude/CLAUDE.md"
        fi
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
    log_header "Batuta.Dots AI Skills Setup"

    echo "This script synchronizes AGENTS.md to tool-specific formats."
    echo "AGENTS.md is the single source of truth for all AI assistants."
    echo ""
    echo "Generate instruction files:"
    echo ""
    printf "  ${CYAN}1)${NC} Claude Code      (CLAUDE.md — includes personality from BatutaClaude/CLAUDE.md)\n"
    printf "  ${CYAN}2)${NC} Gemini CLI       (GEMINI.md)\n"
    printf "  ${CYAN}3)${NC} GitHub Copilot   (.github/copilot-instructions.md)\n"
    printf "  ${CYAN}4)${NC} OpenAI Codex     (CODEX.md)\n"
    printf "  ${CYAN}5)${NC} All of the above\n"
    echo ""
    echo "Sync skills to user config:"
    echo ""
    printf "  ${CYAN}6)${NC} Sync to ~/.claude/skills/\n"
    printf "  ${CYAN}7)${NC} Sync to OpenCode config (BatutaOpenCode/ + ~/.config/opencode/)\n"
    printf "  ${CYAN}8)${NC} Sync to all user configs\n"
    echo ""
    echo "Utilities:"
    echo ""
    printf "  ${CYAN}9)${NC}  Verify generated files\n"
    printf "  ${CYAN}10)${NC} Show help\n"
    echo ""
    printf "  ${CYAN}0)${NC}  Exit\n"
    echo ""
    printf "Enter choice [0-10]: "
}

handle_menu_choice() {
    local choice="$1"

    case $choice in
        1)  generate_claude ;;
        2)  generate_gemini ;;
        3)  generate_copilot ;;
        4)  generate_codex ;;
        5)  generate_all ;;
        6)  sync_claude ;;
        7)  sync_opencode ;;
        8)  sync_all ;;
        9)  verify ;;
        10) show_help ;;
        0)
            log_info "Exiting..."
            exit 0
            ;;
        *)
            log_error "Invalid choice: $choice"
            return 1
            ;;
    esac
}

interactive_menu() {
    show_menu
    read -r choice
    handle_menu_choice "$choice"
}

# ============================================================================
# CLI Argument Parsing
# ============================================================================

show_help() {
    cat << 'EOF'
Batuta.Dots AI Skills Setup
============================

Synchronizes AGENTS.md (the single source of truth) to tool-specific
instruction files for Claude, Gemini, Copilot, and Codex.

Usage: ./skills/setup.sh [OPTIONS]

Generation Options:
  --claude      Generate CLAUDE.md
                  Combines BatutaClaude/CLAUDE.md personality header
                  with AGENTS.md content into a single root CLAUDE.md
  --gemini      Generate GEMINI.md from AGENTS.md
  --copilot     Generate .github/copilot-instructions.md from AGENTS.md
  --codex       Generate CODEX.md from AGENTS.md
  --all         Generate all of the above at once

Sync Options:
  --sync-claude   Copy BatutaClaude/skills/* to ~/.claude/skills/
                    Installs all SKILL.md files and assets so Claude Code
                    can auto-load them based on context detection
  --sync-opencode Copy BatutaClaude/skills/* to:
                    - BatutaOpenCode/skill/  (repo-local)
                    - ~/.config/opencode/skill/  (user config)
  --sync-all      Run both --sync-claude and --sync-opencode

Utility Options:
  --verify      Check that generated files contain AGENTS.md content
                  Validates headers and content presence
  --help, -h    Show this help message

Interactive Mode:
  Run without arguments for a numbered menu (options 1-10 + exit)

Platform Support:
  Designed for Windows (Git Bash / MSYS2 / MINGW64) and native Unix.
  Automatically detects and normalises home directory paths.

Examples:
  ./skills/setup.sh              # Interactive menu
  ./skills/setup.sh --all        # Generate all formats
  ./skills/setup.sh --claude     # Claude Code only
  ./skills/setup.sh --sync-all   # Sync skills to user configs
  ./skills/setup.sh --verify     # Check everything looks right

  # Typical full workflow:
  ./skills/setup.sh --all && ./skills/setup.sh --sync-all && ./skills/setup.sh --verify
EOF
}

parse_args() {
    case "$1" in
        --claude)       generate_claude ;;
        --gemini)       generate_gemini ;;
        --copilot)      generate_copilot ;;
        --codex)        generate_codex ;;
        --all)          generate_all ;;
        --sync-claude)  sync_claude ;;
        --sync-opencode) sync_opencode ;;
        --sync-all)     sync_all ;;
        --verify)       verify ;;
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
