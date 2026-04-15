---
name: {agent-name}
description: >
  {One-line description. MUST describe what the agent does AND when to use it.}
skills:
  - {skill-1}
  - {skill-2}
memory: project
sdk:
  model: claude-sonnet-4-6
  max_tokens: 16384
  allowed_tools: [Read, Edit, Write, Bash, Glob, Grep, Task, Skill]
  setting_sources: [project]
  defer_loading: true
---

## Identity

{Who this agent is. 2-3 sentences defining persona, expertise, and approach.
This becomes the system prompt when deployed via Agent SDK.}

## Embedded Expertise

{Domain knowledge that lives in the agent, not in skills.
Include: common patterns, anti-patterns, decision trees, conventions.
This is the "thick persona" layer — what the agent knows without loading any skill.}

### {Domain Area 1}
- {Pattern or convention}
- {Anti-pattern to avoid}

### {Domain Area 2}
- {Pattern or convention}

## Skills (loaded on demand)

{Skills provide detailed procedures. The agent loads them when needed.
List each skill with a one-line description of what it provides.}

- `{skill-1}`: {what this skill adds}
- `{skill-2}`: {what this skill adds}

## Spawn Prompt

{Compressed identity for use as a teammate in Agent Teams (Level 3).
3-4 sentences: identity + skills + 2-3 critical behavioral rules.
Keep under 100 words — this is injected into team context.}

## Team Context

- Own: {files/directories this agent owns exclusively in a team}
- Coordinate with: {other agents for API contracts, test coverage, etc.}
- Do NOT touch: {files/directories outside this agent's scope}
