---
name: ecosystem-lifecycle
description: >
  Use when a skill or workflow was just created (post-creation classification),
  when the user reports a rule violation (self-heal), when a technology is detected
  without a provisioned skill (continuous provisioning), or when skills need
  syncing between project and hub (propagation).
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-02-26"
  scope: [infra]
  auto_invoke: "After skill creation, rule violation reported, or technology detected without provisioned skill"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch, WebSearch
platforms: [claude, antigravity]
---

# Ecosystem Lifecycle — Autonomous Ecosystem Management

## Purpose

Manages the lifecycle of skills, MCPs, and agent rules AFTER creation. Four autonomous
behaviors that eliminate manual bash operations and make the ecosystem self-managing.

The ecosystem-creator skill CREATES components. This skill MANAGES their lifecycle:
classification, propagation, self-healing, and continuous provisioning.

---

## When to Invoke

| Trigger | Behavior | Section |
|---------|----------|---------|
| ecosystem-creator finishes creating a skill | Classify + offer propagation | Behavior 1 |
| User reports rule violation ("violaste tus reglas") | Self-heal protocol | Behavior 2 |
| Any SDD phase detects tech without provisioned skill | Continuous provisioning | Behavior 3 |
| User says "sincroniza mis skills" or auto-routing detects sync need | Hub sync | Behavior 4 |

---

## Behavior 1: Post-Creation Classification

After ecosystem-creator registers a new skill, evaluate whether it should stay
local or propagate to the batuta-dots hub.

### Classification Decision Tree

```
READ the created SKILL.md frontmatter and body

CHECK indicators:

GENERIC indicators (→ hub candidate):
  ✓ No project-specific paths (no hardcoded /path/to/project)
  ✓ No project-specific tenant IDs, API keys, or config
  ✓ Technology is general (FastAPI, SQLAlchemy, Redis, Temporal, etc.)
  ✓ Skill is useful in 2+ project types
  ✓ MCP is universal (Context7, GitHub, Playwright, sequential-thinking)

SPECIFIC indicators (→ stays local):
  ✗ References project-specific schemas, tables, or API endpoints
  ✗ References a single client/tenant by name
  ✗ MCP has project-specific connection strings (this project's Postgres URI)
  ✗ Skill only makes sense in this project's domain

RESULT:
  All generic indicators + no specific indicators → GENERIC
  Any specific indicator → PROJECT-SPECIFIC
  Mixed signals → AMBIGUOUS (ask user)
```

### Classification Output

Present to the user:

> "El skill **{name}** parece **{genérico/específico del proyecto}**.
> Razón: {evidence — 1-2 sentences}.
>
> 1. **Propagar al hub** batuta-dots (disponible en todos los proyectos)
> 2. **Mantener solo en este proyecto**
> 3. Déjame decidir después"

If user selects (1) → proceed to Propagation (below).
If user selects (2) → done, skill stays in `.claude/skills/`.
If user selects (3) → log in `.batuta/session.md` under "Pending Decisions".

### Skip Classification When

- Skill was created directly in batuta-dots (already in hub)
- Skill was copied from global to project (already exists in hub)
- User explicitly said "solo para este proyecto" during creation

---

## Propagation Protocol

When a skill is approved for hub propagation, the agent handles ALL operations
internally. The user NEVER types bash commands.

### Steps

```
1. LOCATE batuta-dots
   ├── Check: E:/BATUTA PROJECTS/batuta-dots/ (configured path)
   ├── Fallback: ~/batuta-dots/
   ├── Fallback: /tmp/batuta-dots/
   └── If not found: STOP → "No encuentro batuta-dots. Clónalo primero."

2. ENSURE FRESH
   ├── cd to batuta-dots
   ├── git pull origin master (BLOCKING — if fails, STOP and explain)
   └── If dirty tree: STOP → "batuta-dots tiene cambios sin commit."

3. COPY SKILL
   ├── cp -r .claude/skills/{name}/ → batuta-dots/BatutaClaude/skills/{name}/
   ├── Verify SKILL.md has platforms field
   └── If platforms includes 'antigravity':
       └── Run internally: bash infra/sync.sh --to-antigravity

4. PRESENT CHANGES
   ├── Show: "Estos archivos cambiaron en batuta-dots: {list}"
   ├── Show: git diff --stat
   └── Ask: "¿Hago commit y push?"

5. ON USER APPROVAL
   ├── git add BatutaClaude/skills/{name}/ BatutaAntigravity/skills/{name}/
   ├── git commit -m "feat(skills): add {name} from {project}"
   └── git push

6. UPDATE LOCAL ECOSYSTEM
   └── Update .batuta/ecosystem.json: add to skills_shared[]
```

### MCP Propagation

Same protocol applies to universal MCPs:

- Universal MCPs (Context7, GitHub, Playwright) → add to `skill-provisions.yaml`
  under `mcp_rules` with appropriate detection signals
- Project-specific MCPs (this project's Postgres URI) → stay in project `.mcp.json`
- Present: "Este MCP ({name}) es universal. ¿Lo agrego al template de provisioning?"

---

## Behavior 2: Self-Heal Protocol

When the user reports that the agent violated its own rules.

### Trigger Patterns

Detect natural language matching:
- "violaste tus reglas" / "you violated your rules"
- "tu CLAUDE.md dice X pero hiciste Y"
- "no seguiste el execution gate" / "saltaste el scope rule"
- "por qué no usaste el skill?" / "why didn't you use the skill?"
- "esto debería ser una regla" / "this should be a rule"

### Self-Heal Steps

```
1. IDENTIFY — What rule was violated?
   a. Read CLAUDE.md (project root + .claude/CLAUDE.md if exists)
   b. Search for the rule the user references
   c. If rule found: proceed to step 2
   d. If rule NOT found: "No encuentro esa regla en CLAUDE.md.
      ¿Quieres que la agregue?"
      → If yes: skip to step 3 (propose new rule)

2. VERIFY — Did the agent actually violate it?
   a. Review recent actions in this session
   b. Check artifacts created, files modified, decisions made
   c. If NOT violated: explain with evidence
      "Verifiqué mi comportamiento: {evidence}. No hubo violación porque {reason}."
   d. If VIOLATED: acknowledge and continue to step 3
      "Tienes razón. Violé la regla '{rule}' cuando {action}."

3. ROOT CAUSE — Why was the rule violated?
   a. Rule is ambiguous? (two valid interpretations)
   b. Rule contradicted by another rule?
   c. Rule has no enforcement mechanism (cognitive-only, no gate)?
   d. Missing skill that would have caught this?
   e. Rule exists but is buried/hard to find?

4. PROPOSE FIX — Draft a specific patch
   a. If rule is ambiguous → propose clarification text
   b. If rule is missing → propose new section with clear language
   c. If enforcement needed → propose adding to Execution Gate or auto-routing
   d. If skill needed → propose creating a skill (invoke ecosystem-creator)
   e. Show the proposed diff:
      "Propongo este cambio a CLAUDE.md:
       ```diff
       - {old text}
       + {new text}
       ```"

5. ⛔ MANDATORY STOP — Present fix, wait for approval
   NEVER auto-apply rule changes. The user is the final authority on rules.

6. APPLY WITH AUTHORIZATION (if approved)
   a. Update CLAUDE.md in the CURRENT PROJECT (immediate effect)
   b. Locate batuta-dots hub (same as Propagation step 1)
   c. Update BatutaClaude/CLAUDE.md (source of truth for all projects)
   d. If the rule also applies to Antigravity:
      → Update BatutaAntigravity/GEMINI.md with equivalent rule
   e. Present: "Cambios listos en batuta-dots. ¿Hago commit y push?"
   f. On approval: commit + push
   g. Run /batuta-update internally to refresh ~/.claude/ cache
   h. Log the self-heal in .batuta/session.md:
      "Self-heal: regla '{rule}' → {fix description}"
```

### Self-Heal for New Rules

When the user says "esto debería ser una regla" (not a violation, but a new rule):

1. Understand what behavior to codify
2. Draft the rule text (clear, enforceable, with examples)
3. Identify where in CLAUDE.md it belongs (which section)
4. Same approval + propagation flow as above

---

## Behavior 3: Continuous Provisioning

Skills are provisioned during `/sdd-init`, but technology needs emerge at ANY phase.
This behavior ensures skills arrive when needed, not just at project start.

### When It Triggers

During ANY SDD phase (except sdd-explore which has its own Step 2.5):
- Agent encounters a technology, framework, or library
- Agent checks: is there a skill for this in `.claude/skills/` (project)?
- If NO → continuous provisioning activates

### Provisioning Flow

```
1. DETECT — Technology X is being used without a provisioned skill

2. CHECK GLOBAL — Does ~/.claude/skills/{X-skill}/ exist?
   ├── YES → Auto-copy to .claude/skills/{X-skill}/ (SILENT, no user prompt)
   │         Update .provisions.json: add to skills[] and reprovisioned[]
   │         Log: "Skill {X-skill} provisionado automáticamente desde biblioteca global"
   │
   └── NO  → Trigger Skill Gap Detection (INTERACTIVE)
             Present options (same as infra-agent):
             1. Create skill in project
             2. Create skill globally
             3. Continue without skill

3. RELOAD — Skill is now available for the current phase
```

### When NOT to Trigger

- Standard language features (Python basics, JS fundamentals, CSS)
- Technology already has an active skill in `.claude/skills/`
- During sdd-explore (which has its own Skill Gap Detection at Step 2.5)
- One-off scripts explicitly marked as throwaway

### Re-Provisioning After Update

When `/batuta-update` refreshes the global library (`~/.claude/skills/`):
1. Read `.provisions.json` → `tech_detected` list
2. Check if new skills in global match the tech stack
3. If match → auto-copy to project (same silent flow as above)
4. Report: "Nuevos skills disponibles tras actualización: {list}"

---

## Behavior 4: Hub Sync (Internal Operations)

The agent handles all sync operations internally. The user NEVER types bash commands.

### Internal Sync Operations

| Operation | Internal command | When |
|-----------|-----------------|------|
| Refresh project from hub | `bash "$BATUTA_DOTS/infra/setup.sh" --update "$(pwd)"` | /batuta-update or post-self-heal |
| Cross-sync to Antigravity | `bash "$BATUTA_DOTS/infra/sync.sh" --to-antigravity` | After propagating a skill |
| Import project skills to hub | Copy files + `sync.sh --to-antigravity` | /batuta-sync or post-classification |

### Transparency Rule

Always tell the user what you're doing:
- "Actualizando el ecosistema desde batuta-dots..."
- "Sincronizando skills al subfolder de Antigravity..."
- "Refrescando la caché global en ~/.claude/..."

NEVER show the bash commands to the user. They see natural language, not flags.

---

## Two-Layer Configuration System

### Problem
`setup.sh --update` overwrites CLAUDE.md with `cp -f`, destroying project-specific rules.

### Solution
Two configuration layers:

| Layer | File | Managed by | Updated by hub? |
|-------|------|------------|-----------------|
| Hub layer | `CLAUDE.md` (project root) | batuta-dots | YES — always overwritten |
| Project layer | `.claude/CLAUDE.md` | User / agent | NEVER — preserved across updates |

Claude Code reads BOTH files. `.claude/CLAUDE.md` takes priority for this project.

### What Goes Where

**Hub layer (CLAUDE.md root)** — universal rules:
- Personality, tone, language
- SDD pipeline, auto-routing, execution gate
- Scope Rule, skill routing, provisioning
- This file is the "operating system" — same for all projects

**Project layer (.claude/CLAUDE.md)** — project-specific overrides:
- Custom naming conventions
- Domain-specific rules ("all prices include IVA")
- Override defaults ("skip compliance-colombia for this project")
- Project-specific MCP instructions
- Custom auto-routing patterns for this domain

### Migration
If a project has customizations directly in root CLAUDE.md (detected by
`## Project Customizations` marker), `setup.sh --update` migrates them
to `.claude/CLAUDE.md` before overwriting the root.
