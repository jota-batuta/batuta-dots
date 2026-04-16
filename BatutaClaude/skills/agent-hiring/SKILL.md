---
name: agent-hiring
description: >
  Hire agents with persistent contracts.
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-04-13"
  bucket: meta
  auto_invoke:
    - "Delegating a task to a specialist agent"
    - "Creating a new agent contract"
    - "Checking existing agents before execution"
  platforms: [claude]
allowed-tools: Read Write Glob Grep
---

# Agent Hiring Protocol

## Purpose

The main agent NEVER executes tasks directly. For every task, it "hires" a specialist agent. Agents are `.md` files in `.claude/agents/` -- PERMANENT contracts that persist across projects. This skill defines the contract-based hiring system.

## The Protocol (5 Steps)

### Step 1: Detect Need

Analyze the task: "What expertise do I need?" Map to capabilities: tech stack, domain, tools, deliverable. The main agent has NO skills loaded -- it only orchestrates.

### Step 2: Check Existing Agents

Search both `.claude/agents/` (project) and `~/.claude/agents/` (global). Glob `*.md`, read frontmatter.

- **Found**: verify skills are sufficient for THIS task. Read the skill files, verify via web that patterns are current (frameworks change daily).
- **Skills need expansion**: propose adding skills to user before proceeding.

### Step 3: Propose Hire (USER STOP -- mandatory approval)

If no suitable agent exists, present to the user:

```
PROPUESTA DE CONTRATACION:

Agente: {name} (ej: nodejs-specialist, icg-data-explorer)
Rol: {what this agent does -- 1 sentence}
Skills: {list of skills to load}
Modelo: {sonnet|opus|haiku} -- {justification}
  - haiku: tareas rapidas, research ligero, validaciones simples
  - sonnet: implementacion, CRUD, integraciones, la mayoria de tareas
  - opus: arquitectura compleja, debugging profundo, decisiones criticas
Max turns: {number} -- {justification}
Tools: {list -- Read,Write,Edit,Bash,Glob,Grep,WebFetch,WebSearch,Skill}
Entregable: {what the agent must deliver}
Criterio de aceptacion: {how to verify the deliverable}

Apruebas esta contratacion?
```

NEVER skip this step. The user is the "board of directors."

### Step 4: Create Agent File

On user approval, create `.claude/agents/{name}.md`:

```markdown
---
name: {name}
description: {when to use -- trigger keywords for auto-discovery}
tools: {tools list}
model: {model}
skills: {skills list}
maxTurns: {number}
---

# {Name} -- Contract

## Rol
{1 paragraph: specialization}

## Expertise (from skills)

| Skill | What it provides |
|-------|-----------------|
| {skill} | {capability} |

## Deliverable Contract
When invoked, this agent MUST:
1. Read assigned skills FIRST -- verify they are current
2. Research before implementing (chain: KB -> skill -> web -> docs)
3. Execute within file_ownership boundaries
4. Report: FINDINGS / FAILURES / DECISIONS / GOTCHAS

## File Ownership
Only modify files explicitly assigned. Never touch files outside ownership.

## Acceptance Criteria
{From the hiring proposal}
```

### Step 5: Invoke

Spawn via Agent tool with `subagent_type={name}` and prompt containing:
- The specific task
- `file_ownership` list (explicit paths the agent may modify)
- Reference to PRD or design if applicable

## Rules

| Rule | Why |
|------|-----|
| NEVER create inline agents | Inline agents are lost knowledge. File first. |
| NEVER skip user approval | The user is the board of directors. |
| Names must be specific | `icg-data-explorer` not `data-agent`. Name IS contract. |
| Skills belong to agents | Main agent has NO skills -- it orchestrates. |
| Model: haiku=fast, sonnet=DEFAULT, opus=critical | Wrong model = wasted tokens or poor quality. |
| UPDATE outdated agents | Add/remove skills, change model -- with approval. |

## Example

```
Task: "Add JWT refresh token rotation to the auth module"

1. Need: auth expertise, JWT, FastAPI
2. Search agents/ -- nothing matching
3. Propose: auth-specialist, skills=[jwt-auth, fastapi-crud, security-audit],
   model=sonnet, tools=[Read,Write,Edit,Bash,Glob,Grep], max_turns=15
4. User approves -> create .claude/agents/auth-specialist.md
5. Invoke with file_ownership=[src/auth/*, tests/auth/*]
```

## Agent Update Protocol

When an existing agent is outdated: (1) read agent file + its skills, (2) identify gaps, (3) present update proposal to user:

```
ACTUALIZACION DE CONTRATO:
Agente: {name}
Cambios: Skills +{added} -{removed} | Model {old}->{new} | Max turns {old}->{new}
Apruebas esta actualizacion?
```

On approval, edit the `.md` file. Never modify without user consent.

## Integration with Team Orchestrator

For Level 3 (Agent Team) tasks, the hiring protocol applies to EACH teammate. Lead hires teammates via this protocol, each gets its own file, file ownership is defined per teammate (no overlap). The team-orchestrator skill handles coordination after hiring.

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "Create the agent inline for speed" | Inline agents disappear after the session. The next session re-discovers the same need and re-creates the same agent — losing all accumulated context. File first, always. |
| "Don't need user approval for an obvious agent" | The user is the board of directors. Skipping PROPUESTA DE CONTRATACION removes the human checkpoint that catches model misuse and skill mismatches. |
| "Generic name like `data-agent` is fine" | Generic names produce generic behavior. `icg-data-explorer` carries domain context; `data-agent` could mean anything. The name IS the contract. |
| "Skip skills, the agent will figure it out" | The main agent has NO skills loaded. If the spawned agent has no skills either, it's just a fresh Claude with no project context — slower and less accurate than just doing the work. |
| "Use opus for everything, it's the smartest" | Opus on a CRUD task is wasted tokens. The model field exists because cost matters: haiku for fast, sonnet for default, opus for critical only. |
| "Update the agent silently — small change" | Even small updates need user approval. Silent edits to agent files break the contract metaphor and erode trust. |

## Red Flags

- An agent was used during a session but no `.md` file exists in `.claude/agents/` or `~/.claude/agents/`
- PROPUESTA DE CONTRATACION skipped — agent created without explicit user approval
- Agent name is generic (`data-agent`, `helper`, `worker`) instead of domain-specific
- Agent file missing required frontmatter fields (name, description, tools, model, skills, maxTurns)
- Agent invoked with no `file_ownership` list in the prompt
- Multiple agents in same wave with overlapping `file_ownership` paths
- Existing agent edited without ACTUALIZACION DE CONTRATO approval flow
- Main agent loaded skills directly instead of delegating to a hired agent

## Verification Checklist

- [ ] `.claude/agents/{agent-name}.md` file exists with required frontmatter
- [ ] User approval explicitly recorded for the PROPUESTA DE CONTRATACION
- [ ] Agent name is specific (domain or technology), not generic
- [ ] Skills list in frontmatter matches the proposed contract
- [ ] Model selection justified (haiku/sonnet/opus) and matches task complexity
- [ ] Tools list scoped to what the agent actually needs (no tool sprawl)
- [ ] Agent contract includes Rol, Expertise table, Deliverable Contract, File Ownership, Acceptance Criteria
- [ ] When invoking, prompt contains explicit `file_ownership` list with no overlap
- [ ] For Level 3 teams: each teammate has its own approved `.md` file
- [ ] Agent updates flow through ACTUALIZACION DE CONTRATO (no silent edits)
