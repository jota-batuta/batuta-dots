# Changelog

All notable changes to the Batuta ecosystem are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## v15.3.0 — 2026-04-15 — Plugin Install Fixes (SSH auth + curated subset)

### Critical Fixes

**Fix 1: SSH authentication failure**
- `.claude-plugin/marketplace.json` now uses `source: url` with explicit HTTPS URL
- Previous: `{"source": "github", "repo": "jota-batuta/batuta-dots"}` → Claude Code attempted SSH clone → failed without SSH keys
- Now: `{"source": "url", "url": "https://github.com/jota-batuta/batuta-dots.git"}` → uses HTTPS (works with any git credential helper)
- Repo made public (was private) — required for plugin system to clone without auth

**Fix 2: Plugin was installing ALL 46 skills (wrong)**
The plugin.json previously pointed at `BatutaClaude/skills/` which contains all 46 skills. On install, Claude Code would load all 46 skill metadata entries, exceeding the ~450 token budget and making ~33% invisible.

- Created `.claude-plugin/skills/` with ONLY the 17 essential skills (5 always + 8 SDD core + 4 v15.1 meta)
- Created `.claude-plugin/agents/` with 8 agents (5 workers + 3 reviewers)
- Created `.claude-plugin/commands/` with 12 slash commands
- Updated plugin.json to point at these curated directories (`./skills/`, `./agents/`, `./commands/`)
- Domain-specific skills (icg-erp, evolution-api, compliance-colombia, google-adk, etc.) now correctly stay in BatutaClaude/skills/ only — project-provisioned via /batuta-init when relevant tech is detected

### New Infrastructure
- **infra/sync-plugin.sh** — Syncs BatutaClaude/skills|agents|commands → .claude-plugin/ subset
- Run after modifying any essential skill/agent to keep plugin in sync
- Essential skills list hardcoded in script (must match setup.sh `global_skills` array)

### Result

Plugin install now gives user:
- 17 essential skills (not 46) — fits within metadata budget
- 8 agents (5 workers + 3 reviewers)
- 12 slash commands

Bash installer unchanged — still provisions per-project based on tech detection.

### Installation (updated)

```bash
# Via plugin (recommended)
/plugin marketplace add jota-batuta/batuta-dots
/plugin install batuta-dots

# Or via bash (provisioning-aware)
install-batutadots
```

VERSION: 15.2.0 → 15.3.0

## v15.2.0 — 2026-04-15 — Skill Standardization + Plugin Foundation + Provisioning Fixes

### Skill Standardization (43 skills)
All pre-v15.1 skills updated to the standard 7-section format:
- Overview, When to Use, When NOT to Use, Core Sections (preserved), Common Rationalizations, Red Flags, Verification Checklist
- **Common Rationalizations** tables document the excuses agents use to skip each skill, paired with factual rebuttals (pattern adapted from addyosmani/agent-skills MIT)
- **Red Flags** section documents specific signals that a skill is being violated
- **Verification Checklist** provides objective completion criteria
- All skill versions bumped

The 3 v15.1 skills (code-simplification, deprecation-and-migration, git-workflow-and-versioning) already had the standard format.

### Critical Provisioning Fixes
- **Ghost references removed**: `skill-provisions.yaml` line 43 referenced `fastapi-crud` and `jwt-auth` (archived in v15.0). Replaced with `api-design` which is the v15-compatible alternative. FastAPI projects will now provision correctly.
- **v15.1 meta skills documented**: Added `v15_1_meta` section to `skill-provisions.yaml` listing agent-hiring, code-simplification, deprecation-and-migration, git-workflow-and-versioning as ecosystem-essential meta skills.
- **New tech_rules**:
  - `prefect-flows` — triggers on Prefect 3+ detection in requirements.txt or prefect.yaml
  - `pydantic-ai` — triggers on pydantic-ai package detection

### Plugin Foundation
batuta-dots is now installable as a native Claude Code plugin:
- `.claude-plugin/plugin.json` — plugin manifest declaring skills/, agents/, commands/, hooks/ locations
- `.claude-plugin/marketplace.json` — marketplace manifest for `/plugin marketplace add jota-batuta/batuta-dots`
- Bash installer remains as fallback for backward compatibility
- Future: split into `batuta-core` (essential, always) + `batuta-specialized` (optional per tech stack) when repository separation is needed

### Installation (two methods now supported)

**Method 1: Plugin marketplace (recommended for v15.2+)**
```
/plugin marketplace add jota-batuta/batuta-dots
/plugin install batuta-dots@batuta-ecosystem
```

**Method 2: Bash installer (existing)**
```
install-batutadots
```

### Deferred
- Repository separation (batuta-core vs batuta-specialized) — next iteration when plugin ecosystem matures
- Dynamic skill loading via fetch commands — decided NOT to pursue (security risk, against plugin philosophy)

### Attribution
Common Rationalizations, Red Flags, Verification Checklist patterns adapted from addyosmani/agent-skills v0.5.0 (MIT License).

## v15.1.0 — 2026-04-15 — agent-skills Integration

### New Skills (adapted from addyosmani/agent-skills, MIT License)
- **code-simplification** — Chesterton's Fence, Rule of 500, language-specific refactor patterns. Preserves behavior while reducing complexity.
- **deprecation-and-migration** — Code-as-liability mindset, zombie code removal, feature flag lifecycle, compulsory vs advisory deprecation.
- **git-workflow-and-versioning** — Trunk-based development, atomic commits, commit-as-save-point pattern, Build Cop role.

### New Agent Personas (read-only reviewers)
Workers escriben codigo. Reviewers auditan. Nueva separacion:
- **code-reviewer** — Senior Staff Engineer perspective. Evalua calidad, mantenibilidad, scope rule compliance.
- **test-engineer** — QA Specialist. Audita coverage, test quality, pyramid balance.
- **security-auditor** — Security Engineer. Threat modeling, OWASP, RLS validation. Model: opus (deep reasoning).

Reviewers tienen tools read-only (Read, Grep, Glob) — no pueden modificar codigo. Reportan issues y handoff a workers.

### New Infrastructure
- **SIMPLIFY-IGNORE.md + hooks/simplify-ignore.sh** — Glob patterns que el code-simplification skill nunca toca (vendor/, migrations/, generated/, .batuta/, etc.)
- **references/** folder — 4 deep checklists separados de skills:
  - security-checklist.md (OWASP Top 10)
  - performance-checklist.md (Core Web Vitals)
  - accessibility-checklist.md (WCAG 2.1 AA)
  - testing-patterns.md (pyramid, DAMP/DRY)

### CLAUDE.md Updates (+32 lines → 137 total)
- **Skill-Driven Execution section**: Si hay skill aplicable, el agente DEBE invocarla. Intent-to-Skill mapping table.
- **Review Layer section**: Workers vs Reviewers distinction. Flow: sdd-apply → code-reviewer, sdd-verify → test-engineer, security-audit → security-auditor.

### Installation Changes
- **setup.sh --sync** ahora copia 17 skills globales (era 13). Adiciones: agent-hiring, code-simplification, deprecation-and-migration, git-workflow-and-versioning.
- Reviewer personas se copian a ~/.claude/agents/ (8 agents globales, era 5).

### Attribution
Inspired by and adapted from:
- https://github.com/addyosmani/agent-skills v0.5.0 (MIT License)

Specific adaptations: 3 skills, 3 reviewer personas, 4 references, SIMPLIFY-IGNORE pattern, Skill-Driven Execution rule, Workers vs Reviewers separation.

### Pending for v15.2
- Standardize ALL 43 skills with 7-section format (Overview, When to Use, When NOT to Use, Core, Common Rationalizations, Red Flags, Verification Checklist). v15.1 only applies this format to the 3 new skills; the other 40 retain their v15 format and will be batch-updated iteratively.
- Full reformulation of llm-pipeline-design, process-analyst, recursion-designer with concrete gates (flagged REFORMULATE in v15 audit).

## v15.0.0 — 2026-04-13 — Simplification Refactor

### Breaking Changes
- CLAUDE.md rewritten: 331 → 77 lines. Removed: personality, philosophy, tone, expertise, 8 gates, auto-routing table, detail_level, slice sequencing, execution gate
- SDD pipeline: 9 phases → 2 modes (SPRINT default: apply→verify | COMPLETO: explore→design→apply→verify)
- Gates: 8 → 1 (design approval in COMPLETO mode only)
- Agents: 11 → 5 (removed batovf-builder, batovf-copywriter, batovf-deployer, batovf-qa, batovf-supervisor, observability-agent)
- Commands: removed sdd-spec, sdd-archive. Simplified sdd-ff (2 steps), sdd-continue (mode-aware)
- PRD replaces 5-artifact chain (explore+propose+spec+design+tasks) as single planning artifact

### New Features
- PRD as single planning artifact (prd-generator v2.0). CTO writes in Notion, Code reads via MCP
- session.md updates on EVERY interaction (not just at session close)
- Notion KB updates CONSTANTLY during implementation (not batch at archive)
- Forced archival rule: when pivoting, old artifacts → archive/ + SUPERSEDED.md
- SPRINT mode as default (zero gates, zero ceremony)

### Bug Fixes
- setup-antigravity.sh: corrected GitHub URL (batuta → jota-batuta)
- setup.sh: resolve_home() validates USERPROFILE directory exists before use
- session-start.sh: json_escape() fallback produces correct literal \n

### Why
0 of ~20 projects reached production. Root causes: state fragmentation (5 contradictory sources), ceremony overhead (46 tasks for a CRUD), tooling detours. v15 addresses all three with: 1 source of truth (session.md), 2 modes (SPRINT/COMPLETO), constant Notion sync.

## [14.1.0] - 2026-03-20

### Added
- **CHECKPOINT.md** (`.batuta/CHECKPOINT.md`): Operational state capture between compactions. Captures what session.md cannot: current step, failed attempts, in-progress decisions, discovered gotchas. Written by the Stop hook on every exit — no exceptions.
- **Stop Hook — 3-step protocol**: (1) Always write CHECKPOINT.md with full template. (2) Auto-persist non-trivial gotchas and decisions to Notion KB — no user approval needed. (3) Update session.md if significant work done.
- **SessionStart — CHECKPOINT.md injection**: If `.batuta/CHECKPOINT.md` exists, it is automatically injected as "Operational Checkpoint" context. No manual lookup needed after compaction or session resume.
- **MUST rules in CLAUDE.md Core**: Two non-advisory rules — MUST write CHECKPOINT.md before any sequence of 3+ consecutive tool calls; after compaction, read CHECKPOINT.md BEFORE taking any action.
- **Sub-agent visible reasoning** (Behavior): When launching sub-agents via Task tool, the prompt must include explicit reasoning documentation — what was discovered, what was tried and failed, decisions with justification. Sub-agents have no visible thinking blocks.
- **Closed RAG Loop**: Stop hook → CHECKPOINT.md (local) → Notion KB (indexed, searchable) → sdd-explore Step 2.8 retrieves → future agents learn from past sessions' gotchas and decisions.

### What This Means
Two improvements to prevent context loss: (1) When Claude Code's context gets compressed ("compacted"), it used to forget everything it had tried and decided mid-task. Now a mandatory checkpoint is written on every stop, automatically restored on resume. (2) Non-trivial discoveries (gotchas, workarounds, architectural decisions) are automatically saved to the Notion knowledge base at session end — making them searchable in future projects. Notion acts as a cheap, queryable long-term memory (RAG).

## [14.0.0] - 2026-03-14

### Added
- **Approach Research Gate** (sdd-explore Step 2.8): Searches Notion KB and web for existing approaches before proposing options. Prevents reinvention when solutions already exist.
- **Existing Solutions Check** (sdd-apply Step 1.5 expansion): Checks if libraries/APIs identified during Approach Research are installed, evaluates install+adapt vs build custom.
- **Notion KB Persistence** (sdd-archive Step 5.5): Extracts transcendent knowledge from completed changes and proposes Notion KB entries. Advisory only — does not block archiving.
- **CTO Artifact Detection** (CLAUDE.md Step 3a, pipeline-agent Rule 10): Detects pre-existing SDD artifacts in `openspec/changes/` from the CTO layer and skips completed phases.
- **BATUTA CONFIG `artifacts_from` field**: Optional flag signaling SDD artifacts were pre-generated by CTO layer.
- **Notion MCP server**: Added `@notionhq/notion-mcp-server` to mcp-servers.template.json.

### What This Means
Two improvements: (1) The agent now searches for existing approaches before building custom — checking both the company's Notion knowledge base and the web. (2) When the CTO produces SDD artifacts from Claude.ai and copies them to the repo, Claude Code detects them and continues from where the CTO left off instead of re-doing discovery.
