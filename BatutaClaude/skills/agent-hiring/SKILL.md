---
name: agent-hiring
description: >
  Use when the main agent needs to delegate a task. Trigger: "hire agent",
  "create agent", "specialist needed", "delegate task", "spawn agent".
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-04-13"
  scope: [infra]
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
