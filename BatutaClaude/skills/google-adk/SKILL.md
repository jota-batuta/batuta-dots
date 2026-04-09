---
name: google-adk
description: >
  Patterns for building AI agents with Google ADK (Agent Development Kit).
  Trigger: "ADK agent", "Google ADK", "LlmAgent", "FunctionTool", "adk web", "adk api_server",
  "agent with tools", "session management ADK".
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-04-07"
  scope: [capability]
  auto_invoke: "When building or modifying Google ADK agents"
  platforms: [claude]
  category: "capability"
allowed-tools: Read Edit Write Glob Grep Bash
---

## Purpose

Patterns and gotchas for building agents with Google ADK. Covers agent definition, tools, sessions, FastAPI integration, and the runner lifecycle. Prevents common mistakes verified in GitHub issues.

## When to Use

- Building an ADK agent with custom tools
- Integrating ADK with FastAPI and custom endpoints
- Managing sessions per user/group
- Invoking the agent from scheduled tasks (proactive mode)

## Critical Patterns

### Pattern 1: Agent Definition

`Agent` and `LlmAgent` are the SAME class (alias). Use `Agent`.

```python
from google.adk.agents import Agent

agent = Agent(
    name="bato",
    model="gemini-2.5-flash",
    instruction=build_instruction,  # callable for dynamic context
    tools=[query_stock, query_compras, query_traspasos],
)
```

The `instruction` field accepts:
- A string with `{var}` placeholders (injected from session.state)
- A callable `(ReadonlyContext) -> str` for dynamic logic (disables template injection)

Use callable when different sessions need different instructions (e.g., store group vs management group).

### Pattern 2: Tools as Plain Functions

ADK auto-wraps Python functions as `FunctionTool`. No need to use `FunctionTool()` explicitly.

```python
from google.adk.tools import ToolContext

def query_stock(
    nombre_producto: str,
    tool_context: ToolContext,  # ADK injects this — do NOT include in docstring
) -> dict:
    """Consulta el stock actual de un producto en la tienda.

    Args:
        nombre_producto: Nombre o parte del nombre del producto.

    Returns:
        Dict con productos encontrados y sus stocks.
    """
    store_code = tool_context.state.get("store_code")
    # ... query SQL Server ...
    return {"status": "success", "productos": results}
```

Rules:
- `ToolContext` is auto-injected. NEVER include it in the docstring (LLM would try to pass it).
- `*args` and `**kwargs` are invisible to the LLM. Use named params with type hints.
- Async tools (`async def`) are fully supported and run in parallel when possible.
- Use `tool_context.state["temp:key"]` for data that only lives within the current turn.

### Pattern 3: Sessions Per Group

For multi-group WhatsApp agent, use `group_jid` as `session_id`:

```python
from google.adk.sessions import InMemorySessionService
from google.adk.runners import Runner

session_service = InMemorySessionService()
runner = Runner(agent=agent, app_name="batovf", session_service=session_service)

# Create session with store context
session = await session_service.create_session(
    app_name="batovf",
    user_id="system",
    session_id=group_jid,  # "120363xxx@g.us"
    state={"store_code": "PQ", "store_name": "Parque", "almacen": "PQ"},
)
```

NEVER modify `session.state` directly. Always use `ToolContext.state` inside tools.

### Pattern 4: Runner is Stateless and Thread-Safe

Create ONE Runner at startup. Reuse for all concurrent requests from all groups.

```python
# Startup — once
runner = Runner(agent=agent, app_name="batovf", session_service=session_service)

# For each incoming message — reuse runner
async for event in runner.run_async(
    user_id="system",
    session_id=group_jid,
    new_message=types.Content(role="user", parts=[types.Part(text=text)]),
):
    if event.is_final_response() and event.content:
        response = event.content.parts[0].text
```

### Pattern 5: FastAPI Integration

Do NOT use `get_fast_api_app(web=True)` — it mounts static files on `/` and breaks custom endpoints (Issue #51).

For production with custom endpoints (webhook):
```python
from fastapi import FastAPI

app = FastAPI()

# Custom endpoint BEFORE any ADK mount
@app.post("/webhook/whatsapp")
async def webhook(payload: dict):
    ...
```

For development/testing, use `adk web` CLI command separately.

### Pattern 6: Multimodal Input (image, audio, video, document)

`gemini-flash-latest` is multimodal natively. To pass non-text content, build a
`Content` with multiple `Part` objects: a text Part for any caption/instruction
and one Part per file as `inline_data` (a `Blob` with `mime_type` + raw bytes).

```python
from google.genai import types

# Text only — what we did before multimodal
content = types.Content(
    role="user",
    parts=[types.Part(text="cuantas empanadas hay")],
)

# Image with caption
content = types.Content(
    role="user",
    parts=[
        types.Part(text="esto es lo que veo en el estante"),  # caption first
        types.Part(
            inline_data=types.Blob(
                mime_type="image/jpeg",
                data=image_bytes,  # raw bytes, NOT base64
            )
        ),
    ],
)

# Audio voice note (no caption)
content = types.Content(
    role="user",
    parts=[
        types.Part(
            inline_data=types.Blob(
                mime_type="audio/ogg",
                data=audio_bytes,
            )
        ),
    ],
)
```

Pass `content` to `runner.run_async(new_message=content, ...)` exactly the same
way as text. The model handles the multimodal reasoning internally.

**Limits**:
- Max ~20MB inline data per request. For larger files use Google File API and
  pass `Part(file_data=FileData(file_uri=...))` instead.
- Caption order matters: put the text Part FIRST so the model knows the user's
  intent before seeing the file.
- `data` must be raw bytes (not base64). If you got base64 from an upstream
  service (like Evolution API), `base64.b64decode()` it before constructing the
  Blob.

### Pattern 7: Embeddings via Vertex AI

For RAG over multimodal content, the genai SDK does NOT include the multimodal
embedding model. Use `google-cloud-aiplatform` (Vertex AI SDK) and the
`gemini-embedding-2-preview` model. It vectorizes text + image + audio + video +
PDF in the same vector space.

```python
# pyproject.toml
# google-cloud-aiplatform >= 1.71.0

import vertexai
from vertexai.preview.vision_models import MultiModalEmbeddingModel

vertexai.init(project=GCP_PROJECT_ID, location="us-central1")
model = MultiModalEmbeddingModel.from_pretrained("gemini-embedding-2-preview")

# Text only
result = model.get_embeddings(contextual_text="empanada de carne en estante")
text_vector = result.text_embedding  # list[float], up to 3072 dim

# Image (raw bytes)
from vertexai.preview.vision_models import Image
image = Image(image_bytes=image_bytes)
result = model.get_embeddings(image=image)
img_vector = result.image_embedding
```

Truncate to 1536 dimensions (MRL — Matryoshka Representation Learning) so that
pgvector's `hnsw` index works efficiently. Higher dimensions degrade hnsw recall.

Setup requires: GCP project + Vertex AI API enabled + service account with
`roles/aiplatform.user` + JSON key mounted as `GOOGLE_APPLICATION_CREDENTIALS`.

### Pattern 8: Proactive Mode (Scheduled Checks)

Proactive checks (Prefect flows) should NOT share session_id with conversational sessions:

```python
# Proactive — ephemeral session
session_id = f"check-{store_code}-{datetime.now().isoformat()}"

# Reactive — persistent session per group
session_id = group_jid  # "120363xxx@g.us"
```

This prevents check results from contaminating conversational history.

## Gotchas (Verified)

1. `web=True` in `get_fast_api_app` breaks custom endpoints (Issue #51)
2. `InMemorySessionService` loses all data on restart — acceptable for MVP
3. `DatabaseSessionService` with asyncpg has timezone bug (Issue #4366) — use InMemory for MVP
4. `session.state` direct modification bypasses tracking — always use ToolContext
5. ToolContext in docstring makes LLM try to pass it as argument
6. `*args`/`**kwargs` are invisible to LLM schema
7. **`adk web` agent loading** — when launched as `adk web src`, the CLI adds `src/` to sys.path and loads `bato/` as the top-level package. Imports inside `bato/` MUST use `from bato.X import Y`, NOT `from src.bato.X import Y`. The latter works in standalone smoke tests (because cwd is the project root) but fails inside `adk web` with `ModuleNotFoundError: No module named 'src'`.
8. **`adk web` looks for `root_agent`, not `agent`** — when loading the agent module, ADK Web imports `bato.agent.root_agent` (or `bato.root_agent`, or `bato/root_agent.yaml`). If you defined `agent = Agent(...)` for internal use, also export `root_agent = agent` at the bottom of the module so both work.
9. **`gemini-flash-lite-latest` has text corruption bugs** in structured responses (truncated words, missing characters). Use `gemini-flash-latest` instead. The `-latest` alias auto-tracks the newest stable version, so you survive Google's quarterly model deprecations without code changes.
10. **Multimodal Part construction** — `inline_data` takes a `Blob`, not raw bytes. The Blob has `mime_type` (string) and `data` (raw bytes, not base64). If you pass a base64 string, the model fails silently — `b64decode` it first.
11. **Caption goes BEFORE the media Part** — putting the caption Part after the media Part can confuse the model about user intent. Order: text first, then media.
12. **Multimodal API rate limits are stricter than text-only** — image + audio + video requests count against a separate quota. Plan for retries with exponential backoff in production.
13. **`gemini-embedding-2-preview` is NOT in genai SDK** — it's only accessible via `google-cloud-aiplatform` (Vertex AI). Setup requires a GCP service account with `roles/aiplatform.user`. The model is in PUBLIC PREVIEW (since 2026-03-10) — pin a version constant in your wrapper module and monitor the changelog for breaking API changes.
14. **`google.genai.types.Content` requires a `role`** — passing `parts=[]` without `role` raises a confusing TypeError downstream. Always set `role="user"` for incoming messages.
