# Integration Test Report: guia-nextjs-saas.md

**Fecha**: 2026-02-22
**Ejecutor**: Claude (simulacion paso a paso)
**Proyecto test**: `E:\BATUTA PROJECTS\batuta-app-test-2`
**Pasos ejecutados**: 1-6 (setup, SDD init/explore/propose/spec/design/tasks)
**Pasos NO ejecutados**: 7-15 (implementacion real, deploy) — requieren instancia real de Claude Code

---

## Resumen Ejecutivo

Se ejecutaron los primeros 6 pasos de la guia como lo haria un usuario humano.
Se encontraron **12 hallazgos** (4 criticos, 5 importantes, 3 menores).
Los tests actuales (148/148 PASS) verifican existencia de archivos pero NO cubren
estos puntos ciegos funcionales.

---

## Hallazgos

### CRITICOS (rompen la experiencia del usuario)

#### H2: setup.sh --all NO copia CLAUDE.md al proyecto destino
- **Descripcion**: `setup.sh --all` copia CLAUDE.md al root de batuta-dots (el repo fuente), no al proyecto del usuario
- **Impacto**: Un usuario nuevo siguiendo la guia NO tendria CLAUDE.md en su proyecto
- **Reproduccion**: Ejecutar `bash skills/setup.sh --all` desde cualquier directorio → CLAUDE.md aparece en batuta-dots root, no en CWD
- **Test propuesto**: `test_setup_copies_claude_md_to_cwd()` — verificar que `--all` copia CLAUDE.md al directorio actual, no al repo
- **Fix propuesto**: `setup.sh` deberia aceptar `--target <path>` o usar `$PWD` como destino

#### H3: setup.sh --all NO crea .batuta/ directory
- **Descripcion**: La guia dice que el setup crea `.batuta/session.md` y `.batuta/prompt-log.jsonl` pero `setup.sh --all` no los crea
- **Impacto**: Sin estos archivos, O.R.T.A. session continuity no funciona hasta que los hooks los creen
- **Reproduccion**: Ejecutar `bash skills/setup.sh --all` → no existe `.batuta/` en ningun proyecto
- **Test propuesto**: `test_setup_creates_batuta_dir()` — verificar que `--all` crea `.batuta/session.md` y `.batuta/prompt-log.jsonl`
- **Fix propuesto**: Agregar a `setup.sh --all` la creacion de `.batuta/` en el proyecto destino

#### H4: setup.sh --all NO instala hooks nativos
- **Descripcion**: El script sincroniza skills, commands, y agents a `~/.claude/` pero NO merge los hooks de `BatutaClaude/settings.json` al `~/.claude/settings.json` del usuario
- **Impacto**: Sin hooks, el ecosistema pierde: Execution Gate, session continuity, O.R.T.A. teammate monitoring, task quality gate
- **Reproduccion**: Ejecutar `bash skills/setup.sh --all` → `~/.claude/settings.json` no tiene hooks
- **Test propuesto**: `test_setup_installs_hooks()` — verificar que despues de `--all`, `~/.claude/settings.json` contiene los 5 hooks
- **Fix propuesto**: Agregar paso a `setup.sh` que merge hooks (con backup del settings.json existente)

#### H10: ecosystem-creator no distingue ruta de destino (local vs global vs batuta-dots)
- **Descripcion**: Cuando el usuario dice "Opcion 1 — skill acotado al proyecto", no hay logica para guardar el skill en `.claude/skills/` del proyecto (local) vs `~/.claude/skills/` (global) vs `BatutaClaude/skills/` (batuta-dots repo)
- **Impacto**: Skills creados pueden terminar en la ubicacion incorrecta
- **Reproduccion**: El Registration Checklist dice `BatutaClaude/skills/{name}/SKILL.md` que es la ruta del repo batuta-dots
- **Test propuesto**: `test_ecosystem_creator_has_scope_destination()` — verificar que ecosystem-creator tiene logica para project-local skills
- **Fix propuesto**: Agregar al ecosystem-creator logica de destino: local (`.claude/skills/`), global (`~/.claude/skills/`), batuta-dots (`BatutaClaude/skills/`)

---

### IMPORTANTES (degradan la experiencia pero no rompen)

#### H1: La guia no dice que hacer si la carpeta ya existe con contenido
- **Descripcion**: Paso 1 asume carpeta nueva. Si el usuario re-intenta, podria haber conflictos
- **Test propuesto**: N/A (es un problema de documentacion, no de codigo)
- **Fix propuesto**: Agregar nota en Paso 1: "Si la carpeta ya tiene archivos de un intento anterior, borra su contenido primero"

#### H6: sdd-explore tiene Stack Awareness hardcodeado del stack Batuta
- **Descripcion**: La tabla Stack Awareness (Temporal, n8n, LangChain, Redis, Coolify) esta hardcodeada y no se adapta al proyecto
- **Impacto**: Un proyecto Next.js SaaS no usa Temporal ni LangChain pero el skill los busca
- **Test propuesto**: `test_stack_awareness_is_configurable()` — verificar que Stack Awareness puede venir de `openspec/config.yaml`
- **Fix propuesto**: Leer stack de config.yaml en vez de tabla hardcodeada

#### H8: Skill Gap Detection solo checkea `~/.claude/skills/` (global), no `.claude/skills/` (local)
- **Descripcion**: `infra-agent.md` dice "CHECK if a skill exists in `~/.claude/skills/`" — ignora skills locales del proyecto
- **Impacto**: Un skill creado como "project-specific" no seria detectado por el gap detection
- **Test propuesto**: `test_gap_detection_checks_local_skills()` — verificar que infra-agent menciona ambas rutas
- **Fix propuesto**: Cambiar instruccion a "CHECK `~/.claude/skills/` AND `.claude/skills/`"

#### H11: Stack Awareness duplicado en 7 archivos (DRY violation)
- **Descripcion**: La tabla "Batuta Stack Awareness" esta copiada identicamente en 6 skills + 1 template
- **Archivos afectados**: sdd-propose, sdd-init, sdd-explore, sdd-design, sdd-apply, scope-rule, sub-agent-template.md
- **Impacto**: Si cambia el stack, hay que actualizar 7 archivos
- **Test propuesto**: `test_no_duplicate_stack_awareness()` — verificar que la tabla Stack Awareness no esta duplicada, o que todas las copias son identicas
- **Fix propuesto**: Centralizar Stack Awareness en un archivo referenciado (como un include) o generarlo via skill-sync

#### H12: /sdd:continue no documenta el dependency graph
- **Descripcion**: La logica de "next needed phase" no esta documentada. Claude debe inferirla por existencia de archivos
- **Impacto**: Comportamiento impredecible si archivos parciales existen o estan corruptos
- **Test propuesto**: `test_sdd_continue_dependency_graph_documented()` — verificar que pipeline-agent.md tiene tabla explicita de dependencias
- **Fix propuesto**: Agregar tabla: "Si existe proposal pero no spec → run spec. Si existe spec pero no design → run design. Etc."

---

### MENORES (mejoras de calidad)

#### H5: sdd-init referencia artifact_store.mode sin documentar donde viene
- **Descripcion**: El concepto `artifact_store.mode` se usa en 10 skills pero nunca se define como parametro del orquestador
- **Impacto**: Funciona por default (openspec), pero no hay documentacion del contrato
- **Test propuesto**: `test_artifact_store_mode_documented()` — verificar que existe documentacion de artifact_store
- **Fix propuesto**: Documentar artifact_store.mode en pipeline-agent.md o CLAUDE.md

#### H7: .batuta/ no se crea hasta que hooks lo hagan
- **Descripcion**: Los hooks (session-start.sh) crean .batuta/session.md, pero un usuario que abre Claude Code sin hooks activos no tendria estos archivos
- **Impacto**: Minor — funciona sin .batuta/ pero session continuity se pierde
- **Test propuesto**: Cubierto por H3

#### H9: ecosystem-creator Registration Checklist no menciona ruta de destino
- **Descripcion**: La checklist dice `BatutaClaude/skills/{name}/SKILL.md` sin distinguir proyecto vs global
- **Impacto**: Cubierto por H10

---

## Tests Propuestos para setup_test.sh

```bash
# ============================================================================
# INTEGRATION TESTS (de guia-nextjs-saas.md)
# ============================================================================

# I1: setup.sh --all debe funcionar con proyecto destino
test_setup_has_target_option() {
    log_test "setup.sh accepts --target or uses CWD for CLAUDE.md copy"
    # Verificar que setup.sh tiene logica para copiar CLAUDE.md al directorio correcto
    assert_file_contains "$REPO_ROOT/skills/setup.sh" "target\|PWD\|DEST" \
        "setup.sh should support target directory"
}

# I2: setup.sh --all debe instalar hooks
test_setup_installs_hooks() {
    log_test "setup.sh --all installs hooks to ~/.claude/settings.json"
    # Verificar que setup.sh tiene logica para merge hooks
    assert_file_contains "$REPO_ROOT/skills/setup.sh" "hooks\|settings.json" \
        "setup.sh should install hooks"
}

# I3: setup.sh --all debe crear .batuta/
test_setup_creates_batuta_dir() {
    log_test "setup.sh --all creates .batuta/ directory"
    # Verificar que setup.sh crea .batuta/session.md y prompt-log.jsonl
    assert_file_contains "$REPO_ROOT/skills/setup.sh" ".batuta\|session.md" \
        "setup.sh should create .batuta/ directory"
}

# I4: Skill Gap Detection chequea ambas rutas
test_gap_detection_checks_both_paths() {
    log_test "infra-agent.md checks both global and local skill paths"
    local agent="$REPO_ROOT/BatutaClaude/agents/infra-agent.md"
    assert_file_contains "$agent" ".claude/skills" "local skills path reference"
}

# I5: Stack Awareness es consistente
test_stack_awareness_consistency() {
    log_test "All Stack Awareness tables are identical across skills"
    local reference=$(grep -A 10 "Stack Awareness" "$REPO_ROOT/BatutaClaude/skills/sdd-explore/SKILL.md" | head -10)
    for skill in sdd-propose sdd-design sdd-apply sdd-init scope-rule; do
        local current=$(grep -A 10 "Stack Awareness" "$REPO_ROOT/BatutaClaude/skills/$skill/SKILL.md" | head -10)
        if [[ "$reference" != "$current" ]]; then
            log_fail "Stack Awareness in $skill differs from sdd-explore"
        else
            log_pass "Stack Awareness in $skill matches sdd-explore"
        fi
    done
}

# I6: SDD continue dependency graph documentado
test_sdd_continue_has_dependency_graph() {
    log_test "pipeline-agent.md documents SDD phase dependency graph"
    local agent="$REPO_ROOT/BatutaClaude/agents/pipeline-agent.md"
    assert_file_contains "$agent" "dependency\|prerequisite\|requires" \
        "pipeline-agent should document phase dependencies"
}

# I7: ecosystem-creator distingue destino
test_ecosystem_creator_has_destination_logic() {
    log_test "ecosystem-creator distinguishes project-local vs global skill creation"
    local skill="$REPO_ROOT/BatutaClaude/skills/ecosystem-creator/SKILL.md"
    assert_file_contains "$skill" "project.*local\|\.claude/skills\|local.*skill" \
        "ecosystem-creator should document local vs global skill paths"
}
```

---

## Clasificacion por Prioridad de Fix

| # | Hallazgo | Prioridad | Esfuerzo | Archivo a modificar |
|---|----------|-----------|----------|---------------------|
| H4 | setup.sh no instala hooks | P0 | Alto | skills/setup.sh |
| H2 | setup.sh no copia CLAUDE.md al destino | P0 | Medio | skills/setup.sh |
| H3 | setup.sh no crea .batuta/ | P0 | Bajo | skills/setup.sh |
| H10 | ecosystem-creator sin logica de destino | P1 | Medio | BatutaClaude/skills/ecosystem-creator/SKILL.md |
| H8 | Gap Detection solo checkea global | P1 | Bajo | BatutaClaude/agents/infra-agent.md |
| H12 | Dependency graph no documentado | P2 | Bajo | BatutaClaude/agents/pipeline-agent.md |
| H11 | Stack Awareness duplicado (DRY) | P2 | Alto | 7 archivos |
| H6 | Stack Awareness hardcodeado | P2 | Medio | 6 skills |
| H5 | artifact_store no documentado | P3 | Bajo | pipeline-agent.md |
| H1 | Guia sin instruccion de re-intento | P3 | Bajo | docs/guides/guia-nextjs-saas.md |

---

## Conclusion

Los tests actuales (148/148) son excelentes para verificar la **estructura del repositorio batuta-dots**.
Pero NO cubren la **experiencia de instalacion y uso** del ecosistema.

El gap mas critico es que `setup.sh --all` solo instala skills/commands/agents
pero NO instala hooks, permissions, ni crea los archivos de proyecto (.batuta/, CLAUDE.md en destino).

Un usuario siguiendo la guia hoy obtendria un ecosistema "incompleto":
- Skills: OK (15 sincronizados a global)
- Commands: OK (4 sincronizados)
- Agents: OK (3 sincronizados)
- CLAUDE.md en proyecto: FALTA
- .batuta/ en proyecto: FALTA
- Hooks nativos: FALTA (Execution Gate, session continuity, O.R.T.A.)
- Permissions (deny .env, ask git push): FALTA
