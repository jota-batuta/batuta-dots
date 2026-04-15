---
name: batuta-sync
description: >
  Sync skills between the current project and the batuta-dots hub.
  Detects local-only skills, offers hub propagation, cross-syncs to Antigravity.
  The agent handles all operations internally — the user never touches bash.
disable-model-invocation: true
allowed-tools: Bash, Read, Write, Glob, Grep
---

## Batuta Skill Sync

Synchronize skills between this project and the batuta-dots hub. All operations
are internal — the user describes what they want in natural language, the agent
handles the rest.

### Step 1: Locate batuta-dots

Check these locations in order:

1. `E:/BATUTA PROJECTS/batuta-dots/` (configured development path)
2. `~/batuta-dots/`
3. `/tmp/batuta-dots/`

If not found, tell the user: "No encuentro batuta-dots. Necesito un clon local
para sincronizar skills."

Store the path in `$BATUTA_DOTS_PATH`.

### Step 2: Ensure fresh hub

Run `git pull` in `$BATUTA_DOTS_PATH`. If it fails, **STOP** and explain.
Same blocking behavior as `/batuta-update` Step 2.

### Step 3: Scan for sync candidates

Scan the current project for skills not in the hub:

```
FOR each skill in .claude/skills/ AND .agent/skills/:
  IF skill NOT found in $BATUTA_DOTS_PATH/BatutaClaude/skills/:
    ADD to sync_candidates[]
```

Also scan the hub for skills not in the project:

```
FOR each skill in $BATUTA_DOTS_PATH/BatutaClaude/skills/:
  IF skill NOT found in .claude/skills/:
    ADD to available_from_hub[]
```

### Step 4: Present sync plan

```
Plan de sincronización:

  Proyecto → Hub: (skills locales que no están en batuta-dots)
    - {skill-1}: {description}
    - {skill-2}: {description}

  Hub → Proyecto: (skills disponibles que no están provisionados)
    - {skill-3}: {description}
    - {skill-4}: {description}

¿Qué quieres hacer?
1. Sincronizar todo (propagar al hub + traer del hub)
2. Solo propagar mis skills al hub
3. Solo traer skills del hub a este proyecto
4. Seleccionar individualmente
```

### Step 5: Execute sync (internal)

On user approval, the agent runs operations INTERNALLY:

**Project → Hub** (for each approved skill):
1. Run ecosystem-lifecycle classification (generic vs project-specific)
2. If generic and approved: copy to `$BATUTA_DOTS_PATH/BatutaClaude/skills/{name}/`
3. If skill has `platforms: [claude, antigravity]`:
   Run internally: `bash "$BATUTA_DOTS_PATH/infra/sync.sh" --to-antigravity`

**Hub → Project** (for each approved skill):
1. Copy from `$BATUTA_DOTS_PATH/BatutaClaude/skills/{name}/` to `.claude/skills/{name}/`
2. Update `.provisions.json`: add to `skills[]` and `reprovisioned[]`

### Step 6: Commit to hub (with authorization)

If any skills were propagated to the hub:

Present changes:
```
Cambios en batuta-dots:
  + BatutaClaude/skills/{skill-1}/SKILL.md
  + BatutaAntigravity/skills/{skill-1}/SKILL.md (cross-sync)

¿Hago commit y push?
```

**NEVER commit or push without explicit user approval.**

On approval:
- `git add` the changed files
- `git commit -m "feat(skills): sync {skill-names} from {project}"`
- `git push`

### Step 7: Update local ecosystem

Update `.batuta/ecosystem.json`:
- Refresh `skills_local` and `skills_shared` lists
- Update `last_sync` timestamp

Report:
```
Sincronización completada.
  Propagados al hub: {count} skills
  Traídos del hub: {count} skills
  Cross-sync Antigravity: {count} skills
```
