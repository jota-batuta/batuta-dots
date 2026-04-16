---
name: evolution-api
description: >
  Patterns for WhatsApp integration via Evolution API (Baileys-based).
  Trigger: "Evolution API", "WhatsApp", "webhook WhatsApp", "send message group",
  "WhatsApp group", "evolution-api".
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-04-07"
  bucket: build
  auto_invoke: "When integrating with WhatsApp via Evolution API"
  platforms: [claude]
  category: "capability"
allowed-tools: Read Edit Write Glob Grep Bash
---

## Purpose

Verified patterns for sending and receiving WhatsApp messages via Evolution API. Covers webhook parsing, group messaging, and gotchas discovered through GitHub issues.

## When to Use

- Sending messages to WhatsApp groups
- Receiving messages via webhook
- Parsing group message payloads
- Configuring Evolution API webhooks

## Critical Patterns

### Pattern 1: Send Text to Group

```python
import httpx

async def send_text_to_group(group_jid: str, text: str) -> dict:
    url = f"{EVOLUTION_API_URL}/message/sendText/{INSTANCE}"
    headers = {"apikey": API_KEY}
    payload = {
        "number": group_jid,  # MUST be "number", NOT "groupJid"
        "text": text,
    }
    async with httpx.AsyncClient() as client:
        response = await client.post(url, json=payload, headers=headers, timeout=30)
        return response.json()
```

### Pattern 2: Parse Webhook Payload (text + multimodal)

Detects text and ALL media types (image, audio, video, document) so the caller
can decide whether to download the media bytes and process them with a multimodal
LLM. Returns a dict with `media_type` field indicating which path to take.

```python
def parse_webhook(payload: dict) -> dict | None:
    if payload.get("event") != "messages.upsert":
        return None

    data = payload["data"]
    key = data["key"]
    remote_jid = key["remoteJid"]

    if not remote_jid.endswith("@g.us"):
        return None  # Only group messages
    if key.get("fromMe", False):
        return None  # Skip own messages

    message = data.get("message", {})
    media_type = "text"
    mime_type = None
    media_key = None
    text = ""

    # Detect media type — Evolution API uses a different field per type
    if "imageMessage" in message:
        media_type = "image"
        m = message["imageMessage"]
        mime_type = m.get("mimetype", "image/jpeg")
        media_key = m.get("mediaKey")
        text = m.get("caption", "") or ""
    elif "audioMessage" in message:
        media_type = "audio"
        m = message["audioMessage"]
        mime_type = m.get("mimetype", "audio/ogg")
        media_key = m.get("mediaKey")
        text = ""  # audio has no caption
    elif "videoMessage" in message:
        media_type = "video"
        m = message["videoMessage"]
        mime_type = m.get("mimetype", "video/mp4")
        media_key = m.get("mediaKey")
        text = m.get("caption", "") or ""
    elif "documentMessage" in message:
        media_type = "document"
        m = message["documentMessage"]
        mime_type = m.get("mimetype", "application/octet-stream")
        media_key = m.get("mediaKey")
        text = m.get("caption") or m.get("fileName", "") or ""
    else:
        # Text in TWO different locations
        text = (
            message.get("conversation")
            or message.get("extendedTextMessage", {}).get("text")
            or ""
        )
        if not text.strip():
            return None  # sticker, reaction, etc — ignore

    return {
        "group_jid": remote_jid,
        "sender_jid": key.get("participant", ""),
        "sender_name": data.get("pushName", ""),
        "media_type": media_type,        # text|image|audio|video|document
        "text": text.strip(),
        "mime_type": mime_type,          # None for text
        "media_key": media_key,          # needed for download
        "message_id": key.get("id", ""), # needed for download
    }
```

### Pattern 2b: Download Media Bytes from Evolution API

The webhook payload does NOT contain the actual media bytes — only `mediaKey`
and metadata. To get the file content, make a second request to
`/chat/getBase64FromMediaMessage/{instance}` with the `message_id`.

```python
import base64
import httpx

async def download_media(message_id: str) -> bytes:
    url = f"{EVOLUTION_API_URL}/chat/getBase64FromMediaMessage/{INSTANCE}"
    headers = {"apikey": API_KEY, "Content-Type": "application/json"}
    payload = {
        "message": {"key": {"id": message_id}},  # MUST be nested under "message"
        "convertToMp4": False,
    }
    async with httpx.AsyncClient() as client:
        response = await client.post(url, json=payload, headers=headers, timeout=60)
        response.raise_for_status()
        data = response.json()

    # Field name varies by Evolution API version — try both
    b64_str = data.get("base64") or data.get("media")
    if not b64_str:
        raise ValueError(f"No base64 in response. Keys: {list(data.keys())}")

    return base64.b64decode(b64_str)
```

### Pattern 2c: Send Media (PDF, image, audio) to Group

Use `/message/sendMedia/{instance}` for all media types. The `mediatype` field
distinguishes document/image/video/audio. Media is sent as base64 inline (no URL).

```python
import base64
import httpx

async def send_media_to_group(
    group_jid: str,
    file_bytes: bytes,
    file_name: str,
    mime_type: str,
    media_type: str = "document",  # document|image|video|audio
    caption: str = "",
) -> dict:
    url = f"{EVOLUTION_API_URL}/message/sendMedia/{INSTANCE}"
    headers = {"apikey": API_KEY}
    payload = {
        "number": group_jid,           # always "number", even for groups
        "mediatype": media_type,
        "mimetype": mime_type,
        "caption": caption,
        "media": base64.b64encode(file_bytes).decode("ascii"),
        "fileName": file_name,
    }
    async with httpx.AsyncClient() as client:
        response = await client.post(url, json=payload, headers=headers, timeout=120)
        return response.json()
```

For PDFs specifically, validate the `%PDF-` header before sending to avoid
shipping corrupt files to a real WhatsApp group.

### Pattern 3: Configure Webhook

```python
async def setup_webhook(callback_url: str):
    url = f"{EVOLUTION_API_URL}/webhook/instance"
    headers = {"apikey": GLOBAL_API_KEY}
    payload = {
        "url": callback_url,
        "webhook_by_events": False,
        "webhook_base64": False,
        "events": ["MESSAGES_UPSERT"],
    }
    async with httpx.AsyncClient() as client:
        await client.post(url, json=payload, headers=headers)
```

### Pattern 4: Get All Group JIDs

```python
async def get_all_groups():
    url = f"{EVOLUTION_API_URL}/group/fetchAllGroups/{INSTANCE}"
    headers = {"apikey": API_KEY}
    async with httpx.AsyncClient() as client:
        response = await client.get(url, headers=headers)
        groups = response.json()
        # Returns list of: {"id": "120363xxx@g.us", "subject": "Group Name", ...}
        return {g["id"]: g["subject"] for g in groups}
```

### Pattern 5: Rate Limiting for Multiple Groups

```python
import asyncio

MESSAGE_DELAY_SECONDS = 5  # Between groups to avoid ban

async def send_to_all_groups(messages: list[tuple[str, str]]):
    for i, (group_jid, text) in enumerate(messages):
        await send_text_to_group(group_jid, text)
        if i < len(messages) - 1:
            await asyncio.sleep(MESSAGE_DELAY_SECONDS)
```

## Gotchas (Verified)

1. **Field is "number", NOT "groupJid"** — Using "groupJid" returns 400 (Issue #1712)
2. **Text in TWO locations** — `message.conversation` OR `message.extendedTextMessage.text`. Always check both.
3. **pushName is unreliable** — Can be empty or wrong. Use `key.participant` (phone JID) as primary identifier.
4. **GROUPS_UPSERT is NOT for messages** — It fires when a group is CREATED. Group messages come via MESSAGES_UPSERT.
5. **Version >= 2.3.4 required** — v2.2.3 has timeout bug sending to groups (Issue #2039)
6. **Enable "group interaction"** on the instance or you get 400 Bad Request
7. **Ban risk is real but low for small volume** — Delay 3-8s between messages, max 3 alerts/group/day
8. **Two API keys**: Global key manages instances, instance token sends messages. Don't confuse them.
9. **Webhook has no guaranteed delivery** — If BATO is down, messages may be lost. No documented retry count.
10. **WhatsApp formatting**: `*bold*`, `_italic_`, `~strikethrough~`, `` `code` ``
11. **Media bytes are NOT in the webhook** — payload contains only `mediaKey` + metadata. Always make a second request to `/chat/getBase64FromMediaMessage/{instance}` to get the actual file. Don't try to reconstruct from `mediaKey`.
12. **`/chat/getBase64FromMediaMessage` payload structure** — must be `{"message": {"key": {"id": message_id}}}`, NOT just `{"id": message_id}`. Verified against Evolution API v2.3.4+. The response field name varies by version: try `base64` first, fall back to `media`.
13. **`/message/sendMedia` uses `mediatype` field** (note: no underscore) — values are `document`, `image`, `video`, `audio`. PDFs go as `document`. The `mimetype` field is separate (e.g. `application/pdf`).
14. **PDF validation before sending** — check the bytes start with `b"%PDF-"` magic header. WhatsApp will accept and send corrupt files silently and the user will see "could not open document".
15. **Max file size for inline media** — WhatsApp limits media to 16MB on the user side. Evolution API has its own buffer; for files >20MB use a chunked approach or skip the media.
16. **Audio messages have `ptt: True` for voice notes** — this distinguishes voice notes from music files. Both are still in `audioMessage`.
17. **Sticker messages have NO useful payload for BATOVF** — they appear as `stickerMessage` without text or caption. The text-only fallback in `parse_webhook` returns None for these.

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "groupJid is the standard field name in WhatsApp APIs" | WRONG. Evolution API requires `"number"` for ALL messages (groups AND individuals). Using `"groupJid"` returns 400 Bad Request (Issue #1712). The field name is counterintuitive — but it is what the API requires. Verify before assuming. |
| "Text is in `message.conversation` — that's the standard location" | Text lives in TWO different locations depending on message type: `message.conversation` for plain text, `message.extendedTextMessage.text` when the message has formatting, mentions, or quoted replies. Code that checks only one location silently drops half the messages. |
| "We don't need to validate PDF bytes — Evolution API handles it" | Evolution API will accept and "send" corrupt PDF bytes silently. WhatsApp delivers the file, but the recipient sees "could not open document." Always validate with the `b"%PDF-"` magic header BEFORE sending. |

## Red Flags

- Code uses `"groupJid"` field instead of `"number"` — guaranteed 400 error.
- Webhook parser only checks `message.conversation` — misses formatted/quoted/mention messages.
- Evolution API version <2.3.4 — known timeout bug sending to groups (Issue #2039).
- "Group interaction" disabled on the instance — all group sends fail with 400.
- Same API key used for instance management and message sending — confused token security model.
- No rate limiting between message sends to multiple groups — ban risk on WhatsApp side.
- Trying to reconstruct media bytes from `mediaKey` — must call `/chat/getBase64FromMediaMessage` with second request.
- `getBase64FromMediaMessage` payload as `{"id": message_id}` instead of `{"message": {"key": {"id": message_id}}}` — silent failure.
- PDF sent without `b"%PDF-"` header validation — corrupt files arrive silently.
- Webhook handler treats missing delivery as success — Evolution API has no guaranteed delivery.

## Verification Checklist

- [ ] All message payloads use `"number"` field (NEVER `"groupJid"`), even for groups
- [ ] Webhook parser checks BOTH `message.conversation` AND `message.extendedTextMessage.text`
- [ ] Webhook parser handles all media types: `imageMessage`, `audioMessage`, `videoMessage`, `documentMessage`
- [ ] Media download uses `/chat/getBase64FromMediaMessage` with `{"message": {"key": {"id": ...}}}` payload structure
- [ ] Response field fallback: try `base64` first, then `media` (varies by Evolution API version)
- [ ] PDF bytes validated with `b"%PDF-"` magic header BEFORE sending
- [ ] File size <16MB before attempting WhatsApp send (WhatsApp user-side limit)
- [ ] Rate limiting between sends to multiple groups (3-8 second delay)
- [ ] Max alerts per group per day enforced (recommend ≤3) to avoid ban
- [ ] Evolution API version >=2.3.4 (verified, not assumed)
- [ ] "Group interaction" enabled on the instance
- [ ] Two API keys correctly separated: global key for instance management, instance token for sending
- [ ] Webhook handler uses `key.participant` (phone JID) as primary sender ID, not `pushName`
- [ ] `GROUPS_UPSERT` event NOT used for incoming messages (use `MESSAGES_UPSERT` only)
