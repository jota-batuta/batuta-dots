#!/usr/bin/env bash
# ============================================================================
# Batuta.Dots — Claude Code Setup Script
# ============================================================================
# CLAUDE.md is the single entry point. Skills are lazy-loaded.
# This script copies CLAUDE.md to the project root and syncs skills.
#
# For other platforms (Gemini, Copilot, Codex, OpenCode), use:
#   ./infra/replicate-platform.sh --all
#
# Usage:
#   ./infra/setup.sh              # Interactive menu
#   ./infra/setup.sh --claude     # Copy CLAUDE.md to project root
#   ./infra/setup.sh --sync       # Sync skills to ~/.claude/skills/
#   ./infra/setup.sh --all        # Copy + Sync + Hooks
#   ./infra/setup.sh --hooks      # Install hooks + permissions to ~/.claude/settings.json
#   ./infra/setup.sh --project <path>  # Setup a target project (CLAUDE.md + .batuta/ + git + hooks)
#   ./infra/setup.sh --verify     # Verify setup
#   ./infra/setup.sh --help       # Show this help
#
# Platform: Windows (Git Bash / MSYS2 / MINGW) and native Unix
# ============================================================================

set -e

cleanup() {
    rm -f "${REPO_ROOT:-/tmp}/BatutaClaude/CLAUDE.md.tmp" 2>/dev/null
    rm -f "${REPO_ROOT:-/tmp}/BatutaClaude/agents/"*.tmp 2>/dev/null
}
trap cleanup EXIT

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
# Setup target project (--project <path>)
# ============================================================================

setup_project() {
    local target_dir="$1"

    if [[ -z "$target_dir" ]]; then
        log_error "--project requires a target directory path"
        return 1
    fi

    # Resolve relative paths (fallback — main() should have pre-resolved)
    if [[ ! "$target_dir" = /* && ! "$target_dir" =~ ^[A-Za-z]: ]]; then
        log_warning "Path not pre-resolved, using current dir: $(pwd)"
        target_dir="$(pwd)/$target_dir"
    fi

    # Normalize trailing slashes and /. patterns
    target_dir="${target_dir%/}"
    target_dir="${target_dir%/.}"

    if [[ ! -d "$target_dir" ]]; then
        log_error "Target directory does not exist: $target_dir"
        return 1
    fi

    log_header "Batuta.Dots — Project Setup: $target_dir"

    local source_file="$REPO_ROOT/BatutaClaude/CLAUDE.md"

    # 1. Copy CLAUDE.md to target project root
    if [[ -f "$source_file" ]]; then
        cp -f "$source_file" "$target_dir/CLAUDE.md"
        log_success "Copied CLAUDE.md to $target_dir/CLAUDE.md"
    else
        log_error "BatutaClaude/CLAUDE.md not found"
        return 1
    fi

    # 2. Create .batuta/ directory with session.md and prompt-log.jsonl
    local batuta_dir="$target_dir/.batuta"
    mkdir -p "$batuta_dir"

    if [[ ! -f "$batuta_dir/session.md" ]]; then
        local project_name
        project_name=$(basename "$target_dir")
        cat > "$batuta_dir/session.md" << SESSIONEOF
# Session — $project_name

## Project
- **Name**: $project_name
- **Type**: (pending detection)
- **Description**: (pending)
- **Status**: New project

## Current State
- SDD Phase: not started
- No active changes

## Decisions
- (none yet)

## Conventions
- Scope Rule enforced (features/{name}/{type}/)
- SDD pipeline mandatory for all new features

## Next Steps
- Run /sdd:init to detect project type and bootstrap SDD
SESSIONEOF
        log_success "Created $batuta_dir/session.md"
    else
        log_info "session.md already exists, skipping"
    fi

    if [[ ! -f "$batuta_dir/prompt-log.jsonl" ]]; then
        touch "$batuta_dir/prompt-log.jsonl"
        log_success "Created $batuta_dir/prompt-log.jsonl"
    else
        log_info "prompt-log.jsonl already exists, skipping"
    fi

    # 3. Initialize git if not already a repo
    if [[ ! -d "$target_dir/.git" ]]; then
        (cd "$target_dir" && git init -q)
        log_success "Initialized git repository in $target_dir"
    else
        log_info "Git repository already exists, skipping"
    fi

    # 4. Create .gitignore if not exists
    if [[ ! -f "$target_dir/.gitignore" ]]; then
        cat > "$target_dir/.gitignore" << 'IGNOREEOF'
node_modules/
.next/
dist/
.env
.env.local
.env.*.local
*.log
IGNOREEOF
        log_success "Created .gitignore"
    fi

    # 5. Install hooks + permissions to ~/.claude/settings.json
    echo ""
    install_hooks

    echo ""
    log_success "Project setup complete at $target_dir"
    log_info "Next: open Claude Code in $target_dir and run /sdd:init"
}

# ============================================================================
# Install Hooks + Permissions to ~/.claude/settings.json
# ============================================================================

install_hooks() {
    local source_settings="$REPO_ROOT/BatutaClaude/settings.json"
    local target_settings="$HOME_DIR/.claude/settings.json"
    local target_dir="$HOME_DIR/.claude"

    log_info "Installing hooks and permissions to $target_settings"

    if [[ ! -f "$source_settings" ]]; then
        log_error "BatutaClaude/settings.json not found"
        return 1
    fi

    # Ensure ~/.claude/ exists
    mkdir -p "$target_dir"

    if [[ ! -f "$target_settings" ]]; then
        # No existing settings — copy entire file
        cp -f "$source_settings" "$target_settings"
        log_success "Created $target_settings (full copy from BatutaClaude/settings.json)"
        return 0
    fi

    # Existing settings found — backup and merge
    local backup="$target_settings.bak.$(date +%Y%m%d%H%M%S)"
    cp -f "$target_settings" "$backup"
    log_info "Backed up existing settings to $backup"

    # Merge using jq (preferred) or python3 (fallback)
    if command -v jq &>/dev/null; then
        _merge_settings_jq "$source_settings" "$target_settings"
    elif command -v python3 &>/dev/null; then
        _merge_settings_python "$source_settings" "$target_settings"
    else
        log_error "Neither jq nor python3 found. Cannot merge settings."
        log_info "Manual install: copy hooks from $source_settings to $target_settings"
        return 1
    fi
}

_merge_settings_jq() {
    local source="$1"
    local target="$2"
    local tmp="${target}.tmp"

    # Source first + target on top = target values win (not overwritten)
    # Hooks: replace entirely (Batuta is source of truth)
    # Env: keep existing, add missing from source
    # Permissions: union arrays (deduplicated)
    jq -s '
      .[0] as $source | .[1] as $target |
      $target
      | .hooks = $source.hooks
      | .env = ($source.env // {}) + (.env // {})
      | .permissions.deny = ((.permissions.deny // []) + ($source.permissions.deny // []) | unique)
      | .permissions.ask = ((.permissions.ask // []) + ($source.permissions.ask // []) | unique)
      | .permissions.allow = ((.permissions.allow // []) + ($source.permissions.allow // []) | unique)
    ' "$source" "$target" > "$tmp"

    if [[ -s "$tmp" ]]; then
        mv -f "$tmp" "$target"
        log_success "Merged hooks, env, and permissions into $target"
    else
        rm -f "$tmp"
        log_error "jq merge produced empty output — settings not modified"
        return 1
    fi
}

_merge_settings_python() {
    local source="$1"
    local target="$2"
    local merge_exit=0

    python3 -c "
import json, sys

try:
    with open(sys.argv[1]) as f:
        src = json.load(f)
    with open(sys.argv[2]) as f:
        tgt = json.load(f)

    # Replace hooks entirely
    tgt['hooks'] = src.get('hooks', {})

    # Merge env: add missing keys only
    for k, v in src.get('env', {}).items():
        tgt.setdefault('env', {})[k] = tgt.get('env', {}).get(k, v)

    # Merge permissions: union arrays
    for perm_type in ['deny', 'ask', 'allow']:
        src_perms = src.get('permissions', {}).get(perm_type, [])
        tgt_perms = tgt.get('permissions', {}).get(perm_type, [])
        merged = list(dict.fromkeys(tgt_perms + src_perms))
        tgt.setdefault('permissions', {})[perm_type] = merged

    with open(sys.argv[2], 'w') as f:
        json.dump(tgt, f, indent=2, ensure_ascii=False)
        f.write('\n')
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
" "$source" "$target" || merge_exit=$?

    if [[ $merge_exit -eq 0 ]]; then
        log_success "Merged hooks, env, and permissions into $target (python3)"
    else
        log_error "Python merge failed (exit $merge_exit) — settings not modified"
        return 1
    fi
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
        if bash "$sync_script"; then
            log_success "Routing tables regenerated"
        else
            log_error "skill-sync failed — aborting. Fix skill frontmatters and retry."
            return 1
        fi
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
    # 3. Install hooks + permissions to ~/.claude/settings.json
    # 4. Copy updated BatutaClaude/CLAUDE.md to project root (now with updated tables)

    sync_claude
    echo ""
    sync_agents
    echo ""
    run_skill_sync
    echo ""
    install_hooks
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
        log_warning "skill-sync tables not found in CLAUDE.md — run: ./infra/setup.sh --all"
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
    printf "  ${CYAN}3)${NC} Full setup (sync + skill-sync + hooks + copy)\n"
    printf "  ${CYAN}4)${NC} Install hooks + permissions only\n"
    printf "  ${CYAN}5)${NC} Verify setup\n"
    printf "  ${CYAN}6)${NC} Help\n"
    printf "  ${CYAN}0)${NC} Exit\n"
    echo ""
    echo "  Need other platforms? Run: ./infra/replicate-platform.sh --help"
    echo ""
    printf "Enter choice [0-6]: "
}

handle_menu_choice() {
    case "$1" in
        1) generate_claude ;;
        2) sync_claude; sync_agents ;;
        3) do_all ;;
        4) install_hooks ;;
        5) verify ;;
        6) show_help ;;
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

Usage: ./infra/setup.sh [OPTIONS]

Options:
  --claude      Copy BatutaClaude/CLAUDE.md to project root
                  This is the file Claude Code reads automatically.
                  It contains personality, rules, and skill routing.
  --sync        Sync skills, agents, and commands to ~/.claude/
                  Copies all SKILL.md files, assets, scope agents,
                  and slash commands so Claude Code can route and load.
  --all         Full setup: sync + skill-sync + hooks + copy CLAUDE.md (recommended)
  --hooks       Install hooks and permissions to ~/.claude/settings.json
                  Merges Batuta hooks (5), env vars, and permissions.
                  Backs up existing settings before merging.
  --project <path>  Setup a target project directory:
                  - Copies CLAUDE.md to project root
                  - Creates .batuta/ with session.md + prompt-log.jsonl
                  - Initializes git if not already a repo
                  - Creates .gitignore
                  - Installs hooks + permissions
  --verify      Check that CLAUDE.md and skills are properly configured
  --help, -h    Show this help message

Interactive Mode:
  Run without arguments for a numbered menu

Other Platforms:
  To replicate to Gemini, Copilot, Codex, or OpenCode:
  ./infra/replicate-platform.sh --all

Examples:
  ./infra/setup.sh --all          # Full setup (recommended)
  ./infra/setup.sh --verify       # Check everything is correct
  ./infra/setup.sh                # Interactive menu

Platform: Windows (Git Bash / MSYS2 / MINGW64) and native Unix
EOF
}

# ============================================================================
# CLI Argument Parsing
# ============================================================================

parse_args() {
    case "$1" in
        --claude)   generate_claude ;;
        --sync)     sync_claude; sync_agents ;;
        --all)      do_all ;;
        --hooks)    install_hooks ;;
        --project)  shift_done=true; setup_project "$2" ;;
        --verify)   verify ;;
        --help|-h)  show_help; exit 0 ;;
        # Legacy flags — redirect to replicate-platform.sh
        --gemini|--copilot|--codex|--sync-opencode|--sync-all)
            log_warning "Multi-platform flags moved to replicate-platform.sh"
            log_info "Run: ./infra/replicate-platform.sh $1"
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
    # IMPORTANT: Resolve --project path BEFORE cd to REPO_ROOT
    # Otherwise relative paths (like ".") resolve to batuta-dots instead of user's project
    local resolved_project_path=""
    if [[ "$1" == "--project" && -n "$2" ]]; then
        local raw_path="$2"
        if [[ ! "$raw_path" = /* && ! "$raw_path" =~ ^[A-Za-z]: ]]; then
            resolved_project_path="$(cd "$(pwd)" && pwd)/$raw_path"
        else
            resolved_project_path="$raw_path"
        fi
    fi

    cd "$REPO_ROOT"

    if [[ $# -eq 0 ]]; then
        interactive_menu
    else
        if [[ "$1" == "--project" ]]; then
            setup_project "$resolved_project_path"
        else
            parse_args "$@"
        fi
    fi

    echo ""
    log_success "Done!"
}

main "$@"
