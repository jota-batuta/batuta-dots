# /batuta-sync

> Sync skills between the current project and the batuta-dots hub. All operations are internal — the user describes what they want in natural language.

## Instructions

### Step 1: Locate batuta-dots

Check these locations in order:
1. `~/batuta-dots/`
2. `/tmp/batuta-dots/`

If not found, tell the user: "No encuentro batuta-dots. Necesito un clon local para sincronizar."

### Step 2: Ensure fresh hub

Run `git pull` in batuta-dots. If it fails, **STOP** and explain (same as /batuta-update).

### Step 3: Scan for sync candidates

Scan `.agent/skills/` and `.claude/skills/` in the current project for skills not in the hub (`BatutaClaude/skills/`).

Also scan the hub for skills not provisioned in this project.

### Step 4: Present sync plan

Show the user what can be synced in each direction:
- **Project → Hub**: local-only skills that could benefit other projects
- **Hub → Project**: hub skills not yet provisioned here

Ask what they want to do (sync all, just push, just pull, or select individually).

### Step 5: Execute sync (internal)

**Project → Hub**:
1. Evaluate each skill: generic or project-specific?
2. If generic and approved: copy to `BatutaClaude/skills/{name}/`
3. If skill has `platforms: [claude, antigravity]`: also copy to `BatutaAntigravity/skills/{name}/`

**Hub → Project**:
1. Copy from hub to `.agent/skills/{name}/` (Antigravity) or `.claude/skills/{name}/` (Claude)
2. Update `.provisions.json` if it exists

### Step 6: Commit to hub (with authorization)

Present changes and ask: "¿Hago commit y push?"

**NEVER commit or push without explicit approval.**

### Step 7: Report

Show what was synced in each direction and update `.batuta/ecosystem.json`.
