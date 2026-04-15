#!/usr/bin/env bash
# sync-plugin.sh — Sync curated subset from BatutaClaude/ to repo root
#
# Why: The Claude Code plugin system auto-discovers skills/, agents/, commands/
# from the PLUGIN ROOT (which is the repo root for this plugin). It installs
# EVERYTHING it finds there. We want only 17 essential skills + 8 agents + commands,
# NOT the 46 total skills in BatutaClaude/skills/.
#
# BatutaClaude/skills/ = source of truth (all 46 skills, used by bash installer)
# ./skills/ (repo root) = plugin-installable subset (17 essentials)
# ./agents/ (repo root) = plugin agents (8: 5 workers + 3 reviewers)
# ./commands/ (repo root) = plugin commands (12)
#
# Run this after modifying any essential skill or agent.
# Usage: bash infra/sync-plugin.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PLUGIN_DIR="$REPO_ROOT"
SOURCE_DIR="$REPO_ROOT/BatutaClaude"

# WORKAROUND: Keep this list in sync with infra/setup.sh global_skills array.
# Changing one means changing the other.
ESSENTIAL_SKILLS=(
    # always (5)
    scope-rule ecosystem-creator security-audit team-orchestrator ecosystem-lifecycle
    # sdd core (7)
    sdd-explore sdd-design sdd-apply sdd-verify prd-generator tdd-workflow debugging-systematic
    # bootstrap (1)
    sdd-init
    # v15.1 meta (4)
    agent-hiring code-simplification deprecation-and-migration git-workflow-and-versioning
)

echo -e "${CYAN}[INFO]${NC} Syncing plugin subset from BatutaClaude/ to repo root"

# Clean plugin subdirs before re-sync (safe — they're generated)
rm -rf "$PLUGIN_DIR/skills" "$PLUGIN_DIR/agents" "$PLUGIN_DIR/commands"
mkdir -p "$PLUGIN_DIR/skills" "$PLUGIN_DIR/agents" "$PLUGIN_DIR/commands"

# Copy essential skills only
skill_count=0
for skill in "${ESSENTIAL_SKILLS[@]}"; do
    src="$SOURCE_DIR/skills/$skill"
    if [[ -d "$src" ]]; then
        cp -r "$src" "$PLUGIN_DIR/skills/"
        skill_count=$((skill_count + 1))
    else
        echo -e "${RED}[ERROR]${NC} Missing essential skill: $skill"
        exit 1
    fi
done

# Copy all agents (workers + reviewers — all 8 are essential)
agent_count=0
for agent in "$SOURCE_DIR"/agents/*.md; do
    [[ -f "$agent" ]] || continue
    cp "$agent" "$PLUGIN_DIR/agents/"
    agent_count=$((agent_count + 1))
done

# Copy all commands (12 total)
command_count=0
for cmd in "$SOURCE_DIR"/commands/*.md; do
    [[ -f "$cmd" ]] || continue
    cp "$cmd" "$PLUGIN_DIR/commands/"
    command_count=$((command_count + 1))
done

echo -e "${GREEN}[OK]${NC} Synced $skill_count skills + $agent_count agents + $command_count commands to repo root (skills/, agents/, commands/)"
echo -e "${CYAN}[INFO]${NC} Plugin is now ready for /plugin install"
