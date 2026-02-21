# Workflow: /{domain}:{action}

## Command

```
/{domain}:{action} [arguments]
```

## What It Does

{What this workflow does end-to-end. Write this so that a non-technical stakeholder
can understand what happens when someone types this command.}

> **What This Means (Simply):** {One sentence, zero jargon, explaining what this
> command does for the team.}

## Usage

```
/{domain}:{action} {required-arg} [optional-arg]
```

## Arguments

| Argument | Required | Description | Default |
|----------|----------|-------------|---------|
| `{arg1}` | Yes/No | {What this argument controls} | {default value or "none"} |
| `{arg2}` | Yes/No | {What this argument controls} | {default value or "none"} |

## Skill Mapping

The workflow invokes these skills in order:

| Step | Skill Invoked | Purpose | Condition |
|------|--------------|---------|-----------|
| 1 | `{skill-1}` | {What it does in this workflow} | Always |
| 2 | `{skill-2}` | {What it does in this workflow} | {Always or conditional} |
| 3 | `{skill-3}` | {What it does in this workflow} | {Always or conditional} |

### Flow Diagram

```
/{domain}:{action} [args]
|
+-- 1. {skill-1}
|     Input: {what this skill receives}
|     Output: {what this skill produces}
|
+-- 2. {skill-2}
|     Input: {what this skill receives, including output from step 1}
|     Output: {what this skill produces}
|
+-- 3. {skill-3} (if applicable)
      Input: {what this skill receives}
      Output: {final output}
```

## Output

When the workflow completes, the user sees:

```markdown
## {Workflow Name} Complete

{Summary of what was accomplished}

### Results
- {Result 1}
- {Result 2}

### What This Means (Simply)
{Plain-language summary for non-technical stakeholders}

### Next Steps
- {Suggested follow-up action 1}
- {Suggested follow-up action 2}
```

## Error Handling

| Error Condition | Behavior |
|----------------|----------|
| {Skill 1 fails} | {What happens -- abort, retry, skip to next?} |
| {Missing input} | {How to handle -- prompt user, use default?} |
| {Partial completion} | {What to report, what to clean up} |

## Registration Checklist

After creating this workflow, update these files:

- [ ] **CLAUDE.md** -- Add to the appropriate commands section (SDD Commands or Batuta Ecosystem Commands)
- [ ] **CLAUDE.md** -- Add to "Command -> Skill Mapping" section:
  ```markdown
  - `/{domain}:{action}` -> `{skill-1}` then `{skill-2}`
  ```
- [ ] **CLAUDE.md** -- Add to auto-load table if this workflow should be context-triggered
- [ ] **opencode.json** -- Add to agent prompt if this is an SDD-related workflow

## Example

```
User: /{domain}:{action} {example-argument}

AI: [Loads {skill-1}]
    [Performs step 1...]
    [Loads {skill-2}]
    [Performs step 2...]
    [Returns final summary]
```
