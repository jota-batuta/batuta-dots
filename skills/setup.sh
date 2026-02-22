#!/usr/bin/env bash
# ============================================================================
# Batuta.Dots — Claude Code Setup Script
# ============================================================================
# CLAUDE.md is the single entry point. Skills are lazy-loaded.
# This script copies CLAUDE.md to the project root and syncs skills.
#
# For other platforms (Gemini, Copilot, Codex, OpenCode), use:
#   ./skills/replicate-platform.sh --all
#
# Usage:
#   ./skills/setup.sh              # Interactive menu
#   ./skills/setup.sh --claude     # Copy CLAUDE.md to project root
#   ./skills/setup.sh --sync       # Sync skills to ~/.claude/skills/
#   ./skills/setup.sh --all        # Copy + Sync
#   ./skills/setup.sh --verify     # Verify setup
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
# Copy CLAUDE.md to project root
# ============================================================================

generate_claude() {
    local source_file="$REPO_ROOT/BatutaClaude/CLAUDE.md"
    local output_file="$REPO_ROOT/CLAUDE.md"

    log_info "Copying BatutaClaude/CLAUDE.md to project root"

    if [[ ! -f "$source_file" ]]; then
        log_error "BatutaClaude/CLAUDE.md not found at $source_file"
        return 1
    fi

    cp -f "$source_file" "$output_file"

    log_success "Created $output_file (direct copy from BatutaClaude/CLAUDE.md)"
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
# Sync Scope Agents to ~/.claude/agents/
# ============================================================================

sync_agents() {
    local agents_src="$REPO_ROOT/BatutaClaude/agents"
    local agents_dir="$HOME_DIR/.claude/agents"

    log_info "Syncing scope agents to ~/.claude/agents/ ..."

    if [[ ! -d "$agents_src" ]]; then
        log_warning "No agents directory found at $agents_src"
        return 0
    fi

    mkdir -p "$agents_dir"

    local agent_count=0
    for agent_file in "$agents_src"/*.md; do
        [[ ! -f "$agent_file" ]] && continue
        local agent_name
        agent_name=$(basename "$agent_file")
        cp -f "$agent_file" "$agents_dir/$agent_name"
        log_info "  -> Agent: $agent_name"
        agent_count=$((agent_count + 1))
    done

    if [[ $agent_count -gt 0 ]]; then
        log_success "Synced $agent_count agents to ~/.claude/agents/"
    else
        log_warning "No agent files found in $agents_src"
    fi
}

# ============================================================================
# Run Skill-Sync (regenerate routing tables)
# ============================================================================

run_skill_sync() {
    local sync_script="$REPO_ROOT/BatutaClaude/skills/skill-sync/assets/sync.sh"

    log_info "Running skill-sync to regenerate routing tables..."

    if [[ -f "$sync_script" ]]; then
        bash "$sync_script" || log_warning "skill-sync had warnings (check output above)"
        log_success "Routing tables regenerated"
    else
        log_warning "skill-sync script not found at $sync_script"
    fi
}

# ============================================================================
# All: Copy + Sync
# ============================================================================

do_all() {
    log_header "Batuta.Dots — Full Setup (Claude Code)"

    # Order matters:
    # 1. Sync skills, agents, commands to ~/.claude/
    # 2. Run skill-sync to regenerate tables in BatutaClaude/ (source of truth)
    # 3. Copy updated BatutaClaude/CLAUDE.md to project root (now with updated tables)

    sync_claude
    echo ""
    sync_agents
    echo ""
    run_skill_sync
    echo ""
    generate_claude

    echo ""
    log_success "Claude Code fully configured!"
}

# ============================================================================
# Verify
# ============================================================================

verify() {
    log_header "Verifying Claude Code Setup"

    local errors=0

    # Check BatutaClaude/CLAUDE.md (source)
    local source_file="$REPO_ROOT/BatutaClaude/CLAUDE.md"
    if [[ ! -f "$source_file" ]]; then
        log_error "BatutaClaude/CLAUDE.md not found — this is the source file"
        errors=$((errors + 1))
    else
        log_success "BatutaClaude/CLAUDE.md exists (source)"
    fi

    # Check root CLAUDE.md (copy)
    local claude_file="$REPO_ROOT/CLAUDE.md"
    if [[ ! -f "$claude_file" ]]; then
        log_warning "CLAUDE.md does not exist at root (run --claude or --all first)"
        errors=$((errors + 1))
    else
        log_success "CLAUDE.md exists at root"

        if grep -q "Personality" "$claude_file" 2>/dev/null; then
            log_success "CLAUDE.md includes personality content"
        else
            log_error "CLAUDE.md is missing personality content"
            errors=$((errors + 1))
        fi

        if grep -q "Scope Rule" "$claude_file" 2>/dev/null; then
            log_success "CLAUDE.md includes Scope Rule"
        else
            log_error "CLAUDE.md is missing Scope Rule"
            errors=$((errors + 1))
        fi

        if grep -q "Skill Gap Detection" "$claude_file" 2>/dev/null; then
            log_success "CLAUDE.md includes Skill Gap Detection"
        else
            log_error "CLAUDE.md is missing Skill Gap Detection"
            errors=$((errors + 1))
        fi
    fi

    # Check AGENTS.md is gone
    if [[ -f "$REPO_ROOT/AGENTS.md" ]]; then
        log_warning "AGENTS.md still exists — it should have been removed (v3 refactor)"
    else
        log_success "AGENTS.md removed (CLAUDE.md is the single entry point)"
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

    # Check agents sync (v5)
    local claude_agents="$HOME_DIR/.claude/agents"
    if [[ -d "$claude_agents" ]]; then
        local agent_count=0
        for f in "$claude_agents"/*.md; do
            [[ -f "$f" ]] && agent_count=$((agent_count + 1))
        done
        if [[ $agent_count -gt 0 ]]; then
            log_success "$agent_count scope agents synced to ~/.claude/agents/"
        else
            log_warning "~/.claude/agents/ exists but no agents found"
        fi
    else
        log_warning "~/.claude/agents/ does not exist (run --all to sync)"
    fi

    # Check scope agents exist in source (v5)
    local agents_src="$REPO_ROOT/BatutaClaude/agents"
    if [[ -d "$agents_src" ]]; then
        local src_agent_count=0
        for f in "$agents_src"/*.md; do
            [[ -f "$f" ]] && src_agent_count=$((src_agent_count + 1))
        done
        log_success "$src_agent_count scope agents in BatutaClaude/agents/"
    else
        log_warning "BatutaClaude/agents/ directory not found"
    fi

    # Check skill-sync tables present (v5)
    if grep -q "AUTO-GENERATED by skill-sync" "$REPO_ROOT/BatutaClaude/CLAUDE.md" 2>/dev/null; then
        log_success "skill-sync tables present in CLAUDE.md"
    else
        log_warning "skill-sync tables not found in CLAUDE.md — run: ./skills/setup.sh --all"
    fi

    # Check Execution Gate (v5)
    if grep -q "Execution Gate" "$claude_file" 2>/dev/null; then
        log_success "Execution Gate present in CLAUDE.md"
    else
        log_warning "Execution Gate not found in CLAUDE.md"
    fi

    # Check Scope Routing Table (v5)
    if grep -q "Scope Routing Table" "$claude_file" 2>/dev/null; then
        log_success "Scope Routing Table present in CLAUDE.md"
    else
        log_warning "Scope Routing Table not found in CLAUDE.md"
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
    echo "CLAUDE.md is the single entry point. Skills are lazy-loaded."
    echo ""
    printf "  ${CYAN}1)${NC} Copy CLAUDE.md to project root\n"
    printf "  ${CYAN}2)${NC} Sync skills + agents to ~/.claude/\n"
    printf "  ${CYAN}3)${NC} Full setup (sync + skill-sync + copy)\n"
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
        2) sync_claude; sync_agents ;;
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
CLAUDE.md is the single entry point. Skills are lazy-loaded on demand.

Usage: ./skills/setup.sh [OPTIONS]

Options:
  --claude      Copy BatutaClaude/CLAUDE.md to project root
                  This is the file Claude Code reads automatically.
                  It contains personality, rules, and skill routing.
  --sync        Sync skills, agents, and commands to ~/.claude/
                  Copies all SKILL.md files, assets, scope agents,
                  and slash commands so Claude Code can route and load.
  --all         Full setup: sync + skill-sync + copy CLAUDE.md (recommended)
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
