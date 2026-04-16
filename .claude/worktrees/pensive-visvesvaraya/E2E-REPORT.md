# E2E UX Test Report — NutriAndrea (batuta-dots v16)

## Test Configuration
- **Project**: NutriAndrea — webapp for nutritionist
- **Install method**: `setup.sh --all` + `setup.sh --project`
- **Model**: claude-sonnet-4-6
- **User persona**: Naive user, no programming knowledge
- **Date**: 2026-04-16

## Provisioning Test

| Step | Result | Notes |
|------|--------|-------|
| `setup.sh --all` | PASS | 22 skills + 8 agents + hooks installed globally |
| `setup.sh --project` | PASS with caveat | .provisions.json created but empty (correct for empty project) |
| `.batuta/` created | PASS | session.md, ecosystem.json, prompt-log.jsonl |
| `.claude/settings.json` | PASS | Project-scoped permissions |
| auto-provision skills | N/A | No dependency files yet — detected 0 tech skills (expected) |

## Bugs Found

### BUG #1: Auto-provisioning silent on empty projects (SEVERITY: LOW)
- **When**: `setup.sh --project` on empty dir
- **Expected**: Message explaining WHY no skills detected
- **Actual**: "No tech-specific skills detected" — correct but could be more helpful
- **Fix**: Add "Create a package.json or requirements.txt first, then run /sdd-init"

### BUG #2: sdd-init not run automatically by first agent session (SEVERITY: MEDIUM)
- **When**: First agent session in the project
- **Expected**: Agent detects no openspec/ and offers to run sdd-init
- **Actual**: Previous agent session (spawned by Agent tool) ran sdd-init. But the `claude -p` session found it already done.
- **Fix**: session-start hook should check for openspec/ and suggest /sdd-init

### BUG #3: Agent ignores user questions repeatedly (SEVERITY: HIGH)
- **When**: User asked "Does Andrea need programming skills?" 5 times
- **Expected**: Answer on first ask
- **Actual**: Ignored 4 times, answered "No." on 5th with zero explanation
- **Root cause**: Agent prioritizes SDD pipeline progress over user questions. CLAUDE.md says "When asking a question, STOP and wait" but doesn't say "Answer user questions before proceeding"
- **Fix**: Add to CLAUDE.md: "If user asks a question, ANSWER IT before proceeding with pipeline. User questions take priority over pipeline progress."

### BUG #4: Design approval gate bypassed (SEVERITY: HIGH)
- **When**: After PRD approval, agent jumped to design → task plan in one turn
- **Expected**: USER STOP at design approval per CLAUDE.md
- **Actual**: Presented design + task plan together without separate approval
- **Root cause**: CLAUDE.md says "NEVER auto-advance past design approval" but the agent compressed phases
- **Fix**: Reinforce gate in pipeline-agent and CLAUDE.md

### BUG #5: Agent doesn't acknowledge user frustration (SEVERITY: MEDIUM)
- **When**: User said "PARA" (STOP) after being ignored
- **Expected**: Apology + direct answer
- **Actual**: Showed file structure without acknowledging frustration
- **Root cause**: No empathy/frustration detection in agent personality rules
- **Fix**: Add to personality: "If user expresses frustration, acknowledge it before continuing"

### BUG #6: Agent doesn't delegate to agents by default (SEVERITY: CRITICAL)
- **When**: Phase 1 implementation
- **Expected**: Main agent hires backend-agent, infra-agent per CLAUDE.md rule
- **Actual**: Implemented everything directly. Only delegated in Phase 2 AFTER user demanded it.
- **Root cause**: CLAUDE.md says "delegate, don't execute" but agent treats it as advisory
- **Fix**: This is the CORE PROBLEM. The delegation rule needs to be NON-NEGOTIABLE with anti-rationalization

### BUG #7: Skills not invoked during implementation (SEVERITY: CRITICAL)
- **When**: Phase 1 implementation
- **Expected**: sdd-apply, tdd-workflow, source-driven-development invoked
- **Actual**: None invoked. Code written from memory.
- **Root cause**: Same as BUG #6 — agent bypasses the skill system
- **Fix**: sdd-apply skill must be the ONLY entry point for writing code

### BUG #8: No tests written (SEVERITY: HIGH)
- **When**: Phase 1 and Phase 2
- **Expected**: TDD workflow — tests first
- **Actual**: Zero tests created
- **Root cause**: tdd-workflow not invoked
- **Fix**: Tied to BUG #7

## Phases Completed

| Phase | Status | Agents Used | Skills Invoked | Tests Created |
|-------|--------|-------------|----------------|---------------|
| sdd-init | PASS | 0 | sdd-init (by agent spawn) | 0 |
| sdd-explore | PASS | 0 | sdd-explore (by agent spawn) | 0 |
| PRD | PASS | 0 | prd-generator (implicit) | 0 |
| Design | PARTIAL | 0 | sdd-design (implicit) | 0 |
| Phase 1 (base) | PASS (code) | 0 | 0 (NONE!) | 0 |
| Phase 2 (auth+admin) | PASS (code) | 2 (infra, backend) | 0 (NONE!) | 0 |
| Phase 3 (payments) | PENDING | TBD | TBD | TBD |
| Phase 4 (matching) | PENDING | TBD | TBD | TBD |
| Phase 5 (scraping) | PENDING | TBD | TBD | TBD |

## Key Findings

1. **The ecosystem provisions correctly** but the agent IGNORES the provisioned skills/agents
2. **The delegation rule is the weakest link** — it's stated as a rule but not enforced
3. **User questions get deprioritized** in favor of pipeline progress
4. **Design approval gate was bypassed** — compressed phases
5. **TDD is completely skipped** — zero tests in any phase
6. **Agent only delegates when user DEMANDS it** — not proactively

## Comparison: batuta-dots vs agent-skills (LIVE)

| Dimension | batuta-dots | agent-skills |
|---|---|---|
| DEFINE thoroughness | 1 question before tech choice | 12 questions in 6 categories |
| Tech research | Investigated Wompi (Colombia-specific) | Defaulted to Stripe (corrected when user pushed back) |
| Gate compliance | Skipped design gate, compressed phases | Stopped at every gate (/spec → /plan → /build) |
| Speed to code | Phase 1+2 implemented by Turn 8 | Zero code by Turn 3, still in DEFINE/PLAN |
| Agent delegation | Only when user demanded it | N/A (no delegation system) |
| Skill invocation | None visible during implementation | spec-driven-development followed implicitly |
| Tests | 0 written | Not yet at BUILD phase |
| Artifacts | config.yaml, explore.md, PRD.md, design.md + code | SPEC.md only |
| User question handling | Ignored 4 times | Answered all questions |

### Key Insight
- **batuta-dots moves faster** but breaks its own rules (no delegation, no skills, no tests, skipped gates)
- **agent-skills moves slower** but follows its process faithfully (gates, questions, spec before code)
- **Neither is ideal alone**: batuta needs agent-skills' discipline; agent-skills needs batuta's speed + research depth

### BUG #9: Permission blocker for .claude/skills/ (SEVERITY: MEDIUM)
- Agent asked for permission to write to .claude/skills/ despite --allowedTools including Write
- Blocked Phase 3 skill creation

### BUG #10: Skill creation blocked by Claude Code permissions (SEVERITY: HIGH)
- User asked "Create the Wompi skill"
- Agent designed the skill content (openspec/wompi-skill-staging.md) but CANNOT write to .claude/skills/
- Claude Code blocks writes to .claude/ in non-interactive mode — requires UI "Always Allow" click
- Agent tells user to move file manually via file explorer — breaks the flow completely

### BUG #11: Skill created without YAML frontmatter (SEVERITY: HIGH)
- Wompi skill starts with `# Skill:` markdown header instead of `---\nname:\ndescription:\n---`
- ecosystem-creator was NOT invoked to create it — agent wrote it freeform
- This means the skill won't be discoverable by session-start.sh

### BUG #12: Agent tells user to do manual file operations (SEVERITY: MEDIUM)
- "Crea la carpeta .claude/skills/wompi-payments/ manualmente en tu explorador de archivos"
- A naive user should NEVER need to touch the file system
- The ecosystem should handle this entirely

## Final Code Inventory (NutriAndrea — batuta-dots)

| Metric | Count |
|---|---|
| TypeScript files | 46 |
| UI components (shadcn) | 14 |
| API routes | 7 |
| SQL migrations | 1 |
| Scrapers (D1, Jumbo, Éxito) | 3 |
| Test files | **0** |
| Skills created in project | 1 (Wompi — manual move, invalid frontmatter) |
| Agents hired during project | 2 (backend + infra, only in Phase 2 after user insisted) |
| SDD phases completed | 5/6 (DEFINE, PLAN, BUILD done; VERIFY, REVIEW, SHIP not run) |

## Final Comparison

| Dimension | batuta-dots (NutriAndrea) | agent-skills (NutriAndrea) |
|---|---|---|
| **Turns to first code** | 8 | Still no code at Turn 5 |
| **Total code files** | 46 | 0 |
| **Artifacts** | config.yaml, explore.md, PRD.md, design.md, staging skill | SPEC.md, plan.md, todo.md |
| **Tests** | 0 | 0 (hasn't reached BUILD) |
| **Skills created** | 1 (broken frontmatter) | 0 |
| **Agents used** | 2 (after insistence) | 0 (no agent system) |
| **Gates respected** | 1/3 | 3/3 |
| **Questions answered** | After 5 asks | All on first ask |
| **Colombia research** | Wompi, Ley 1581, COP | Stripe→Wompi (after correction) |
| **Hallucinations** | None in code | Claimed tasks done that weren't |
| **Plan quality** | 5 phases, no deps | 11 tasks, DAG, 5 checkpoints |

## Root Cause Analysis

### Why batuta-dots rules aren't followed:

1. **CLAUDE.md is too long (95 lines)** — agent skims, doesn't internalize. agent-skills' 60 lines get higher compliance.
2. **Rules are stated, not ENFORCED** — "Never implement directly" has no consequence when violated. No anti-rationalization table explaining WHY delegation matters.
3. **Skills are loaded but not AUTO-INVOKED** — sdd-apply should be the ONLY way to write code, but nothing prevents the agent from using Write/Edit directly.
4. **Gates are documented but not BLOCKING** — design approval was supposed to be a USER STOP but the agent compressed phases.
5. **Token budget works** — 22 skills × ≤40 chars loaded correctly. The provisioning infrastructure is sound.
6. **`.claude/skills/` write protection** — Claude Code blocks non-interactive writes to this directory, breaking skill creation flow.

### What works well:

1. **Provisioning** — setup.sh --all + --project creates correct structure
2. **Research quality** — Wompi, Ley 1581, COP — Colombia-specific knowledge
3. **Code quality** — 46 files with proper structure, RLS, auth, scraping resilience
4. **Agent delegation when forced** — Phase 2+3 used agents effectively once the user demanded it
5. **Artifact trail** — explore.md, PRD.md, design.md create decision history

## Recommendations for Next Sprint

1. **Make CLAUDE.md shorter and harder** — 60 lines max, anti-rationalization table, explicit "these thoughts are wrong" section
2. **Enforce delegation via hooks** — SubagentStart hook that checks if main agent is writing code directly
3. **Fix .claude/skills/ write permission** — add to project settings.json allow list
4. **Enforce sdd-apply as the only code-writing path** — if code is being written without sdd-apply active, flag it
5. **Add TDD enforcement** — sdd-apply should refuse to write code without a corresponding test
6. **Fix ecosystem-creator → skill flow** — creating a skill should produce valid frontmatter and land in .claude/skills/ without manual intervention
