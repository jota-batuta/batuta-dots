# /batuta:sync-skills — Regenerate Routing Tables

Regenerates the AUTO-GENERATED routing tables in CLAUDE.md and scope agent files by reading all SKILL.md frontmatters.

## What It Does

1. Scans all `BatutaClaude/skills/*/SKILL.md` files
2. Extracts frontmatter: `name`, `scope`, `auto_invoke`, `allowed-tools`
3. Groups skills by scope
4. Replaces the `<!-- AUTO-GENERATED -->` sections in:
   - `BatutaClaude/CLAUDE.md` (Available Skills table)
   - `BatutaClaude/agents/{scope}-agent.md` (Skills table per scope)
5. Reports: skills synced, agents updated, warnings

## Steps

1. Run: `bash BatutaClaude/skills/skill-sync/assets/sync.sh`
2. Show the sync summary to the user
3. If there are warnings (missing frontmatter fields), list them

## Options

- `--dry-run` — Preview what would change without writing files
- `--scope <name>` — Only sync a specific scope (e.g., `pipeline`)
- `--verbose` — Show detailed output

## When to Run

- After creating or modifying any SKILL.md
- After adding a new scope agent
- When routing tables seem stale or a skill is missing from them
