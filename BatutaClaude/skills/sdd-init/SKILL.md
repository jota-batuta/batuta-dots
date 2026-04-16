---
name: sdd-init
description: >
  Use when starting SDD in a new project, bootstrapping openspec/. /sdd-init
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2025-01-01"
  bucket: define
  auto_invoke: "Starting SDD workflow, /sdd-init"
  platforms: [claude, antigravity]
allowed-tools: Read Edit Write Glob Grep Bash
---

## Purpose

You are a sub-agent responsible for bootstrapping the Spec-Driven Development (SDD) structure in a project. You initialize the `openspec/` directory and optionally create the project config.

You operate as part of the Batuta system: CTO and Technical Mentor for Batuta software factory. Patient educator who documents for non-technical stakeholders.

## Execution and Persistence Contract

From the orchestrator:
- `artifact_store.mode`: `auto | engram | openspec | none`

Resolution:
- If mode resolves to `openspec`, run full bootstrap and create `openspec/`.
- If mode resolves to `engram`, do not create `openspec/`; save detected project context to Engram.
- If mode resolves to `none`, return detected context without writing project files.

## What to Do

### Step 1: Detect Project Context

Read the project to understand:
- **Tech stack** (check package.json, go.mod, pyproject.toml, requirements.txt, Dockerfile, docker-compose.yml, coolify configs, temporal workflows, n8n exports, etc.)
- **Project type** — classify as one of: `webapp` | `automation` | `ai-agent` | `infrastructure` | `data-pipeline` | `library`
- **Existing conventions** (linters, test frameworks, CI)
- **Architecture patterns** in use (multi-tenant RLS, event-driven, workflow orchestration, agent graphs, etc.)

#### Empty Project Handling

If the project directory is empty (no package.json, no source files, no config files):
1. **Do NOT guess** the tech stack — there is nothing to detect
2. **ASK the user** for: project type, intended tech stack, and brief description
3. Use the user's answers to populate `config.yaml` context
4. Note in the config: `detected_from: user_input (empty project)`

This is common for new projects initialized via `/batuta-init`. The user's description from `/sdd-explore` will provide the real context.

#### Project Type Detection Heuristics

| Signal | Likely Type |
|---|---|
| Next.js, React, frontend routes, portal UI | `webapp` |
| n8n workflow exports, cron jobs, event triggers | `automation` |
| LangChain/LangGraph/Google ADK, agent definitions, tool schemas | `ai-agent` |
| Dockerfiles, Coolify configs, Terraform, Pulumi, Ansible | `infrastructure` |
| ETL scripts, Temporal workflows, data transforms, pipeline DAGs | `data-pipeline` |
| pyproject.toml with build-system, setup.py, package publishing config | `library` |

<!-- Stack Awareness: contextualized for this phase. See sdd-explore for base reference. -->
#### Batuta Stack Detection

Actively look for these technologies common in Batuta projects:
- **Workflow orchestration**: Temporal.io workers/workflows, n8n workflow JSON exports
- **AI/ML**: Python with LangChain, LangGraph, Google ADK (Agent Development Kit)
- **Databases**: PostgreSQL with multi-tenant RLS policies, Redis for caching/queues
- **Observability**: Langfuse for LLM tracing, structured logging
- **Privacy**: Presidio for PII detection/anonymization
- **Deployment**: Coolify configurations, Docker Compose, container definitions
- **Frontend**: Next.js portal application

### Step 2: Initialize Persistence Backend

If mode resolves to `openspec`, create this directory structure:

```
openspec/
├── config.yaml              <- Project-specific SDD config
├── specs/                   <- Source of truth (empty initially)
└── changes/                 <- Active changes
    └── archive/             <- Completed changes
```

### Step 3: Generate Config (openspec mode)

Based on what you detected, create the config when in `openspec` mode:

```yaml
# openspec/config.yaml
schema: spec-driven

project_type: {detected type: webapp | automation | ai-agent | infrastructure | data-pipeline | library}

context: |
  Tech stack: {detected stack}
  Architecture: {detected patterns}
  Testing: {detected test framework}
  Style: {detected linting/formatting}
  Multi-tenancy: {yes/no, with RLS strategy if detected}
  Orchestration: {Temporal/n8n/none}

documentation:
  strategy: {auto-detected based on project_type}
  # One of: api-reference | runbook | user-guide | sdk-docs | architecture-decision-records | mixed
  audiences:
    - developers
    - {additional audiences based on project_type}
  formats:
    - markdown
    - {additional formats if detected: openapi, asyncapi, mermaid, etc.}
  locations:
    specs: openspec/specs/
    decisions: openspec/decisions/
    runbooks: openspec/runbooks/

rules:
  proposal:
    - Include rollback plan for risky changes
    - Identify affected modules/packages
    - For multi-tenant changes, specify tenant isolation impact
  specs:
    - Use Given/When/Then format for scenarios
    - Use RFC 2119 keywords (MUST, SHALL, SHOULD, MAY)
    - For ai-agent projects, include tool-call and fallback scenarios
    - For automation projects, include trigger conditions and error recovery
  design:
    - Include sequence diagrams for complex flows
    - Document architecture decisions with rationale
    - For data-pipeline projects, include data lineage diagrams
    - For infrastructure projects, include deployment topology
  tasks:
    - Group tasks by phase (infrastructure, implementation, testing)
    - Use hierarchical numbering (1.1, 1.2, etc.)
    - Keep tasks small enough to complete in one session
  apply:
    - Follow existing code patterns and conventions
    - Load relevant coding skills for the project stack
    - For Temporal workflows, ensure idempotency and retry policies
    - For RLS-enabled databases, validate tenant isolation in every query
  verify:
    - Run tests if test infrastructure exists
    - Compare implementation against every spec scenario
    - For ai-agent projects, verify tool schemas and fallback behavior
    - For multi-tenant projects, verify tenant data isolation
  archive:
    - Warn before merging destructive deltas (large removals)
    - Document decisions for non-technical stakeholders when applicable
```

#### Documentation Strategy by Project Type

| Project Type | Strategy | Extra Audiences | Extra Formats |
|---|---|---|---|
| `webapp` | `mixed` | product-owners, end-users | openapi, mermaid |
| `automation` | `runbook` | operations, business-analysts | mermaid |
| `ai-agent` | `architecture-decision-records` | product-owners, compliance | mermaid |
| `infrastructure` | `runbook` | operations, security | mermaid |
| `data-pipeline` | `architecture-decision-records` | data-analysts, business-analysts | mermaid |
| `library` | `sdk-docs` | external-developers | openapi |

### Step 3.5: Generate Domain Experts (Optional)

If the project involves domain-specific business logic (finance, HR, legal, etc.), offer to create a `domain-experts.md` file:

```
ASK USER: "Este proyecto tiene dominios de negocio especificos?
  (1) Finanzas/Contabilidad  (2) RRHH/Seleccion  (3) Legal/Regulatorio
  (4) Inventario/Logistica   (5) Otro             (6) No aplica"
```

If the user selects one or more, generate `openspec/domain-experts.md`:

```markdown
# Domain Experts — {Project Name}

## Expert: {Domain Name}
- **Scope**: What this expert validates
- **Key rules**: Business rules the system must respect
- **Terminology**: Domain-specific terms and their definitions
- **Validation criteria**: How to verify domain correctness
- **Approver**: Who decides when rules are ambiguous
```

Pre-configured templates available for Finance (Colombian tax, NIIF, NIT validation) and HR (competency frameworks, Colombian labor law basics).

If user says "No aplica", skip this step entirely.

### Step 3.7: Generate Project-Level Hooks (Recommended)

Generate `.claude/settings.local.json` with deterministic hook enforcement using the supported hooks (SessionStart and Stop):

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "cat .batuta/session.md 2>/dev/null || echo 'No session context found. Run /sdd-init to bootstrap.'"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/session-save.sh"
          }
        ]
      }
    ]
  }
}
```

**Why**: Without project-level hooks, session continuity depends on Claude "remembering" the rules from CLAUDE.md — which is not deterministic. These hooks make context injection and session persistence automatic.

If `.claude/settings.local.json` already exists, READ it first and MERGE (do not overwrite).

### Step 3.8: Project Skill Provisioning (Auto-Scope)

Provision the project with ONLY the skills and MCPs it needs based on detected technologies. This reduces context noise from 33+ global skills to typically 12-16 relevant ones.

**Principle**: "El agente solo ve lo que el proyecto necesita. Contexto limpio = decisiones claras."

Read the provisioning map from `assets/skill-provisions.yaml` (relative to this skill's location, or `~/.claude/skills/sdd-init/assets/skill-provisions.yaml`).

#### Step 3.8.0 — Pre-check: Verify Global Library

Before provisioning, verify the global skill library is populated:

```bash
ls ~/.claude/skills/ 2>/dev/null | head -1
```

**If `~/.claude/skills/` is empty or missing**:
- DO NOT write `.provisions.json`. An empty manifest locks session-start.sh to an empty
  local dir permanently (PATH 1 blocks the global fallback).
- Inform the user:
  "⚠ La biblioteca global de skills (`~/.claude/skills/`) está vacía o no existe.
   Antes de continuar, ejecuta este comando desde la carpeta de batuta-dots:
   ```bash
   ./infra/setup.sh --all
   ```
   Esto sincroniza skills, agents y hooks al directorio global. Dime cuando termine."
- **STOP** — do not advance to Phase 1 until the user confirms setup.sh --all completed.

#### Phase 1 — Build Provision Set

Using the tech stack detected in Step 1:

```
PROVISION MATCHING:
1. Start with: always[] + sdd[] → 13 skills baseline
2. For each tech_rule in skill-provisions.yaml:
   a. Check file signals: do any files[] exist in the project?
   b. Check content_pattern: grep dependency files for regex matches
   c. Check project_type: does it match Step 1 detection?
   d. Check context_mentions: do any keywords appear in user's description or project docs?
   e. If ANY signal matches → add rule's skills[] to provision set
3. Deduplicate the provision set
```

#### Phase 2 — Copy Skills to Project

```
FOR EACH skill in provision set:
1. Source: ~/.claude/skills/{skill-name}/
   (fallback: look in BatutaClaude/skills/{skill-name}/ if hub is available)
2. If source exists:
   a. Create .claude/skills/{skill-name}/ in project
   b. Copy SKILL.md
   c. Copy assets/ directory if it exists
   d. Log: "✓ Provisioned: {skill-name}"
3. If source NOT found:
   a. Log: "⚠ Skill '{skill-name}' not found in global library — skip"
```

Create `.claude/skills/` directory if it does not exist.

#### Phase 3 — Generate Project .mcp.json

Using the MCP rules from `skill-provisions.yaml`:

```
1. Start with: mcp_rules.always (context7, semgrep, sequential-thinking)
2. For each MCP rule in mcp_rules:
   a. Evaluate detection signals (same as tech_rules)
   b. If match → add MCP config to .mcp.json
3. For env vars with placeholders (YOUR_*_HERE):
   → Keep placeholders — user fills in real values
4. Write .mcp.json to project root
5. If .gitignore exists and .mcp.json not in it:
   → Append .mcp.json to .gitignore (may contain secrets after user edits)
```

#### Phase 3.5 — Cross-Reference Tech Skills with MCPs

After generating `.mcp.json` from `mcp_rules`, cross-reference the `tech_rules` entries
to suggest additional MCPs that complement the provisioned skills:

```
1. For each matched tech_rule from Phase 1:
   a. If rule has mcps[] field → collect those MCP names
   b. Check if each MCP is already in .mcp.json (from Phase 3)
   c. If not yet configured → add to "suggested MCPs" list
2. For each suggested MCP:
   a. Look up its config in mcp_rules (by name)
   b. If found → add to .mcp.json automatically
   c. If NOT found in mcp_rules → log as recommendation only
3. Present a summary table of MCPs by source:
```

**MCP Summary Table (show to user)**:

```markdown
| MCP | Source | Status | Why |
|-----|--------|--------|-----|
| semgrep | Global (always) | Ready | Security scanning — always active |
| sequential-thinking | Global (always) | Ready | Complex reasoning support |
| context7 | Global (always) | Ready | Live documentation lookup |
| {name} | Detected: {tech_rule match} | Ready / Needs ENV | {AI Pyramid layer / skill mapping} |

**MCPs requiring configuration**:
- {name}: Set `{ENV_VAR}` in `.mcp.json` with your {description}
```

This cross-reference ensures that when a technology is detected (e.g., SQLAlchemy triggers
`sqlalchemy-models` skill), the complementary MCP (e.g., `postgres`) is also provisioned
without requiring a separate detection pass.

#### Phase 4 — Write Provisions Manifest

Write `.claude/skills/.provisions.json`:

```json
{
  "schema_version": "1.0",
  "provisioned_at": "{ISO-8601 timestamp}",
  "provisioned_by": "sdd-init/3.8",
  "source": "~/.claude/skills/",
  "project_type": "{detected project type from Step 1}",
  "tech_detected": ["{tech1}", "{tech2}", "..."],
  "skills": ["{skill1}", "{skill2}", "..."],
  "mcps_generated": ["{mcp1}", "{mcp2}", "..."],
  "reprovisioned": []
}
```

This manifest signals to `session-start.sh` that the project is provisioned and should use project-scoped skill discovery (local only, no global scan).

#### Phase 5 — Present Summary

Show the user what was provisioned (non-interactive — no approval needed per skill):

```markdown
### Project Skill Provisioning Complete

**Skills provisioned ({count}/{total_available})**:
- **Always**: scope-rule, ecosystem-creator, security-audit, team-orchestrator
- **SDD Pipeline**: 9 SDD phase skills
- **Tech-matched**: {list of tech-specific skills} (detected: {technologies})

**Not provisioned** (available in global library if needed later):
- {list of skipped skills with reason}

**MCPs configured ({count})**:
| MCP | Source | Status | Action Required |
|-----|--------|--------|-----------------|
| semgrep | Global (always) | Ready | None — security scanning is always active |
| sequential-thinking | Global (always) | Ready | None — complex reasoning support |
| context7 | Global (always) | Ready | None — live documentation lookup |
| {name} | Detected: {technology} | Ready / Placeholder | {None / Set ENV_VAR in .mcp.json} |

> To add skills later: `/sdd-explore` Skill Gap Detection will detect missing skills and offer to copy them from the global library.
> To add MCPs later: Phase 3.5 cross-references tech_rules with mcps fields automatically.
```

### Step 3.9: Agent Provisioning (v13)

After skill provisioning (Step 3.8), provision agents from the same `skill-provisions.yaml`.

Agents are domain specialists with embedded expertise. Unlike skills (which provide patterns and templates), agents carry coordination-level knowledge and team context for Agent Teams.

#### Phase 1 — Always Agents

```
1. Read `always_agents` from skill-provisions.yaml
2. For each agent in the list:
   a. Source: ~/.claude/agents/{agent-name}.md
      (fallback: BatutaClaude/agents/{agent-name}.md if hub is available)
   b. If source exists:
      - Create .claude/agents/ directory if it does not exist
      - Copy {agent-name}.md to .claude/agents/
      - Log: "Provisioned agent: {agent-name} (always)"
   c. If source NOT found:
      - Log: "Agent '{agent-name}' not found in global library — skip"
```

#### Phase 2 — Technology-Detected Agents

```
1. Read `agent_rules` from skill-provisions.yaml
2. For each rule:
   a. Check detection signals (same logic as tech_rules in Step 3.8):
      - content_pattern: grep dependency files for regex matches
      - project_type: match against Step 1 detection
   b. If ANY signal matches → collect rule's agents[]
3. Deduplicate against already-provisioned agents (from Phase 1)
4. For each matched agent:
   a. Copy from ~/.claude/agents/ (or hub fallback) to .claude/agents/
   b. Log: "Provisioned agent: {agent-name} (detected: {technology})"
```

#### Phase 3 — Update Provisions Manifest

Update `.claude/skills/.provisions.json` to include provisioned agents:

```json
{
  "skills": ["...existing skills..."],
  "agents": [
    {"agent": "pipeline-agent", "source": "global", "provisioned_at": "2026-03-09", "reason": "always"},
    {"agent": "quality-agent", "source": "global", "provisioned_at": "2026-03-09", "reason": "always"},
    {"agent": "backend-agent", "source": "global", "provisioned_at": "2026-03-09", "reason": "detected: fastapi"},
    {"agent": "data-agent", "source": "global", "provisioned_at": "2026-03-09", "reason": "detected: langchain"}
  ]
}
```

#### Phase 4 — Present Summary

Append agent provisioning to the Step 3.8 summary:

```markdown
**Agents provisioned ({count})**:
- **Always**: pipeline-agent, infra-agent, observability-agent, quality-agent
- **Tech-matched**: {list of domain agents} (detected: {technologies})

> To add agents later: `sdd-explore` Skill Gap Detection can also identify missing domain agents.
```

### Step 4: Return Summary

Return a structured summary:

```
## SDD Initialized

**Project**: {project name}
**Type**: {detected project_type}
**Stack**: {detected stack}
**Location**: openspec/

### Structure Created
- openspec/config.yaml    <- Project config with detected context
- openspec/specs/         <- Ready for specifications
- openspec/changes/       <- Ready for change proposals

### Documentation Strategy
- **Strategy**: {detected strategy}
- **Audiences**: {list of audiences}
- **Formats**: {list of formats}

### Next Steps
Ready for /sdd-explore <topic> or /sdd-new <change-name>.
```

## Rules

- NEVER create placeholder spec files — specs are created via sdd-spec during a change
- ALWAYS detect the real tech stack, don't guess
- ALWAYS classify the project_type — if ambiguous, pick the dominant type and note secondary concerns in context
- If the project already has an `openspec/` directory, report what exists and ask the orchestrator if it should be updated
- Keep config.yaml context CONCISE — no more than 10 lines
- Documentation strategy MUST be set based on project_type detection, not hardcoded
- When documenting for non-technical stakeholders, use plain language and avoid jargon in summaries
- Return a structured envelope with: `status`, `executive_summary`, `detailed_report` (optional), `artifacts`, `next_recommended`, and `risks`

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "My project is too simple for SDD" | Simple projects become complex projects faster than expected. The cost of `openspec/` is one directory; the cost of NOT having it shows up the first time you need to coordinate a change. |
| "I'll add SDD when the project grows" | Retrofitting SDD onto a sprawling codebase is 10x harder than bootstrapping it now. Init takes minutes; back-filling takes weeks. |
| "Tech detection is unreliable, I'll skip it" | The detection heuristics are documented and explicit. If detection is wrong, override the result — but skipping it produces a `config.yaml` with no project context, breaking downstream skills. |
| "Skip provisioning, all skills work globally" | Global skills produce context noise (33+ skills). Provisioning trims to ~12-16 relevant skills, making the agent's decisions sharper. |
| "Hooks are optional, I'll set them up later" | Without hooks, session continuity depends on Claude "remembering" — which is non-deterministic. Init is the right moment to make context injection automatic. |

## Red Flags

- `openspec/` directory missing after sdd-init claimed success
- `config.yaml` present but `context` field empty or filled with placeholder text
- `project_type` set to `webapp` for a project with no frontend (heuristics ignored)
- `.claude/skills/.provisions.json` missing despite Phase 4 completing
- `.mcp.json` missing despite MCP rules matching the detected stack
- `.claude/agents/` directory empty despite agent provisioning Phase 1+2
- Empty project case: tech stack guessed instead of asking the user
- `~/.claude/skills/` is empty AND `.provisions.json` was written anyway (locks the project to empty local dir)
- Documentation strategy hardcoded instead of derived from project_type table

## Verification Checklist

- [ ] `openspec/` directory created with `config.yaml`, `specs/`, `changes/`, `changes/archive/`
- [ ] `config.yaml` `project_type` matches detected signals (or user-confirmed for empty projects)
- [ ] `config.yaml` `context` field documents real tech stack (not placeholder)
- [ ] Documentation strategy and audiences match the project_type table
- [ ] `.claude/settings.local.json` includes SessionStart + Stop hooks (merged if pre-existing)
- [ ] `.claude/skills/` populated with provisioned skills + `.provisions.json` manifest
- [ ] `.mcp.json` generated with always-on MCPs + tech-detected MCPs
- [ ] `.claude/agents/` populated with always_agents + tech-detected agents
- [ ] Pre-check verified `~/.claude/skills/` is populated before writing `.provisions.json`
- [ ] Summary returned to orchestrator includes detected stack + provisioned skills + MCP table
