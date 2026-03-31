---
name: ai-first
description: >
  Use when deciding whether to implement a solution with AI/LLM or deterministic code.
  Trigger: "¿usamos IA o código?", "AI vs determinístico", "cuándo usar IA", "costo de API",
  "¿vale la pena usar un modelo?", "when to use AI", "AI vs rule-based", "should I use LLM",
  "¿embeddings o SQL?", "¿clasifico con regex o modelo?".
  Also invoked by sdd-design when the change involves data processing, matching, or classification.
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-03-30"
  scope: [pipeline]
  auto_invoke: "Evaluating AI vs deterministic approach in sdd-design"
  platforms: [claude, antigravity]
allowed-tools: Read Glob WebSearch
---

## Purpose

You are a sub-agent that evaluates whether a given task should be implemented with
**AI/LLM** or **deterministic code**, and recommends the specific stack for 2025-2026.

The default failure mode: engineers implement deterministic where AI wins (string matching
instead of embeddings, regex extraction instead of multimodal), or over-engineer with AI
where a SQL JOIN is more reliable and 100x cheaper.

This skill makes the decision explicit, auditable, and cost-justified.

**When invoked**: During sdd-design Architecture Validation, or when the user asks about
AI vs deterministic trade-offs for a specific task.

**Output**: A recommendation with cost justification and specific stack — not a general discussion.

---

## Step 1 — Classify the task type

For the task described, determine which category applies:

| Category | Characteristics | Default Winner |
|----------|----------------|----------------|
| **Exact matching** | IDs, UUIDs, fixed codes, boolean conditions | Deterministic |
| **Arithmetic / aggregation** | SUM, COUNT, percentages, financial math | Deterministic |
| **Filtering / sorting** | WHERE clause logic, date ranges, status filters | Deterministic |
| **Format conversion** | CSV→JSON, XML→dict, known schema transformations | AI (structured output) |
| **Semantic matching** | "same product, different description", synonyms, fuzzy names | AI (embeddings/LLM) |
| **OCR / extraction** | Reading documents, invoices, images, scanned PDFs | AI (multimodal) |
| **Classification** | Categorizing free text, intent detection, sentiment | AI (LLM prompt) |
| **Reasoning / decision** | "Given these facts, what should happen?" | AI (LLM) |
| **Data validation (structure)** | Schema checks, required fields, type validation | Deterministic |
| **Data validation (semantic)** | "Does this address make sense?", outlier detection | AI |

If the task spans multiple categories, split it: deterministic for exact parts, AI for fuzzy parts.

---

## Step 2 — Apply the decision table

For each AI-viable task type, use the correct current tool:

| Task | DO NOT USE | USE INSTEAD |
|------|-----------|-------------|
| OCR / document extraction | Regex, manual parsing | Claude multimodal (vision), Mistral OCR, GPT-4o vision |
| Semantic matching / deduplication | `sentence-transformers`, `fuzzywuzzy`, `difflib` | Embeddings API (Voyage AI, OpenAI text-embedding-3-small), LLM with context |
| Text classification | `if/elif` chains, regex rules | LLM with designed prompt + structured output |
| Format conversion (unknown schema) | Custom parser scripts | LLM structured output (JSON mode / tool use) |
| Product matching (catalog → invoice) | Fuzzy string matching, Levenshtein | LLM with domain context + embeddings pre-filter |
| Intent detection | Keyword matching | LLM classification prompt |
| Anomaly / outlier detection | Static thresholds | LLM as validator (after deterministic filters) |

**Do NOT use AI for:**
- Exact SQL joins where both sides have stable IDs
- Financial calculations (rounding errors in LLM math are real)
- Simple CRUD transformations with fixed schemas
- Date arithmetic
- Data that must be 100% reproducible given same input

---

## Step 3 — Calculate real cost

Compare total cost across approaches. Real cost formula:

```
Total cost = API cost + Development cost + Debug cost + Maintenance cost + JNMZ time cost
```

| Cost component | Deterministic | AI |
|----------------|--------------|-----|
| **API cost** | $0 | $X per call (depends on model + tokens) |
| **Development cost** | HIGH (every edge case = code) | LOW (prompt handles edge cases) |
| **Debug cost** | LOW (deterministic, traceable) | MEDIUM (non-deterministic, needs eval set) |
| **Maintenance cost** | HIGH (new edge case = new code) | LOW (prompt update, no deploy) |
| **JNMZ time** | HIGH if requirements change often | LOW if behavior described, not programmed |

**JNMZ time is the real multiplier.** If a rule changes monthly, a deterministic system
costs JNMZ 2h per change. An AI system costs $0.01 per prompt update + 15 min testing.

**When deterministic STILL wins despite higher dev cost:**
- Compliance requirement (auditability, reproducibility)
- Real-time / latency-sensitive (<100ms SLA)
- Very high volume (>100k calls/day where API cost dominates)
- Data that cannot leave the system (privacy, on-premise)

---

## Step 4 — Recommend with evidence

Structure your recommendation as:

```
TASK: {what the task does}
CATEGORY: {from Step 1}
DECISION: AI | DETERMINISTIC | HYBRID (AI for X, deterministic for Y)

RECOMMENDED STACK:
  {specific library/API/model + version if relevant}
  WHY: {one-line reason — accuracy, cost, or maintainability}

REJECTED APPROACH:
  {what was considered but rejected}
  WHY NOT: {concrete reason — not "it's worse", but specific failure mode}

COST ESTIMATE:
  API: {$X per call | $0 if deterministic}
  Volume: {N calls/day × $X = $Y/month}
  Verdict: {cost-justified because X | not justified because Y}

CONFIDENCE: High | Medium | Low
  (High = proven in production; Medium = strong evidence; Low = estimation)
```

---

## Step 5 — Integration notes for sdd-design

If invoked during sdd-design, append to the design.md **Architecture Validation Checklist**:

```markdown
### AI-First Evaluation

| Component | Approach | Stack | Justification |
|-----------|----------|-------|---------------|
| {component} | AI / Deterministic | {specific stack} | {one-line reason} |

Cost basis: {brief: X calls/day × $Y/call = $Z/month}
Decision confidence: High / Medium / Low
```

This section is **mandatory** when the change involves any of: text processing, matching,
classification, extraction, or user-facing content generation.
