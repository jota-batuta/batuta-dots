#!/usr/bin/env bash
# ============================================================================
# Batuta.Dots — One-Liner Installer
# ============================================================================
# Installs Batuta ecosystem without leaving a permanent clone.
# Clones to a temp directory, installs the chosen platform, cleans up.
#
# Usage (curl):
#   bash <(curl -fsSL https://raw.githubusercontent.com/jota-batuta/batuta-dots/main/infra/install.sh)
#
# Usage (wget):
#   bash <(wget -qO- https://raw.githubusercontent.com/jota-batuta/batuta-dots/main/infra/install.sh)
#
# Non-interactive:
#   bash <(curl -fsSL URL) --claude        # Claude Code only
#   bash <(curl -fsSL URL) --antigravity   # Antigravity (Gemini CLI) only
#   bash <(curl -fsSL URL) --both          # Both platforms
#
# Windows (Git Bash):
#   curl -fsSL URL -o /tmp/batuta-install.sh && bash /tmp/batuta-install.sh
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

# ============================================================================
# Prerequisites
# ============================================================================

check_prerequisites() {
    if ! command -v git &>/dev/null; then
        log_error "git is required but not found. Please install git first."
        exit 1
    fi
}

# ============================================================================
# Temp Directory + Cleanup
# ============================================================================

INSTALL_DIR=""

cleanup() {
    if [[ -n "$INSTALL_DIR" && -d "$INSTALL_DIR" ]]; then
        log_info "Cleaning up temporary directory..."
        rm -rf "$INSTALL_DIR"
    fi
}
trap cleanup EXIT INT TERM

create_temp_dir() {
    INSTALL_DIR="$(mktemp -d "${TMPDIR:-/tmp}/batuta-dots-install-XXXXXX")"
    log_info "Using temporary directory: $INSTALL_DIR"
}

# ============================================================================
# Clone Repository
# ============================================================================

clone_repo() {
    log_info "Cloning batuta-dots (shallow)..."
    if ! git clone --depth 1 https://github.com/jota-batuta/batuta-dots.git "$INSTALL_DIR/batuta-dots" 2>&1; then
        log_error "Failed to clone batuta-dots repository."
        log_info "Check your internet connection and try again."
        exit 1
    fi
    log_success "Repository cloned."
}

# ============================================================================
# Platform Selection (interactive)
# ============================================================================

select_platform() {
    log_header "Batuta.Dots — Installer"

    echo "Which platform do you want to install?"
    echo ""
    printf "  ${CYAN}1)${NC} BatutaClaude  — Claude Code (skills, agents, commands, hooks)\n"
    printf "  ${CYAN}2)${NC} BatutaAntigravity — Gemini CLI (skills, workflows)\n"
    printf "  ${CYAN}3)${NC} Both platforms\n"
    printf "  ${CYAN}0)${NC} Cancel\n"
    echo ""
    printf "Enter choice [0-3]: "
    read -r choice

    case "$choice" in
        1) PLATFORM="claude" ;;
        2) PLATFORM="antigravity" ;;
        3) PLATFORM="both" ;;
        0) log_info "Installation cancelled."; exit 0 ;;
        *)
            log_error "Invalid choice: $choice"
            exit 1
            ;;
    esac
}

# ============================================================================
# Install Claude Code
# ============================================================================

install_claude() {
    log_header "Installing BatutaClaude (Claude Code)"

    local repo_dir="$INSTALL_DIR/batuta-dots"

    # 1. Global install: skills, agents, commands, hooks, output-styles → ~/.claude/
    bash "$repo_dir/infra/setup.sh" --all

    # 2. Setup caller's current directory as a Batuta project
    log_info "Setting up current directory as Batuta project: $CALLER_DIR"
    bash "$repo_dir/infra/setup.sh" --project "$CALLER_DIR"
}

# ============================================================================
# Install Antigravity (Gemini CLI)
# ============================================================================

install_antigravity() {
    log_header "Installing BatutaAntigravity (Gemini CLI)"

    local repo_dir="$INSTALL_DIR/batuta-dots"

    # Global + workspace install
    bash "$repo_dir/BatutaAntigravity/setup-antigravity.sh" --all
}

# ============================================================================
# Help
# ============================================================================

show_help() {
    cat << 'EOF'
Batuta.Dots — One-Liner Installer
===================================

Installs the Batuta ecosystem without leaving a permanent clone.

Usage:
  bash <(curl -fsSL https://raw.githubusercontent.com/jota-batuta/batuta-dots/main/infra/install.sh)

Options:
  --claude        Install BatutaClaude (Claude Code) only
  --antigravity   Install BatutaAntigravity (Gemini CLI) only
  --both          Install both platforms
  --help, -h      Show this help message

What gets installed:
  Claude Code     → ~/.claude/ (skills, agents, commands, hooks, output-styles, settings.json)
                  → Current directory gets CLAUDE.md + .batuta/
  Antigravity     → ~/.gemini/antigravity/ (skills, workflows, GEMINI.md)

Windows (Git Bash):
  curl -fsSL URL -o /tmp/batuta-install.sh && bash /tmp/batuta-install.sh

After installation:
  Open Claude Code in your project and run /sdd-init to get started.
EOF
}

# ============================================================================
# Main
# ============================================================================

main() {
    # Save the caller's working directory BEFORE any cd operations
    CALLER_DIR="$(pwd)"

    local platform_arg=""

    # Parse CLI arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --claude)       platform_arg="claude"; shift ;;
            --antigravity)  platform_arg="antigravity"; shift ;;
            --both|--all)   platform_arg="both"; shift ;;
            --help|-h)      show_help; exit 0 ;;
            *)
                log_error "Unknown option: $1"
                echo ""
                show_help
                exit 1
                ;;
        esac
    done

    check_prerequisites
    create_temp_dir
    clone_repo

    if [[ -n "$platform_arg" ]]; then
        PLATFORM="$platform_arg"
    else
        select_platform
    fi

    case "$PLATFORM" in
        claude)
            install_claude
            ;;
        antigravity)
            install_antigravity
            ;;
        both)
            install_claude
            echo ""
            install_antigravity
            ;;
    esac

    echo ""
    log_success "Installation complete!"
    log_info "Temporary files cleaned up automatically."

    case "$PLATFORM" in
        claude|both)
            echo ""
            log_info "Your project at $CALLER_DIR is ready."
            log_info "Open Claude Code and run /sdd-init to get started."
            ;;
        antigravity)
            echo ""
            log_info "Open Antigravity in your project and start working."
            ;;
    esac
}

main "$@"
