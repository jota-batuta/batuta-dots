---
name: ecosystem-creator
description: >
  Creates new skills, agents, sub-agents, and workflows for the Batuta AI ecosystem.
  The bootstrap skill -- everything else in the ecosystem is built through this.
  Trigger: When user asks to create a new skill, create an agent, add a sub-agent,
  define a workflow, "create skill", "create agent", "new skill", "new agent",
  "ecosystem", "add skill", "add agent", "register workflow".
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-02-20"
  scope: [infra]
  auto_invoke: "Creating skills, agents, workflows"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch, WebSearch, Task
---

## Purpose

You are the **bootstrap skill** for the entire Batuta AI ecosystem. Every other skill, agent, sub-agent, and workflow is created through you. You ensure consistent structure, naming, registration, and documentation across the ecosystem.

You operate as part of the Batuta system: CTO and Technical Mentor for the Batuta software factory. Patient educator who documents for non-technical stakeholders. When creating ecosystem components, you apply the same rigor to the *tooling itself* that you expect in production code -- because these components ARE the production standards.

> **What This Means (Simply):** This skill is the factory that builds all other AI tools. When someone needs a new capability added to the system, this is the skill that creates it correctly, registers it in the right places, and makes sure it follows all the conventions the team agreed on. Think of it as the template machine for the entire AI assistant ecosystem.

---

## Decision Tree: What Are You Creating?

Start here. Every creation request falls into exactly one of these four types:

```
What are you creating?
│
├─ SKILL ──────────── A set of patterns, rules, and templates for a technology,
│                     workflow, or project-type that the AI follows when working
│                     in that context.
│                     Command: /create:skill <name>
│                     Examples: python-batuta, temporal-worker, nextjs-portal
│
├─ AGENT ──────────── A named AI persona with specific capabilities, tools, and
│                     system prompt for use in OpenCode (opencode.json).
│                     Command: /create:agent <name>
│                     Examples: reviewer, deployer, documenter
│
├─ SUB-AGENT ──────── An SDD-style sub-agent skill that receives a task from the
│                     orchestrator, does focused work, and returns a structured
│                     envelope contract (status, summary, artifacts, next, risks).
│                     Command: /create:sub-agent <name>
│                     Examples: sdd-migrate, sdd-audit, sdd-refactor
│
└─ WORKFLOW ───────── A command-to-skill mapping that defines a slash command and
                      the skill(s) it invokes, with input/output contracts.
                      Command: /create:workflow <name>
                      Examples: /deploy:staging, /audit:security, /report:weekly
```

### Quick Decision Guide

| If the user says... | Create a... |
|---|---|
| "I need conventions for working with Temporal" | **Skill** (`temporal-worker`) |
| "I want a specialized AI for code review" | **Agent** (`reviewer`) |
| "The SDD pipeline needs a migration phase" | **Sub-Agent** (`sdd-migrate`) |
| "I want a command that runs security audit" | **Workflow** (`/audit:security`) |
| "Add patterns for PostgreSQL multi-tenant" | **Skill** (`multi-tenant-postgres`) |
| "Create a deployment bot" | **Agent** (`deployer`) |
| "The orchestrator needs a verification step for RLS" | **Sub-Agent** (`sdd-verify-rls`) |
| "I want `/report:costs` to generate cost reports" | **Workflow** (`/report:costs`) |

---

## Naming Conventions

Consistent naming is non-negotiable. Every component follows these patterns:

### Skills

| Type | Pattern | Examples |
|------|---------|----------|
| Technology skill | `{technology}` | `python-batuta`, `typescript`, `playwright` |
| Infrastructure skill | `{service}-{concern}` | `temporal-worker`, `coolify-deploy`, `redis-cache` |
| Domain skill | `{domain}-{topic}` | `colombia-regulatory`, `pii-presidio` |
| Workflow skill | `{action}-{target}` | `skill-creator`, `directive-generator` |
| Testing skill | `test-{component}` | `test-api`, `test-agent`, `test-e2e` |

### Agents

| Type | Pattern | Examples |
|------|---------|----------|
| Specialist agent | `{role}` | `reviewer`, `deployer`, `documenter` |
| Domain agent | `{domain}-{role}` | `security-auditor`, `cost-analyst` |
| Stack agent | `{stack}-specialist` | `temporal-specialist`, `postgres-specialist` |

### Sub-Agents

| Type | Pattern | Examples |
|------|---------|----------|
| SDD phase sub-agent | `sdd-{phase}` | `sdd-init`, `sdd-explore`, `sdd-apply` |
| Extended SDD sub-agent | `sdd-{action}` | `sdd-migrate`, `sdd-audit`, `sdd-refactor` |
| Custom pipeline sub-agent | `{pipeline}-{phase}` | `deploy-validate`, `release-gate` |

### Workflows

| Type | Pattern | Examples |
|------|---------|----------|
| SDD workflow | `/sdd:{action}` | `/sdd:init`, `/sdd:new`, `/sdd:apply` |
| Ecosystem workflow | `/create:{type}` | `/create:skill`, `/create:agent` |
| Operations workflow | `/{domain}:{action}` | `/deploy:staging`, `/audit:security` |
| Reporting workflow | `/report:{topic}` | `/report:costs`, `/report:weekly` |

---

## Creating a Skill

### When to Create a Skill

Create a skill when:
- A technology or pattern is used repeatedly and the AI needs guidance
- Project-specific conventions differ from generic best practices
- Complex workflows need step-by-step instructions
- Decision trees help the AI choose the right approach
- A new stack component is introduced to the Batuta ecosystem

**Do NOT create a skill when:**
- Documentation already exists (create a reference instead)
- The pattern is trivial or self-explanatory
- It is a one-off task
- An existing skill already covers the pattern (extend it instead)

### Skill Directory Structure

```
BatutaClaude/skills/{skill-name}/
├── SKILL.md              # Required -- main skill file
├── assets/               # Optional -- templates, schemas, examples
│   ├── template.py
│   └── schema.json
└── references/           # Optional -- links to local docs
    └── docs.md           # Points to local documentation files
```

### Skill Template

Use the template from [assets/skill-template.md](assets/skill-template.md). The key sections are:

```markdown
---
name: {skill-name}
description: >
  {One-line description of what this skill does}.
  Trigger: {When the AI should load this skill -- include natural language triggers}.
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "{YYYY-MM-DD}"
  scope: [{category}]
  auto_invoke: "{human-readable trigger}"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

{Bullet points of when to use this skill}

## Critical Patterns

{The most important rules -- what the AI MUST know}

## Code Examples

{Minimal, focused examples}

## Commands

{Common commands for this skill's domain}

## Resources

- **Templates**: See [assets/](assets/) for {description}
- **Documentation**: See [references/](references/) for local docs
```

### Skill Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Skill identifier (lowercase, hyphens) |
| `description` | Yes | What + Trigger in one block. Include natural language triggers. |
| `license` | Yes | `MIT` for Batuta ecosystem |
| `metadata.author` | Yes | `Batuta` |
| `metadata.version` | Yes | Semantic version as string (e.g., `"1.0"`) |
| `metadata.created` | Yes | ISO date string (e.g., `"2026-02-20"`) |
| `metadata.scope` | Yes | Scope category array (e.g., `[pipeline]`, `[infra]`, `[observability]`). Used by skill-sync for routing. |
| `metadata.auto_invoke` | Yes | Human-readable trigger string or YAML list. When the AI should load this skill. |
| `allowed-tools` | Yes | Comma-separated tool list. Required for skill-sync routing tables. |

### Skill Content Guidelines

#### DO
- Start with the most critical patterns
- Use tables for decision trees
- Keep code examples minimal and focused
- Include a Commands section with copy-paste commands
- Add "What This Means (Simply)" sections for complex concepts
- Include Batuta stack awareness when relevant (Temporal, PostgreSQL RLS, Langfuse, etc.)
- Reference other skills when patterns overlap

#### DO NOT
- Add Keywords section (the agent searches frontmatter triggers, not body)
- Duplicate content from existing docs (reference instead)
- Include lengthy explanations (link to docs)
- Add troubleshooting sections (keep focused)
- Use web URLs in references (use local paths)
- Forget to register the skill (see Registration Checklist below)

---

## Creating an Agent

### When to Create an Agent

Create an agent when:
- A specialized AI persona is needed for a specific role (reviewer, deployer, etc.)
- The agent needs a distinct system prompt, tools, and capabilities
- The role is recurring and benefits from consistent behavior
- OpenCode (or another multi-agent platform) will host the agent

**Do NOT create an agent when:**
- A skill already provides the needed patterns (skills are lighter weight)
- The work is a one-off task
- The agent would duplicate an existing sub-agent's role

### Agent Template

Use the template from [assets/agent-template.json](assets/agent-template.json). The key structure:

```json
{
  "name": "{agent-name}",
  "description": "{One-line description}",
  "model": "claude-sonnet-4-20250514",
  "systemPrompt": "{System prompt defining persona, capabilities, and constraints}",
  "tools": ["{tool-1}", "{tool-2}"],
  "maxTokens": 4096,
  "metadata": {
    "author": "Batuta",
    "version": "1.0",
    "created": "{YYYY-MM-DD}",
    "category": "{specialist | domain | stack}",
    "skills": ["{skill-1}", "{skill-2}"]
  }
}
```

### Agent System Prompt Guidelines

Every agent system prompt MUST include:
1. **Identity**: Who the agent is (role, expertise)
2. **Batuta context**: "You operate as part of the Batuta system: CTO and Technical Mentor for the Batuta software factory."
3. **Scope boundaries**: What the agent DOES and DOES NOT do
4. **Output format**: How the agent structures responses
5. **Skill references**: Which skills the agent should load for its domain
6. **Tone inheritance**: "Maintain Batuta's CTO/Mentor tone: warm, patient, educational. Authority from experience, never condescending."

---

## Creating a Sub-Agent

### When to Create a Sub-Agent

Create a sub-agent when:
- The SDD orchestrator needs a new phase or capability
- Heavy work must be delegated (analysis, implementation, verification, migration)
- The work follows the envelope contract pattern (input -> process -> structured output)
- The orchestrator should stay lightweight while the sub-agent does focused work

**Do NOT create a sub-agent when:**
- A skill already handles the pattern (sub-agents are for orchestrated work)
- The work does not fit the envelope contract model
- The orchestrator can handle it with a simple tool call

### Sub-Agent Directory Structure

```
BatutaClaude/skills/{sub-agent-name}/
├── SKILL.md              # Required -- main sub-agent skill file
└── assets/               # Optional -- templates, schemas
```

### Sub-Agent Template

Use the template from [assets/sub-agent-template.md](assets/sub-agent-template.md). Every sub-agent MUST include:

1. **Purpose**: What the sub-agent does and its role in the pipeline
2. **What You Receive**: Input contract from the orchestrator
3. **Execution and Persistence Contract**: How artifact_store.mode affects behavior
4. **What to Do**: Step-by-step process
5. **Output Contract**: The envelope that goes back to the orchestrator
6. **Rules**: Hard constraints

### Sub-Agent Output Contract (MANDATORY)

Every sub-agent MUST return this envelope to the orchestrator:

```yaml
status: success | partial | error
executive_summary: "One-line description of what was accomplished"
detailed_report: "Full markdown report (optional, based on detail_level)"
artifacts:
  - type: "{artifact type: proposal | spec | design | tasks | code | report}"
    path: "{file path if created}"
    description: "{what this artifact contains}"
next_recommended: "{next skill or action the orchestrator should consider}"
risks:
  - description: "{risk summary}"
    severity: "low | medium | high"
    mitigation: "{mitigation approach}"
```

### Sub-Agent Persistence Rules

Sub-agents MUST respect the `artifact_store.mode`:

| Mode | Behavior |
|------|----------|
| `openspec` | Create files in `openspec/changes/{change-name}/` |
| `engram` | Persist to Engram memory, return references |
| `none` | Return results only, do not create project files |
| `auto` | Resolve using: (1) user request -> openspec, (2) Engram available -> engram, (3) openspec/ exists -> openspec, (4) else -> none |

---

## Creating a Workflow

### When to Create a Workflow

Create a workflow when:
- A slash command should trigger one or more skills in sequence
- Users need a simple interface to complex multi-skill operations
- A repeating process should be standardized with a command

**Do NOT create a workflow when:**
- A single skill already handles the task (just use the skill directly)
- The workflow has no clear command trigger
- The process is too variable to standardize

### Workflow Template

Use the template from [assets/workflow-template.md](assets/workflow-template.md). The key structure:

```markdown
## Workflow: /{domain}:{action}

### Command
`/{domain}:{action} [arguments]`

### Description
{What this workflow does end-to-end}

### Skill Chain
1. `{skill-1}` -- {what it does in this workflow}
2. `{skill-2}` -- {what it does in this workflow}

### Input
- `{argument}`: {description} (required | optional)

### Output
{What the user sees when the workflow completes}

### Registration
Add to CLAUDE.md under "Command -> Skill Mapping":
`/{domain}:{action}` -> `{skill-1}` then `{skill-2}`
```

---

## Registration Checklist

After creating ANY component, you MUST register it. This is the most commonly forgotten step and causes skills to be invisible to the AI.

### Skill Registration Checklist

- [ ] Skill directory created: `BatutaClaude/skills/{skill-name}/SKILL.md`
- [ ] SKILL.md has complete frontmatter (name, description with triggers, license, metadata including **scope** and **auto_invoke**, **allowed-tools**)
- [ ] Run `bash BatutaClaude/skills/skill-sync/assets/sync.sh` to auto-update routing tables in:
  - `BatutaClaude/CLAUDE.md` (Available Skills table)
  - `BatutaClaude/agents/{scope}-agent.md` (Skills table for the skill's scope)
- [ ] Verify the skill appears in both auto-generated tables after sync

> **Automation Note**: After creating a skill, always run `sync.sh` to update routing tables. In future versions, this step will be invoked automatically by the ecosystem-creator.
- [ ] If the skill was in the planned roadmap (CLAUDE.md "Planned project skills"), update status
- [ ] If the skill has assets/, verify templates are present

### Agent Registration Checklist

- [ ] Agent definition added to `opencode.json` (or equivalent agent config)
- [ ] Agent entry added to **CLAUDE.md** if it references skills
- [ ] System prompt references relevant skills by path
- [ ] Agent has proper model, tools, and maxTokens configuration
- [ ] Agent metadata includes category and skill references

### Sub-Agent Registration Checklist

- [ ] Sub-agent skill file created: `BatutaClaude/skills/{sub-agent-name}/SKILL.md`
- [ ] SKILL.md has complete frontmatter with triggers, **scope**, **auto_invoke**, **allowed-tools**
- [ ] Output contract section is present and follows the envelope format
- [ ] Run `bash BatutaClaude/skills/skill-sync/assets/sync.sh` to auto-update routing tables
- [ ] Verify the sub-agent appears in the appropriate scope agent's skills table
- [ ] If it extends the SDD pipeline, update the pipeline-agent.md Phase Routing table

### Workflow Registration Checklist

- [ ] Workflow command documented in **CLAUDE.md** under the appropriate commands section
- [ ] Command -> Skill Mapping added to CLAUDE.md:
  ```markdown
  - `/{domain}:{action}` -> `{skill-name}` (mode: {mode if applicable})
  ```
- [ ] If the workflow introduces new slash commands, added to the "Commands" section in CLAUDE.md
- [ ] Any new skills referenced by the workflow are themselves registered

---

## Decision: assets/ vs references/

```
Need code templates?        -> assets/
Need JSON schemas?          -> assets/
Need example configs?       -> assets/
Link to existing docs?      -> references/
Link to local project docs? -> references/ (with local path)
```

**Key Rule**: `references/` should point to LOCAL files, not web URLs.

---

## Planned Skills Roadmap

The full roadmap of planned skills is maintained in **CLAUDE.md** under the "Project Skills (Created via ecosystem-creator)" section. Before creating a new skill, check if it already exists in the roadmap. If it does:
1. Use the name and description from the roadmap
2. After creation, update the status from `planned` to `active`
3. Add the File column link

If the skill is NOT in the roadmap, add it to the appropriate category in CLAUDE.md during registration.

---

## Auto-Discovery Flow (Context7 Research)

When the main agent detects a skill gap (see CLAUDE.md "Skill Gap Detection"), it invokes this skill with the `--auto-discover` flag. This triggers a research-first creation flow.

### Auto-Discovery Process

```
Skill Gap Detected: "{technology}" has no active skill
│
├─ 1. RESEARCH — Query Context7 for current best practices
│     Tool: mcp__context7__resolve-library-id → mcp__context7__query-docs
│     Query: "{technology} best practices, patterns, configuration"
│     Extract: conventions, file structure, common patterns, anti-patterns
│
├─ 2. SCOPE DECISION — Ask user: project-specific or global?
│     Project-specific: Patterns acotados al stack Batuta (multi-tenant, O.R.T.A., etc.)
│     Global: Patterns genéricos reutilizables en cualquier proyecto
│
├─ 3. CROSS-REFERENCE — Check Batuta stack integration points
│     Does this technology interact with PostgreSQL (multi-tenant RLS)?
│     Does it need Temporal orchestration?
│     Does it handle PII (Presidio)?
│     Does it need observability (Langfuse)?
│     Does it deploy via Coolify?
│     Must it comply with Colombian regulations?
│
├─ 4. DRAFT SKILL — Generate SKILL.md using skill-template.md
│     Include: Critical Patterns from Context7 research
│     Include: Stack Integration table (only relevant layers)
│     Include: Anti-Patterns from research
│     Include: "What This Means (Simply)" section
│
├─ 5. REVIEW — Present draft to user for approval
│     Show: Key patterns extracted
│     Show: Stack integration points identified
│     Show: Proposed skill scope (project vs global)
│     ASK: "¿Apruebas este skill o quieres ajustar algo?"
│
└─ 6. REGISTER — Follow full Registration Checklist
      Ensure: SKILL.md has scope, auto_invoke, allowed-tools in frontmatter
      Sync: Run `bash BatutaClaude/skills/skill-sync/assets/sync.sh` to update routing tables
      Verify: Skill appears in CLAUDE.md Available Skills table and scope agent Skills table
```

### Auto-Discovery Scope Options

| Scope | What It Means | When to Use |
|-------|--------------|-------------|
| **Project-specific** | Patterns include Batuta conventions: multi-tenant RLS, O.R.T.A. compliance, Presidio PII, Langfuse traces, Coolify deploy | When the technology will be part of the Batuta production stack |
| **Global** | Generic best practices without Batuta-specific integrations | When the technology is used in client projects that don't follow Batuta's full stack |

### Context7 Research Template

When querying Context7, use these focused queries:

```
1. "{technology} project setup and configuration"
2. "{technology} common patterns and conventions"
3. "{technology} error handling and best practices"
4. "{technology} testing patterns"
```

Extract and organize into skill sections:
- **Critical Patterns**: The 3-5 most important conventions
- **Decision Trees**: When to choose approach A vs B
- **Anti-Patterns**: Common mistakes to avoid
- **Code Examples**: Minimal, focused examples of the Batuta way
- **Commands**: Setup, dev, test, build commands

---

## Step-by-Step Process

Regardless of what you are creating, follow this process:

### 1. Classify the Request

Use the Decision Tree above to determine: Skill, Agent, Sub-Agent, or Workflow.

If ambiguous, ASK the user. Do not guess.

### 2. Check for Duplicates

```
Search BatutaClaude/skills/ for existing skills with similar names.
Search CLAUDE.md for existing entries.
Search CLAUDE.md for existing context entries.
```

If a similar component exists, ask the user if they want to:
- **Extend** the existing component
- **Replace** it with a new version
- **Create** a separate component (confirm the naming difference)

### 3. Gather Requirements

Ask the user (if not already clear):

**For Skills:**
- What technology or pattern does this cover?
- What are the critical rules the AI must follow?
- Are there code examples or templates needed?
- Which projects will use this skill?

**For Agents:**
- What role does this agent play?
- What tools does it need?
- What skills should it reference?
- What are its scope boundaries?

**For Sub-Agents:**
- What phase of which pipeline does this serve?
- What does it receive from the orchestrator?
- What artifacts does it produce?
- What is the next step after it completes?

**For Workflows:**
- What is the slash command trigger?
- What skills are chained together?
- What arguments does it accept?
- What does the user see when it completes?

### 4. Create the Component

Use the appropriate template from [assets/](assets/):
- Skill: [assets/skill-template.md](assets/skill-template.md)
- Agent: [assets/agent-template.json](assets/agent-template.json)
- Sub-Agent: [assets/sub-agent-template.md](assets/sub-agent-template.md)
- Workflow: [assets/workflow-template.md](assets/workflow-template.md)

### 5. Register the Component

Follow the Registration Checklist for the component type. This step is MANDATORY.

### 6. Verify Registration

After registering, verify:
- [ ] The component appears in CLAUDE.md Available Skills table
- [ ] The component appears in the appropriate scope agent's Skills table (for skills and sub-agents)
- [ ] The file structure matches the expected layout
- [ ] The frontmatter is complete and valid

### 7. Report to User

Return a summary:

```markdown
## Component Created

**Type**: {Skill | Agent | Sub-Agent | Workflow}
**Name**: {component-name}
**Location**: {file path}

### What Was Created
- {List of files created}

### What Was Registered
- {List of files updated with registration entries}

### Next Steps
- {Any follow-up actions needed}

### What This Means (Simply)
{One paragraph explaining what was created and why it matters, in plain language.}
```

---

## Checklist Before Creating Any Component

- [ ] Component type identified (Skill / Agent / Sub-Agent / Workflow)
- [ ] Component does not already exist (checked `skills/`, CLAUDE.md, CLAUDE.md)
- [ ] Name follows naming conventions for its type
- [ ] Requirements are clear (or clarification has been requested)
- [ ] Appropriate template is being used
- [ ] Frontmatter is complete (description includes trigger keywords)
- [ ] Registration plan is clear (which files need updating)
- [ ] If planned in roadmap, roadmap entry will be updated

---

## Commands

| Command | Description |
|---------|-------------|
| `/create:skill <name>` | Create a new skill (technology, workflow, or project-type) |
| `/create:agent <name>` | Create a new agent definition for OpenCode |
| `/create:sub-agent <name>` | Create a new SDD-style sub-agent skill with envelope contract |
| `/create:workflow <name>` | Create a new workflow command with skill mapping |

---

## Resources

- **Templates**: See [assets/](assets/) for all component templates
  - [skill-template.md](assets/skill-template.md) -- Skill SKILL.md template
  - [agent-template.json](assets/agent-template.json) -- Agent definition template
  - [sub-agent-template.md](assets/sub-agent-template.md) -- Sub-agent SKILL.md template
  - [workflow-template.md](assets/workflow-template.md) -- Workflow definition template
- **Registration targets**: CLAUDE.md (Available Skills table — auto-generated by skill-sync)
- **Planned roadmap**: CLAUDE.md under "Project Skills" section
