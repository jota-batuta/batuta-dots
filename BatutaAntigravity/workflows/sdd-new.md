# /sdd-new

> Start a new change: explore the codebase and create a proposal. Runs sdd-explore then sdd-propose for the given change name.

## Instructions

The argument `{{args}}` is the change name. Use it as the change identifier throughout the pipeline.

### Step 1: Create change directory

Create the directory `openspec/changes/{{args}}/` if it does not already exist.

### Step 2: Explore

1. Locate and read the `sdd-explore` skill at `.agent/skills/sdd-explore/SKILL.md` or `~/.gemini/antigravity/skills/sdd-explore/SKILL.md`.
2. Follow the skill instructions exactly, using `{{args}}` as the exploration topic.
3. Save the exploration output to `openspec/changes/{{args}}/explore.md`.

### Step 3: Propose

1. Locate and read the `sdd-propose` skill at `.agent/skills/sdd-propose/SKILL.md` or `~/.gemini/antigravity/skills/sdd-propose/SKILL.md`.
2. Follow the skill instructions exactly, using the exploration results as input.
3. Save the proposal output to `openspec/changes/{{args}}/proposal.md`.

If any skill file does not exist, tell the user:

```
Los skills SDD no estan instalados. Ejecuta /batuta-update primero para sincronizar el ecosistema.
```
