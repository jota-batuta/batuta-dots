# /save-session

> Save current session state to .batuta/session.md. Replaces Claude Code's automatic Stop hook with an explicit workflow.

## Instructions

### Step 1: Check for significant work

Determine if significant work was done in this session:
- Any SDD phase execution
- 3+ files created or modified
- Bug fix with root cause analysis
- New skill or agent created
- 5+ meaningful exchanges on the same topic

If no significant work was done, tell the user: "No hay cambios significativos que guardar en esta sesion."

### Step 2: Gather session state

Collect the following information from the current session:
- **WHERE are we**: Project type, stack, 1-line status, current SDD phase
- **WHY did we get here**: Key decisions with rationale, conventions discovered
- **HOW to continue**: Actionable next steps, blockers, what to do first

### Step 3: Prune and enforce budget

Before writing, apply the Session Budget (80 lines max):
1. Completed SDD changes → REMOVE from Active Changes (they're in openspec/archive/)
2. Decisions now obvious from code → REMOVE
3. Next Steps already done → REMOVE
4. Individual file paths → NEVER list (use summaries: "4 parsers, 48 tests")
5. Implementation details (regex patterns, S3 paths, test counts) → REMOVE (they live in code)
6. If over 80 lines → trim oldest decisions and notes until compliant

### Step 4: Write session file

Create or update `.batuta/session.md` with the gathered state. Use this structure:

```markdown
# Session — {project-name}

> Briefing for a new agent: WHERE are we, WHY, HOW to continue.
> Budget: 80 lines max. Details live in code and openspec/.

## Project
- **Type**: {type}
- **Stack**: {stack}
- **Status**: {1-line status}

## Active SDD Changes

| Change | Phase | Last Updated |
|--------|-------|--------------|

## Key Decisions (WHY we got here)
- {date}: {decision + rationale — 1-2 lines}

## Conventions
- {patterns: date formats, money handling, naming, etc.}

## Next Steps (HOW to continue)
- [ ] {actionable item}
```

The session file is for PROJECT context only. Never put personal preferences here.

### Step 5: Confirm

Tell the user:

```
Sesion guardada en .batuta/session.md ({N} lineas, dentro del budget de 80).
```
