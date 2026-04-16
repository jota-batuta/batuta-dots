---
name: skill-eval
description: >
  Use when testing, evaluating, or benchmarking skills to verify they change agent
  behavior as intended. /skill:eval <name>, /skill:benchmark
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-03-09"
  bucket: meta
  auto_invoke: "Testing skills, evaluating skill effectiveness, benchmarking skills"
  platforms: [claude, antigravity]
  category: capability
allowed-tools: Read Glob Grep Bash Task
---

## Purpose

You are the **quality gate for the Batuta skill ecosystem**. Every skill claims to
change agent behavior -- you verify that claim empirically. You spawn controlled
sub-agent experiments: one WITHOUT the skill loaded (the RED baseline) and one WITH
the skill loaded (the GREEN test), then compare the results against defined criteria.

This is the automated evolution of the manual RED-GREEN-REFACTOR pattern that
ecosystem-creator used at Step 5.5. Instead of relying on the creator's judgment,
you use structured test cases defined in `SKILL.eval.yaml` files to make skill
validation repeatable, comparable, and auditable.

> **What This Means (Simply):** Think of this skill as a "unit test runner" for AI
> skills. Just like you test code to make sure it works, this skill tests whether
> an AI instruction file (a skill) actually makes the AI behave differently. It runs
> the same task twice -- once without the skill and once with it -- and checks if the
> skill made the expected difference. If it did not, the skill needs improvement.

---

## When to Use

- After creating or modifying a skill, to verify it changes behavior as intended
- When a skill is suspected of being ineffective ("the agent ignores it")
- During periodic ecosystem health checks (benchmark mode)
- When ecosystem-creator Step 5.5 detects a `SKILL.eval.yaml` file
- When onboarding a new team member who wants to understand what skills do
- When comparing two versions of a skill to see which performs better

---

## Modes

### Mode Selection Decision Tree

```
What do you need?
|
+-- Test a specific skill against its eval cases
|   --> EVAL MODE
|   Command: /skill:eval <skill-name>
|
+-- A skill failed eval and you want to fix it
|   --> IMPROVE MODE
|   Command: /skill:eval <skill-name> --improve
|   (Also invoked automatically when eval mode returns FAIL)
|
+-- Assess the health of multiple skills at once
    --> BENCHMARK MODE
    Command: /skill:benchmark [--all | skill-name-1 skill-name-2 ...]
```

---

## Mode 1: Eval

**Purpose**: Run a skill's `SKILL.eval.yaml` test cases and produce a structured pass/fail verdict.

### Input

- `skill_name`: Name of the skill to evaluate (e.g., `scope-rule`, `ecosystem-creator`)
- Skill location: resolved from `BatutaClaude/skills/{skill_name}/` or `~/.claude/skills/{skill_name}/` or `.claude/skills/{skill_name}/`

### Process

```
Eval Mode
|
+-- 1. LOCATE — Find the skill and its eval file
|     +-- Read BatutaClaude/skills/{skill_name}/SKILL.md (or global/local path)
|     +-- Read BatutaClaude/skills/{skill_name}/SKILL.eval.yaml
|     +-- If SKILL.eval.yaml not found:
|         +-- STOP: "No eval cases found. Create SKILL.eval.yaml first,
|         |    or use ecosystem-creator assets/skill-eval-template.yaml as a starting point."
|         +-- Return status: error, reason: "missing_eval_file"
|
+-- 2. PARSE — Load and validate eval cases
|     +-- Parse YAML: extract skill name, version, cases[]
|     +-- Validate each case has: id, description, task, quality_criteria[], anti_criteria[]
|     +-- If validation fails: STOP with specific error per case
|
+-- 3. RED RUN — Baseline without skill (per case)
|     +-- For each case in cases[]:
|     |   +-- Spawn a sub-agent (Task tool) with this system prompt:
|     |   |   "You are an AI assistant. Complete the following task.
|     |   |    Do NOT load any skill files. Work from your general knowledge only.
|     |   |    Task: {case.task}"
|     |   +-- Capture the sub-agent's response as red_response
|     |   +-- Evaluate red_response against anti_criteria[]:
|     |   |   +-- For each anti_criterion: does the response exhibit this behavior?
|     |   |   +-- Record: red_matches_anti[] (boolean per criterion)
|     |   +-- Evaluate red_response against quality_criteria[]:
|     |       +-- For each quality_criterion: does the response satisfy this?
|     |       +-- Record: red_matches_quality[] (boolean per criterion)
|     +-- BUSINESS RULE: The RED run establishes the baseline. If the agent
|         already satisfies ALL quality_criteria WITHOUT the skill, the skill
|         may be redundant for this case. Flag it but do not fail.
|
+-- 4. GREEN RUN — Test with skill loaded (per case)
|     +-- For each case in cases[]:
|     |   +-- Read the full SKILL.md content
|     |   +-- Spawn a sub-agent (Task tool) with this system prompt:
|     |   |   "You are an AI assistant operating under the following skill.
|     |   |    Read and follow the skill instructions carefully.
|     |   |    --- SKILL START ---
|     |   |    {full SKILL.md content}
|     |   |    --- SKILL END ---
|     |   |    Task: {case.task}"
|     |   +-- Capture the sub-agent's response as green_response
|     |   +-- Evaluate green_response against quality_criteria[]:
|     |   |   +-- For each quality_criterion: does the response satisfy this?
|     |   |   +-- Record: green_matches_quality[] (boolean per criterion)
|     |   +-- Evaluate green_response against anti_criteria[]:
|     |       +-- For each anti_criterion: does the response exhibit this behavior?
|     |       +-- Record: green_matches_anti[] (boolean per criterion)
|     +-- BUSINESS RULE: The GREEN run must satisfy quality_criteria AND must NOT
|         exhibit anti_criteria behaviors. Both conditions must hold for PASS.
|
+-- 5. VERDICT — Compare RED vs GREEN per case
|     +-- For each case:
|     |   +-- PASS if:
|     |   |   (a) green_matches_quality ALL true
|     |   |   (b) green_matches_anti ALL false (no anti-behavior in GREEN)
|     |   |   (c) At least one quality_criterion improved from RED to GREEN
|     |   |       OR RED already passed all (skill reinforces correct behavior)
|     |   +-- FAIL if:
|     |   |   (a) Any green_matches_quality is false, OR
|     |   |   (b) Any green_matches_anti is true (skill did not prevent anti-behavior)
|     |   +-- PARTIAL if:
|     |       (a) Some quality_criteria pass but not all, AND
|     |       (b) No anti_criteria match (skill helps but incompletely)
|     +-- Overall verdict:
|         +-- ALL cases PASS --> skill verdict: PASS
|         +-- ANY case FAIL --> skill verdict: FAIL
|         +-- Mix of PASS and PARTIAL, no FAIL --> skill verdict: PARTIAL
|
+-- 6. REPORT — Return structured results
      +-- See Output Contract below
```

### Evaluation Criteria Assessment

When evaluating whether a sub-agent response matches a criterion (quality or anti),
use your judgment as a skilled reviewer. Criteria are written in natural language.

**Matching rules:**
- A quality_criterion is MET if the response demonstrates the described behavior,
  produces the described output, or follows the described process
- An anti_criterion is MATCHED (bad) if the response exhibits the failure mode
  described -- the agent does what the anti_criterion says WITHOUT being corrected
- When in doubt, lean toward FAIL -- false negatives (missing a real problem) are
  worse than false positives (flagging a non-issue) for skill quality

---

## Mode 2: Improve

**Purpose**: Take eval results with FAIL or PARTIAL verdicts, analyze root causes, and propose concrete edits to the SKILL.md that would fix the failures.

### Input

- `skill_name`: Name of the skill to improve
- `eval_results`: Output from a previous eval run (or run eval first if not provided)

### Process

```
Improve Mode
|
+-- 1. OBTAIN RESULTS — Get eval data
|     +-- If eval_results provided: use them
|     +-- If not: run Eval mode first, then continue with results
|     +-- If eval verdict is PASS: "Skill passed all cases. No improvements needed."
|         Return status: success, message: "no_improvements_needed"
|
+-- 2. ANALYZE — Root cause each failure
|     +-- For each FAIL or PARTIAL case:
|     |   +-- Compare red_response vs green_response
|     |   +-- Identify which quality_criteria were NOT met in GREEN
|     |   +-- Identify which anti_criteria WERE matched in GREEN
|     |   +-- Classify root cause:
|     |       +-- TRIGGER: Skill description does not activate for this task type
|     |       +-- INSTRUCTION: Skill body lacks the specific instruction needed
|     |       +-- ENFORCEMENT: Skill has the instruction but lacks enforcement rules
|     |       +-- CONFLICT: Skill instructions conflict with each other or with
|     |       |   the agent's base behavior
|     |       +-- SCOPE: Task is outside the skill's intended scope (not a bug)
|     +-- Record: failure_analysis[] with case_id, root_cause, evidence, proposed_fix
|
+-- 3. PROPOSE — Generate specific SKILL.md edits
|     +-- For each failure_analysis:
|     |   +-- Generate a concrete edit proposal:
|     |       +-- TRIGGER root cause --> modify description or "When to Use" section
|     |       +-- INSTRUCTION root cause --> add/modify a pattern or rule in body
|     |       +-- ENFORCEMENT root cause --> add to "Rules" section or strengthen
|     |       |   existing rule with MUST/NEVER language
|     |       +-- CONFLICT root cause --> resolve the conflict, explain tradeoff
|     |       +-- SCOPE root cause --> no edit needed, document as out-of-scope
|     +-- Present edits as diffs showing old_string --> new_string
|     +-- WORKAROUND: Edits are presented as text diffs, not applied directly,
|         because the user must approve changes to skill definitions.
|
+-- 4. REVIEW — Present to user
|     +-- Show each proposed edit with:
|     |   +-- Which case it fixes (case_id)
|     |   +-- Root cause classification
|     |   +-- The specific diff
|     |   +-- Expected impact on other cases (does this edit risk breaking passing cases?)
|     +-- MANDATORY STOP: Wait for user approval before applying any edit
|
+-- 5. APPLY & RE-EVAL — On approval
      +-- Apply approved edits to SKILL.md
      +-- Re-run Eval mode to verify fixes
      +-- If new failures appear: report them, do NOT auto-loop
      +-- Return: updated eval results with before/after comparison
```

### Root Cause Classification Reference

| Root Cause | Symptom | Typical Fix |
|-----------|---------|-------------|
| TRIGGER | GREEN response ignores skill entirely | Fix `description` field: add missing trigger words |
| INSTRUCTION | GREEN follows skill but misses specific behavior | Add pattern/rule to SKILL.md body |
| ENFORCEMENT | GREEN acknowledges rule but skips it | Add MUST/NEVER language in Rules section |
| CONFLICT | GREEN follows one rule but violates another | Resolve contradiction, add priority order |
| SCOPE | Task is genuinely outside skill's purpose | Add to "When NOT to use" section, adjust eval case |

---

## Mode 3: Benchmark

**Purpose**: Run eval mode across multiple skills and generate a consolidated health report. Useful for periodic ecosystem audits and tracking skill quality over time.

### Input

- `target`: `--all` (every skill with a SKILL.eval.yaml) or a list of skill names
- `output_path`: defaults to `docs/qa/benchmark-{YYYY-MM-DD}.md`

### Process

```
Benchmark Mode
|
+-- 1. DISCOVER — Find all skills with eval files
|     +-- Scan BatutaClaude/skills/*/SKILL.eval.yaml
|     +-- Scan ~/.claude/skills/*/SKILL.eval.yaml (if --all)
|     +-- Scan .claude/skills/*/SKILL.eval.yaml (if --all)
|     +-- If target is a list: filter to only named skills
|     +-- If no eval files found:
|         STOP: "No SKILL.eval.yaml files found. Use ecosystem-creator
|         assets/skill-eval-template.yaml to create eval cases."
|
+-- 2. EXECUTE — Run eval mode for each skill
|     +-- For each skill with eval file:
|     |   +-- Run Eval mode (Mode 1)
|     |   +-- Capture: verdict, case_count, pass_count, fail_count, partial_count
|     |   +-- Estimate token usage: count input/output tokens from sub-agent calls
|     |   +-- Record wall-clock time for each skill's eval
|     +-- BUSINESS RULE: Benchmark does NOT auto-run improve mode on failures.
|         It reports them for human review.
|
+-- 3. AGGREGATE — Compile results
|     +-- Calculate:
|     |   +-- Overall pass rate: total_pass / total_cases * 100
|     |   +-- Per-skill pass rate
|     |   +-- Total estimated token usage across all evals
|     |   +-- Total wall-clock time
|     |   +-- Skills with zero eval coverage (no SKILL.eval.yaml)
|     +-- Identify:
|         +-- Top performers: skills with 100% pass rate
|         +-- Needs attention: skills with any FAIL
|         +-- Partial coverage: skills with PARTIAL results
|         +-- No coverage: skills without SKILL.eval.yaml
|
+-- 4. REPORT — Generate markdown report
      +-- Write to output_path (default: docs/qa/benchmark-{YYYY-MM-DD}.md)
      +-- See Benchmark Report Format below
      +-- Return the report content in the envelope
```

### Benchmark Report Format

```markdown
# Skill Benchmark Report
> Date: {YYYY-MM-DD}
> Skills evaluated: {count}
> Overall pass rate: {percentage}%

## Summary

| Metric | Value |
|--------|-------|
| Skills with eval files | {N} |
| Skills without eval files | {M} |
| Total test cases | {total} |
| Passed | {pass} |
| Failed | {fail} |
| Partial | {partial} |
| Estimated token usage | {tokens} |
| Total time | {duration} |

## Results by Skill

| Skill | Cases | Pass | Fail | Partial | Verdict | Notes |
|-------|-------|------|------|---------|---------|-------|
| {skill-name} | {N} | {P} | {F} | {PT} | PASS/FAIL/PARTIAL | {brief note} |

## Needs Attention

{For each skill with FAIL verdict:}
### {skill-name}
- **Failed cases**: {case_ids}
- **Root causes**: {summary from eval}
- **Recommended action**: Run `/skill:eval {skill-name} --improve`

## Coverage Gaps

Skills without SKILL.eval.yaml:
- {skill-name-1}
- {skill-name-2}

## What This Means (Simply)

> This report shows how well our AI skill library is working. A skill that "passes"
> means the AI behaves noticeably better with the skill than without it. A "fail"
> means the skill is not having the intended effect and needs revision. Think of it
> like a health checkup for our AI toolbox.
```

---

## SKILL.eval.yaml Schema

Each skill's eval file follows this schema:

```yaml
# SKILL.eval.yaml -- Behavioral test cases for {skill-name}
# Each case defines: task (the prompt), quality_criteria, anti_criteria.
# Run with: /skill:eval {skill-name}

skill: "{skill-name}"          # Must match the skill's frontmatter name
version: "1.0"                 # Eval file version (independent of skill version)
cases:
  - id: "{unique-case-id}"     # e.g., "trigger-01", "bypass-01", "edge-01"
    description: "{Human-readable description of what this case tests}"
    task: >
      {The prompt given to the sub-agent. Should be realistic -- the kind of
      request a real user would make that should trigger this skill.}
    quality_criteria:
      - "{Observable behavior that indicates the skill is working correctly}"
      - "{Another observable behavior -- be specific and measurable}"
    anti_criteria:
      - "{Behavior the agent exhibits WITHOUT the skill -- the failure mode}"
      - "{Another failure mode to check for}"
```

### Schema Field Reference

| Field | Required | Description |
|-------|----------|-------------|
| `skill` | Yes | Must match the skill's `name` in frontmatter |
| `version` | Yes | Eval file version. Increment when cases change. |
| `cases` | Yes | Array of test cases. Minimum 1, recommended 2-4. |
| `cases[].id` | Yes | Unique identifier. Convention: `{type}-{number}` where type is `trigger`, `bypass`, `edge`, `regression`. |
| `cases[].description` | Yes | Human-readable purpose of this test case. |
| `cases[].task` | Yes | The prompt sent to the sub-agent. Write as a realistic user request. |
| `cases[].quality_criteria` | Yes | Array of expected behaviors when skill is active. Min 1. |
| `cases[].anti_criteria` | Yes | Array of failure behaviors (what happens without the skill). Min 1. |

### Case Type Conventions

| Case Type | ID Prefix | Purpose |
|-----------|-----------|---------|
| `trigger` | `trigger-NN` | Primary scenario that should activate the skill |
| `bypass` | `bypass-NN` | Tests where the agent might rationalize skipping the skill |
| `edge` | `edge-NN` | Edge cases, boundary conditions, unusual inputs |
| `regression` | `regression-NN` | Cases that previously failed and were fixed |

---

## Output Contract (Envelope)

All modes return the standard Batuta sub-agent envelope:

### Eval Mode Envelope

```yaml
status: success | partial | error
executive_summary: "Skill {name}: {verdict} — {pass}/{total} cases passed"
detailed_report: |
  ## Eval Results: {skill-name}

  | Case | Verdict | Quality Criteria Met | Anti Criteria Avoided |
  |------|---------|---------------------|----------------------|
  | {id} | {PASS/FAIL/PARTIAL} | {N}/{total} | {N}/{total} |

  ### Case Details
  {Per-case breakdown with RED vs GREEN comparison}
artifacts:
  - type: report
    path: ""  # Eval results are returned inline, not persisted
    description: "Eval results for {skill-name}"
eval_data:
  skill: "{skill-name}"
  verdict: "PASS | FAIL | PARTIAL"
  cases:
    - id: "{case-id}"
      verdict: "PASS | FAIL | PARTIAL"
      red_summary: "{brief summary of RED run behavior}"
      green_summary: "{brief summary of GREEN run behavior}"
      quality_met: [true, false, ...]
      anti_avoided: [true, true, ...]
next_recommended: "improve | benchmark | none"
risks:
  - description: "{any risk identified during eval}"
    severity: "low | medium | high"
    mitigation: "{approach}"
```

### Improve Mode Envelope

```yaml
status: success | partial | error
executive_summary: "Proposed {N} edits to {skill-name} addressing {M} failures"
detailed_report: |
  ## Improvement Proposals for {skill-name}

  ### Edit 1: {description}
  **Root cause**: {classification}
  **Case**: {case-id}
  **Diff**:
  ```
  - {old text}
  + {new text}
  ```
  **Expected impact**: {what this fixes}
artifacts:
  - type: report
    path: ""
    description: "Improvement proposals for {skill-name}"
improvement_data:
  skill: "{skill-name}"
  proposals:
    - case_id: "{case-id}"
      root_cause: "TRIGGER | INSTRUCTION | ENFORCEMENT | CONFLICT | SCOPE"
      section: "{SKILL.md section to modify}"
      old_string: "{text to replace}"
      new_string: "{replacement text}"
next_recommended: "eval | none"
risks:
  - description: "Edit may affect other passing cases"
    severity: "low"
    mitigation: "Re-run eval after applying edits"
```

### Benchmark Mode Envelope

```yaml
status: success | partial | error
executive_summary: "Benchmark complete: {N} skills evaluated, {pass_rate}% pass rate"
detailed_report: "{Full benchmark report markdown}"
artifacts:
  - type: report
    path: "docs/qa/benchmark-{date}.md"
    action: created
    description: "Skill ecosystem benchmark report"
benchmark_data:
  total_skills: {N}
  evaluated: {M}
  no_coverage: {K}
  overall_pass_rate: {percentage}
  per_skill:
    - skill: "{name}"
      verdict: "PASS | FAIL | PARTIAL"
      cases: {N}
      passed: {P}
next_recommended: "improve {worst-skill} | none"
risks:
  - description: "{any systemic issues found}"
    severity: "medium"
    mitigation: "{approach}"
```

---

## Critical Patterns

### Pattern 1: Sub-Agent Isolation

The RED and GREEN sub-agents MUST be properly isolated. The RED sub-agent must
have NO access to the skill being tested. The GREEN sub-agent must have the FULL
skill content injected into its system prompt.

```
# BUSINESS RULE: Sub-agent isolation is the foundation of eval validity.
# If the RED sub-agent can see the skill, the comparison is meaningless.
# If the GREEN sub-agent has a truncated skill, the eval tests a broken version.

RED sub-agent prompt:
  "You are an AI assistant. Complete the following task.
   Do NOT load any skill files. Work from your general knowledge only.
   Task: {case.task}"

GREEN sub-agent prompt:
  "You are an AI assistant operating under the following skill.
   Read and follow the skill instructions carefully.
   --- SKILL START ---
   {FULL SKILL.md content, including frontmatter}
   --- SKILL END ---
   Task: {case.task}"
```

### Pattern 2: Criteria Must Be Observable

Quality and anti criteria must describe **observable behaviors** in the sub-agent's
response, not internal states or intentions. The evaluator (this skill) reads the
response text and judges whether each criterion is met.

**Good criteria (observable):**
- "Response includes a decision tree before proposing a file location"
- "Response asks 'Who will use this?' before creating any file"
- "Response generates YAML frontmatter with all required fields"

**Bad criteria (not observable):**
- "Agent understands the scope rule" (understanding is not observable)
- "Agent considers alternatives" (considering is internal)
- "Agent is aware of the convention" (awareness is not observable)

### Pattern 3: Realistic Tasks

Eval tasks must be realistic user requests, not synthetic test prompts. The sub-agent
should not be able to detect that it is being tested. Use the language and tone that
real users of the Batuta ecosystem would use.

```yaml
# GOOD: Realistic user request
task: >
  Necesito crear un archivo helpers.ts para funciones compartidas
  entre los modulos de inventario y facturacion.

# BAD: Synthetic test prompt
task: >
  Test: Create a file and verify scope rule is applied.
```

---

## Anti-Patterns (Never Do This)

| Anti-Pattern | Why It Is Wrong | Do This Instead |
|--------------|-----------------|-----------------|
| Testing with trivial tasks | Trivial tasks pass without any skill | Use tasks complex enough to expose differences |
| Writing criteria the agent always meets | Eval will always PASS, giving false confidence | Criteria must describe skill-specific behavior |
| Running eval without RED baseline | Cannot know if skill made a difference | Always run RED first, then GREEN |
| Auto-applying improve suggestions | Untested changes can break other cases | Always re-run eval after edits |
| Skipping bypass cases | Misses the most common failure mode: rationalization | Every eval file should have at least one bypass case |
| Running benchmark too frequently | Wastes tokens on unchanged skills | Benchmark after batch changes or monthly |

---

## Rules

1. **ALWAYS run RED before GREEN** -- the baseline establishes what the skill changes. Without it, you cannot attribute behavior to the skill.
2. **NEVER modify a skill based on eval results without user approval** -- improve mode proposes, the user decides.
3. **ALWAYS use realistic task prompts in the user's language** -- Batuta ecosystem users primarily communicate in Spanish. Eval tasks should reflect this.
4. **NEVER skip the anti_criteria check** -- a GREEN run that passes quality but still exhibits anti behaviors is a FAIL, not a PASS.
5. **ALWAYS return the envelope contract** -- even on error, return a structured envelope so the caller (ecosystem-creator, pipeline-agent, or user) can process results programmatically.
6. **NEVER run improve mode automatically after eval** -- inform the user of failures and let them decide whether to improve. Exception: when called from ecosystem-creator Step 5.5 in an automated flow, the skill may suggest improve but must still show results first.
7. **ALWAYS include case IDs in reports** -- every verdict, every failure, every proposal must reference the specific case ID for traceability.
8. **NEVER evaluate a skill against a SKILL.eval.yaml from a different skill** -- the eval file and the skill must be for the same skill (matched by the `skill` field in YAML).

---

## What This Means (Simply)

> **For non-technical readers**: This skill is a testing tool for our AI instruction
> library. Every "skill" in our system is a set of instructions that tells the AI how
> to handle specific situations -- like a recipe book for different tasks. But how do
> we know the recipes actually work?
>
> This skill answers that question by running a controlled experiment: give the AI a
> task WITHOUT the recipe, then give it the SAME task WITH the recipe, and compare
> the results. If the recipe makes the AI perform better, it passes. If not, we know
> exactly what to fix.
>
> Think of it like A/B testing for AI behavior. The "A" group (RED) has no special
> instructions. The "B" group (GREEN) has the skill loaded. We measure the difference
> and that tells us if our skills are actually working.

---

## Resources

- **Templates**: See `BatutaClaude/skills/ecosystem-creator/assets/skill-eval-template.yaml` for the eval case template
- **Integration**: ecosystem-creator Step 5.5 invokes this skill when SKILL.eval.yaml exists
- **Benchmark reports**: Generated at `docs/qa/benchmark-{date}.md`

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "Evaluating skills is overhead — the skill obviously works" | "Obvious" is a feeling. Eval mode is empirical evidence. Skills that "obviously work" are the most likely to silently fail when the agent rationalizes around them. |
| "Skills work until they don't — I'll write evals when I see a problem" | By the time you see a problem in production, the skill has been silently failing for weeks. RED-GREEN baseline catches drift before it ships. |
| "Running eval on every skill change is too expensive" | Eval cost is one-time; debugging a skill that silently regresses is recurring. Cost-benefit favors eval-on-change for any skill with `bypass-NN` cases. |
| "I'll skip the RED baseline — I already know what the agent does without the skill" | Without RED, you cannot attribute behavior to the skill. The comparison is the point. Skipping RED reduces eval to "did GREEN respond" — useless. |
| "Auto-apply the improve-mode suggestions — they look reasonable" | Untested edits can break passing cases. Improve mode proposes; the user (and the next eval run) verifies. |

## Red Flags

- Eval verdict is PASS but no `bypass-NN` cases exist — you tested only happy paths, not rationalization resistance
- RED and GREEN responses look identical — either the skill is being ignored or the task is too trivial to expose differences
- Eval criteria contain "understands", "considers", "is aware of" — these are not observable, the eval is meaningless
- Improve mode proposes edits that touch 5+ sections at once — too broad, will likely break other cases
- Benchmark report shows 100% pass rate across all skills — either the skills are flawless (unlikely) or the eval cases are too easy
- Running eval against an SKILL.eval.yaml whose `skill:` field doesn't match the skill name — wrong file
- Eval task written in English when the project's users speak Spanish — the skill won't trigger in real use

## Verification Checklist

- [ ] Every eval case has at least one `quality_criterion` AND one `anti_criterion` (both arrays non-empty)
- [ ] Criteria describe observable behaviors in the response text (not internal states like "understands")
- [ ] At least one `bypass-NN` case exists per skill (tests rationalization resistance, not just trigger)
- [ ] Tasks are realistic user requests in the project's primary language (Spanish for Batuta)
- [ ] RED run was executed and recorded BEFORE the GREEN run for each case
- [ ] PASS verdict requires: all quality_criteria met AND zero anti_criteria matched
- [ ] Improve mode proposals were reviewed by the user before application; eval was re-run after edits
- [ ] Envelope returned with `status`, `executive_summary`, and `eval_data` (or `improvement_data`/`benchmark_data`)
