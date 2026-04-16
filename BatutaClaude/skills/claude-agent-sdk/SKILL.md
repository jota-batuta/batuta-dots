---
name: claude-agent-sdk
description: >
  Use when building applications with the Claude Agent SDK, deploying batuta-dots
  agents programmatically, or scaffolding SDK-powered CI/CD pipelines and embedded assistants.
  Trigger: "Agent SDK", "deploy agent", "SDK deployment", "setting_sources",
  "programmatic agent", "CI/CD agent", "embedded assistant", "defer_loading".
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-03-09"
  bucket: build
  auto_invoke: "Building applications with Claude Agent SDK or deploying batuta agents programmatically"
  platforms: [claude, antigravity]
  category: capability
allowed-tools: Read Edit Write Glob Grep Bash WebFetch WebSearch
---

# Claude Agent SDK -- Deploying Batuta Agents Programmatically

## Purpose

This skill guides the scaffolding and deployment of batuta-dots agents outside of
Claude Code's interactive CLI. The Claude Agent SDK (`claude-agent-sdk` for Python,
`@anthropic-ai/claude-agent-sdk` for TypeScript) enables running agents in CI/CD
pipelines, background workers, and embedded product assistants -- all while preserving
batuta-dots skills, CLAUDE.md rules, and MCP server configurations.

The core insight: `setting_sources=["project"]` tells the SDK to load `.claude/skills/`
and `CLAUDE.md` automatically, so agents deployed via SDK follow the same rules as
agents running in Claude Code. This eliminates the "works in dev, different in prod"
problem for AI-assisted workflows.

## When to Use

- **CI/CD automation**: Deploying batuta agents for automated code review, PR analysis,
  or security scanning in GitHub Actions or similar systems
- **Background workers**: Running long-lived agents for data processing, monitoring,
  or scheduled tasks without user interaction
- **Embedded assistants**: Integrating batuta agents into web applications, APIs, or
  products where Claude powers a feature accessible to end users
- **Headless execution**: Any scenario where agents must run without the interactive
  Claude Code terminal (servers, containers, cron jobs)
- **Multi-agent orchestration**: Coordinating multiple specialized agents via SDK in
  a single application (e.g., quality-agent + security-agent in a review pipeline)

## Critical Patterns

### Pattern 1: Loading Batuta Skills via SDK (Python)

The SDK's `setting_sources` parameter is the bridge between batuta-dots configuration
and programmatic agent execution. When set to `["project"]`, it reads the same files
Claude Code reads interactively.

```python
# BUSINESS RULE: setting_sources=["project"] loads .claude/skills/ + CLAUDE.md
# This ensures SDK agents follow the same rules as interactive Claude Code sessions.
from claude_agent_sdk import query, ClaudeAgentOptions

async def run_agent(prompt: str) -> str:
    """Run a batuta agent with project skills loaded.

    Args:
        prompt: The task description for the agent.

    Returns:
        The agent's final text response.
    """
    result_parts = []
    async for msg in query(
        prompt=prompt,
        options=ClaudeAgentOptions(
            setting_sources=["project"],  # loads .claude/skills/ + CLAUDE.md
            allowed_tools=["Read", "Glob", "Grep", "Bash"],
        ),
    ):
        if msg.type == "text":
            result_parts.append(msg.content)
    return "".join(result_parts)
```

### Pattern 2: Loading Batuta Skills via SDK (TypeScript)

```typescript
// BUSINESS RULE: settingSources: ["project"] loads .claude/skills/ + CLAUDE.md
// Same behavior as Python -- skills, CLAUDE.md, and commands are auto-discovered.
import { query, ClaudeAgentOptions } from "@anthropic-ai/claude-agent-sdk";

async function runAgent(prompt: string): Promise<string> {
  const resultParts: string[] = [];
  for await (const msg of query({
    prompt,
    options: {
      settingSources: ["project"],
      allowedTools: ["Read", "Glob", "Grep", "Bash"],
    } satisfies ClaudeAgentOptions,
  })) {
    if (msg.type === "text") {
      resultParts.push(msg.content);
    }
  }
  return resultParts.join("");
}
```

### Pattern 3: Parsing Agent Definitions from .md Files

Batuta agents (in `BatutaClaude/agents/`) have YAML frontmatter with an `sdk:` block
that defines deployment configuration. This parser converts those definitions into
SDK-compatible configuration objects.

```python
import yaml
import re

def parse_agent_md(path: str) -> dict:
    """Parse a batuta agent .md file into SDK-compatible config.

    Batuta agent files use YAML frontmatter for metadata and a markdown body
    as the system prompt. The sdk: block in frontmatter specifies deployment
    parameters (model, max_tokens, allowed_tools, setting_sources, defer_loading).

    Args:
        path: Absolute path to the agent .md file.

    Returns:
        Dictionary with name, prompt, model, max_tokens, allowed_tools,
        setting_sources, and defer_loading keys.
    """
    with open(path) as f:
        content = f.read()
    # WORKAROUND: YAML frontmatter is between --- delimiters at file start.
    # Standard YAML libraries don't handle this format natively.
    match = re.match(r'^---\n(.*?)\n---\n(.*)$', content, re.DOTALL)
    if not match:
        raise ValueError(f"No YAML frontmatter found in {path}")
    frontmatter = yaml.safe_load(match.group(1))
    body = match.group(2)

    sdk_config = frontmatter.get('sdk', {})
    return {
        'name': frontmatter['name'],
        'prompt': body,  # Full markdown body becomes the system prompt
        'model': sdk_config.get('model', 'claude-sonnet-4-6'),
        'max_tokens': sdk_config.get('max_tokens', 16384),
        'allowed_tools': sdk_config.get('allowed_tools', []),
        'setting_sources': sdk_config.get('setting_sources', ['project']),
        'defer_loading': sdk_config.get('defer_loading', False),
    }
```

### Pattern 4: Tool Search with defer_loading

When deploying agents with many MCP servers configured (5+), enabling `defer_loading`
prevents all tools from being loaded into context at startup. Instead, the agent uses
Tool Search to discover tools on-demand, reducing token overhead by approximately 85%.

```python
# BUSINESS RULE: defer_loading reduces token overhead by ~85% with 5+ MCP servers.
# Tools are discovered on-demand via Tool Search instead of loaded upfront.
# Without this, 10 MCP servers can add 20K+ tokens to every agent turn.
options = ClaudeAgentOptions(
    setting_sources=["project"],
    defer_loading=True,  # enables Tool Search for on-demand tool discovery
    allowed_tools=["Read", "Glob", "Grep", "Bash", "WebFetch"],
)
```

```typescript
// TypeScript equivalent
const options: ClaudeAgentOptions = {
  settingSources: ["project"],
  deferLoading: true,
  allowedTools: ["Read", "Glob", "Grep", "Bash", "WebFetch"],
};
```

### Pattern 5: Hooks Mapping (Claude Code to SDK)

Claude Code hooks translate directly to SDK hook handlers. The SDK uses matcher
objects to filter which tool invocations trigger hooks.

| Claude Code Hook | SDK Equivalent | When It Fires |
|-----------------|----------------|---------------|
| `SessionStart` | `hooks.SessionStart` | Agent session begins |
| `Stop` | `hooks.SessionEnd` | Agent session ends |
| `PreToolUse` | `hooks.PreToolUse` with `HookMatcher` | Before a tool executes |
| `PostToolUse` | `hooks.PostToolUse` with `HookMatcher` | After a tool executes |

```python
from claude_agent_sdk import query, ClaudeAgentOptions, Hooks, HookMatcher

# BUSINESS RULE: Hooks enforce the same safety rules in SDK as in Claude Code.
# PreToolUse hooks can block dangerous operations (e.g., force pushes).
hooks = Hooks(
    pre_tool_use=[
        {
            "matcher": HookMatcher(tool_name="Bash"),
            "handler": validate_bash_command,  # Your validation function
        }
    ],
    session_start=[inject_session_context],
    session_end=[save_session_state],
)

async for msg in query(
    prompt="Review this PR",
    options=ClaudeAgentOptions(
        setting_sources=["project"],
        hooks=hooks,
    ),
):
    print(msg)
```

### Pattern 6: SDK Project Structure

When scaffolding an SDK-powered application, the project needs both the SDK dependency
and the batuta-dots configuration that the SDK will load.

```
my-sdk-project/
├── .claude/
│   ├── skills/           # Provisioned by /sdd-init or copied from hub
│   │   ├── security-audit/SKILL.md
│   │   └── api-design/SKILL.md
│   ├── commands/         # Custom slash commands (optional)
│   └── CLAUDE.md         # Project-layer overrides
├── CLAUDE.md             # Hub-layer rules (from batuta-dots)
├── agents/               # Agent definitions with sdk: blocks
│   ├── quality-agent.md
│   └── security-agent.md
├── src/
│   ├── agent_runner.py   # SDK integration code
│   └── ...
├── pyproject.toml        # or package.json for TypeScript
└── .mcp.json             # MCP server configuration
```

## Decision Trees

### When to Use SDK vs Claude Code CLI

| Scenario | Use | Why |
|----------|-----|-----|
| Interactive coding session | Claude Code CLI | Full IDE integration, native hooks, real-time feedback |
| CI/CD code review pipeline | Agent SDK + quality-agent | Automated, headless, repeatable, runs in GitHub Actions |
| Background data processing | Agent SDK + data-pipeline-agent | Long-running, no user interaction, server-side |
| Embedded product assistant | Agent SDK + domain agent | Custom UX, API-driven, end-user facing |
| One-off scripting task | Claude Code CLI | Simpler setup, no SDK boilerplate needed |
| Scheduled report generation | Agent SDK | Cron-driven, headless, needs file system access |
| Multi-agent pipeline | Agent SDK | Orchestrate multiple agents programmatically |

### When to Enable defer_loading

| MCP Server Count | defer_loading | Why |
|-----------------|---------------|-----|
| 0-2 | `false` | Low overhead; direct loading is faster |
| 3-4 | Optional | Marginal benefit; test both and measure |
| 5+ | `true` (recommended) | Significant token savings (~85% reduction) |
| 10+ | `true` (mandatory) | Without it, context fills with tool definitions |

### Setting Sources Configuration

| Use Case | setting_sources | What Loads |
|----------|----------------|------------|
| Full batuta integration | `["project"]` | .claude/skills/, CLAUDE.md, .claude/commands/ |
| SDK only (no batuta) | `[]` or omitted | Only explicit prompt and tools |
| User-scoped global config | `["user"]` | ~/.claude/ global settings |
| Both project + user | `["project", "user"]` | All project + global settings |

## Anti-Patterns (Never Do This)

| Anti-Pattern | Why It Is Wrong | Do This Instead |
|--------------|-----------------|-----------------|
| Hardcode skill content in SDK code | Skills change independently; hardcoding couples SDK code to a point-in-time snapshot | Use `setting_sources=["project"]` to load skills dynamically |
| Copy SKILL.md content into prompts | Duplicates content, drifts from source of truth, increases maintenance burden | Let SDK auto-load from `.claude/skills/` |
| Skip `defer_loading` with 5+ MCPs | Token waste causes accuracy degradation and increased costs; 10 MCPs can add 20K+ tokens | Enable `defer_loading: true` for 5+ MCP servers |
| Use Agent SDK for simple scripts | SDK adds overhead (dependencies, async boilerplate, configuration); overkill for one-shot tasks | Use the Anthropic Client SDK (Messages API) directly |
| Run SDK agents without CLAUDE.md | Agents lose all batuta rules, conventions, and safety checks | Always include `setting_sources=["project"]` with CLAUDE.md present |
| Deploy without testing locally first | SDK behavior may differ from CLI due to hooks and tool availability | Test with `claude --print` first, then migrate to SDK |
| Ignore sdk: block in agent .md files | The sdk: block defines deployment parameters; ignoring it means guessing configuration | Parse sdk: block with `parse_agent_md()` helper |
| Load all tools when only a few are needed | Wastes tokens, increases latency, and may expose unnecessary capabilities | Specify minimal `allowed_tools` list for each use case |

## Code Examples

### Example 1: CI/CD Pipeline Agent (Python -- GitHub Actions)

This example deploys the quality-agent in a GitHub Actions workflow to review PRs
automatically.

```python
#!/usr/bin/env python3
"""CI/CD PR Review Agent -- runs quality-agent via Claude Agent SDK.

Business context: Automates code review on pull requests using the batuta
quality-agent. Runs in GitHub Actions, posts review comments via GitHub CLI.
"""
import asyncio
import os
import sys
from claude_agent_sdk import query, ClaudeAgentOptions

# BUSINESS RULE: Agent runs with project settings so it follows the same
# rules (CLAUDE.md, skills) that developers use in their Claude Code sessions.
OPTIONS = ClaudeAgentOptions(
    model="claude-sonnet-4-6",
    setting_sources=["project"],
    allowed_tools=["Read", "Glob", "Grep", "Bash"],
    max_tokens=16384,
    defer_loading=True,
)

async def review_pr(pr_number: str) -> str:
    """Run quality-agent to review a PR.

    Args:
        pr_number: GitHub PR number to review.

    Returns:
        The agent's review as a markdown string.
    """
    prompt = f"""Review PR #{pr_number} for:
1. Code quality and adherence to project conventions
2. Security issues (use security-audit skill patterns)
3. Missing tests or documentation
4. Breaking changes

Use `gh pr diff {pr_number}` to see the changes.
Use `gh pr view {pr_number}` for PR description and metadata.
Output a structured review with sections for each category."""

    result_parts = []
    async for msg in query(prompt=prompt, options=OPTIONS):
        if msg.type == "text":
            result_parts.append(msg.content)
    return "".join(result_parts)

async def main():
    """Entry point for CI/CD execution."""
    pr_number = os.environ.get("PR_NUMBER")
    if not pr_number:
        print("ERROR: PR_NUMBER environment variable not set", file=sys.stderr)
        sys.exit(1)

    review = await review_pr(pr_number)
    print(review)

    # WORKAROUND: Post review as a PR comment using GitHub CLI.
    # The SDK cannot interact with GitHub directly without the gh tool.
    with open("/tmp/review.md", "w") as f:
        f.write(review)
    os.system(f"gh pr comment {pr_number} --body-file /tmp/review.md")

if __name__ == "__main__":
    asyncio.run(main())
```

**GitHub Actions workflow:**

```yaml
# .github/workflows/agent-review.yml
# BUSINESS RULE: Runs on PR open/update. Uses Agent SDK for automated review.
name: Agent PR Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    name: AI Code Review
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install claude-agent-sdk
      - name: Run Agent Review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          PR_NUMBER: ${{ github.event.pull_request.number }}
        run: python scripts/review_pr.py
```

### Example 2: Embedded Assistant (TypeScript -- Express API)

This example exposes a batuta agent as an API endpoint that products can call.

```typescript
/**
 * Embedded Assistant API -- serves a batuta agent via Express.
 *
 * Business context: Provides an AI assistant endpoint for product features
 * that need code analysis or documentation capabilities. The agent runs
 * with project skills loaded, ensuring consistent behavior with dev sessions.
 */
import express, { Request, Response } from "express";
import { query, ClaudeAgentOptions } from "@anthropic-ai/claude-agent-sdk";

const app = express();
app.use(express.json());

// BUSINESS RULE: limit tools to read-only for embedded assistants.
// SECURITY: embedded agents should never have write access to the filesystem.
const ASSISTANT_OPTIONS: ClaudeAgentOptions = {
  model: "claude-sonnet-4-6",
  settingSources: ["project"],
  allowedTools: ["Read", "Glob", "Grep"],
  maxTokens: 8192,
  deferLoading: true,
};

/**
 * POST /api/assistant -- send a prompt to the embedded agent.
 *
 * Request body: { prompt: string }
 * Response: { response: string }
 */
app.post("/api/assistant", async (req: Request, res: Response) => {
  const { prompt } = req.body;
  if (!prompt || typeof prompt !== "string") {
    return res.status(400).json({ error: "prompt is required" });
  }

  try {
    const parts: string[] = [];
    for await (const msg of query({ prompt, options: ASSISTANT_OPTIONS })) {
      if (msg.type === "text") {
        parts.push(msg.content);
      }
    }
    return res.json({ response: parts.join("") });
  } catch (err) {
    console.error("Agent error:", err);
    return res.status(500).json({ error: "Agent execution failed" });
  }
});

const PORT = process.env.PORT ?? 3001;
app.listen(PORT, () => console.log(`Assistant API on port ${PORT}`));
```

### Example 3: Multi-Agent Orchestration (Python)

Running multiple specialized agents in sequence for a comprehensive review.

```python
"""Multi-agent orchestration -- runs quality + security agents in sequence.

Business context: Complex reviews benefit from specialized agents. Each agent
focuses on its domain expertise (loaded from batuta skills), and results are
combined into a unified report.
"""
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions

# BUSINESS RULE: Each agent gets minimal tools for its specific task.
# This follows the principle of least privilege.
QUALITY_OPTS = ClaudeAgentOptions(
    model="claude-sonnet-4-6",
    setting_sources=["project"],
    allowed_tools=["Read", "Glob", "Grep", "Bash"],
    max_tokens=16384,
)

SECURITY_OPTS = ClaudeAgentOptions(
    model="claude-sonnet-4-6",
    setting_sources=["project"],
    allowed_tools=["Read", "Glob", "Grep"],  # No Bash for security agent
    max_tokens=16384,
)

async def run_agent(prompt: str, options: ClaudeAgentOptions) -> str:
    """Run a single agent and collect its text output.

    Args:
        prompt: Task description for the agent.
        options: SDK configuration (model, tools, settings).

    Returns:
        Concatenated text output from the agent.
    """
    parts = []
    async for msg in query(prompt=prompt, options=options):
        if msg.type == "text":
            parts.append(msg.content)
    return "".join(parts)

async def comprehensive_review(target_path: str) -> dict:
    """Run quality and security reviews in parallel.

    Args:
        target_path: Path to the code directory to review.

    Returns:
        Dictionary with 'quality' and 'security' review results.
    """
    # BUSINESS RULE: Run agents in parallel for speed.
    # Each agent has its own context and tool permissions.
    quality_task = run_agent(
        f"Review {target_path} for code quality, test coverage, and documentation.",
        QUALITY_OPTS,
    )
    security_task = run_agent(
        f"Review {target_path} for security vulnerabilities using security-audit skill.",
        SECURITY_OPTS,
    )
    quality_result, security_result = await asyncio.gather(
        quality_task, security_task
    )
    return {"quality": quality_result, "security": security_result}
```

## Commands

```bash
# Install Claude Agent SDK (Python)
pip install claude-agent-sdk

# Install Claude Agent SDK (TypeScript)
npm install @anthropic-ai/claude-agent-sdk

# Test agent execution locally before deploying
# Uses Claude Code CLI with --print to simulate headless execution
claude --print "Review src/ for security issues"

# Verify .claude/skills/ are being loaded
claude --print "List all loaded skills"

# Parse and validate agent .md file frontmatter
python -c "
import yaml, re
with open('BatutaClaude/agents/pipeline-agent.md') as f:
    m = re.match(r'^---\n(.*?)\n---', f.read(), re.DOTALL)
    print(yaml.safe_load(m.group(1)).get('sdk', {}))
"
```

## Rules

- MUST use `setting_sources=["project"]` when deploying batuta agents via SDK -- this ensures CLAUDE.md rules and skills are loaded
- MUST enable `defer_loading=true` when deploying with 5 or more MCP servers -- token overhead without it degrades accuracy and increases costs
- MUST specify a minimal `allowed_tools` list for each agent -- never grant tools the agent does not need (principle of least privilege)
- MUST parse the `sdk:` block from agent .md frontmatter for deployment configuration -- never hardcode model, max_tokens, or tools
- MUST test agent execution locally with `claude --print` before deploying to CI/CD or production
- NEVER hardcode skill content in SDK application code -- skills are loaded dynamically from `.claude/skills/`
- NEVER grant write tools (`Edit`, `Write`, `Bash`) to embedded assistants serving end users -- read-only tools only for security
- NEVER use Agent SDK for tasks that the Anthropic Client SDK (Messages API) handles -- SDK is for tool-using agents, not simple completions
- NEVER deploy agents without a CLAUDE.md file in the project root -- without it, agents have no behavioral guardrails

## Stack Integration

| Layer | Integration Point |
|-------|-------------------|
| **Claude Code CLI** | Test and prototype agents interactively before deploying via SDK |
| **batuta-dots hub** | Skills and CLAUDE.md are the source of truth; SDK loads them at runtime |
| **GitHub Actions** | CI/CD pipeline runner for automated agent tasks (PR review, security scan) |
| **Docker / Coolify** | Container deployment for long-running agent services |
| **MCP Servers** | SDK loads MCP config from `.mcp.json`; `defer_loading` manages overhead |
| **sdd-init** | Provisions skills into `.claude/skills/` that SDK agents will load |
| **worker-scaffold** | Scaffold Docker containers for SDK-powered background agent workers |
| **ci-cd-pipeline** | Integrate agent review steps into existing CI/CD workflows |

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Agent ignores CLAUDE.md rules | `setting_sources` not set | Add `setting_sources=["project"]` |
| Agent cannot find skills | `.claude/skills/` not provisioned | Run `/sdd-init` or copy skills from hub |
| High token usage with MCPs | `defer_loading` not enabled | Set `defer_loading=True` for 5+ MCPs |
| Agent times out | `max_tokens` too low or task too broad | Increase `max_tokens` or narrow the prompt |
| Tools not available | `allowed_tools` missing entries | Add required tools to the list |
| MCP tools not discovered | `.mcp.json` missing or misconfigured | Verify `.mcp.json` exists and is valid JSON |
| Agent runs but produces no output | Not collecting `text` message types | Check `msg.type == "text"` in the async loop |
| Different behavior vs Claude Code | Hooks not mapped to SDK equivalents | Map hooks using Pattern 5 (Hooks Mapping) |

## What This Means (Simply)

> **For non-technical readers**: Think of Claude Code as a chef working in your
> kitchen -- you talk to them directly and they cook your meal. The Agent SDK is
> like giving that same chef a recipe book and putting them in a restaurant kitchen
> where meals are prepared automatically when orders come in. The chef still follows
> the same recipes (skills) and house rules (CLAUDE.md), but now they work without
> you standing there giving instructions. This skill teaches you how to set up that
> "restaurant kitchen" -- whether it is for automatically reviewing code changes,
> processing data in the background, or powering an AI feature in your product.
> The key idea is that the agent behaves the same whether you are talking to it
> directly or it is running on its own.

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "setting_sources is optional -- I'll just put the rules in the prompt" | Rules in the prompt are a snapshot. The next time CLAUDE.md updates, your SDK agent silently runs with stale rules. `setting_sources=["project"]` keeps the SDK agent in lockstep with what developers see in Claude Code. Skipping it guarantees prod-vs-dev drift |
| "I'll skip defer_loading -- 5 MCPs is not that many" | 5 MCP servers is roughly 10-20K tokens of tool definitions loaded on every turn. That is 10-20K tokens of context the model could be using for actual work. With `defer_loading=true` the model discovers tools on demand via Tool Search and reclaims that context |
| "I'll grant the assistant Edit and Write -- it makes the API more useful" | Embedded assistants serving end users should never have write access. The first prompt-injection attack in user input becomes an arbitrary file write or shell execution. Read-only tools by default; expand only after a documented threat-model review |
| "I'll hardcode the agent prompt in the SDK code -- it's faster than parsing the .md" | Hardcoded prompts diverge from the source of truth in `BatutaClaude/agents/`. The agent file gets updated, the SDK keeps the old prompt, and you debug ghost behavior for hours. Parse the `.md` file at startup; the cost is one regex per process |
| "Different behavior in SDK vs Claude Code is fine -- they are different runtimes" | Different is acceptable; surprising is not. The SDK is designed to mirror Claude Code behavior when `setting_sources=["project"]` is set. If they diverge, it is almost always a missing setting (hooks not mapped, tools not allowed, defer_loading not enabled), and fixing the config restores parity |

## Red Flags

- `query()` or `Query()` called without `setting_sources=["project"]` in a batuta project
- 5+ MCP servers configured without `defer_loading=true`
- `allowed_tools` includes write tools (`Edit`, `Write`, `Bash`) for an embedded/end-user-facing assistant
- Agent prompt hardcoded as a Python string literal instead of parsed from `BatutaClaude/agents/*.md`
- SDK deployment without a `CLAUDE.md` file in the project root
- `sdk:` block in agent .md frontmatter ignored when configuring `ClaudeAgentOptions`
- Production deployment without a prior `claude --print` smoke test run locally
- Hooks defined in `settings.json` for Claude Code but not mapped to SDK `Hooks` for the SDK agent
- `model` not pinned in `ClaudeAgentOptions` (relies on SDK default which can change between releases)
- `max_tokens` left at default for a long-running review task (will silently truncate)
- Agent that streams output but the consumer never filters by `msg.type == "text"` (collects metadata as content)

## Verification Checklist

- [ ] `ClaudeAgentOptions(setting_sources=["project"], ...)` is set on every batuta agent run
- [ ] `defer_loading=True` is enabled when 5 or more MCP servers are configured
- [ ] `allowed_tools` is the minimal list required for the task (principle of least privilege)
- [ ] Embedded/end-user-facing assistants are restricted to read-only tools (`Read`, `Glob`, `Grep`)
- [ ] Agent prompt and config are parsed from `BatutaClaude/agents/*.md` via `parse_agent_md()` -- not hardcoded
- [ ] `CLAUDE.md` exists in the project root that the SDK loads via `setting_sources=["project"]`
- [ ] Local smoke test with `claude --print "..."` passes before deploying to CI/CD or production
- [ ] Claude Code hooks (PreToolUse, PostToolUse, SessionStart, Stop) are mapped to SDK `Hooks` equivalents
- [ ] `model` is explicitly set in `ClaudeAgentOptions` (e.g., `claude-sonnet-4-6`); not relying on SDK default
- [ ] `max_tokens` is sized for the worst-case task output (16384 for reviews; 4096-8192 for short responses)
- [ ] Stream consumer filters by `msg.type == "text"` to collect only user-visible content
- [ ] `.mcp.json` is committed and validated as JSON; MCP servers are reachable from the deployment environment
