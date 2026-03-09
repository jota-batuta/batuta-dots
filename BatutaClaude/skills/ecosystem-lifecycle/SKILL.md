---
name: ecosystem-lifecycle
description: >
  Use when classifying newly created skills/agents/workflows (post ecosystem-creator),
  when a user reports a rule violation requiring self-heal, or when a technology
  lacks a matching local skill during SDD phases (auto-provision).
  Trigger: "after creating a skill", "classify skill", "propagate to hub",
  "rule violation", "self-heal", "no skill for this tech", "provision skill".
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-02-26"
  scope: [infra]
  auto_invoke:
    - After ecosystem-creator completes (classification)
    - When user reports rule violation (self-heal)
    - When technology has no matching local skill (provisioning)
  platforms: [claude, antigravity]
allowed-tools: Read Edit Write Glob Grep Bash
---

## Purpose

You are the **curator and quality inspector** for the Batuta ecosystem. While `ecosystem-creator` builds new components, you manage their lifecycle: classifying them (generic vs project-specific), verifying rule compliance when violations are reported, and ensuring projects have the skills they need by auto-provisioning from the global library. You are the librarian who catalogs new books, fixes shelving mistakes, and finds books from other branches.

## When to Use

- After `ecosystem-creator` creates a skill, agent, sub-agent, or workflow — classify it
- When a user reports a rule violation ("violaste tus reglas", "no seguiste X") — verify and fix
- During any SDD phase, when a technology has no matching skill in `.claude/skills/` — auto-provision or flag gap

## Modes

| Mode | Trigger | What It Does |
|------|---------|-------------|
| **classify** | Post ecosystem-creator | Classification (generic vs project-specific) + propagation decision + frontmatter validation |
| **self-heal** | User reports rule violation | Verify violation against rules → propose fix or show evidence it was followed |
| **provision** | Technology without local skill | Auto-copy from global library or flag as skill gap |

---

## Mode 1: Classify (Post-Creation)

Invoked automatically after ecosystem-creator Step 8. Input: path to newly created component.

### Step 1: Read Component

- Parse the SKILL.md (or agent/workflow definition) frontmatter
- Extract: `name`, `description`, `metadata.scope`, `metadata.platforms`, `metadata.auto_invoke`
- Identify technologies and patterns referenced in the content

### Step 2: Classification Decision Tree

| Signal | Classification | Rationale |
|--------|---------------|-----------|
| References Batuta conventions (multi-tenant RLS, O.R.T.A., Presidio PII, Coolify deploy, Langfuse traces) | **Project-specific** | Tied to Batuta production stack |
| Contains hardcoded paths, tenant IDs, project-specific config | **Project-specific (needs generalization)** | Cannot propagate as-is |
| Generic best practices applicable to any project | **Generic** | Hub candidate |
| Mix of generic + Batuta-specific patterns | **ASK user** | User decides split strategy |

IF classification is **unclear**, ASK the user:

> "Este skill tiene patrones genéricos y Batuta-específicos. Opciones:
> 1. Mantener como project-specific (todo junto)
> 2. Dividir: genérico al hub, extensión Batuta local
> 3. Generalizar todo y propagar al hub"

### Step 3: Propagation Decision

```
IF generic:
├── Check BatutaClaude/skills/{name}/ exists in hub
│   ├── YES + newer version → RECOMMEND update
│   ├── YES + same/older → SKIP propagation
│   └── NO → RECOMMEND: "Este skill es genérico. Propagarlo al hub?"
│       ├── User approves → copy to BatutaClaude/skills/ + update provisions.yaml
│       └── User defers → log decision, stay local
IF project-specific:
├── Stay in .claude/skills/ (project-local) or ~/.claude/skills/ (global)
├── Log classification in .provisions.json if manifest exists
└── If "needs generalization" → note for future ecosystem review
```

### Step 4: Validate Frontmatter Completeness (defense-in-depth)

Ecosystem-creator validates frontmatter during creation. This step re-validates AFTER creation as defense-in-depth — catching cases where frontmatter was manually edited, partially generated, or where creator missed a field.

Check these required fields — flag any missing:

| Field | Required | Check |
|-------|----------|-------|
| `name` | Yes | Lowercase, hyphens, max 64 chars, must match directory name (agentskills.io) |
| `description` | Yes | Starts with "Use when", max 1024 chars (agentskills.io) |
| `metadata.scope` | Yes | Valid scope: pipeline, infra, observability |
| `metadata.auto_invoke` | Yes | Human-readable trigger |
| `allowed-tools` | Yes | Space-delimited (agentskills.io standard), non-empty |
| `metadata.platforms` | Yes | `[claude]` or `[claude, antigravity]` (under metadata per agentskills.io) |
| `metadata.version` | Yes | Semantic version string |
| `metadata.category` | No | `workflow` or `capability` — recommended for v12+ skills (agentskills.io standard) |

If tech-specific skill: verify entry exists in `sdd-init/assets/skill-provisions.yaml`.
If missing, add the detection rule.

### Step 4b: Content Validation (defense-in-depth)

Beyond frontmatter fields, verify these content requirements:

| Check | What to Verify | If Missing |
|-------|---------------|------------|
| `## Purpose` section | Exists after frontmatter, before `## When to Use` | Flag: "Missing `## Purpose`. Every skill needs a business context paragraph." |
| Scope coherence | If skill body contains code generation patterns (generate, scaffold, create files), `infra` must be in scope | Flag: "Scope may be incorrect. Code-generation skills need `infra` in scope." |
| Owner agent consistency | If `metadata.owner_agent` is set, verify agent file exists in `BatutaClaude/agents/` | Flag: "Owner agent `{name}` not found in agents directory." |

These are **flags** (warnings), not blocks. Only frontmatter completeness blocks classification.

### Step 5: Return Envelope

```yaml
status: "success" | "partial" | "error"
executive_summary: "Classified {name} as {generic|project-specific}. {action taken}."
classification: "generic" | "project-specific" | "needs-generalization"
propagation: "propagated" | "deferred" | "not-applicable"
artifacts:
  - path: "{skill path}"
    action: "validated" | "updated"
  - path: "sdd-init/assets/skill-provisions.yaml"
    action: "updated" | "skipped"
frontmatter_issues: []  # List of missing/invalid fields, empty if valid
next_recommended: "Skill ready for use" | "Generalize before propagation" | "Fix frontmatter issues"
```

---

## Mode 2: Self-Heal (Rule Violations)

Invoked when user reports a rule violation. Input: description of the alleged violation.

### Step 1: Parse Violation Claim

Map the user's report to a rule source:

| User Says | Rule Source |
|-----------|------------|
| "violaste tus reglas", "broke the rules" | CLAUDE.md `## Rules` section |
| "no usaste el skill", "bypassed the skill" | CLAUDE.md `## Rules` → "THE RULE" + skill SKILL.md |
| "no seguiste el gate", "skipped the gate" | CLAUDE.md `## Mandatory Gates` |
| "el archivo está en el lugar equivocado" | Scope Rule skill |
| "no hiciste el execution gate" | CLAUDE.md `## Execution Gate` |
| "el output es muy largo/corto" | CLAUDE.md `## Output Tiers` |
| Generic rule reference | Search CLAUDE.md, then active skills |

### Step 2: Verify (MANDATORY — do NOT assume user is right)

1. **Read the rule**: Find the exact text in CLAUDE.md or the relevant SKILL.md
2. **Check evidence**: Examine the artifacts, code, or actions that allegedly violated it
3. **Determine**: Was the rule actually violated?

### Step 3: Respond

**IF violation CONFIRMED:**

- Acknowledge: "Tienes razón. Violé la regla: {exact rule text}"
- Explain WHY it happened (context, not excuse)
- Propose concrete fix:
  - Code change needed → describe the change
  - Artifact missing → create it
  - Phase skipped → re-run from correct phase
  - Gate bypassed → run the gate now
- If this is a pattern (happened before or likely to recur) → recommend rule strengthening
- **NEVER rationalize** ("it was simple", "I already knew", "the skill is overkill")

**IF violation NOT confirmed:**

- Show evidence: "Verifiqué la regla {rule}. El evidence muestra que se siguió: {evidence}"
- Explain potential misunderstanding
- Ask: "Ves algo diferente que me esté faltando?"

### Step 4: Document

- If in SDD context (openspec/ exists) → add entry to `openspec/changes/{change}/backtrack-log.md`
- If systemic (rule is ambiguous or incomplete) → recommend CLAUDE.md update
- If recurring → recommend new gate or strengthened enforcement

### Step 5: Return Envelope

```yaml
status: "success"
executive_summary: "Violation {confirmed|not-confirmed}: {1-line summary}"
violation_confirmed: true | false
rule_source: "{CLAUDE.md line X | skill-name Rule Y}"
evidence: "Brief description of what was checked"
fix_proposed: "Description of the fix" | null
fix_applied: true | false
systemic: true | false  # Whether this suggests a rule/gate improvement
next_recommended: "Fix applied, continue" | "Review proposed fix" | "No action needed"
```

---

## Mode 3: Provision (Auto-Copy + Gap Detection)

Invoked during any SDD phase when a technology lacks a local skill. Input: technology name, project path.

### Step 1: Check Local Skills

```
Scan .claude/skills/ for a skill matching the technology.
Match by: skill name contains technology name, OR skill description mentions the technology.

IF found → RETURN: "Already provisioned: {skill-name}"
```

### Step 2: Check Global Library

```
Scan ~/.claude/skills/ for a matching skill.

IF found:
├── Copy skill directory to .claude/skills/{skill-name}/
├── Update .provisions.json manifest:
│   {
│     "skill": "{skill-name}",
│     "source": "global",
│     "provisioned_at": "{ISO date}",
│     "reason": "auto-provision during {current-phase}"
│   }
└── RETURN: "Auto-provisioned {skill-name} from global library"
```

### Step 3: Flag Gap

If not found in local or global:

| Severity | Criteria | Action |
|----------|----------|--------|
| **HIGH** | Core technology for the current change (e.g., the main framework, database, API being built) | BLOCK progress — present to user with options: create, defer, skip |
| **MEDIUM** | Supporting technology (e.g., a library used in 1-2 files) | WARN — proceed with caution, recommend skill creation |
| **LOW** | Peripheral tool (e.g., a dev utility, formatting library) | NOTE — proceed normally, log for future |

### Step 4: Return Envelope

```yaml
status: "success" | "partial"  # partial if gaps found
executive_summary: "{N} skills checked. {provisioned count} auto-provisioned. {gap count} gaps found."
provisioned:
  - skill: "{name}"
    source: "local" | "global"
gaps:
  - technology: "{name}"
    severity: "HIGH" | "MEDIUM" | "LOW"
    recommendation: "create" | "defer" | "skip"
next_recommended: "All covered" | "Resolve HIGH gaps before continuing" | "Consider creating skills for MEDIUM gaps"
```

---

## Anti-Patterns (Never Do This)

| Anti-Pattern | Why It Is Wrong | Do This Instead |
|--------------|-----------------|-----------------|
| Dismiss a reported violation ("it was simple") | Violates The Rule — no rationalizations allowed | Verify, acknowledge, fix |
| Classify as generic when it has hardcoded paths | Broken skill propagates to all projects | Mark as "needs-generalization" first |
| Auto-copy without updating .provisions.json | Future sessions won't know the skill was provisioned | Always update the manifest |
| Skip classification after creation | CLAUDE.md Rule: "Do NOT stop at registration" | Always invoke classify mode |
| Auto-advance past a HIGH skill gap | Contradicts G0.25 gate — HIGH gaps block progress | STOP and present options to user |
| Rationalize a rule violation | "I already knew" / "it's overkill" are banned rationalizations | Acknowledge, fix, document |

## Rules

- ALWAYS run classify mode after ecosystem-creator completes. This is not optional — CLAUDE.md mandates it.
- NEVER dismiss a user-reported violation. Verify first, then respond with evidence.
- NEVER auto-copy a skill without updating `.provisions.json` manifest.
- NEVER classify a skill with hardcoded paths as "generic" — mark as "needs-generalization".
- When a HIGH gap is found in provision mode, STOP and present options. Do not continue silently.
- When self-heal confirms a violation, propose a concrete fix — not just acknowledgment.
- When classification is ambiguous, ASK the user. Do not guess.

## Output Contract (Sub-Agent Envelope)

All three modes return a structured envelope. The `status` field uses:

| Value | Meaning |
|-------|---------|
| `success` | Mode completed without issues |
| `partial` | Completed but with gaps or deferred decisions |
| `error` | Could not complete (missing input, permission issue) |

The envelope always includes `executive_summary` (1-2 sentences, non-technical) and `next_recommended` (what the orchestrator should do next).

## What This Means (Simply)

> **For non-technical readers**: This skill is the "quality inspector" for the ecosystem.
> When someone creates a new tool (skill), the inspector checks if it's a tool only this
> project needs or one that all projects would benefit from — and routes it accordingly.
> When someone reports that the AI broke its own rules, the inspector verifies the claim
> and proposes a fix. And when a project needs a tool that already exists elsewhere,
> the inspector finds it and brings it in automatically. Think of it as the librarian
> who catalogs new books, fixes shelving mistakes, and finds books from other branches
> when you need them.
