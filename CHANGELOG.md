# Changelog

All notable changes to the Batuta ecosystem are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [14.3.0] - 2026-03-30

### Added
- **prd-generator skill** (skill #39): After Task Plan Approval, pipeline-agent generates `openspec/changes/{name}/PRD.md` — a consolidated brief of spec + design + tasks. Enables context reset between planning and execution sessions.
- **G1.5 Context Reset gate** (pipeline-agent): Informational gate between task plan approval and sdd-apply. Presents the generated PRD.md and recommends starting a fresh execution session. Does not block.
- **Discovery Depth rules** (pipeline-agent): Formally documented anti-shallow-loop protocol — read code before assuming, restate flows with specifics, mandatory Technical Assumptions section in proposals.
- **Output Tiers definitions** (pipeline-agent): detail_level definitions (`concise`/`standard`/`deep`) moved from CLAUDE.md into pipeline-agent where they're used.
- **Core Rule #0 — Research first**: Explicit chain (MCP → WebFetch → WebSearch) as the first core rule. Training data may be outdated — always verify.

### Changed
- **CLAUDE.md refactored**: 741 → 297 lines. Removed CTO Strategy Layer section (absorbed into pipeline-agent), Output Tiers section, Behavior section (merged into Session & Output rule), full Slice Sequencing detail, and verbose auto-routing (192 → 22 lines). CLAUDE.md is now operational context, not a routing system.
- **pipeline-agent.md expanded**: 246 → 295 lines. Absorbed Discovery Depth, Output Tiers, and G1.5 gate.
- **Auto-routing simplified**: Compressed from 192 lines to an intent classification table + 4 routing rules.
- **Version**: 14.0.0 → 14.3.0

### What This Means
CLAUDE.md was acting as a 741-line routing system, causing agents to lose track of rules mid-session. This version strips it to ~300 lines of operational context (personality, core rules, gates, commands) and moves the "how" details into pipeline-agent and skills where they belong. The PRD generation concept (inspired by PRD-first development patterns) creates a clean context reset between the planning and execution sessions — the planning session accumulates exploratory reasoning and rejected proposals; the execution session starts fresh with only the final approved decisions.

## [14.2.0] - 2026-03-25

### Added
- **Notion as Primary Memory**: Explicit priority chain for context restoration: `Interaction 0: Notion MCP → session.md → CHECKPOINT.md`. Notion is now queried at the start of every session if MCP is configured.
- **Notion KB auto-persistence**: Stop hook (STEP 2) evaluates CHECKPOINT.md content and automatically persists non-trivial gotchas/decisions to Notion KB (`data_source_id: 58433974`) without user approval. Filter: skip trivial items (step counts, timestamps, file paths).
- **Closed RAG loop formalized**: `Stop hook → CHECKPOINT.md (local) → Notion KB (indexed) → sdd-explore Step 2.8 (retrieves) → future agents learn from past sessions`.

### Changed
- **Session Budget enforcement**: session.md rules tightened — AC Status section lifecycle documented, Next Steps limited to 3 items max.
- **Skills loading fix**: 3-way detection logic in `session-start.sh` corrected — `.provisions.json` + local skills + global skills resolved in correct order.

### What This Means
Notion went from being a "nice to have" to the primary long-term memory. Each session end automatically indexes discovered gotchas into a searchable knowledge base. Future agents working on similar problems retrieve those learnings during exploration. The closed loop means Batuta gets smarter with every project without manual knowledge curation.

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
