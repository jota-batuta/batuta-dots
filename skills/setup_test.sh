#!/usr/bin/env bash
# ============================================================================
# Batuta.Dots setup.sh — Automated Tests (Claude Code focused)
# ============================================================================
# Run:  ./skills/setup_test.sh
#
# Tests verify:
#   - BatutaClaude/CLAUDE.md exists and is not empty
#   - AGENTS.md has been removed (v3 refactor)
#   - setup.sh is executable
#   - SKILL.md files have valid YAML frontmatter
#   - scope-rule skill exists
#   - .gitignore excludes generated files
#   - Copied CLAUDE.md contains expected content
#   - Skills sync creates correct directories
#   - Idempotency and error handling
#   - replicate-platform.sh exists for future use
#
# Platform: Windows (Git Bash / MSYS2 / MINGW) and native Unix
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SETUP_SCRIPT="$SCRIPT_DIR/setup.sh"

# ============================================================================
# Test Counters & Colors
# ============================================================================
PASSED=0
FAILED=0
SKIPPED=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# ============================================================================
# Test Helpers
# ============================================================================

log_test() { printf "\n${CYAN}[TEST]${NC} %s\n" "$1"; }
log_pass() { printf "  ${GREEN}[PASS]${NC} %s\n" "$1"; PASSED=$((PASSED + 1)); }
log_fail() { printf "  ${RED}[FAIL]${NC} %s\n" "$1"; FAILED=$((FAILED + 1)); }
log_skip() { printf "  ${YELLOW}[SKIP]${NC} %s\n" "$1"; SKIPPED=$((SKIPPED + 1)); }

assert_file_exists()   { [[ -f "$1" ]] && log_pass "File exists: $(basename "$1")" || log_fail "File missing: $1"; }
assert_file_not_empty() { [[ -s "$1" ]] && log_pass "File is not empty: $(basename "$1")" || log_fail "File is empty: $1"; }
assert_dir_exists()    { [[ -d "$1" ]] && log_pass "Directory exists: $1" || log_fail "Directory missing: $1"; }

assert_file_contains() {
    local file="$1" pattern="$2" label="${3:-$2}"
    grep -q "$pattern" "$file" 2>/dev/null && log_pass "Contains '$label': $(basename "$file")" || log_fail "Missing '$label': $(basename "$file")"
}

assert_file_not_contains() {
    local file="$1" pattern="$2" label="${3:-$2}"
    ! grep -q "$pattern" "$file" 2>/dev/null && log_pass "Does not contain '$label': $(basename "$file")" || log_fail "Should not contain '$label': $(basename "$file")"
}

# ============================================================================
# 1. Source File Tests
# ============================================================================

test_claude_md_source_exists() {
    log_test "BatutaClaude/CLAUDE.md exists and is not empty"
    assert_file_exists "$REPO_ROOT/BatutaClaude/CLAUDE.md"
    assert_file_not_empty "$REPO_ROOT/BatutaClaude/CLAUDE.md"
}

test_agents_md_removed() {
    log_test "AGENTS.md has been removed (v3 refactor)"
    if [[ -f "$REPO_ROOT/AGENTS.md" ]]; then
        log_fail "AGENTS.md still exists — should have been removed in v3 refactor"
    else
        log_pass "AGENTS.md correctly removed"
    fi
}

test_setup_script_is_executable() {
    log_test "setup.sh exists and is executable"
    assert_file_exists "$SETUP_SCRIPT"
    if [[ -x "$SETUP_SCRIPT" ]]; then
        log_pass "setup.sh has executable permission"
    elif head -1 "$SETUP_SCRIPT" | grep -q '#!/usr/bin/env bash\|#!/bin/bash'; then
        log_pass "setup.sh has valid shebang (Windows may not report -x)"
    else
        log_fail "setup.sh is not executable and has no valid shebang"
    fi
}

# ============================================================================
# 2. SKILL.md YAML Frontmatter Validation
# ============================================================================

test_skill_files_have_valid_frontmatter() {
    log_test "All SKILL.md files have valid YAML frontmatter"

    local skills_dir="$REPO_ROOT/BatutaClaude/skills"
    [[ ! -d "$skills_dir" ]] && { log_fail "BatutaClaude/skills/ does not exist"; return; }

    local required_fields=("name" "description" "license" "metadata")
    local total=0 valid=0

    for skill_file in "$skills_dir"/*/SKILL.md; do
        [[ ! -f "$skill_file" ]] && continue
        total=$((total + 1))
        local skill_name=$(basename "$(dirname "$skill_file")")

        if ! head -1 "$skill_file" | grep -q '^---'; then
            log_fail "$skill_name/SKILL.md: missing opening ---"
            continue
        fi

        local has_closing=$(awk 'NR==1 && /^---/{found=1; next} found && /^---/{print "yes"; exit}' "$skill_file")
        [[ "$has_closing" != "yes" ]] && { log_fail "$skill_name/SKILL.md: missing closing ---"; continue; }

        local frontmatter=$(awk 'NR==1 && /^---/{found=1; next} found && /^---/{exit} found{print}' "$skill_file")
        local field_ok=true
        for field in "${required_fields[@]}"; do
            echo "$frontmatter" | grep -q "^${field}:" || { log_fail "$skill_name/SKILL.md: missing '$field'"; field_ok=false; }
        done
        [[ "$field_ok" == true ]] && valid=$((valid + 1))
    done

    [[ $total -eq 0 ]] && log_fail "No SKILL.md files found"
    [[ $valid -eq $total && $total -gt 0 ]] && log_pass "All $total SKILL.md files have valid frontmatter"
}

# ============================================================================
# 3. Scope Rule Skill Exists
# ============================================================================

test_scope_rule_skill_exists() {
    log_test "scope-rule skill exists"
    assert_file_exists "$REPO_ROOT/BatutaClaude/skills/scope-rule/SKILL.md"
    assert_file_contains "$REPO_ROOT/BatutaClaude/skills/scope-rule/SKILL.md" "scope-rule" "skill name"
    assert_file_contains "$REPO_ROOT/BatutaClaude/skills/scope-rule/SKILL.md" "Who will use this" "decision tree"
}

# ============================================================================
# 4. .gitignore Tests
# ============================================================================

test_gitignore_excludes_generated() {
    log_test ".gitignore excludes generated files"
    local gitignore="$REPO_ROOT/.gitignore"
    [[ ! -f "$gitignore" ]] && { log_fail ".gitignore does not exist"; return; }

    assert_file_contains "$gitignore" "/CLAUDE.md" "CLAUDE.md exclusion"
    assert_file_contains "$gitignore" "/GEMINI.md" "GEMINI.md exclusion"
    assert_file_contains "$gitignore" "/CODEX.md" "CODEX.md exclusion"
}

# ============================================================================
# 5. Claude Code Copy Tests
# ============================================================================

test_copy_claude_creates_file() {
    log_test "setup.sh --claude copies CLAUDE.md to root"
    rm -f "$REPO_ROOT/CLAUDE.md"

    if bash "$SETUP_SCRIPT" --claude >/dev/null 2>&1; then
        log_pass "setup.sh --claude ran successfully"
    else
        log_fail "setup.sh --claude exited with error"
        return
    fi

    assert_file_exists "$REPO_ROOT/CLAUDE.md"
}

test_claude_md_contains_expected_content() {
    log_test "CLAUDE.md contains expected content"
    [[ ! -f "$REPO_ROOT/CLAUDE.md" ]] && bash "$SETUP_SCRIPT" --claude >/dev/null 2>&1

    assert_file_contains "$REPO_ROOT/CLAUDE.md" "Personality" "personality section"
    assert_file_contains "$REPO_ROOT/CLAUDE.md" "Scope Rule" "scope rule section"
    assert_file_contains "$REPO_ROOT/CLAUDE.md" "Skill Gap Detection" "gap detection"
    assert_file_contains "$REPO_ROOT/CLAUDE.md" "Auto-invoke table" "skill routing"
    assert_file_contains "$REPO_ROOT/CLAUDE.md" "SDD Commands" "SDD commands table"
}

test_claude_md_is_direct_copy() {
    log_test "CLAUDE.md is a direct copy of BatutaClaude/CLAUDE.md"
    [[ ! -f "$REPO_ROOT/CLAUDE.md" ]] && bash "$SETUP_SCRIPT" --claude >/dev/null 2>&1

    if diff -q "$REPO_ROOT/BatutaClaude/CLAUDE.md" "$REPO_ROOT/CLAUDE.md" >/dev/null 2>&1; then
        log_pass "CLAUDE.md is identical to BatutaClaude/CLAUDE.md"
    else
        log_fail "CLAUDE.md differs from BatutaClaude/CLAUDE.md (should be direct copy)"
    fi
}

test_claude_md_no_agents_reference() {
    log_test "CLAUDE.md does not reference AGENTS.md"
    [[ ! -f "$REPO_ROOT/CLAUDE.md" ]] && bash "$SETUP_SCRIPT" --claude >/dev/null 2>&1

    assert_file_not_contains "$REPO_ROOT/CLAUDE.md" "AGENTS.md" "AGENTS.md reference"
}

# ============================================================================
# 6. Sync Tests
# ============================================================================

test_sync_claude_creates_directories() {
    log_test "Skills sync creates correct directories"
    local skills_src="$REPO_ROOT/BatutaClaude/skills"
    [[ ! -d "$skills_src" ]] && { log_fail "BatutaClaude/skills/ not found"; return; }

    local tmp_home=$(mktemp -d)
    HOME="$tmp_home" USERPROFILE="" bash "$SETUP_SCRIPT" --sync >/dev/null 2>&1 || true

    local claude_skills="$tmp_home/.claude/skills"
    [[ -d "$claude_skills" ]] && log_pass "~/.claude/skills/ created" || { log_fail "~/.claude/skills/ NOT created"; rm -rf "$tmp_home"; return; }

    local count=0
    for d in "$claude_skills"/*/; do [[ -d "$d" ]] && count=$((count + 1)); done
    [[ $count -gt 0 ]] && log_pass "$count skill directories synced" || log_fail "No skills synced"

    [[ -f "$claude_skills/scope-rule/SKILL.md" ]] && log_pass "scope-rule synced" || log_fail "scope-rule not synced"
    [[ -f "$claude_skills/ecosystem-creator/SKILL.md" ]] && log_pass "ecosystem-creator synced" || log_fail "ecosystem-creator not synced"

    rm -rf "$tmp_home"
}

# ============================================================================
# 7. Help and Error Handling
# ============================================================================

test_help_flag_works() {
    log_test "--help flag works"
    bash "$SETUP_SCRIPT" --help 2>&1 | grep -q "Usage:" && log_pass "--help shows Usage" || log_fail "--help missing Usage"
    bash "$SETUP_SCRIPT" --help 2>&1 | grep -q "Batuta" && log_pass "--help mentions Batuta" || log_fail "--help missing Batuta"
}

test_legacy_flags_redirect() {
    log_test "Legacy multi-platform flags redirect to replicate-platform.sh"
    local output=$(bash "$SETUP_SCRIPT" --gemini 2>&1)
    echo "$output" | grep -q "replicate-platform" && log_pass "--gemini redirects" || log_fail "--gemini doesn't redirect"
}

test_invalid_flag_shows_error() {
    log_test "Invalid flag shows error"
    bash "$SETUP_SCRIPT" --nonexistent 2>&1 | grep -q "Unknown option" && log_pass "Invalid flag reports error" || log_fail "No error for invalid flag"
}

# ============================================================================
# 8. Replicate Platform Script Exists
# ============================================================================

test_replicate_platform_exists() {
    log_test "replicate-platform.sh exists for future use"
    assert_file_exists "$SCRIPT_DIR/replicate-platform.sh"
    assert_file_contains "$SCRIPT_DIR/replicate-platform.sh" "replicate" "replication purpose"
}

# ============================================================================
# 9. Idempotency
# ============================================================================

test_multiple_runs_are_idempotent() {
    log_test "Multiple runs produce the same result"

    bash "$SETUP_SCRIPT" --claude >/dev/null 2>&1
    local first_hash
    if command -v md5sum &>/dev/null; then
        first_hash=$(md5sum "$REPO_ROOT/CLAUDE.md" | cut -d' ' -f1)
    elif command -v md5 &>/dev/null; then
        first_hash=$(md5 -q "$REPO_ROOT/CLAUDE.md")
    else
        log_skip "No md5sum available"
        return
    fi

    bash "$SETUP_SCRIPT" --claude >/dev/null 2>&1
    local second_hash
    if command -v md5sum &>/dev/null; then
        second_hash=$(md5sum "$REPO_ROOT/CLAUDE.md" | cut -d' ' -f1)
    else
        second_hash=$(md5 -q "$REPO_ROOT/CLAUDE.md")
    fi

    [[ "$first_hash" == "$second_hash" ]] && log_pass "Idempotent" || log_fail "Not idempotent"
}

# ============================================================================
# Run All Tests
# ============================================================================

printf "\n${CYAN}${BOLD}================================================================${NC}\n"
printf "${CYAN}${BOLD}  Batuta.Dots — Test Suite (Claude Code)${NC}\n"
printf "${CYAN}${BOLD}================================================================${NC}\n"

test_claude_md_source_exists
test_agents_md_removed
test_setup_script_is_executable
test_skill_files_have_valid_frontmatter
test_scope_rule_skill_exists
test_gitignore_excludes_generated
test_copy_claude_creates_file
test_claude_md_contains_expected_content
test_claude_md_is_direct_copy
test_claude_md_no_agents_reference
test_sync_claude_creates_directories
test_help_flag_works
test_legacy_flags_redirect
test_invalid_flag_shows_error
test_replicate_platform_exists
test_multiple_runs_are_idempotent

# ============================================================================
# Summary
# ============================================================================

TOTAL=$((PASSED + FAILED + SKIPPED))

printf "\n${CYAN}${BOLD}================================================================${NC}\n"
printf "${CYAN}${BOLD}  Test Summary${NC}\n"
printf "${CYAN}${BOLD}================================================================${NC}\n"
printf "  ${GREEN}Passed:  %d${NC}\n" "$PASSED"
printf "  ${RED}Failed:  %d${NC}\n" "$FAILED"
printf "  ${YELLOW}Skipped: %d${NC}\n" "$SKIPPED"
printf "  Total:   %d\n" "$TOTAL"
echo ""

[[ $FAILED -gt 0 ]] && { printf "${RED}${BOLD}SOME TESTS FAILED${NC}\n"; exit 1; } || { printf "${GREEN}${BOLD}ALL TESTS PASSED${NC}\n"; exit 0; }
