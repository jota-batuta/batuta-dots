#!/usr/bin/env bash
# ============================================================================
# Batuta.Dots — One-Liner Installer
# ============================================================================
# Installs Batuta ecosystem without leaving a permanent clone.
#
# For PRIVATE repos (recommended):
#   git clone --depth 1 https://github.com/jota-batuta/batuta-dots.git /tmp/batuta-install && bash /tmp/batuta-install/infra/install.sh && rm -rf /tmp/batuta-install
#
# For PUBLIC repos (curl one-liner):
#   bash <(curl -fsSL https://raw.githubusercontent.com/jota-batuta/batuta-dots/master/infra/install.sh)
#
# Non-interactive:
#   bash /tmp/batuta-install/infra/install.sh --claude
#   bash /tmp/batuta-install/infra/install.sh --antigravity
#   bash /tmp/batuta-install/infra/install.sh --both
#
# Platform: Windows (WSL / Git Bash / MSYS2) and native Unix
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
# Detect Repo Location
# ============================================================================
# The script can run in two modes:
#   1. FROM A CLONE: user ran "git clone ... /tmp/X && bash /tmp/X/infra/install.sh"
#      → REPO_DIR is detected from the script's own location
#      → No temp dir needed, no cleanup (user manages the clone)
#   2. VIA CURL: user ran "bash <(curl ...)"
#      → Script is piped, no file location to detect
#      → Must clone to a temp dir and clean up after

REPO_DIR=""
NEEDS_CLEANUP=false

detect_or_clone_repo() {
    # Try to detect if this script lives inside a batuta-dots clone
    local script_dir
    if [[ -n "${BASH_SOURCE[0]}" && "${BASH_SOURCE[0]}" != "bash" && -f "${BASH_SOURCE[0]}" ]]; then
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        local candidate="$(cd "$script_dir/.." 2>/dev/null && pwd)"

        if [[ -d "$candidate/BatutaClaude" && -d "$candidate/infra" ]]; then
            REPO_DIR="$candidate"
            log_info "Detected batuta-dots at: $REPO_DIR"
            return 0
        fi
    fi

    # Not running from inside a clone — need to clone
    log_info "Cloning batuta-dots to temporary directory..."

    local tmp_dir
    tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/batuta-dots-install-XXXXXX")"
    NEEDS_CLEANUP=true

    if ! git clone --depth 1 https://github.com/jota-batuta/batuta-dots.git "$tmp_dir/batuta-dots" 2>&1; then
        log_error "Failed to clone batuta-dots."
        log_info "If the repo is private, clone it first:"
        log_info "  git clone --depth 1 https://github.com/jota-batuta/batuta-dots.git /tmp/batuta-install"
        log_info "  bash /tmp/batuta-install/infra/install.sh"
        log_info "  rm -rf /tmp/batuta-install"
        rm -rf "$tmp_dir"
        exit 1
    fi

    REPO_DIR="$tmp_dir/batuta-dots"
    INSTALL_TEMP_DIR="$tmp_dir"
    log_success "Repository cloned."
}

cleanup() {
    if [[ "$NEEDS_CLEANUP" == true && -n "$INSTALL_TEMP_DIR" && -d "$INSTALL_TEMP_DIR" ]]; then
        log_info "Cleaning up temporary directory..."
        rm -rf "$INSTALL_TEMP_DIR"
    fi
}
trap cleanup EXIT INT TERM

# ============================================================================
# Platform Selection (interactive)
# ============================================================================

select_platform() {
    log_header "Batuta.Dots — Installer"

    echo "Which platform do you want to install?"
    echo ""
    printf "  ${CYAN}1)${NC} BatutaClaude  — Claude Code (skills, agents, commands, hooks)\n"
    printf "  ${CYAN}2)${NC} BatutaAntigravity — Antigravity IDE (skills, workflows)\n"
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

    # 1. Global install: skills, agents, commands, hooks, output-styles → ~/.claude/
    bash "$REPO_DIR/infra/setup.sh" --all

    # 2. Setup caller's current directory as a Batuta project
    log_info "Setting up current directory as Batuta project: $CALLER_DIR"
    bash "$REPO_DIR/infra/setup.sh" --project "$CALLER_DIR"
}

# ============================================================================
# Install Antigravity
# ============================================================================

install_antigravity() {
    log_header "Installing BatutaAntigravity (Antigravity IDE)"

    # Global + workspace install
    bash "$REPO_DIR/BatutaAntigravity/setup-antigravity.sh" --all
}

# ============================================================================
# Help
# ============================================================================

show_help() {
    cat << 'EOF'
Batuta.Dots — Installer
=========================

Installs the Batuta ecosystem without leaving a permanent clone.

Usage (private repo — recommended):
  git clone --depth 1 https://github.com/jota-batuta/batuta-dots.git /tmp/batuta-install
  bash /tmp/batuta-install/infra/install.sh
  rm -rf /tmp/batuta-install

Usage (public repo):
  bash <(curl -fsSL https://raw.githubusercontent.com/jota-batuta/batuta-dots/master/infra/install.sh)

Options:
  --claude        Install BatutaClaude (Claude Code) only
  --antigravity   Install BatutaAntigravity (Antigravity IDE) only
  --both          Install both platforms
  --help, -h      Show this help message

What gets installed:
  Claude Code     → ~/.claude/ (skills, agents, commands, hooks, output-styles, settings.json)
                  → Current directory gets CLAUDE.md + .batuta/
  Antigravity     → ~/.gemini/antigravity/ (skills, workflows, GEMINI.md)

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
    detect_or_clone_repo

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

    if [[ "$NEEDS_CLEANUP" == true ]]; then
        log_info "Temporary files cleaned up automatically."
    fi

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
