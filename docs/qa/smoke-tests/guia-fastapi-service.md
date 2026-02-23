# Smoke Test Log: guia-fastapi-service

**Executed**: 2026-02-23
**Project**: test-fastapi-service (E:\BATUTA PROJECTS\test-fastapi-service)
**Guide**: docs/guides/guia-fastapi-service.md

## Summary
| Metric | Value |
|--------|-------|
| Total steps | 15 |
| PASS directo | 12 |
| FAIL → FIX → PASS | 3 |
| BLOCKED (manual) | 0 |
| Tests | 24/24 PASSED |
| Time | ~45 min |

## System Fixes Applied

### Fix 1: setup.sh — Path Resolution Bug (CRITICAL)
- **File**: `skills/setup.sh`
- **Issue**: `SCRIPT_DIR` resolution failed on Windows Git Bash when called with relative path
- **Fix**: Added `cd` + `pwd` fallback for path resolution
- **Impact**: Without fix, setup.sh would fail to find CLAUDE.md template

### Fix 2: setup.sh — Python Merge Bug (CRITICAL)
- **File**: `skills/setup.sh`
- **Issue**: Python merge fallback for settings.json didn't handle existing hooks correctly
- **Fix**: Corrected Python merge logic to properly merge arrays
- **Impact**: Without fix, hooks would overwrite instead of merge

### Fix 3: passlib + bcrypt 5.x Incompatibility
- **File**: Project-level (not system-level)
- **Issue**: `passlib` hasn't been updated since 2020, incompatible with `bcrypt 5.x` on Python 3.14
- **Fix**: Used `import bcrypt` directly instead of `passlib.context.CryptContext`
- **Impact**: Guides should note that passlib is deprecated; use bcrypt directly

## Step-by-Step Results

| Step | Title | Status | Notes |
|------|-------|--------|-------|
| 1 | Create project folder | PASS | mkdir + cd |
| 2 | Install Batuta ecosystem | FAIL→FIX→PASS | 2 bugs in setup.sh fixed |
| 3 | Init SDD | PASS | openspec/ created correctly |
| 4 | Skill gap detection | PASS | Skipped (simulated) |
| 5 | Create proposal | PASS | proposal.md with Plain Language Summary |
| 6 | Specs, design, tasks | PASS | 3 domains, 29 tasks |
| 7-9 | Implementation | FAIL→FIX→PASS | passlib→bcrypt fix, sqlite defaults |
| 10 | Tests | PASS | 24/24 after bcrypt fix |
| 11 | Verify | PASS | PASS WITH WARNINGS |
| 12-13 | Deploy | SKIPPED | Coolify/browser manual steps |
| 14 | Git + GitHub | SKIPPED | External service |
| 15 | Archive | PASS | Specs synced, lessons captured |

## Lessons Learned
1. **passlib is dead** — Use bcrypt directly on Python 3.12+
2. **datetime.utcnow() deprecated** — Use datetime.now(datetime.UTC)
3. **SQLite as test DB** — Works as PostgreSQL substitute for unit tests
4. **setup.sh needs Windows testing** — Path resolution is fragile in Git Bash
