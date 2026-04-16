---
name: shipping-and-launch
description: >
  Use when deploying to production, preparing pre-launch checklists, staging rollouts,
  or developing rollback strategies. Trigger: "deploy", "launch", "go live", "rollout",
  "pre-launch", "feature flag", "rollback", "staged release", "production release".
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-04-16"
  inspired_by: "addyosmani/agent-skills v0.5.0 (MIT)"
  bucket: ship
  auto_invoke:
    - Deploying features to production
    - Preparing pre-launch checklists
    - Planning staged rollouts or feature flag strategies
    - Defining rollback plans before deployment
  platforms: [claude, antigravity]
allowed-tools: Read Edit Write Glob Grep Bash
---

# Shipping and Launch

## Purpose

This skill closes the last mile of the SDD pipeline: getting verified code to production
safely. The core principle is that every launch should be **reversible, observable, and
incremental**. A launch is not the end of the cycle — it is the beginning of the
observability phase.

This skill activates after sdd-verify reports a green Pyramid (L1-L3 pass) and works
alongside ci-cd-pipeline, which handles deployment mechanics. shipping-and-launch handles
**strategy**: when to advance, when to hold, when to roll back, and what to monitor in
the first hour.

## When to Use

- Production deployment of any feature that reaches real users
- Significant user-facing changes (UI, pricing, permissions, data model)
- Database or infrastructure migrations
- Beta or early access launches
- Any deployment to environments with real traffic

## When NOT to Use

- Internal tooling or developer-facing-only changes
- Documentation-only updates
- Local development or staging-only deployments
- Changes that never reach end users (build tooling, test helpers)

## Critical Patterns

### Pattern 1: Pre-Launch Checklist (5 Categories)

Run this checklist in full before cutting any production release. Each category must
be green before advancing to the next deployment stage.

**Code Quality**
- All tests pass (Pyramid L1-L3 green from sdd-verify)
- No debug code, console.log, or development-only flags left in
- Error handling complete — no unhandled promise rejections or bare `except` clauses
- Code reviewed (by teammate or quality-agent)

**Security**
- No secrets, API keys, or credentials committed or logged
- Vulnerability scan run (npm audit, pip-audit, or equivalent)
- Input validation enforced at all API boundaries
- Authentication and authorization checks confirmed for new endpoints
- Rate limiting configured on public-facing routes
- CORS policy reviewed — no wildcard origins in production

**Performance**
- Core Web Vitals within targets (LCP < 2.5s, INP < 200ms, CLS < 0.1) for frontend changes
- Database queries checked for N+1 patterns and missing indexes
- Bundle size within budget (no unexpected regressions)
- Load test results reviewed for new endpoints under expected peak traffic

**Infrastructure**
- Environment variables set in production (not inherited from staging)
- Database migrations applied and verified reversible
- DNS and SSL certificates confirmed valid
- Health check endpoints responding correctly
- Log aggregation and error tracking active

**Documentation**
- README and relevant ADRs updated
- API documentation reflects new or changed endpoints
- Changelog entry written
- User-facing release notes prepared (if applicable)

---

### Pattern 2: Feature Flag Strategy

Deploy code behind a flag so you can enable the feature independently from deploying
the code. Think of it as separating the act of "putting the code in production" from
the act of "turning the feature on." This gives you a kill switch with zero downtime.

```
ROLLOUT SEQUENCE
────────────────
1. Deploy with flag OFF (code is live but feature is invisible)
2. Enable for internal team (validate in real production environment)
3. Enable for 5% of users — canary (watch error rates for 30 min)
4. Advance to 25%  → monitor for 2 hours
5. Advance to 50%  → monitor for 4 hours
6. Advance to 100% → remove flag from code in next sprint
```

**Flag ownership rules**:
- Every flag has a named owner and an expiration date (maximum 90 days)
- No nested flags — if flag A controls flag B, extract them into a single combined flag
- Both states (ON and OFF) must be tested in CI — a flag that breaks the OFF path is a bug

---

### Pattern 3: Staged Rollout with Decision Thresholds

Before advancing to the next percentage stage, measure against these thresholds.
Do not proceed on schedule — proceed on signal.

| Signal | Threshold | Action |
|--------|-----------|--------|
| Error rate | Within 20% of pre-launch baseline | Advance |
| Error rate | 20-100% above baseline | HOLD — investigate before advancing |
| Error rate | More than 2x baseline | ROLLBACK immediately |
| P95 latency | Within 20% of baseline | Advance |
| P95 latency | More than 50% above baseline | ROLLBACK immediately |
| Key conversion metric | Within 10% of baseline | Advance |
| Key conversion metric | More than 20% drop | HOLD — investigate |

**HOLD** means: freeze the rollout at current percentage, open an incident, investigate
root cause. Do not roll back unless thresholds cross into the ROLLBACK zone — a hold
preserves the 5% canary while you gather signal.

---

### Pattern 4: Rollback Strategy (MANDATORY — document BEFORE deploying)

A rollback plan written during an incident is a plan written under panic. Write it
before you deploy. The plan must answer four questions:

```
ROLLBACK PLAN TEMPLATE
──────────────────────
Trigger conditions:
  - Error rate exceeds [X]% for [Y] minutes
  - Latency P95 exceeds [Z]ms sustained for [W] minutes
  - [Business metric] drops below [threshold]

Rollback steps:
  1. Disable feature flag OR redeploy previous image tag [specify which]
  2. [Any manual steps, e.g., flush a cache, revert a config value]
  3. Confirm health endpoint returns 200 post-rollback
  4. Notify team in #incidents channel

Database considerations:
  - Are the migrations applied in this release reversible? [YES / NO]
  - If NO: what is the data mitigation plan? [describe]
  - If additive columns: rollback is safe — old code ignores new columns
  - If destructive migrations: rollback requires a separate forward migration

Estimated rollback time: [X] minutes
Who executes: [role or person on-call]
```

If the migration is NOT reversible, that must be discovered BEFORE the deployment
window — not during an incident.

---

### Pattern 5: Post-Launch Verification (First Hour)

Deploy, then stay present. An unattended deployment is a deployment that fails silently.

```
FIRST-HOUR CHECKLIST
─────────────────────
T+0  min  Health endpoint returns 200 — confirm the process is up
T+2  min  Error dashboard shows no spike since deploy
T+5  min  Latency dashboards within baseline
T+10 min  Manually walk the critical user flow (sign in → main action → confirm)
T+15 min  Confirm structured logs are flowing and contain expected fields
T+20 min  Confirm rollback mechanism is accessible (flag UI, deploy rollback command)
T+30 min  If canary: review error rate before advancing to next stage
T+60 min  Summarize status to the team: green / hold / rolled back
```

Do not close the deployment session until you have completed the T+60 summary.

---

## Integration with SDD Pipeline

```
sdd-explore → sdd-propose → sdd-spec → sdd-design → sdd-tasks
    → sdd-apply → sdd-verify → [shipping-and-launch] → sdd-archive
```

**Pre-condition**: sdd-verify must report Pyramid L1-L3 green before this skill
activates. A verify report with any RED layer is a hard block on shipping — fix
the layer, re-verify, then ship.

**pipeline-agent**: Ship is a CONDITIONAL phase. Not every change requires a full
staged rollout — pipeline-agent evaluates scope. A documentation-only change or a
dev-tool fix does not trigger this skill. A user-facing feature always does.

**ci-cd-pipeline skill**: Handles the deployment MECHANICS — Dockerfile builds,
CI/CD pipeline steps, Coolify deployment targets. shipping-and-launch handles the
STRATEGY: when to advance stages, what thresholds trigger a rollback, and what to
verify in the first hour after going live. Both skills are complementary — use
ci-cd-pipeline for "how to deploy" and this skill for "whether to advance."

---

## Common Rationalizations

| Rationalization | Counter |
|---|---|
| "Staging passed, so production will be fine" | Production differs in data volume, traffic patterns, third-party integrations, and edge cases that staging never generates. Staging success is necessary but not sufficient. |
| "Feature flags add unnecessary complexity" | Every feature benefits from a kill switch. The complexity of a flag is a few lines of configuration. The complexity of an emergency hotfix is hours of firefighting under pressure. |
| "We can add monitoring after launch" | You cannot debug what you cannot see. Monitoring must precede the launch — not follow it. Configuring dashboards during an incident is the worst possible time to learn a tool. |
| "It's a small change, a rollback plan is overkill" | Small changes cause outages too. A 2-minute rollback plan saves hours of coordination during an incident. The cost is negligible; the insurance is real. |
| "We'll fix issues as they come up" | Reactive firefighting costs roughly 10x more in team time than proactive verification. The first-hour checklist exists precisely to catch issues before they reach 100% of users. |
| "We've shipped this type of change before without problems" | Each release is different. Prior success is not a substitute for current verification. |

---

## Red Flags

- Deploying without a written rollback plan
- No production monitoring or error tracking configured before the first request hits
- Big-bang release: 0% to 100% with no gradual rollout or canary
- Feature flags without a named owner or an expiration date
- Unattended deployment — deploying and walking away before the first-hour checklist is complete
- Manual configuration changes applied directly to production (not via code or config management)
- Deploying on Friday afternoon or immediately before a holiday
- Skipping the staged rollout because "we're confident" — confidence is not signal, metrics are
- Irreversible database migrations deployed without a data mitigation plan documented in advance

---

## What This Means (Simply)

> **For non-technical readers**: Shipping a feature is like opening a new store location.
> You would not unlock the doors on day one without first making sure the lights work, the
> registers are functional, and the staff knows what to do if something breaks. Shipping
> software is the same: before we "open the doors" to users, we run a checklist across
> five areas (code quality, security, performance, infrastructure, and documentation).
> Then we let a small percentage of users in first — like a soft opening — and only expand
> to everyone once we confirm nothing is broken. We also write down the "fire drill plan"
> before we open, so that if something does go wrong, we already know the steps to take
> rather than figuring it out under pressure.

---

## Verification Checklist

- [ ] Pre-launch checklist complete (all 5 categories: code, security, performance, infrastructure, documentation)
- [ ] Feature flags configured with named owner and expiration date (if applicable)
- [ ] Rollback plan documented: trigger conditions, rollback steps, database considerations, estimated time
- [ ] Monitoring dashboards active and alerting configured before first user request
- [ ] Team notified of deployment schedule and on-call rotation confirmed
- [ ] sdd-verify report shows Pyramid L1-L3 green (hard block if any layer is RED)
- [ ] Staged rollout plan defined: percentages and decision thresholds documented
- [ ] Database migrations verified reversible, or data mitigation plan documented if not
- [ ] T+0:  health endpoint returns 200
- [ ] T+2:  error dashboard shows no spike since deploy
- [ ] T+5:  latency dashboards within baseline
- [ ] T+10: critical user flow manually verified end-to-end
- [ ] T+15: structured logs flowing with expected fields
- [ ] T+20: rollback mechanism confirmed accessible
- [ ] T+60: deployment status summary shared with team (green / hold / rolled back)
