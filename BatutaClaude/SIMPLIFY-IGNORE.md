# SIMPLIFY-IGNORE Patterns

Files and directories that the `code-simplification` skill should NEVER touch.
The simplify-ignore hook reads this file to prevent unintended refactors of
protected code.

## Always ignore (ecosystem defaults)
- `vendor/**` — Third-party code, not our responsibility
- `node_modules/**` — Managed by npm/yarn
- `.venv/**` — Python virtual environments
- `venv/**` — Python virtual environments (alternative name)
- `migrations/**` — Database migrations are immutable once applied
- `**/__pycache__/**` — Python bytecode
- `dist/**` — Generated distribution output
- `build/**` — Generated build output
- `.next/**` — Next.js build output
- `target/**` — Rust/Java build output

## Batuta-specific ignore
- `.batuta/**` — Session state, checkpoints, team history
- `.claude/worktrees/**` — Temporary worktrees
- `openspec/changes/archive/**` — Archived SDD artifacts (SUPERSEDED immutable)
- `legacy/**` — Legacy code under explicit freeze (requires justification to touch)
- `**/generated/**` — Auto-generated code (OpenAPI clients, Prisma, protobuf)

## Test fixtures
- `tests/fixtures/**` — Test data should remain verbatim
- `tests/**/snapshot/**` — Snapshot test expectations
- `tests/**/__snapshots__/**` — Jest snapshots

## BatutaAntigravity
- `BatutaAntigravity/workflows/**` — Cross-platform workflows (use `/batuta-sync` to update)

## How to extend
Add glob patterns (one per line with `- ` prefix) to this file.
The `hooks/simplify-ignore.sh` script reads patterns on the fly — no restart needed.

## How code-simplification respects this
Before modifying any file, the skill MUST run:
```bash
bash ~/.claude/hooks/simplify-ignore.sh {file-path}
# exit 0 = IGNORE (do not simplify)
# exit 1 = OK to simplify
```

If the exit code is 0, the skill reports: "File {path} is in SIMPLIFY-IGNORE.md, skipping."
