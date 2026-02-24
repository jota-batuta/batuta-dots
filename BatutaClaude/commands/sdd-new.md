---
name: sdd-new
description: >
  Start a new change: explore the codebase and create a proposal.
  Runs sdd-explore then sdd-propose for the given change name.
argument-hint: "<change-name>"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebSearch, WebFetch
---

## SDD New Change

Start a new SDD change by running explore + propose in sequence.

The argument ($ARGUMENTS) is the change name. Use it as the change identifier throughout the pipeline.

### Step 1: Create change directory

```
openspec/changes/{change-name}/
```

### Step 2: Explore

Invoke the `sdd-explore` skill. Read `~/.claude/skills/sdd-explore/SKILL.md` and follow it.
Save output to `openspec/changes/{change-name}/explore.md`.

### Step 3: Propose

Invoke the `sdd-propose` skill. Read `~/.claude/skills/sdd-propose/SKILL.md` and follow it.
Save output to `openspec/changes/{change-name}/proposal.md`.

If any skill file does not exist, tell the user:
```
Los skills SDD no estan instalados. Ejecuta /batuta-init primero para sincronizar el ecosistema.
```
