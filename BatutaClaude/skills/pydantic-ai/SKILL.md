---
name: pydantic-ai
version: "1.1"
description: Use when building AI agents with Pydantic AI (pydantic-ai) — Python framework by the Pydantic team for structured agents with typed dependencies, function tools, and dynamic instructions. Trigger — "Pydantic AI", "pydantic-ai", "Agent() constructor", "@agent.tool", "RunContext[Deps]", "AGUIAdapter", "agent.to_ag_ui", "ag-ui protocol", "GoogleModel gemini", "expose agent web ui". Covers Agent definition, typed dependencies, tool decorators, dynamic instructions, Gemini/Google provider, and AG-UI web exposure (equivalent to ADK Web for Pydantic AI agents).
---

# Pydantic AI Skill

**Source of truth**: https://pydantic.dev/docs/ai/ (canonical) — formerly https://ai.pydantic.dev/ (301 redirects to new home). Always verify with the live docs before coding — Pydantic AI evolves fast.

## What it is
Pydantic AI is an agent framework from the Pydantic team. It turns plain Python functions into LLM-callable tools using Pydantic for schema generation and validation. It is to Python agents what FastAPI is to HTTP APIs: typed, minimal, and schema-first.

Core primitives:
- `Agent` — the main entry point. Binds a model, instructions, typed dependencies, tools, and output type.
- `RunContext[Deps]` — injected into tools; carries `ctx.deps` (your typed dependency container) and conversation state.
- `@agent.tool` / `@agent.tool_plain` — register callables as LLM tools. The first receives `RunContext`, the second does not.
- `@agent.instructions` — dynamic system prompt built per-run from `RunContext`.
- `Agent.run()` / `.run_sync()` / `.run_stream()` — execute the agent.

## Install
```bash
# Minimal + specific extras (recommended for PoC + production)
pip install 'pydantic-ai-slim[google,ag-ui]'

# Or full install with every provider
pip install pydantic-ai
```

Extras matrix (as of April 2026):
- `[google]` — GoogleModel (Gemini) via `google-genai` SDK.
- `[openai]` — OpenAI-compatible models.
- `[ag-ui]` — AG-UI protocol adapter for exposing agents over HTTP. Brings `ag-ui-protocol`, `starlette`.

## Canonical Agent Definition

```python
from dataclasses import dataclass, field
from pydantic_ai import Agent, RunContext

@dataclass
class MyDeps:
    """Typed dependency container — pass with `agent.run(..., deps=MyDeps(...))`."""
    user_id: str
    # Mutable state is legal — Pydantic AI does NOT freeze deps between tool calls.
    # Tools that need to mutate session state can write directly to a dict field.
    state: dict = field(default_factory=dict)

agent = Agent(
    'google-gla:gemini-3.1-flash-lite-preview',
    deps_type=MyDeps,
    output_type=str,
    instructions="Static fallback instructions (overridden by @agent.instructions below).",
)

@agent.instructions
def build_instructions(ctx: RunContext[MyDeps]) -> str:
    """Dynamic system prompt built per-run from deps.

    Equivalent to ADK's `instruction=lambda ctx: ...` callable pattern.
    Can be sync or async. Return str or None (None skips the dynamic block).
    """
    return f"You are helping user {ctx.deps.user_id}."

@agent.tool
def fetch_data(ctx: RunContext[MyDeps], query: str) -> dict:
    """Fetch data from the backend.

    Args:
        query: what to search for.
    """
    # ctx.deps gives typed access to MyDeps. Mutate freely — persists across tool calls.
    ctx.deps.state["last_query"] = query
    return {"ok": True, "query": query}

@agent.tool_plain
def utc_now() -> str:
    """Return current UTC time — does not need session context."""
    from datetime import datetime, timezone
    return datetime.now(timezone.utc).isoformat()

# Run it
result = agent.run_sync("Find X", deps=MyDeps(user_id="u-42"))
print(result.output)
```

## Key Rules

### Tool signature rules
- **First parameter must be `ctx: RunContext[Deps]`** if the tool needs deps. Otherwise use `@agent.tool_plain`.
- Tool parameters are auto-converted to JSON schema by Pydantic. Use standard type hints (`int`, `str`, `list[str]`, `dict`, Pydantic models, etc.).
- Return anything JSON-serializable (`dict` is typical).
- **Docstrings are LLM-facing**: they become the tool description and per-arg descriptions. Pydantic AI parses Google, NumPy, and Sphinx docstring styles. Write them for the model, not for humans.

### Deps are NOT frozen
Unlike some frameworks, Pydantic AI passes your `deps` object by reference to every tool in a run. You CAN mutate fields. This is the idiomatic way to implement stateful tools (e.g. "set session store"):

```python
@agent.tool
def set_store(ctx: RunContext[MyDeps], store_code: str) -> dict:
    ctx.deps.state["store"] = store_code  # persists for the rest of this run AND future runs if you reuse deps
    return {"ok": True}
```

If you want fresh state per run, construct a fresh `deps` instance for each `agent.run()` call.

### Dynamic instructions vs dynamic system_prompt
- `@agent.instructions` — new-style decorator, receives `RunContext`, returns `str | None`. Preferred.
- `@agent.system_prompt(dynamic=True)` — older pattern, still supported. The `dynamic=True` kwarg makes it re-evaluate when `message_history` is provided.

## Google / Gemini Provider

```python
from pydantic_ai import Agent
from pydantic_ai.models.google import GoogleModel

# Option 1: model string (preferred for quick agents)
agent = Agent('google-gla:gemini-3.1-flash-lite-preview', ...)

# Option 2: explicit GoogleModel (needed for custom provider config)
model = GoogleModel('gemini-3.1-flash-lite-preview', provider='google-gla')
agent = Agent(model, ...)
```

- `google-gla` = Google Generative Language API (aistudio.google.com key → `GOOGLE_API_KEY` env var).
- `google-vertex` = Vertex AI (enterprise; requires GCP project + service account).
- `gateway` = Pydantic AI gateway (if you're using their hosted gateway).

Env vars picked up automatically: `GOOGLE_API_KEY` for `google-gla`.

## AG-UI: Exposing an agent over HTTP (equivalent of `adk web`)

Pydantic AI does NOT ship a built-in web UI the way Google ADK does (`adk web` spawns a local playground). Instead, it integrates with the **AG-UI protocol** — an open standard created by the CopilotKit team and adopted by Pydantic AI, LangGraph, and others. AG-UI standardizes how a web frontend talks to an agent backend (streaming tokens, tool events, shared state).

Pydantic AI exposes three integration points (documented at https://pydantic.dev/docs/ai/integrations/ui/ag-ui/):

1. **`AGUIAdapter.run_stream()`** — raw stream; integrate with any web framework by hand.
2. **`AGUIAdapter.dispatch_request()`** — one-liner for Starlette/FastAPI. **This is the idiomatic path.**
3. **`AGUIApp`** — a standalone ASGI app you can mount at any path in an existing FastAPI.

### Minimal FastAPI example (recommended)

```python
from fastapi import FastAPI
from starlette.requests import Request
from starlette.responses import Response

from pydantic_ai import Agent
from pydantic_ai.ui.ag_ui import AGUIAdapter

agent = Agent('google-gla:gemini-3.1-flash-lite-preview', instructions="Be concise.")
app = FastAPI()

@app.post('/agent')
async def run_agent(request: Request) -> Response:
    return await AGUIAdapter.dispatch_request(request, agent=agent)
```

Run with:
```bash
uvicorn your_module:app --reload --port 8000
```

### Passing deps to a per-request agent
`dispatch_request` accepts a `deps` kwarg — use it to inject per-request state (auth, session, tenant):

```python
@app.post('/agent')
async def run_agent(request: Request) -> Response:
    deps = MyDeps(user_id=request.headers.get("x-user"))
    return await AGUIAdapter.dispatch_request(request, agent=agent, deps=deps)
```

### What about the frontend?
Pydantic AI only exposes the **backend** AG-UI endpoint. The frontend is a separate concern. Options:
- **CopilotKit** — the AG-UI client. `npx create-copilotkit` scaffolds a React/Next.js app that talks to any AG-UI endpoint. This is the closest to ADK Web — a ready-made chat playground.
- **Raw curl / Python client** — for PoC validation you can POST an AG-UI `RunAgentInput` payload and consume the SSE stream.
- **Custom frontend** — any client that speaks AG-UI's event protocol.

For quick local testing without a frontend, use `agent.run_sync(...)` in a Python REPL or script — faster feedback than spinning up the web server.

## Common Gotchas

### 1. Importing an ADK-style tool that takes `tool_context`
Pydantic AI derives the tool schema from the **wrapper function signature**, not from the wrapped function. If you're porting ADK tools (which take `tool_context: ToolContext`), the ADK `tool_context` arg will leak into the schema if you pass it as a regular parameter. Wrap them:

```python
class _ShimCtx:
    """Duck-typed stand-in for ADK's ToolContext — tools only read/write .state."""
    def __init__(self, state: dict):
        self.state = state

@agent.tool
def consultar_stock(ctx: RunContext[MyDeps], nombre_producto: str) -> dict:
    """Consulta el stock actual de un producto."""
    from bato.tools.stock import consultar_stock as _orig
    return _orig(nombre_producto, _ShimCtx(ctx.deps.state))
```

### 2. `deps_type` vs `output_type`
`deps_type` is the input container. `output_type` is the structured result type — use a Pydantic model or a primitive (`str`, `bool`). Setting `output_type=str` means the agent returns free-form text (tool calls still work).

### 3. Async tools
Pydantic AI handles `async def` tools transparently. Wrappers over async ADK tools must be `async` and `await` the underlying call:

```python
@agent.tool
async def generar_informe(ctx: RunContext[MyDeps], tienda: str) -> dict:
    from bato.tools.informe import generar_informe_tienda as _orig
    return await _orig(tienda, _ShimCtx(ctx.deps.state))
```

### 4. Training data is stale
Pydantic AI releases frequently. Any pattern older than 3 months may be wrong. When in doubt: **WebFetch https://pydantic.dev/docs/ai/** for the current canonical docs before coding. Do NOT trust training data for API surface — verify.

## Verification Checklist (before committing agent code)

- [ ] `Agent()` constructor: `model`, `deps_type`, `output_type`, and either `instructions=` or `@agent.instructions`.
- [ ] Every `@agent.tool` has `ctx: RunContext[Deps]` as first arg; every `@agent.tool_plain` does not.
- [ ] Every tool has a docstring (LLM reads it).
- [ ] Deps dataclass has `@dataclass` and all fields are typed.
- [ ] Async tools are `async def` AND their underlying call is `await`-ed.
- [ ] Model string matches provider: `'google-gla:gemini-...'` for Gemini via GLA.
- [ ] Env var present: `GOOGLE_API_KEY` for google-gla.
- [ ] If exposing via web: `AGUIAdapter.dispatch_request(request, agent=agent, deps=...)` inside a FastAPI POST route, run with `uvicorn`.

## References
- https://pydantic.dev/docs/ai/ — main docs home
- https://pydantic.dev/docs/ai/core-concepts/agent/ — Agent reference
- https://pydantic.dev/docs/ai/tools-toolsets/tools/ — tools & decorators
- https://pydantic.dev/docs/ai/integrations/providers/google/ — Gemini provider
- https://pydantic.dev/docs/ai/integrations/ui/ag-ui/ — AG-UI integration
- https://github.com/pydantic/pydantic-ai — source

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "My training data is current enough -- I'll skip the WebFetch" | Pydantic AI ships breaking API changes monthly. Patterns from 3 months ago may still compile but produce wrong tool schemas, broken streams, or silent state corruption. The cost of one WebFetch is 30 seconds; the cost of debugging a stale API pattern is hours |
| "I'll verify the docs later -- let me get the agent working first" | "Working" without verification means it produced text without crashing. That is not the same as correct. Tool schemas, dep injection, and AG-UI dispatch all have subtle behaviors (deps not frozen, tool_context invisible to LLM, role required on Content) that are easy to get wrong and hard to detect from the output |
| "I can copy the ADK tool signature -- they look similar" | They are not. ADK injects `tool_context: ToolContext`; Pydantic AI uses `ctx: RunContext[Deps]`. Copying the ADK signature leaks `tool_context` into the LLM-facing schema, and the model will try to pass it as an argument. Wrap, don't copy |
| "I'll use `@agent.system_prompt` -- it's what the old tutorial showed" | The new pattern is `@agent.instructions`. The old `system_prompt(dynamic=True)` still works but is being deprecated in upcoming releases. New code should use `@agent.instructions` |
| "Sync tool is fine even though the underlying call is async -- I'll just use `asyncio.run()`" | `asyncio.run()` inside an async event loop raises `RuntimeError: cannot be called from a running event loop`. Pydantic AI's runner is async; sync tools that wrap async calls without `await` either crash or block the loop. Make the tool `async def` |

## Red Flags

- Code written without a recent (within 2 weeks) WebFetch of https://pydantic.dev/docs/ai/
- `@agent.tool` function with first parameter named `tool_context` (ADK pattern leaking into Pydantic AI)
- Missing docstring on a `@agent.tool` (the LLM reads the docstring as the tool description)
- `*args` or `**kwargs` in a tool signature (invisible to the LLM schema, will not be called correctly)
- `asyncio.run()` called inside an async tool body
- `Agent()` without `deps_type=` declared, then `ctx.deps` accessed inside tools
- AG-UI endpoint that does not pass `deps=` per request (every request shares the same deps instance)
- Reusing the same `deps` instance across `agent.run()` calls when fresh state is needed per run
- Model string typo (`gemini-flash-lite-latest` instead of `gemini-flash-latest` -- the lite has known text corruption bugs)
- Missing `GOOGLE_API_KEY` env var when using `google-gla:` provider prefix

## Verification Checklist (Rationalization-Focused)

- [ ] Latest `pydantic.dev/docs/ai/` content was fetched within the past 2 weeks before writing agent code
- [ ] Every `@agent.tool` has `ctx: RunContext[Deps]` as the first parameter; every `@agent.tool_plain` does NOT
- [ ] No tool function uses `tool_context` as a parameter name (that is ADK -- if porting, wrap with a shim)
- [ ] Every tool has a non-empty docstring written for the LLM (not for humans)
- [ ] Async tools are declared `async def` AND await any async calls inside
- [ ] `deps_type=` is declared on `Agent()` if any tool reads `ctx.deps`
- [ ] AG-UI endpoints construct fresh `deps` per request and pass them via `dispatch_request(..., deps=...)`
- [ ] Model string uses a stable alias (`gemini-flash-latest`) -- avoid `-lite-` variants known to corrupt structured output
- [ ] `GOOGLE_API_KEY` env var is present and validated at startup
- [ ] Dynamic instructions use `@agent.instructions` (current API), not `@agent.system_prompt(dynamic=True)` (legacy)
