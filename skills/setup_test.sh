#!/usr/bin/env bash
# ============================================================================
# Batuta.Dots setup.sh — Automated Tests
# ============================================================================
# Run:  ./skills/setup_test.sh
#
# Tests verify:
#   - AGENTS.md exists and is not empty
#   - setup.sh is executable
#   - SKILL.md files have valid YAML frontmatter
#   - opencode.json (if present) is valid JSON with expected agents
#   - .gitignore excludes generated files
#   - Generated files contain AGENTS.md content
#   - Skills sync creates correct directories
#   - Idempotency and error handling
#
# Platform: Windows (Git Bash / MSYS2 / MINGW) and native Unix
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SETUP_SCRIPT="$SCRIPT_DIR/setup.sh"

# ============================================================================
# Test Counters
# ============================================================================
PASSED=0
FAILED=0
SKIPPED=0

# ============================================================================
# Colors
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# ============================================================================
# Test Helpers
# ============================================================================

log_test() {
    printf "\n${CYAN}[TEST]${NC} %s\n" "$1"
}

log_pass() {
    printf "  ${GREEN}[PASS]${NC} %s\n" "$1"
    PASSED=$((PASSED + 1))
}

log_fail() {
    printf "  ${RED}[FAIL]${NC} %s\n" "$1"
    FAILED=$((FAILED + 1))
}

log_skip() {
    printf "  ${YELLOW}[SKIP]${NC} %s\n" "$1"
    SKIPPED=$((SKIPPED + 1))
}

assert_file_exists() {
    if [[ -f "$1" ]]; then
        log_pass "File exists: $(basename "$1")"
    else
        log_fail "File missing: $1"
    fi
}

assert_file_not_empty() {
    if [[ -s "$1" ]]; then
        log_pass "File is not empty: $(basename "$1")"
    else
        log_fail "File is empty or missing: $1"
    fi
}

assert_file_contains() {
    local file="$1"
    local pattern="$2"
    local label="${3:-$pattern}"

    if grep -q "$pattern" "$file" 2>/dev/null; then
        log_pass "Contains '$label': $(basename "$file")"
    else
        log_fail "Missing '$label': $(basename "$file")"
    fi
}

assert_dir_exists() {
    if [[ -d "$1" ]]; then
        log_pass "Directory exists: $1"
    else
        log_fail "Directory missing: $1"
    fi
}

# ============================================================================
# 1. Prerequisite Tests
# ============================================================================

test_agents_md_exists_and_not_empty() {
    log_test "AGENTS.md exists and is not empty"

    assert_file_exists "$REPO_ROOT/AGENTS.md"
    assert_file_not_empty "$REPO_ROOT/AGENTS.md"
}

test_setup_script_is_executable() {
    log_test "setup.sh exists and is executable"

    assert_file_exists "$SETUP_SCRIPT"

    # On Windows/Git Bash, file permissions may not behave like Unix.
    # Check both executable bit and shebang line.
    if [[ -x "$SETUP_SCRIPT" ]]; then
        log_pass "setup.sh has executable permission"
    else
        # On Windows, -x may not work as expected. Check shebang instead.
        if head -1 "$SETUP_SCRIPT" | grep -q '#!/usr/bin/env bash\|#!/bin/bash'; then
            log_pass "setup.sh has valid shebang (Windows may not report -x correctly)"
        else
            log_fail "setup.sh is not executable and has no valid shebang"
        fi
    fi
}

# ============================================================================
# 2. SKILL.md YAML Frontmatter Validation
# ============================================================================

test_skill_files_have_valid_frontmatter() {
    log_test "All SKILL.md files have valid YAML frontmatter"

    local skills_dir="$REPO_ROOT/BatutaClaude/skills"

    if [[ ! -d "$skills_dir" ]]; then
        log_fail "BatutaClaude/skills/ directory does not exist"
        return
    fi

    local required_fields=("name" "description" "license" "metadata")
    local total=0
    local valid=0

    for skill_file in "$skills_dir"/*/SKILL.md; do
        [[ ! -f "$skill_file" ]] && continue
        total=$((total + 1))

        local skill_name
        skill_name=$(basename "$(dirname "$skill_file")")

        # Check that file starts with YAML frontmatter delimiter ---
        if ! head -1 "$skill_file" | grep -q '^---'; then
            log_fail "$skill_name/SKILL.md: missing YAML frontmatter (no opening ---)"
            continue
        fi

        # Check for closing --- delimiter
        # Extract frontmatter: everything between first --- and next ---
        local has_closing
        has_closing=$(awk 'NR==1 && /^---/{found=1; next} found && /^---/{print "yes"; exit}' "$skill_file")
        if [[ "$has_closing" != "yes" ]]; then
            log_fail "$skill_name/SKILL.md: missing closing --- in frontmatter"
            continue
        fi

        # Check for required fields in the frontmatter block
        local frontmatter
        frontmatter=$(awk 'NR==1 && /^---/{found=1; next} found && /^---/{exit} found{print}' "$skill_file")

        local field_ok=true
        for field in "${required_fields[@]}"; do
            if ! echo "$frontmatter" | grep -q "^${field}:"; then
                log_fail "$skill_name/SKILL.md: missing required field '$field'"
                field_ok=false
            fi
        done

        if [[ "$field_ok" == true ]]; then
            valid=$((valid + 1))
        fi
    done

    if [[ $total -eq 0 ]]; then
        log_fail "No SKILL.md files found in BatutaClaude/skills/"
    elif [[ $valid -eq $total ]]; then
        log_pass "All $total SKILL.md files have valid frontmatter (name, description, license, metadata)"
    fi
}

# ============================================================================
# 3. opencode.json Validation
# ============================================================================

test_opencode_json_valid() {
    log_test "opencode.json is valid JSON with expected agents"

    local opencode_file="$REPO_ROOT/opencode.json"

    if [[ ! -f "$opencode_file" ]]; then
        log_skip "opencode.json not found (optional — will be created later)"
        return
    fi

    # Check valid JSON - try python first, then node, then jq
    local json_valid=false
    if command -v python3 &>/dev/null; then
        if python3 -c "import json; json.load(open('$opencode_file'))" 2>/dev/null; then
            json_valid=true
        fi
    elif command -v python &>/dev/null; then
        if python -c "import json; json.load(open('$opencode_file'))" 2>/dev/null; then
            json_valid=true
        fi
    elif command -v node &>/dev/null; then
        if node -e "JSON.parse(require('fs').readFileSync('$opencode_file','utf8'))" 2>/dev/null; then
            json_valid=true
        fi
    elif command -v jq &>/dev/null; then
        if jq empty "$opencode_file" 2>/dev/null; then
            json_valid=true
        fi
    else
        log_skip "No JSON validator available (python3/node/jq)"
        return
    fi

    if [[ "$json_valid" == true ]]; then
        log_pass "opencode.json is valid JSON"
    else
        log_fail "opencode.json is not valid JSON"
        return
    fi

    # Check for agents key (flexible check)
    if grep -q '"agents"' "$opencode_file" 2>/dev/null; then
        log_pass "opencode.json contains agents definition"
    else
        log_fail "opencode.json missing 'agents' key"
    fi
}

# ============================================================================
# 4. .gitignore Tests
# ============================================================================

test_gitignore_excludes_generated() {
    log_test ".gitignore excludes generated files"

    local gitignore="$REPO_ROOT/.gitignore"

    if [[ ! -f "$gitignore" ]]; then
        log_fail ".gitignore does not exist"
        return
    fi

    local patterns=("/CLAUDE.md" "/GEMINI.md" "/CODEX.md" "copilot-instructions.md")
    local labels=("CLAUDE.md" "GEMINI.md" "CODEX.md" "copilot-instructions.md")

    for i in "${!patterns[@]}"; do
        local pat="${patterns[$i]}"
        local lbl="${labels[$i]}"

        if grep -q "$pat" "$gitignore" 2>/dev/null; then
            log_pass ".gitignore excludes $lbl"
        else
            log_fail ".gitignore does not exclude $lbl"
        fi
    done
}

# ============================================================================
# 5. Generation Tests (run setup.sh --all, then verify output)
# ============================================================================

test_generate_all_creates_files() {
    log_test "setup.sh --all generates all instruction files"

    # Clean up any existing generated files
    rm -f "$REPO_ROOT/CLAUDE.md" "$REPO_ROOT/GEMINI.md" "$REPO_ROOT/CODEX.md"
    rm -f "$REPO_ROOT/.github/copilot-instructions.md"

    # Run generation
    if bash "$SETUP_SCRIPT" --all >/dev/null 2>&1; then
        log_pass "setup.sh --all ran successfully"
    else
        log_fail "setup.sh --all exited with error"
        return
    fi

    assert_file_exists "$REPO_ROOT/CLAUDE.md"
    assert_file_exists "$REPO_ROOT/GEMINI.md"
    assert_file_exists "$REPO_ROOT/CODEX.md"
    assert_file_exists "$REPO_ROOT/.github/copilot-instructions.md"
}

test_generated_files_contain_agents_content() {
    log_test "Generated files contain AGENTS.md content"

    # Make sure generated files exist
    if [[ ! -f "$REPO_ROOT/CLAUDE.md" ]]; then
        bash "$SETUP_SCRIPT" --all >/dev/null 2>&1 || true
    fi

    # Check for a distinctive string from AGENTS.md
    local check_strings=("Single Source of Truth" "Auto-invoke Skills" "Batuta")

    for file in CLAUDE.md GEMINI.md CODEX.md; do
        local full_path="$REPO_ROOT/$file"
        if [[ ! -f "$full_path" ]]; then
            log_fail "$file does not exist — cannot verify content"
            continue
        fi

        for str in "${check_strings[@]}"; do
            assert_file_contains "$full_path" "$str" "$str"
        done
    done

    # Copilot
    local copilot="$REPO_ROOT/.github/copilot-instructions.md"
    if [[ -f "$copilot" ]]; then
        for str in "${check_strings[@]}"; do
            assert_file_contains "$copilot" "$str" "$str"
        done
    fi
}

test_generated_files_have_correct_headers() {
    log_test "Generated files have correct auto-generation headers"

    if [[ ! -f "$REPO_ROOT/CLAUDE.md" ]]; then
        bash "$SETUP_SCRIPT" --all >/dev/null 2>&1 || true
    fi

    local expected_headers=(
        "CLAUDE.md:Claude Code Instructions"
        "GEMINI.md:Gemini CLI Instructions"
        "CODEX.md:OpenAI Codex Instructions"
    )

    for entry in "${expected_headers[@]}"; do
        local file="${entry%%:*}"
        local header="${entry#*:}"
        local full_path="$REPO_ROOT/$file"

        if [[ -f "$full_path" ]]; then
            assert_file_contains "$full_path" "$header" "$header"
            assert_file_contains "$full_path" "Auto-generated from AGENTS.md" "auto-gen warning"
            assert_file_contains "$full_path" "Do not edit directly" "do-not-edit warning"
        else
            log_fail "$file does not exist"
        fi
    done

    # Copilot header
    local copilot="$REPO_ROOT/.github/copilot-instructions.md"
    if [[ -f "$copilot" ]]; then
        assert_file_contains "$copilot" "GitHub Copilot Instructions" "Copilot header"
    fi
}

test_claude_includes_personality() {
    log_test "CLAUDE.md includes BatutaClaude/CLAUDE.md personality"

    local claude_file="$REPO_ROOT/CLAUDE.md"
    local personality="$REPO_ROOT/BatutaClaude/CLAUDE.md"

    if [[ ! -f "$personality" ]]; then
        log_skip "BatutaClaude/CLAUDE.md does not exist"
        return
    fi

    if [[ ! -f "$claude_file" ]]; then
        bash "$SETUP_SCRIPT" --claude >/dev/null 2>&1 || true
    fi

    # Check that personality content is in CLAUDE.md
    # Use a distinctive string from the personality file
    if grep -q "Personality" "$personality" 2>/dev/null; then
        assert_file_contains "$claude_file" "Personality" "personality section"
    elif grep -q "Rules" "$personality" 2>/dev/null; then
        assert_file_contains "$claude_file" "Rules" "rules section"
    else
        # Just check that CLAUDE.md is bigger than AGENTS.md (personality was added)
        local claude_size agents_size
        claude_size=$(wc -c < "$claude_file")
        agents_size=$(wc -c < "$REPO_ROOT/AGENTS.md")
        if [[ $claude_size -gt $agents_size ]]; then
            log_pass "CLAUDE.md is larger than AGENTS.md (personality content included)"
        else
            log_fail "CLAUDE.md does not appear to include personality content"
        fi
    fi
}

# ============================================================================
# 6. Sync Tests
# ============================================================================

test_sync_claude_creates_directories() {
    log_test "Skills sync (--sync-claude) creates correct directories"

    local skills_src="$REPO_ROOT/BatutaClaude/skills"

    if [[ ! -d "$skills_src" ]]; then
        log_fail "BatutaClaude/skills/ not found — cannot test sync"
        return
    fi

    # Use a temporary HOME to avoid modifying real ~/.claude
    local tmp_home
    tmp_home=$(mktemp -d)
    trap "rm -rf '$tmp_home'" RETURN 2>/dev/null || true

    # Run sync with overridden HOME
    HOME="$tmp_home" USERPROFILE="" bash "$SETUP_SCRIPT" --sync-claude >/dev/null 2>&1 || true

    local claude_skills="$tmp_home/.claude/skills"

    if [[ -d "$claude_skills" ]]; then
        log_pass "~/.claude/skills/ directory created"
    else
        log_fail "~/.claude/skills/ directory NOT created"
        rm -rf "$tmp_home"
        return
    fi

    # Check that at least one skill was copied
    local count=0
    for d in "$claude_skills"/*/; do
        [[ -d "$d" ]] && count=$((count + 1))
    done

    if [[ $count -gt 0 ]]; then
        log_pass "$count skill directories synced to ~/.claude/skills/"
    else
        log_fail "No skill directories found in ~/.claude/skills/"
    fi

    # Check a specific known skill
    if [[ -f "$claude_skills/ecosystem-creator/SKILL.md" ]]; then
        log_pass "ecosystem-creator/SKILL.md synced correctly"
    else
        log_fail "ecosystem-creator/SKILL.md not found after sync"
    fi

    rm -rf "$tmp_home"
}

# ============================================================================
# 7. Help and Error Handling Tests
# ============================================================================

test_help_flag_works() {
    log_test "--help flag shows usage information"

    if bash "$SETUP_SCRIPT" --help 2>&1 | grep -q "Usage:"; then
        log_pass "--help shows Usage"
    else
        log_fail "--help does not show Usage"
    fi

    if bash "$SETUP_SCRIPT" --help 2>&1 | grep -q "Batuta"; then
        log_pass "--help mentions Batuta"
    else
        log_fail "--help does not mention Batuta"
    fi
}

test_invalid_flag_shows_error() {
    log_test "Invalid flag shows error"

    if bash "$SETUP_SCRIPT" --this-does-not-exist 2>&1 | grep -q "Unknown option"; then
        log_pass "Invalid flag reports 'Unknown option'"
    else
        log_fail "Invalid flag does not report error properly"
    fi
}

# ============================================================================
# 8. Idempotency Test
# ============================================================================

test_multiple_runs_are_idempotent() {
    log_test "Multiple runs produce the same result (idempotent)"

    bash "$SETUP_SCRIPT" --claude >/dev/null 2>&1

    # Get hash of first run
    local first_hash
    if command -v md5sum &>/dev/null; then
        first_hash=$(md5sum "$REPO_ROOT/CLAUDE.md" | cut -d' ' -f1)
    elif command -v md5 &>/dev/null; then
        first_hash=$(md5 -q "$REPO_ROOT/CLAUDE.md")
    else
        log_skip "No md5sum or md5 available for hash comparison"
        return
    fi

    # Run again
    bash "$SETUP_SCRIPT" --claude >/dev/null 2>&1

    local second_hash
    if command -v md5sum &>/dev/null; then
        second_hash=$(md5sum "$REPO_ROOT/CLAUDE.md" | cut -d' ' -f1)
    else
        second_hash=$(md5 -q "$REPO_ROOT/CLAUDE.md")
    fi

    if [[ "$first_hash" == "$second_hash" ]]; then
        log_pass "Two consecutive runs produce identical CLAUDE.md"
    else
        log_fail "Consecutive runs produced different CLAUDE.md (not idempotent)"
    fi
}

# ============================================================================
# Run All Tests
# ============================================================================

printf "\n${CYAN}${BOLD}================================================================${NC}\n"
printf "${CYAN}${BOLD}  Batuta.Dots setup.sh — Test Suite${NC}\n"
printf "${CYAN}${BOLD}================================================================${NC}\n"

# 1. Prerequisites
test_agents_md_exists_and_not_empty
test_setup_script_is_executable

# 2. SKILL.md frontmatter
test_skill_files_have_valid_frontmatter

# 3. opencode.json
test_opencode_json_valid

# 4. .gitignore
test_gitignore_excludes_generated

# 5. Generation
test_generate_all_creates_files
test_generated_files_contain_agents_content
test_generated_files_have_correct_headers
test_claude_includes_personality

# 6. Sync
test_sync_claude_creates_directories

# 7. Help / errors
test_help_flag_works
test_invalid_flag_shows_error

# 8. Idempotency
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

if [[ $FAILED -gt 0 ]]; then
    printf "${RED}${BOLD}SOME TESTS FAILED${NC}\n"
    exit 1
else
    printf "${GREEN}${BOLD}ALL TESTS PASSED${NC}\n"
    exit 0
fi
