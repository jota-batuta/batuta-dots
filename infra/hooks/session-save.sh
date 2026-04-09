#!/usr/bin/env bash
# =============================================================================
# O.R.T.A. Hook: Stop
# =============================================================================
# Runs at the end of EVERY Claude Code turn (not just session exit).
# Responsibilities (all deterministic shell — no LLM calls):
#
#   1. Archive CHECKPOINT.md to checkpoint-archive/ (keep last 10)
#   2. Write a stub CHECKPOINT.md if none exists (safety net)
#   3. Append turn summary to session-log.jsonl (keep last 50 entries).
#      This is the audit trail that powers the Core MUST rule for session.md
#      updates in CLAUDE.md — the agent diffs session-log.jsonl against
#      session.md to know what needs refreshing at every turn close.
#
# Historical note: earlier versions of this hook deferred session.md updates
# to a "prompt hook" that was removed in commit da7d5fe (fix/hooks-command-only).
# The prompt hook's responsibility was never migrated, which made session.md
# updates effectively orphaned. Fix/hub-self-dogfood restored the mechanism via
# the deterministic session-log.jsonl audit trail.
#
# Input: JSON via stdin from Claude Code hooks system
#   { "session_id": "...", "cwd": "...", "last_assistant_message": "...", ... }
#
# Exit codes:
#   0 = allow stop
# =============================================================================

set -euo pipefail

# Read JSON from stdin (Claude Code hooks protocol)
INPUT=$(cat)

# Detect JSON parser once (jq > python3 > python > none)
_JSON_CMD=""
if jq --version >/dev/null 2>&1; then _JSON_CMD="jq"
elif python3 --version >/dev/null 2>&1; then _JSON_CMD="python3"
elif python --version >/dev/null 2>&1; then _JSON_CMD="python"
fi

json_val() {
    local field="$1" default="$2"
    case "$_JSON_CMD" in
        jq)      echo "$INPUT" | jq -r ".$field // \"$default\"" ;;
        python3) echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('$field','$default'))" ;;
        python)  echo "$INPUT" | python -c "import sys,json; d=json.load(sys.stdin); print(d.get('$field','$default'))" ;;
        *)       echo "$default" ;;
    esac
}

CWD=$(json_val cwd ".")

# Find project's .batuta/ directory
BATUTA_DIR=""
if [[ -d "$CWD/.batuta" ]]; then
    BATUTA_DIR="$CWD/.batuta"
elif [[ -n "${CLAUDE_PROJECT_DIR:-}" && -d "$CLAUDE_PROJECT_DIR/.batuta" ]]; then
    BATUTA_DIR="$CLAUDE_PROJECT_DIR/.batuta"
fi

# If no .batuta directory, nothing to do
if [[ -z "$BATUTA_DIR" ]]; then
    exit 0
fi

# =============================================================================
# CHECKPOINT Archive (runs before prompt hook writes new CHECKPOINT.md)
# =============================================================================
# WHY: The prompt hook overwrites CHECKPOINT.md on every Stop. Without an archive,
# gotchas from a previous session are permanently lost if Notion MCP was unavailable.
# Keeping the last 10 versions in checkpoint-archive/ provides a local safety net
# even when the RAG loop (Notion KB) is not configured.
# =============================================================================
CHECKPOINT_FILE="$BATUTA_DIR/CHECKPOINT.md"
if [[ -f "$CHECKPOINT_FILE" ]]; then
    ARCHIVE_DIR="$BATUTA_DIR/checkpoint-archive"
    mkdir -p "$ARCHIVE_DIR"
    # Use UTC timestamp for unambiguous ordering across timezones
    TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ 2>/dev/null || date +%Y%m%dT%H%M%SZ)
    cp "$CHECKPOINT_FILE" "$ARCHIVE_DIR/${TIMESTAMP}-checkpoint.md" 2>/dev/null || true
    # Retain only the 10 most recent archives to prevent unbounded growth
    # WORKAROUND: ls -t | tail -n +11 is POSIX-compatible; find -mtime is not reliable on Windows/Git Bash
    ls -t "$ARCHIVE_DIR"/*.md 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true
fi

# =============================================================================
# Fallback CHECKPOINT.md stub (safety net if prompt hook fails or times out)
# =============================================================================
# WHY: The prompt hook asks Claude to write CHECKPOINT.md as Step 1. If Claude
# does not execute the prompt (timeout, compaction, error), no CHECKPOINT.md is
# written. This stub ensures the file ALWAYS exists after a Stop, so SessionStart
# can inject at least minimal context on the next resume.
# This stub is minimal and will be overwritten by the prompt hook when it runs
# correctly — it only persists if the prompt hook failed entirely.
# =============================================================================
CHECKPOINT_EXISTS_BEFORE_PROMPT=false
[[ -f "$CHECKPOINT_FILE" ]] && CHECKPOINT_EXISTS_BEFORE_PROMPT=true

# The prompt hook runs AFTER this command hook. We write the stub now.
# If the prompt hook succeeds, it will overwrite this stub with real content.
if [[ "$CHECKPOINT_EXISTS_BEFORE_PROMPT" == "false" ]]; then
    TIMESTAMP_NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")
    cat > "$CHECKPOINT_FILE" << EOF
# Checkpoint — ${TIMESTAMP_NOW}

## Qué estoy haciendo
[stub — session-save.sh wrote this because no prior CHECKPOINT.md existed]

## Estado
- Paso actual: N/A
- Archivo/módulo en trabajo: N/A
- Branch: N/A

## Nota
Este stub fue escrito por session-save.sh como seguridad.
Si el prompt hook ejecutó correctamente, este archivo fue reemplazado.
Si ves esto en la próxima sesión, el prompt hook no ejecutó en la sesión anterior.
EOF
fi

# =============================================================================
# Session Log Append (deterministic audit trail for session.md MUST rule)
# =============================================================================
# WHY: CLAUDE.md Core rule requires session.md update at every response close,
# but a shell script cannot summarize intelligently. The compromise: this hook
# appends a mechanical turn record to session-log.jsonl, giving the agent a
# reliable data source to diff against session.md. The agent remains responsible
# for the human-readable summary; the hook guarantees the data exists.
#
# Format: one JSON object per line — {"ts": "2026-04-08T12:34:56Z", "summary": "..."}
# Retention: last 50 entries (older entries truncated via tail -n 50).
# =============================================================================
LAST_MSG=$(json_val last_assistant_message "")
if [[ -n "$LAST_MSG" ]]; then
    LOG_FILE="$BATUTA_DIR/session-log.jsonl"
    TS_NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")

    # Truncate message to 300 chars and escape for JSON
    # WHY 300: long enough to capture the gist, short enough to keep the log
    # under ~30KB even after 50 entries (deterministic size budget).
    case "$_JSON_CMD" in
        jq)
            echo "$LAST_MSG" | jq -Rs --arg ts "$TS_NOW" \
                '{ts: $ts, summary: (.[:300])}' -c >> "$LOG_FILE" 2>/dev/null || true
            ;;
        python3|python)
            PY_CMD="$_JSON_CMD"
            echo "$LAST_MSG" | "$PY_CMD" -c "
import sys, json
msg = sys.stdin.read()[:300]
print(json.dumps({'ts': '$TS_NOW', 'summary': msg}))
" >> "$LOG_FILE" 2>/dev/null || true
            ;;
        *)
            # Fallback: naive sed escape. Good enough when jq/python unavailable.
            ESCAPED=$(echo "$LAST_MSG" | head -c 300 | tr '\n' ' ' | sed 's/\\/\\\\/g; s/"/\\"/g')
            echo "{\"ts\":\"$TS_NOW\",\"summary\":\"$ESCAPED\"}" >> "$LOG_FILE"
            ;;
    esac

    # Retention: keep last 50 turns
    if [[ -f "$LOG_FILE" ]] && [[ $(wc -l < "$LOG_FILE" 2>/dev/null || echo 0) -gt 50 ]]; then
        tail -n 50 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
    fi
fi

exit 0
