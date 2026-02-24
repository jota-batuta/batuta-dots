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
- **Current state**: What is the project's current status?
- **What was accomplished**: List completed tasks, phases, or changes.
- **Pending items**: What remains to be done?
- **Key decisions**: Any architectural, design, or technical decisions made.
- **Active change**: If an SDD change is in progress, note its name and current phase.

### Step 3: Write session file

Create or update `.batuta/session.md` with the gathered state. Use this structure:

```markdown
# Session State
> Last updated: {current date and time}

## Current State
{project status summary}

## Accomplished
{list of completed items}

## Pending
{list of remaining items}

## Key Decisions
{decisions and their rationale}

## Active SDD Change
{change name and phase, or "None"}
```

The session file is for PROJECT context only. Never put personal preferences here.

### Step 4: Confirm

Tell the user:

```
Sesion guardada en .batuta/session.md.
```
