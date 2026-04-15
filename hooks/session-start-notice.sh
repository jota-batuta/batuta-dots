#!/usr/bin/env bash
# session-start-notice.sh — Detect unititialized Batuta projects and suggest /batuta-init
#
# This hook runs at SessionStart when the batuta-dots plugin is enabled.
# It checks if the current working directory looks like a project (has package.json,
# pyproject.toml, .git, etc.) but doesn't yet have .batuta/ — suggesting the user
# may want to initialize it.
#
# Output goes to stdout which Claude Code injects as additionalContext.
# The notice is SUGGESTIVE only — it doesn't auto-run anything.

set -euo pipefail

# Read JSON input from stdin (Claude Code passes session info)
# We don't actually use the JSON fields, but consume stdin to not block.
if [[ -t 0 ]]; then
    :  # No stdin, skip
else
    cat > /dev/null 2>&1 || true
fi

# Determine project directory
# Claude Code sets CLAUDE_PROJECT_DIR, otherwise use PWD
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${PWD:-}}"

# Skip if no project dir or it's the user's home directory
if [[ -z "$PROJECT_DIR" ]] || [[ "$PROJECT_DIR" == "$HOME" ]] || [[ "$PROJECT_DIR" == "/" ]]; then
    exit 0
fi

# Skip if .batuta/ already exists (project is initialized)
if [[ -d "$PROJECT_DIR/.batuta" ]]; then
    exit 0
fi

# Skip if no common project markers — don't nag in random dirs
project_detected=false
for marker in package.json pyproject.toml requirements.txt Pipfile setup.py go.mod Cargo.toml composer.json .git; do
    if [[ -e "$PROJECT_DIR/$marker" ]]; then
        project_detected=true
        break
    fi
done

if [[ "$project_detected" == "false" ]]; then
    exit 0
fi

# Skip if CLAUDE.md already exists (maybe batuta-configured but .batuta/ was deleted)
if [[ -f "$PROJECT_DIR/CLAUDE.md" ]]; then
    exit 0
fi

# Inject notice for Claude
cat <<'EOF'

## Batuta Ecosystem Notice (from batuta-dots plugin)

This project does not have a `.batuta/` directory. If the user wants to use Batuta conventions
(SDD pipeline SPRINT/COMPLETO, agent delegation, session continuity), suggest running:

    /batuta-dots:batuta-init

This will:
- Copy batuta-dots CLAUDE.md to the project root
- Create .batuta/ with session.md and CHECKPOINT.md templates
- Provision tech-specific skills based on detected stack (e.g., react-nextjs if Next.js detected,
  icg-erp if ICG context mentioned, etc.)

If the user is just exploring or doesn't want Batuta in this project, ignore this notice.
EOF
