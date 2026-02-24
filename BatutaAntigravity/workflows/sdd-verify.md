# /sdd-verify

> Verify implementation using the AI Validation Pyramid: linting, tests, documentation checks, and cross-layer security validation.

## Instructions

### Step 1: Find the active change

If `{{args}}` is provided, use it as the change name.
If not, look in `openspec/changes/` for the most recently modified change directory.

### Step 2: Verify prerequisites

Check that implementation exists (source code files created by sdd-apply).

### Step 3: Execute

Locate and read the `sdd-verify` skill at `.agent/skills/sdd-verify/SKILL.md` or `~/.gemini/antigravity/skills/sdd-verify/SKILL.md` and follow it exactly.

The verification report will be saved to `openspec/changes/{change-name}/verify.md`.

If the skill file does not exist, tell the user:

```
El skill sdd-verify no esta instalado. Ejecuta /batuta-update primero para sincronizar el ecosistema.
```
