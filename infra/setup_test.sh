#!/usr/bin/env bash
# ============================================================================
# Batuta.Dots setup.sh — Automated Tests (Claude Code focused)
# ============================================================================
# Run:  ./infra/setup_test.sh
#
# Tests verify:
#   Foundation:
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
#   v4:
#   - session template exists in infra/templates/
#   - CLAUDE.md contains v4+ sections (Session Continuity, Execution Gate)
#   - (v11.1: prompt-tracker and analyze-prompts removed)
#   v5 (MoE + Execution Gate + Frontmatter + Skill-Sync):
#   - Execution Gate with LIGHT/FULL modes
#   - Scope Routing Table with 3 scope agents
#   - Follow Questions removed
#   - "just do it → PROCEED" removed
#   - 3 scope agent files exist with sync delimiters
#   - (v11.1: prompt-tracker removed)
#   - All skills have scope, auto_invoke, allowed-tools
#   - Agents sync via setup.sh
#   - (v11.1: skill-sync removed)
#   - (v11.1: AUTO-GENERATED delimiters removed)
#   v6→v9 (Quality Audit + Folder Reorganization):
#   - docs/architecture/ directory exists with architecture docs
#   - docs/guides/ contains execution guides
#   - docs/qa/ directory exists with quality reports
#   - BatutaClaude/VERSION file exists
#   - teams/ directory exists with templates and playbook
#   v9.3 (Post-Smoke-Test Corrections):
#   - All 22 skills have ## Purpose section
#   - New skills (fastapi-crud, jwt-auth, sqlalchemy-models) have valid frontmatter
#   - 7 team templates (including temporal-io-app)
#   - settings.json hooks point to infra/ (not skills/)
#   - No guides reference old skills/setup.sh path
#   - sdd-apply has Code Documentation Standard section
#   - CLAUDE.md has code documentation enforcement rule
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
    assert_file_contains "$REPO_ROOT/CLAUDE.md" "Scope Routing Table" "scope routing table (v5)"
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
# 10. Prompt Tracker Skill (v4)
# ============================================================================

test_session_template_exists() {
    log_test "session template exists in infra/templates/ (v11.1)"
    assert_file_exists "$REPO_ROOT/infra/templates/session-template.md"
    assert_file_contains "$REPO_ROOT/infra/templates/session-template.md" "Session Context" "session context header"
}

# ============================================================================
# 11. CLAUDE.md v4 Sections
# ============================================================================

test_claude_md_has_v4_sections() {
    log_test "CLAUDE.md contains v4+ sections"
    local claude_src="$REPO_ROOT/BatutaClaude/CLAUDE.md"

    assert_file_contains "$claude_src" "Session Continuity" "session continuity section"
    assert_file_contains "$claude_src" "Execution Gate" "execution gate (v5, replaces Follow Questions)"
}

# ============================================================================
# 12. CLAUDE.md v5 — Execution Gate (replaces Follow Questions)
# ============================================================================

test_claude_md_has_execution_gate() {
    log_test "CLAUDE.md has Execution Gate with LIGHT/FULL modes (v5)"
    local claude_src="$REPO_ROOT/BatutaClaude/CLAUDE.md"

    assert_file_contains "$claude_src" "Execution Gate" "Execution Gate section"
    assert_file_contains "$claude_src" "LIGHT" "LIGHT gate mode"
    assert_file_contains "$claude_src" "FULL" "FULL gate mode"
    assert_file_contains "$claude_src" "Cannot be skipped" "gate is mandatory"
}

# ============================================================================
# 13. CLAUDE.md v5 — Scope Routing Table
# ============================================================================

test_claude_md_has_scope_routing() {
    log_test "CLAUDE.md has Scope Routing (v11.1)"
    local claude_src="$REPO_ROOT/BatutaClaude/CLAUDE.md"

    assert_file_contains "$claude_src" "Scope Routing" "scope routing section"
    assert_file_contains "$claude_src" "pipeline" "pipeline scope reference"
    assert_file_contains "$claude_src" "infra" "infra scope reference"
    assert_file_contains "$claude_src" "observability" "observability scope reference"
}

# ============================================================================
# 14. CLAUDE.md v5 — Follow Questions removed
# ============================================================================

test_claude_md_no_follow_questions() {
    log_test "CLAUDE.md no longer has Follow Questions (replaced by Gate in v5)"
    local claude_src="$REPO_ROOT/BatutaClaude/CLAUDE.md"

    assert_file_not_contains "$claude_src" "Follow Questions" "Follow Questions (removed in v5)"
}

# ============================================================================
# 15. CLAUDE.md v5 — "just do it → PROCEED" removed
# ============================================================================

test_claude_md_no_just_do_it_proceed() {
    log_test "CLAUDE.md no longer has 'just do it → PROCEED' (v5)"
    local claude_src="$REPO_ROOT/BatutaClaude/CLAUDE.md"

    assert_file_not_contains "$claude_src" "just do it.*PROCEED" "'just do it → PROCEED' pattern"
}

# ============================================================================
# 16. Scope Agents exist (v5)
# ============================================================================

test_scope_agents_exist() {
    log_test "3 scope agent files exist in BatutaClaude/agents/ (v5)"
    local agents_dir="$REPO_ROOT/BatutaClaude/agents"

    assert_dir_exists "$agents_dir"
    assert_file_exists "$agents_dir/pipeline-agent.md"
    assert_file_exists "$agents_dir/infra-agent.md"
    assert_file_exists "$agents_dir/observability-agent.md"

    # Verify agents have skill listings (auto-discovered, no more AUTO-GENERATED delimiters)
    assert_file_contains "$agents_dir/pipeline-agent.md" "auto-discovered" "pipeline-agent notes auto-discovery"
    assert_file_contains "$agents_dir/infra-agent.md" "auto-discovered" "infra-agent notes auto-discovery"
}

# ============================================================================
# 17. (v11.1: prompt-tracker removed — test replaced)
# ============================================================================

test_execution_gate_is_cognitive_rule() {
    log_test "Execution Gate is a cognitive rule in CLAUDE.md (v11.1)"
    local claude_src="$REPO_ROOT/BatutaClaude/CLAUDE.md"
    assert_file_contains "$claude_src" "cognitive rule" "execution gate defined as cognitive rule"
}

# ============================================================================
# 18. All skills have scope (v5 frontmatter)
# ============================================================================

test_all_skills_have_scope() {
    log_test "All SKILL.md files have metadata.scope (v5)"
    local skills_dir="$REPO_ROOT/BatutaClaude/skills"
    local total=0 with_scope=0

    for skill_file in "$skills_dir"/*/SKILL.md; do
        [[ ! -f "$skill_file" ]] && continue
        total=$((total + 1))
        local skill_name=$(basename "$(dirname "$skill_file")")
        if grep -q "scope:" "$skill_file" 2>/dev/null; then
            with_scope=$((with_scope + 1))
        else
            log_fail "$skill_name/SKILL.md: missing 'scope'"
        fi
    done

    [[ $total -eq 0 ]] && log_fail "No SKILL.md files found"
    [[ $with_scope -eq $total && $total -gt 0 ]] && log_pass "All $total skills have scope field"
}

# ============================================================================
# 19. All skills have auto_invoke (v5 frontmatter)
# ============================================================================

test_all_skills_have_auto_invoke() {
    log_test "All SKILL.md files have metadata.auto_invoke (v5)"
    local skills_dir="$REPO_ROOT/BatutaClaude/skills"
    local total=0 with_invoke=0

    for skill_file in "$skills_dir"/*/SKILL.md; do
        [[ ! -f "$skill_file" ]] && continue
        total=$((total + 1))
        local skill_name=$(basename "$(dirname "$skill_file")")
        if grep -q "auto_invoke:" "$skill_file" 2>/dev/null; then
            with_invoke=$((with_invoke + 1))
        else
            log_fail "$skill_name/SKILL.md: missing 'auto_invoke'"
        fi
    done

    [[ $total -eq 0 ]] && log_fail "No SKILL.md files found"
    [[ $with_invoke -eq $total && $total -gt 0 ]] && log_pass "All $total skills have auto_invoke field"
}

# ============================================================================
# 20. All skills have allowed-tools (v5 frontmatter)
# ============================================================================

test_all_skills_have_allowed_tools() {
    log_test "All SKILL.md files have allowed-tools (v5)"
    local skills_dir="$REPO_ROOT/BatutaClaude/skills"
    local total=0 with_tools=0

    for skill_file in "$skills_dir"/*/SKILL.md; do
        [[ ! -f "$skill_file" ]] && continue
        total=$((total + 1))
        local skill_name=$(basename "$(dirname "$skill_file")")
        if grep -q "allowed-tools:" "$skill_file" 2>/dev/null; then
            with_tools=$((with_tools + 1))
        else
            log_fail "$skill_name/SKILL.md: missing 'allowed-tools'"
        fi
    done

    [[ $total -eq 0 ]] && log_fail "No SKILL.md files found"
    [[ $with_tools -eq $total && $total -gt 0 ]] && log_pass "All $total skills have allowed-tools field"
}

# ============================================================================
# 21. Agents sync correctly via setup.sh (v5)
# ============================================================================

test_agents_sync_correctly() {
    log_test "setup.sh syncs scope agents to ~/.claude/agents/"
    local agents_src="$REPO_ROOT/BatutaClaude/agents"
    [[ ! -d "$agents_src" ]] && { log_fail "BatutaClaude/agents/ not found"; return; }

    local tmp_home=$(mktemp -d)
    HOME="$tmp_home" USERPROFILE="" bash "$SETUP_SCRIPT" --sync >/dev/null 2>&1 || true

    local claude_agents="$tmp_home/.claude/agents"
    [[ -d "$claude_agents" ]] && log_pass "~/.claude/agents/ created" || { log_fail "~/.claude/agents/ NOT created"; rm -rf "$tmp_home"; return; }

    [[ -f "$claude_agents/pipeline-agent.md" ]] && log_pass "pipeline-agent.md synced" || log_fail "pipeline-agent.md not synced"
    [[ -f "$claude_agents/infra-agent.md" ]] && log_pass "infra-agent.md synced" || log_fail "infra-agent.md not synced"
    [[ -f "$claude_agents/observability-agent.md" ]] && log_pass "observability-agent.md synced" || log_fail "observability-agent.md not synced"

    rm -rf "$tmp_home"
}

# ============================================================================
# 22. (v11.1: skill-sync removed — test replaced)
# ============================================================================

test_no_skill_sync_remnants() {
    log_test "skill-sync directory does not exist (v11.1)"
    if [[ -d "$REPO_ROOT/BatutaClaude/skills/skill-sync" ]]; then
        log_fail "skill-sync directory still exists"
    else
        log_pass "skill-sync directory removed"
    fi
}

# ============================================================================
# 23. AUTO-GENERATED delimiters present (v5)
# ============================================================================

test_no_auto_generated_delimiters() {
    log_test "No AUTO-GENERATED delimiters in CLAUDE.md or agents (v11.1)"
    local claude_src="$REPO_ROOT/BatutaClaude/CLAUDE.md"
    local agents_dir="$REPO_ROOT/BatutaClaude/agents"

    # CLAUDE.md should NOT have old delimiters
    if grep -q "AUTO-GENERATED by skill-sync" "$claude_src" 2>/dev/null; then
        log_fail "CLAUDE.md still has AUTO-GENERATED delimiters"
    else
        log_pass "CLAUDE.md has no AUTO-GENERATED delimiters"
    fi

    # Agent files should NOT have old delimiters
    for agent in pipeline-agent infra-agent observability-agent; do
        local agent_file="$agents_dir/${agent}.md"
        if [[ -f "$agent_file" ]]; then
            if grep -q "AUTO-GENERATED by skill-sync" "$agent_file" 2>/dev/null; then
                log_fail "${agent}.md still has AUTO-GENERATED delimiters"
            else
                log_pass "${agent}.md clean"
            fi
        fi
    done
}

# ============================================================================
# 24. docs/architecture/ directory exists with architecture docs (v9, was about/ in v6)
# ============================================================================

test_about_directory_exists() {
    log_test "docs/architecture/ directory exists with architecture docs (v9)"
    local arch_dir="$REPO_ROOT/docs/architecture"

    assert_dir_exists "$arch_dir"
    assert_file_exists "$arch_dir/arquitectura-diagrama.md"
    assert_file_exists "$arch_dir/arquitectura-para-no-tecnicos.md"
}

# ============================================================================
# 25. docs/guides/ contains execution guides (v9, was guides/ in v6)
# ============================================================================

test_guides_no_architecture_docs() {
    log_test "docs/guides/ contains execution guides (v9)"
    local guides_dir="$REPO_ROOT/docs/guides"

    assert_dir_exists "$guides_dir"
    assert_file_exists "$guides_dir/guia-batuta-app.md"
    assert_file_exists "$guides_dir/guia-temporal-io-app.md"
    assert_file_exists "$guides_dir/guia-langchain-gmail-agent.md"

    # Architecture docs should NOT be in guides/ (moved to docs/architecture/)
    if [[ -f "$guides_dir/arquitectura-diagrama.md" ]]; then
        log_fail "arquitectura-diagrama.md still in docs/guides/ (should be in docs/architecture/)"
    else
        log_pass "arquitectura-diagrama.md correctly in docs/architecture/"
    fi

    if [[ -f "$guides_dir/arquitectura-para-no-tecnicos.md" ]]; then
        log_fail "arquitectura-para-no-tecnicos.md still in docs/guides/ (should be in docs/architecture/)"
    else
        log_pass "arquitectura-para-no-tecnicos.md correctly in docs/architecture/"
    fi
}

# ============================================================================
# 26. docs/qa/ directory exists with quality reports (v9, was qa/ in v6)
# ============================================================================

test_qa_directory_exists() {
    log_test "docs/qa/ directory exists with quality reports (v9)"
    local qa_dir="$REPO_ROOT/docs/qa"

    assert_dir_exists "$qa_dir"

    local report_count=0
    local subdir_count=0
    for f in "$qa_dir"/*.md; do
        [[ -f "$f" ]] && report_count=$((report_count + 1))
    done
    for d in "$qa_dir"/*/; do
        [[ -d "$d" ]] && subdir_count=$((subdir_count + 1))
    done
    local total=$((report_count + subdir_count))

    [[ $total -ge 2 ]] && log_pass "$total quality report items in docs/qa/ ($report_count files + $subdir_count subdirs)" || log_fail "Expected at least 2 report items in docs/qa/, found $total"
}

# ============================================================================
# 27. BatutaClaude/VERSION file exists (v6)
# ============================================================================

test_version_file_exists() {
    log_test "BatutaClaude/VERSION file exists (v6)"
    local version_file="$REPO_ROOT/BatutaClaude/VERSION"

    assert_file_exists "$version_file"
    assert_file_not_empty "$version_file"

    if head -1 "$version_file" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+'; then
        log_pass "VERSION contains valid semver format"
    else
        log_fail "VERSION does not contain a valid semver format"
    fi
}

# ============================================================================
# 28. team-orchestrator skill exists with proper frontmatter (v7)
# ============================================================================

test_team_orchestrator_skill_exists() {
    log_test "team-orchestrator SKILL.md exists with infra scope (v7)"
    local skill_file="$REPO_ROOT/BatutaClaude/skills/team-orchestrator/SKILL.md"

    assert_file_exists "$skill_file"
    assert_file_not_empty "$skill_file"
    assert_file_contains "$skill_file" "scope:.*infra" "scope includes infra"
    assert_file_contains "$skill_file" "auto_invoke" "has auto_invoke field"
}

# ============================================================================
# 29. O.R.T.A. hooks exist (v7)
# ============================================================================

test_orta_hooks_exist() {
    log_test "O.R.T.A. hooks for Agent Teams exist (v7)"
    local hooks_dir="$REPO_ROOT/infra/hooks"

    assert_dir_exists "$hooks_dir"
    assert_file_exists "$hooks_dir/orta-teammate-idle.sh"
    assert_file_exists "$hooks_dir/orta-task-gate.sh"

    # Verify both have valid shebangs
    if head -1 "$hooks_dir/orta-teammate-idle.sh" | grep -q '#!/usr/bin/env bash\|#!/bin/bash'; then
        log_pass "orta-teammate-idle.sh has valid shebang"
    else
        log_fail "orta-teammate-idle.sh missing valid shebang"
    fi

    if head -1 "$hooks_dir/orta-task-gate.sh" | grep -q '#!/usr/bin/env bash\|#!/bin/bash'; then
        log_pass "orta-task-gate.sh has valid shebang"
    else
        log_fail "orta-task-gate.sh missing valid shebang"
    fi
}

# ============================================================================
# 30. settings.json has Agent Teams configuration (v7)
# ============================================================================

test_settings_has_agent_teams() {
    log_test "settings.json has Agent Teams config (v11.1)"
    local settings="$REPO_ROOT/BatutaClaude/settings.json"

    assert_file_contains "$settings" "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" "Agent Teams feature flag"
    assert_file_contains "$settings" "teammateMode" "teammate mode setting"
    # TeammateIdle and TaskCompleted hooks removed in v11.1
    assert_file_not_contains "$settings" "TeammateIdle" "TeammateIdle hook (removed in v11.1)"
    assert_file_not_contains "$settings" "TaskCompleted" "TaskCompleted hook (removed in v11.1)"
}

# ============================================================================
# 31. CLAUDE.md has Team Routing section (v7)
# ============================================================================

test_claude_md_has_team_routing() {
    log_test "CLAUDE.md has Team Routing section (v7)"
    local claude_src="$REPO_ROOT/BatutaClaude/CLAUDE.md"

    assert_file_contains "$claude_src" "Team Routing" "Team Routing section"
    assert_file_contains "$claude_src" "Agent Team" "Agent Team reference"
}

# ============================================================================
# 32. Scope agents have Spawn Prompt sections (v7)
# ============================================================================

test_scope_agents_have_spawn_prompts() {
    log_test "All scope agents have Agent Team spawn prompts (v7)"
    local agents_dir="$REPO_ROOT/BatutaClaude/agents"

    for agent in pipeline-agent infra-agent observability-agent; do
        local agent_file="$agents_dir/${agent}.md"
        if [[ -f "$agent_file" ]]; then
            if grep -q "Spawn Prompt" "$agent_file" 2>/dev/null; then
                log_pass "${agent}.md has Spawn Prompt section"
            else
                log_fail "${agent}.md missing Spawn Prompt section"
            fi
            if grep -q "Team Context" "$agent_file" 2>/dev/null; then
                log_pass "${agent}.md has Team Context section"
            else
                log_fail "${agent}.md missing Team Context section"
            fi
        else
            log_fail "${agent}.md not found"
        fi
    done
}

# ============================================================================
# 33. (v11.1: prompt-tracker removed — test replaced)
# ============================================================================

test_no_prompt_tracker_remnants() {
    log_test "prompt-tracker directory does not exist (v11.1)"
    if [[ -d "$REPO_ROOT/BatutaClaude/skills/prompt-tracker" ]]; then
        log_fail "prompt-tracker directory still exists"
    else
        log_pass "prompt-tracker directory removed"
    fi
}

# ============================================================================
# 34. security-audit skill exists with proper frontmatter (v9)
# ============================================================================

test_security_audit_skill_exists() {
    log_test "security-audit SKILL.md exists with infra+pipeline scope (v9)"
    local skill_file="$REPO_ROOT/BatutaClaude/skills/security-audit/SKILL.md"

    assert_file_exists "$skill_file"
    assert_file_not_empty "$skill_file"
    assert_file_contains "$skill_file" "scope:.*infra" "scope includes infra"
    assert_file_contains "$skill_file" "scope:.*pipeline" "scope includes pipeline"
    assert_file_contains "$skill_file" "OWASP\|owasp" "references OWASP"
    assert_file_contains "$skill_file" "Threat Model\|threat.model" "has Threat Model"
}

# ============================================================================
# 35. Team templates exist (v9)
# ============================================================================

test_team_templates_exist() {
    log_test "Team templates exist in teams/templates/ (v9)"
    local templates_dir="$REPO_ROOT/teams/templates"

    assert_dir_exists "$templates_dir"

    local template_count=0
    for f in "$templates_dir"/*.md; do
        [[ -f "$f" ]] && template_count=$((template_count + 1))
    done

    if [[ $template_count -ge 6 ]]; then
        log_pass "$template_count team templates in teams/templates/"
    else
        log_fail "Expected at least 6 templates, found $template_count"
    fi

    assert_file_exists "$templates_dir/nextjs-saas.md"
    assert_file_exists "$templates_dir/fastapi-service.md"
    assert_file_exists "$templates_dir/n8n-automation.md"
    assert_file_exists "$templates_dir/ai-agent.md"
    assert_file_exists "$templates_dir/data-pipeline.md"
    assert_file_exists "$templates_dir/refactoring.md"
}

# ============================================================================
# 36. Team playbook exists (v9)
# ============================================================================

test_team_playbook_exists() {
    log_test "Team playbook exists at teams/playbook.md (v9)"
    local playbook="$REPO_ROOT/teams/playbook.md"

    assert_file_exists "$playbook"
    assert_file_not_empty "$playbook"
}

# ============================================================================
# 37. 10 guides exist in docs/guides/ (v9)
# ============================================================================

test_ten_guides_exist() {
    log_test "10 execution guides exist in docs/guides/ (v9)"
    local guides_dir="$REPO_ROOT/docs/guides"

    local guide_count=0
    for f in "$guides_dir"/guia-*.md; do
        [[ -f "$f" ]] && guide_count=$((guide_count + 1))
    done

    if [[ $guide_count -ge 10 ]]; then
        log_pass "$guide_count guides in docs/guides/"
    else
        log_fail "Expected at least 10 guides, found $guide_count"
    fi
}

# ============================================================================
# 38. Contract-First Protocol in team-orchestrator (v9)
# ============================================================================

test_contract_first_protocol() {
    log_test "team-orchestrator has Contract-First Protocol (v9)"
    local skill_file="$REPO_ROOT/BatutaClaude/skills/team-orchestrator/SKILL.md"

    assert_file_contains "$skill_file" "Contract-First Protocol" "Contract-First Protocol section"
    assert_file_contains "$skill_file" "File Ownership" "File Ownership rules"
    assert_file_contains "$skill_file" "Contract Diff" "Contract Diff verification"
}

# ============================================================================
# 39. Security integrated in sdd-design and sdd-verify (v9)
# ============================================================================

test_security_integration() {
    log_test "security-audit integrated in sdd-design and sdd-verify (v9)"
    local design_file="$REPO_ROOT/BatutaClaude/skills/sdd-design/SKILL.md"
    local verify_file="$REPO_ROOT/BatutaClaude/skills/sdd-verify/SKILL.md"

    assert_file_contains "$design_file" "Threat Model\|threat.model\|Security" "sdd-design has security section"
    assert_file_contains "$verify_file" "Security Check\|security.check\|security-audit" "sdd-verify has security check"
}

# ============================================================================
# 40. Total skill count is 15 (v9)
# ============================================================================

test_twentytwo_skills_total() {
    log_test "22 skills total in BatutaClaude/skills/ (v11.1)"
    local skills_dir="$REPO_ROOT/BatutaClaude/skills"

    local skill_count=0
    for d in "$skills_dir"/*/; do
        [[ -d "$d" && -f "$d/SKILL.md" ]] && skill_count=$((skill_count + 1))
    done

    if [[ $skill_count -eq 22 ]]; then
        log_pass "$skill_count skills (expected 22)"
    else
        log_fail "Expected 22 skills, found $skill_count"
    fi
}

# ============================================================================
# 41. infra-agent includes security-audit in skills list (v9)
# ============================================================================

test_infra_agent_has_security() {
    log_test "infra-agent.md includes security-audit skill (v9)"
    local agent_file="$REPO_ROOT/BatutaClaude/agents/infra-agent.md"

    assert_file_contains "$agent_file" "security-audit" "security-audit in infra-agent skills"
}

# --- v9.1 tests: Integration Test Findings (from guia-nextjs-saas integration test) ---

test_setup_has_install_hooks() {
    log_test "setup.sh has install_hooks function"
    assert_file_contains "$REPO_ROOT/infra/setup.sh" "install_hooks" \
        "setup.sh should contain install_hooks function"
}

test_setup_has_hooks_flag() {
    log_test "setup.sh accepts --hooks flag"
    assert_file_contains "$REPO_ROOT/infra/setup.sh" "\-\-hooks" \
        "setup.sh should accept --hooks flag"
}

test_gap_detection_checks_both_paths() {
    log_test "infra-agent checks both global and local skill paths"
    assert_file_contains "$REPO_ROOT/BatutaClaude/agents/infra-agent.md" ".claude/skills" \
        "infra-agent should reference project-local .claude/skills/ path"
}

test_ecosystem_creator_has_destination_logic() {
    log_test "ecosystem-creator distinguishes local vs global skill creation"
    assert_file_contains "$REPO_ROOT/BatutaClaude/skills/ecosystem-creator/SKILL.md" "project-local\|Project-local" \
        "ecosystem-creator should document project-local destination"
}

test_artifact_store_documented() {
    log_test "artifact_store.mode is documented in pipeline-agent"
    assert_file_contains "$REPO_ROOT/BatutaClaude/agents/pipeline-agent.md" "artifact_store\|Artifact Store" \
        "pipeline-agent should document artifact_store"
}

test_stack_awareness_cross_referenced() {
    log_test "Stack Awareness tables have source reference comments"
    local count=0
    for skill in sdd-propose sdd-design sdd-apply sdd-init scope-rule; do
        local skill_file="$REPO_ROOT/BatutaClaude/skills/$skill/SKILL.md"
        if [[ -f "$skill_file" ]] && grep -q "Stack Awareness" "$skill_file" 2>/dev/null; then
            count=$((count + 1))
        fi
    done
    if [[ $count -ge 4 ]]; then
        log_pass "Stack Awareness present in $count/5 skills"
    else
        log_fail "Stack Awareness only found in $count/5 skills"
    fi
}

test_commands_mention_hooks() {
    log_test "batuta-init and batuta-update commands mention hooks"
    assert_file_contains "$REPO_ROOT/BatutaClaude/commands/batuta-init.md" "hooks" \
        "batuta-init should mention hooks installation"
    assert_file_contains "$REPO_ROOT/BatutaClaude/commands/batuta-update.md" "hooks" \
        "batuta-update should mention hooks installation"
}

# ============================================================================
# v9.3 Tests: Doc Standards + Infra Rename + New Skills + Templates
# ============================================================================

test_all_skills_have_purpose_section() {
    log_test "All 22 skills have ## Purpose section (v11.1)"
    local skills_dir="$REPO_ROOT/BatutaClaude/skills"
    local missing=0

    for d in "$skills_dir"/*/; do
        [[ ! -d "$d" || ! -f "$d/SKILL.md" ]] && continue
        local skill_name
        skill_name=$(basename "$d")
        if ! grep -q "## Purpose" "$d/SKILL.md" 2>/dev/null; then
            log_fail "Skill '$skill_name' missing ## Purpose section"
            missing=$((missing + 1))
        fi
    done

    [[ $missing -eq 0 ]] && log_pass "All skills have ## Purpose section"
}

test_new_skills_have_valid_frontmatter() {
    log_test "New skills (fastapi-crud, jwt-auth, sqlalchemy-models) have valid frontmatter (v9.3)"
    local skills_dir="$REPO_ROOT/BatutaClaude/skills"

    for skill in fastapi-crud jwt-auth sqlalchemy-models; do
        local skill_file="$skills_dir/$skill/SKILL.md"
        assert_file_exists "$skill_file"
        assert_file_contains "$skill_file" "^name:" "frontmatter name field in $skill"
        assert_file_contains "$skill_file" "scope:" "frontmatter scope field in $skill"
        assert_file_contains "$skill_file" "auto_invoke:" "frontmatter auto_invoke field in $skill"
        assert_file_contains "$skill_file" "allowed-tools:" "frontmatter allowed-tools field in $skill"
    done
}

test_seven_team_templates() {
    log_test "7 team templates exist in teams/templates/ (v9.3)"
    local templates_dir="$REPO_ROOT/teams/templates"
    local template_count=0

    for f in "$templates_dir"/*.md; do
        [[ -f "$f" ]] && template_count=$((template_count + 1))
    done

    if [[ $template_count -ge 7 ]]; then
        log_pass "$template_count team templates (expected >= 7)"
    else
        log_fail "Expected at least 7 templates, found $template_count"
    fi

    # Verify temporal-io-app template specifically exists
    assert_file_exists "$templates_dir/temporal-io-app.md"
    assert_file_contains "$templates_dir/temporal-io-app.md" "Composicion del Equipo" \
        "temporal-io-app template has team composition section"
}

test_hooks_point_to_infra_directory() {
    log_test "settings.json hooks point to infra/ directory (v9.3)"
    local settings="$REPO_ROOT/BatutaClaude/settings.json"

    assert_file_contains "$settings" "infra/hooks/" "hooks reference infra/ directory"
    assert_file_not_contains "$settings" "skills/hooks/" "no legacy skills/hooks/ references"
}

test_no_guides_reference_old_skills_path() {
    log_test "No active guides reference old skills/setup.sh path (v9.3)"
    local guides_dir="$REPO_ROOT/docs/guides"
    local found=0

    for guide in "$guides_dir"/guia-*.md; do
        [[ ! -f "$guide" ]] && continue
        if grep -q "skills/setup\.sh" "$guide" 2>/dev/null; then
            log_fail "$(basename "$guide") still references skills/setup.sh"
            found=$((found + 1))
        fi
    done

    [[ $found -eq 0 ]] && log_pass "No guides reference old skills/setup.sh path"
}

test_sdd_apply_has_documentation_standard() {
    log_test "sdd-apply has Code Documentation Standard section (v9.3)"
    local apply_file="$REPO_ROOT/BatutaClaude/skills/sdd-apply/SKILL.md"

    assert_file_contains "$apply_file" "Code Documentation Standard" \
        "sdd-apply has documentation standard section"
    assert_file_contains "$apply_file" "module docstring" \
        "sdd-apply mentions module docstrings"
    assert_file_contains "$apply_file" "SECURITY:" \
        "sdd-apply mentions SECURITY: prefix"
}

test_claude_md_has_doc_standard_rule() {
    log_test "CLAUDE.md has code documentation enforcement rule (v9.3)"
    local claude_md="$REPO_ROOT/BatutaClaude/CLAUDE.md"

    assert_file_contains "$claude_md" "module docstring" \
        "CLAUDE.md mentions module docstring requirement"
    assert_file_contains "$claude_md" "SECURITY:" \
        "CLAUDE.md mentions SECURITY: prefix"
    assert_file_contains "$claude_md" "sdd-apply" \
        "CLAUDE.md references sdd-apply for full standard"
}

# ============================================================================
# v9.4 Tests: SDD Command Wrappers + Colon-to-Hyphen Migration
# ============================================================================

test_eleven_commands_synced() {
    log_test "11 commands exist in BatutaClaude/commands/ (v11.1)"
    local cmd_dir="$REPO_ROOT/BatutaClaude/commands"
    local expected_commands=(
        "batuta-init.md"
        "batuta-update.md"
        "create.md"
        "sdd-init.md"
        "sdd-explore.md"
        "sdd-new.md"
        "sdd-continue.md"
        "sdd-ff.md"
        "sdd-apply.md"
        "sdd-verify.md"
        "sdd-archive.md"
    )

    local found=0
    for cmd in "${expected_commands[@]}"; do
        if [[ -f "$cmd_dir/$cmd" ]]; then
            found=$((found + 1))
        else
            assert_file_exists "$cmd_dir/$cmd" "Command $cmd exists"
        fi
    done

    if [[ $found -eq ${#expected_commands[@]} ]]; then
        log_pass "All 11 command files exist in BatutaClaude/commands/"
    fi
}

test_sdd_commands_use_hyphens_not_colons() {
    log_test "No /sdd: or /create: references in BatutaClaude/ (v9.4)"
    local has_colons=0

    # Check all .md files in BatutaClaude/ for old colon format
    while IFS= read -r -d '' file; do
        if grep -q "/sdd:" "$file" 2>/dev/null || grep -q "/create:" "$file" 2>/dev/null; then
            has_colons=1
            log_fail "File still uses colon format: $file"
        fi
    done < <(find "$REPO_ROOT/BatutaClaude" -name "*.md" -print0)

    if [[ $has_colons -eq 0 ]]; then
        log_pass "No /sdd: or /create: references in BatutaClaude/"
    fi
}

test_claude_md_commands_use_hyphens() {
    log_test "CLAUDE.md SDD Commands table uses correct format (v11.1)"
    local claude_md="$REPO_ROOT/BatutaClaude/CLAUDE.md"

    assert_file_contains "$claude_md" "/sdd-init" \
        "CLAUDE.md has /sdd-init (hyphen format)"
    assert_file_contains "$claude_md" "/sdd-new" \
        "CLAUDE.md has /sdd-new (hyphen format)"
    assert_file_contains "$claude_md" "/create" \
        "CLAUDE.md has /create command (unified in v11.1)"

    # Verify NO colon format remains
    if grep -q '`/sdd:' "$claude_md" 2>/dev/null; then
        log_fail "CLAUDE.md still has /sdd: format (should be /sdd-)"
    else
        log_pass "CLAUDE.md has no /sdd: references"
    fi
}

# ============================================================================
# 48. Hooks use new matcher+hooks wrapper format (v9.4)
# ============================================================================

test_hooks_use_new_matcher_format() {
    log_test "settings.json hooks use new matcher+hooks wrapper format (v9.4)"
    local settings="$REPO_ROOT/BatutaClaude/settings.json"

    # New format: each event array contains objects with a "hooks" array property
    # Old format: objects with "type" directly in the event array (no wrapper)

    if command -v python3 &>/dev/null; then
        local result
        result=$(python3 -c "
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
hooks = data.get('hooks', {})
errors = []
for event, entries in hooks.items():
    if not isinstance(entries, list):
        errors.append(f'{event}: not a list')
        continue
    for i, entry in enumerate(entries):
        if 'hooks' not in entry:
            errors.append(f'{event}[{i}]: missing hooks wrapper (old format?)')
        elif not isinstance(entry['hooks'], list):
            errors.append(f'{event}[{i}].hooks: not a list')
if errors:
    print('FAIL:' + ';'.join(errors))
else:
    print('PASS')
" "$settings" 2>&1) || true

        if [[ "$result" == "PASS" ]]; then
            log_pass "All hook events use new matcher+hooks wrapper format"
        else
            log_fail "Hooks format validation: ${result#FAIL:}"
        fi
    elif command -v jq &>/dev/null; then
        local bad_hooks
        bad_hooks=$(jq -r '.hooks | to_entries[] | .key as $event | .value[] | select(.hooks == null) | $event' "$settings" 2>/dev/null)
        if [[ -z "$bad_hooks" ]]; then
            log_pass "All hook events use new matcher+hooks wrapper format"
        else
            log_fail "Hook events missing hooks wrapper: $bad_hooks"
        fi
    else
        log_skip "Neither python3 nor jq available to validate hooks format"
    fi
}

# ============================================================================
# v10.2 tests: One-Liner Installer + Output Styles
# ============================================================================

test_install_script_exists() {
    log_test "infra/install.sh exists and is well-formed"
    local install_script="$REPO_ROOT/infra/install.sh"

    assert_file_exists "$install_script"
    assert_file_contains "$install_script" "#!/usr/bin/env bash" "shebang"
    assert_file_contains "$install_script" "cleanup()" "cleanup function"
    assert_file_contains "$install_script" "trap cleanup" "cleanup trap"
    assert_file_contains "$install_script" "mktemp" "temp directory creation"
    assert_file_contains "$install_script" "select_platform" "platform selection"
}

test_output_styles_source_exists() {
    log_test "BatutaClaude/output-styles/batuta.md exists"
    assert_file_exists "$REPO_ROOT/BatutaClaude/output-styles/batuta.md"
}

test_do_all_does_not_call_generate_claude() {
    log_test "do_all() does not call generate_claude"
    # Extract the do_all function body and check it does NOT call generate_claude
    local setup="$REPO_ROOT/infra/setup.sh"
    if grep -A 20 '^do_all()' "$setup" | grep -q 'generate_claude'; then
        log_fail "do_all() still calls generate_claude — should be removed"
    else
        log_pass "do_all() does not call generate_claude"
    fi
}

test_do_all_does_not_call_sync_antigravity() {
    log_test "do_all() does not call sync_antigravity"
    local setup="$REPO_ROOT/infra/setup.sh"
    if grep -A 20 '^do_all()' "$setup" | grep -q 'sync_antigravity'; then
        log_fail "do_all() still calls sync_antigravity — should be removed"
    else
        log_pass "do_all() does not call sync_antigravity"
    fi
}

test_do_all_calls_sync_output_styles() {
    log_test "do_all() calls sync_output_styles"
    local setup="$REPO_ROOT/infra/setup.sh"
    if grep -A 20 '^do_all()' "$setup" | grep -q 'sync_output_styles'; then
        log_pass "do_all() calls sync_output_styles"
    else
        log_fail "do_all() does not call sync_output_styles"
    fi
}

# ============================================================================
# Run All Tests
# ============================================================================

printf "\n${CYAN}${BOLD}================================================================${NC}\n"
printf "${CYAN}${BOLD}  Batuta.Dots — Test Suite (Claude Code)${NC}\n"
printf "${CYAN}${BOLD}================================================================${NC}\n"

# --- Foundation tests ---
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

# --- v4 tests ---
test_session_template_exists
test_claude_md_has_v4_sections

# --- v5 tests: MoE + Execution Gate + Frontmatter + Skill-Sync ---
test_claude_md_has_execution_gate
test_claude_md_has_scope_routing
test_claude_md_no_follow_questions
test_claude_md_no_just_do_it_proceed
test_scope_agents_exist
test_execution_gate_is_cognitive_rule
test_all_skills_have_scope
test_all_skills_have_auto_invoke
test_all_skills_have_allowed_tools
test_agents_sync_correctly
test_no_skill_sync_remnants
test_no_auto_generated_delimiters

# --- v6 tests: Quality Audit + Folder Reorganization ---
test_about_directory_exists
test_guides_no_architecture_docs
test_qa_directory_exists
test_version_file_exists

# --- v7 tests: Agent Teams + 3-Level Execution ---
test_team_orchestrator_skill_exists
test_orta_hooks_exist
test_settings_has_agent_teams
test_claude_md_has_team_routing
test_scope_agents_have_spawn_prompts
test_no_prompt_tracker_remnants

# --- v9 tests: Security + Contracts + Templates + Guides ---
test_security_audit_skill_exists
test_team_templates_exist
test_team_playbook_exists
test_ten_guides_exist
test_contract_first_protocol
test_security_integration
test_twentytwo_skills_total
test_infra_agent_has_security

# --- v9.1 tests: Integration Test Findings ---
test_setup_has_install_hooks
test_setup_has_hooks_flag
test_gap_detection_checks_both_paths
test_ecosystem_creator_has_destination_logic
test_artifact_store_documented
test_stack_awareness_cross_referenced
test_commands_mention_hooks

# --- v9.3 tests: Doc Standards + Infra Rename + New Skills + Templates ---
test_all_skills_have_purpose_section
test_new_skills_have_valid_frontmatter
test_seven_team_templates
test_hooks_point_to_infra_directory
test_no_guides_reference_old_skills_path
test_sdd_apply_has_documentation_standard
test_claude_md_has_doc_standard_rule

# --- v9.4 tests: SDD Command Wrappers + Colon-to-Hyphen Migration ---
test_eleven_commands_synced
test_sdd_commands_use_hyphens_not_colons
test_claude_md_commands_use_hyphens

# --- v9.4 tests: Hooks New Format (matcher + hooks wrapper) ---
test_hooks_use_new_matcher_format

# --- v10.2 tests: One-Liner Installer + Output Styles ---
test_install_script_exists
test_output_styles_source_exists
test_do_all_does_not_call_generate_claude
test_do_all_does_not_call_sync_antigravity
test_do_all_calls_sync_output_styles

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
