# Changelog de Refactorizacion — Batuta.Dots

> Documento de traza. Registra CADA modificacion arquitectural, POR QUE se hizo, y como revertirla si es necesario.

---

## v11.0.1 — Dynamic Skill Discovery + Hardcoded Reference Cleanup (2026-02-26)

### Contexto

The v11.0 bootstrap prompt hardcoded a list of 24 skills that would become stale when new skills are created via `/create-skill`. Audit revealed 40+ hardcoded references across the ecosystem. This patch makes the skill inventory fully dynamic and fixes all stale counts and version references.

### Changes

- **Dynamic Skill Discovery**: `session-start.sh` now scans `~/.claude/skills/*/SKILL.md` and project-local `.claude/skills/*/SKILL.md`, extracts name + scope from YAML frontmatter, groups by scope, and injects a `Batuta Skill Inventory` into session context. No hardcoded lists.
- **Simplified Bootstrap Prompt**: `settings.json` SessionStart prompt hook no longer lists skills — it references the dynamically injected inventory above.
- **Hook Count Fix**: Documentation updated from "4/5 hooks" to "6 hooks" across 8 files. Added missing `PostToolUse` to enumerated lists.
- **Version References**: Updated all stale `v10.0`/`v10.1`/`v10.2` references to `v11.0` across 13+ files (CHANGELOG historical entries left as-is).
- **Command Count Fix**: `14+ commands` updated to `15 commands` in READMEs.
- **Test Fixture Fix**: `setup_test.sh` updated from 18 to 24 expected skills.

### Files Modified (18)

`infra/hooks/session-start.sh`, `BatutaClaude/settings.json`, `README.md`, `README.es.md`, `BatutaClaude/CLAUDE.md`, `BatutaAntigravity/GEMINI.md`, `academia/README.md`, `academia/03-nivel-dos/hooks-y-automatizacion.md`, `academia/06-referencia/glosario.md`, `academia/07-verificacion/quiz-nivel-dos.md`, `academia/07-verificacion/quiz-nivel-uno.md`, `docs/guides/guia-batuta-antigravity.md`, `docs/qa/integration-tests/nextjs-saas.md`, `docs/qa/integration-tests/ai-agent-adk.md`, `docs/architecture/arquitectura-diagrama.md`, `docs/architecture/arquitectura-para-no-tecnicos.md`, `infra/setup_test.sh`, `CHANGELOG-refactor.md`

### Rollback

```bash
git revert <commit-hash>  # Reverts all changes
# Then manually restore hardcoded skill list in settings.json bootstrap prompt
```

---

## v11.0 — SDD Pipeline Hardening + Superpowers Adoption (2026-02-26)

### Contexto

Full audit of the SDD pipeline revealed 16 gaps (GAP-01→16). Simultaneously, analysis of the Superpowers framework (58k+ stars) identified 4 patterns worth adopting. This release hardens the pipeline, adds deterministic enforcement, and standardizes skill conventions.

### GAP Fixes (16)

- GAP-01: Skill Gap Detection as HARD GATE (blocking, not advisory)
- GAP-02: Execution Gate deterministic via hook (not cognitive)
- GAP-03: Auto-advance between gateless phases
- GAP-04: Forward-only SDD transitions with explicit backtrack
- GAP-05: Phase routing tables in pipeline-agent
- GAP-06: Artifact loading by convention
- GAP-07: Pipeline-agent DELEGATE-ONLY rule
- GAP-08: session.md injection via SessionStart hook
- GAP-09: Auto-routing rules in CLAUDE.md
- GAP-10: Cost-benefit analysis mandatory in proposals
- GAP-11: Discovery Completeness 5-question checklist
- GAP-12: Documentation tasks mandatory in task breakdown
- GAP-13: Amendment History in proposals
- GAP-14: archive_ready flag in verify reports
- GAP-15: ecosystem improvement triggers in archive
- GAP-16: MCP Discovery Awareness (local + web search)

### Superpowers Adoptions (4 of 5)

- Batuta Bootstrap ("The Rule") — SessionStart prompt hook that enforces skill usage with red-flag rationalizations
- 2-Stage Review (Pattern E) — spec + quality review loop per task for Level 2+ complexity
- RED-GREEN-REFACTOR for skills — empirical skill validation before registration in ecosystem-creator
- Description = Trigger Only — all 24 SKILL.md descriptions rewritten as "Use when..." (Superpowers convention)
- Token Efficiency (A5) — DEFERRED to separate PR

### Archivos modificados

- `BatutaClaude/settings.json`: +Bootstrap prompt hook in SessionStart
- `BatutaClaude/CLAUDE.md`: +THE RULE philosophy, +MCP Discovery summary, +G0.25 reference
- `BatutaClaude/agents/pipeline-agent.md`: +Phase routing, +G0.25, +MCP Awareness, +GAP fixes
- `BatutaClaude/skills/*/SKILL.md` (24 archivos): description rewrite + various GAP fixes
- `BatutaClaude/skills/ecosystem-creator/SKILL.md`: +Step 5.5 RED-GREEN-REFACTOR, +MCP Validation, +description convention
- `BatutaClaude/skills/team-orchestrator/SKILL.md`: +Pattern E (Superpowers-Style Review)
- `BatutaClaude/skills/sdd-explore/SKILL.md`: +G0.25, +Discovery Completeness, +MCP Discovery, +Skill Gap hard gate
- `BatutaClaude/skills/sdd-propose/SKILL.md`: +Cost-benefit mandatory, +Amendment History
- `BatutaClaude/skills/sdd-tasks/SKILL.md`: +Documentation tasks mandatory
- `BatutaClaude/skills/sdd-verify/SKILL.md`: +archive_ready flag
- `BatutaClaude/skills/sdd-archive/SKILL.md`: +ecosystem improvement triggers
- `BatutaClaude/skills/sdd-apply/SKILL.md`: +MCP Documentation Check

~26 files in Superpowers commit + 15 files in GAP commits = ~41 files total.

### Principio de diseno

- **THE RULE**: If a skill applies, use it. If an MCP applies, consult it. No exceptions. Enforced deterministically via SessionStart hook, not cognitively via instructions.
- **TRIGGER-ONLY DESCRIPTIONS**: Skill frontmatter description = activation conditions only. Workflow summaries go in ## Purpose. Prevents Claude from using description as shortcut.
- **VALIDATE BEFORE SHIP**: RED-GREEN-REFACTOR for skills ensures they actually improve agent behavior before registration.

### Rollback

git revert the 4 commits in this branch (5dcc765, cab75fd, 65823e6, 27bf32c).

---

## v10.2 — Multi-Platform Support: BatutaAntigravity + Bidirectional Sync (2026-02-24)

### Contexto

El desarrollador usa Claude Code (Max x20, $200/mes) para proyectos complejos. Google Antigravity IDE es gratis durante preview con Gemini 3 Pro. La estrategia: ejecucion en paralelo — Claude Code para arquitectura y features complejas, Antigravity para scripts, automatizaciones y quick wins. Ambos comparten el mismo cerebro CTO y skills via batuta-dots como hub central.

### Contenido creado

- `BatutaAntigravity/` subfolder completo (GEMINI.md + 11 workflows + setup script + settings template)
- `infra/sync.sh` — Motor de sync bidireccional (--to-antigravity, --from-project, --all)
- Campo `platforms` en los 24 SKILL.md (22 = [claude, antigravity], 2 = [claude])
- `.batuta/ecosystem.json` — version tracking para detectar drift entre hub y proyectos
- `docs/guides/guia-batuta-antigravity.md` — Guia de uso multi-plataforma
- `academia/04-nivel-tres/leccion-05-multi-plataforma.md` — Leccion academia

### Archivos modificados

- `BatutaClaude/CLAUDE.md`: +PORTABLE SKILLS en Philosophy, +ecosystem.json en Session Continuity
- `BatutaClaude/agents/infra-agent.md`: Ecosystem Auto-Update implementado (era placeholder)
- `BatutaClaude/skills/skill-sync/SKILL.md`: +platforms field documentation
- `BatutaClaude/skills/*/SKILL.md` (24 archivos): +campo `platforms` en frontmatter
- `infra/setup.sh`: +sync_antigravity(), +ecosystem.json generation, +--antigravity flag
- `infra/hooks/session-start.sh`: +ecosystem.json version drift detection
- `infra/replicate-platform.sh`: +--antigravity flag, deprecate --gemini
- README.md, README.es.md: +seccion multi-platform, +BatutaAntigravity/ en directory tree
- `docs/architecture/arquitectura-diagrama.md`: +Hub & Spoke diagram, +folder structure v10.2
- `docs/architecture/arquitectura-para-no-tecnicos.md`: +analogia "Dos Cocinas"
- CHANGELOG-refactor.md: +entrada v10.2

### Principio de diseno

- **PORTABLE SKILLS**: Skills son agnósticos de plataforma (estándar abierto SKILL.md). El campo `platforms` en frontmatter controla distribucion. batuta-dots es el hub; proyectos y plataformas son spokes.
- **Full Brain, Adapted Body**: GEMINI.md conserva el 100% del cerebro CTO (filosofia, gates, skills, comportamiento). Solo adapta la ejecucion a lo que Antigravity puede hacer (rules en vez de hooks, workflows en vez de commands).
- **Hub & Spoke Sync**: Flujo bidireccional — skills creados en cualquier proyecto/plataforma se propagan al hub, y del hub a todos los spokes.

### Rollback

git revert del commit, o rm -rf BatutaAntigravity/ y revertir cambios en los archivos listados.

---

## v10.1 -- Academia: Manual de Capacitacion Completo (2026-02-24)

### Contexto

Batuta Dots v10.0 tenia 24 skills, 3 agentes, 12 guias, y documentacion tecnica completa pero faltaba un manual de uso progresivo para usuarios de todos los niveles. La academia cierra ese gap: un curso completo que lleva al usuario desde "que es esto" hasta "puedo extender el ecosistema".

### Contenido creado

- 54 archivos en academia/ organizados en 8 modulos
- 21 casos de uso reales en 10 industrias (operaciones, mantenimiento, produccion, supply chain, logistica, marketing, finanzas, RRHH, estudiantes, desarrollo web)
- 4 niveles progresivos: Cero (fundamentos), Uno (ecosistema), Dos (flujos avanzados), Tres (extension)
- 4 rutas recomendadas: Estudiante, Desarrollador, Operaciones/Industria, CTO/Lider tecnico
- 5 quizzes de autoevaluacion + checklist de graduacion
- Modulo de referencia completo: comandos, fichas tecnicas de 24 skills, glosario A-Z, troubleshooting, comparativa vs alternativas

### Archivos modificados

- README.md: +seccion Academia con tabla de modulos
- README.es.md: +seccion Academia (version espanol)
- CHANGELOG-refactor.md: +entrada v10.1
- academia/ (54 archivos nuevos): curso completo

### Rollback

git revert del commit, o rm -rf academia/ y revertir READMEs.

---

## v10.0 — CTO Strategy Layer: Unificacion Desktop → Code (2026-02-23)

### Contexto

Antes de v10.0, se operaba con un va y ven entre Claude Desktop (16 CTO skills) y Claude Code (18 Batuta skills). Copiar directivas manualmente era insostenible. v10.0 unifica todo en Code: 6 skills nuevos, 3 gates, 6 skills enriquecidos, 2 guias. Skills nuevos: process-analyst, recursion-designer, compliance-colombia, data-pipeline-design, llm-pipeline-design, worker-scaffold. Gates: G0.5, G1, G2. Enriquecidos: sdd-explore, sdd-propose, sdd-design, sdd-verify, sdd-archive, sdd-init. Guias: guia-auditoria-contable, guia-seleccion-personal. Metricas: 18→24 skills, 0→3 gates, 10→12 guias. Rollback: `git revert <commit-hash>`.

---

## v9.2 — Correccion Integral: 8 Patrones Sistemicos + 7 Hallazgos Individuales (2026-02-23)

### Contexto

Integration tests en las 10 guias del ecosistema con 10 agentes independientes (A1-A10). **74 hallazgos** (7C, 28I, 39M) en **8 patrones sistemicos**. Analisis de 6 capas de impacto. Reporte: `docs/qa/integration-tests/consolidado-10-guias.md`.

### Patrones Sistemicos Corregidos

| ID | Patron | Fix |
|----|--------|-----|
| PS-1 | `/sdd-new` duplica explore (8/10) | Eliminado explore standalone, solo `/sdd-new` |
| PS-2 | `/sdd-continue` = 1 fase (8/10) | Aclarado + nota `/sdd-ff` + fix "ver estado" |
| PS-3 | Opcion B `--all` → `--project` (7/10) | `setup.sh --project .` |
| PS-4 | Colon → hyphen (7/10 + CLAUDE.md) | `/batuta-analyze-prompts` unificado |
| PS-5 | Glosario observability (4/10) | "observabilidad y continuidad de sesion" |
| PS-6 | Piramide capas 4-5 (2/10) | Layer 4=Code Review, Layer 5=Manual Testing |
| PS-7 | Templates `src/` → `features/` (6) | Alineados con Scope Rule |
| PS-8 | `jota-batuta` hardcoded (5/10) | `[TU-ORGANIZACION-O-USUARIO]` |

### Hallazgos Individuales: I-1 (cli→library), I-2 (+batuta-init en tabla), I-3 (advertencia directorio), I-4 (lessons-learned.md), I-5 (local vs global skill), I-6 (version 9.2.0), I-7 (security prompt simplificado)

### Archivos modificados (17)

`BatutaClaude/CLAUDE.md`, `session-template.md`, 6 templates en `teams/templates/`, 10 guias en `docs/guides/`, `VERSION`

### Rollback
```bash
git revert <commit-hash>
```

---

## v9.1 — Integration Test Fixes (12 Findings from guia-nextjs-saas) (2026-02-22)

### Contexto

Se ejecutaron los pasos 1-6 de `guia-nextjs-saas.md` como prueba de integracion real en un proyecto nuevo. Se identificaron 12 hallazgos (4 criticos, 5 importantes, 3 menores). Tras exploracion profunda: H12 ya resuelto (pipeline-agent ya tenia dependency graph), H11 reclasificado (Stack Awareness no es duplicacion, es especializacion por fase). Reporte completo en `docs/qa/integration-test-nextjs-saas.md`.

### Hallazgos corregidos

| ID | Severidad | Titulo | Fix |
|----|----------|--------|-----|
| H4 | CRITICO | setup.sh no instala hooks nativos | +`install_hooks()` con merge jq/python3: hooks=replace, env=add-missing, permissions=union |
| H1 | CRITICO | guia-nextjs-saas sin nota de re-intento | +nota en Step 1: limpiar carpeta si tiene archivos previos |
| H2 | IMPORTANTE | Guias no mencionan `--project <path>` | 10 guias actualizadas con referencia a hooks y opciones de setup |
| H8 | IMPORTANTE | Skill Gap Detection solo checa ruta global | infra-agent ahora checa `~/.claude/skills/` Y `.claude/skills/` |
| H10 | IMPORTANTE | ecosystem-creator hardcodea destino | +tabla 3 destinos: project-local, global, batuta-repo |
| H5 | MEDIO | artifact_store.mode no documentado | +seccion Artifact Store en pipeline-agent.md |
| H6 | MEDIO | Stack Awareness hardcodeado | +nota de adaptabilidad en sdd-explore |
| H11 | MENOR | Stack Awareness sin cross-references | +comentarios HTML de referencia en 5 skills |

> H12 (dependency graph) ya resuelto en v9.0. H7 cubierto por H4 (hooks install). H3 cubierto por H2 (guias update). H9 informativo.

### Nueva funcion: install_hooks()

Merge inteligente de `BatutaClaude/settings.json` → `~/.claude/settings.json`:
- **hooks**: reemplazo completo (Batuta = source of truth)
- **env**: solo agrega variables faltantes (no sobreescribe existentes)
- **permissions**: union de arrays (deny, ask, allow) con dedup
- Implementacion dual: `jq` (preferido) con fallback `python3`
- Backup automatico: `settings.json.bak.YYYYMMDD`

### Archivos modificados (29)

| Archivo | Cambio | Razon |
|---------|--------|-------|
| `skills/setup.sh` | +`install_hooks()`, `_merge_settings_jq()`, `_merge_settings_python()`, flag `--hooks`, menu actualizado | H4: instalar hooks nativos |
| `BatutaClaude/commands/batuta-init.md` | Step 3 usa --sync + --hooks, confirmacion menciona hooks | H4: init incluye hooks |
| `BatutaClaude/commands/batuta-update.md` | Descripcion, tabla y reporte mencionan hooks | H4: update documenta hooks |
| `BatutaClaude/agents/infra-agent.md` | Dual-path: global + project-local | H8: Gap Detection ambas rutas |
| `BatutaClaude/skills/ecosystem-creator/SKILL.md` | Tabla 3 destinos + logic condicional en Registration | H10: destinos claros |
| `BatutaClaude/agents/pipeline-agent.md` | +seccion Artifact Store | H5: documentar artifact_store.mode |
| `BatutaClaude/skills/sdd-explore/SKILL.md` | +nota adaptabilidad Stack Awareness | H6: no hardcodear stack |
| `BatutaClaude/skills/sdd-{propose,design,apply,init}/SKILL.md` | +cross-reference HTML comments | H11: trazabilidad |
| `BatutaClaude/skills/scope-rule/SKILL.md` | +cross-reference HTML comment | H11: trazabilidad |
| 10 guias en `docs/guides/` | Setup instructions mencionan hooks | H2: commands correctos |
| `docs/guides/guia-nextjs-saas.md` | +nota re-intento Step 1 | H1: carpeta con archivos previos |
| `README.md` | Quick Start, How It Works, setup.sh Reference actualizados | Docs arquitectonicas |
| `README.es.md` | Mismos cambios en espanol + dual-path Gap Detection | Docs arquitectonicas |
| `docs/architecture/arquitectura-diagrama.md` | +--hooks en Mermaid, dual-path en flowchart | Docs arquitectonicas |
| `docs/architecture/arquitectura-para-no-tecnicos.md` | Hooks en Inventario, batuta-init actualizado | Docs arquitectonicas |
| `skills/setup_test.sh` | +7 integration tests (155 total) | Cobertura de v9.1 |
| `BatutaClaude/VERSION` | 9.0.0 → 9.1.0 | Version bump |

### Metricas

| Metrica | v9.0 | v9.1 |
|---------|------|------|
| Hallazgos abiertos | 12 (del integration test) | 0 |
| setup.sh flags | --claude/--sync/--all/--verify/--project | +--hooks |
| Gap Detection paths | 1 (global) | 2 (global + project-local) |
| ecosystem-creator destinos | 1 (hardcodeado) | 3 (project-local, global, batuta-repo) |
| Stack Awareness cross-refs | 0 | 5 skills con referencia a sdd-explore |
| Tests en setup_test.sh | 148 | 155 (+7 integration) |

### Rollback

```bash
git checkout v9.0 -- skills/setup.sh BatutaClaude/commands/ BatutaClaude/agents/ \
  BatutaClaude/skills/ docs/guides/ docs/architecture/ README.md README.es.md \
  skills/setup_test.sh BatutaClaude/VERSION
```

### Decisiones de diseno

| Decision | Alternativa rechazada | Razon |
|----------|----------------------|-------|
| Hooks replace completo | Merge granular por hook | Batuta es source of truth; merge granular es fragil |
| Dual-path Gap Detection | Solo agregar global path | Proyectos con .claude/skills/ local perderian deteccion |
| 3 destinos ecosystem-creator | Pregunta abierta al usuario | Tabla explicita reduce friccion y errores |
| Cross-references (no centralizacion) | Tabla Stack Awareness centralizada | Cada fase tiene version contextualizada (cols diferentes) |

---

## v9.0 — Contract-First + Security + Guides + Teams Playbook + Restructure (2026-02-22)

### Contexto

Post-v8: incorporacion del protocolo Contract-First (inspirado en Cole's context-engineering-intro), skill de seguridad AI-first, 10 guias de ejecucion, team templates con playbook, y reestructura de carpetas a monorepo organizado.

### Cambios principales

| Categoria | Cambio | Impacto |
|-----------|--------|---------|
| Restructura | `about/` → `docs/architecture/`, `guides/` → `docs/guides/`, `qa/` → `docs/qa/` | Monorepo organizado bajo docs/ |
| Security | Nuevo skill `security-audit` (OWASP AI, threat model, secrets, deps) | 15 skills totales (era 14) |
| Security | Threat Model integrado en sdd-design, Security Check en sdd-verify | Seguridad en todo el pipeline SDD |
| Contracts | Contract-First Protocol en team-orchestrator | Contratos, file ownership, cross-review |
| Templates | 6 team templates en `teams/templates/` | Assets reutilizables por stack |
| Playbook | `teams/playbook.md` | Knowledge base de patrones de equipo |
| Guides | 7 guias nuevas + 3 actualizadas = 10 total | Cobertura completa de casos de uso |
| Infra | infra-agent ahora tiene 5 skills (+ security-audit) | Seguridad integrada en infra scope |

### Archivos creados

| Archivo | Descripcion |
|---------|-------------|
| `BatutaClaude/skills/security-audit/SKILL.md` | AI-first security: 10-point checklist, threat model, secrets scan, dependency audit, Claude Security |
| `teams/templates/nextjs-saas.md` | Template: Next.js SaaS (Pattern D) |
| `teams/templates/fastapi-service.md` | Template: FastAPI microservice (Pattern D) |
| `teams/templates/n8n-automation.md` | Template: n8n automation (Pattern A) |
| `teams/templates/ai-agent.md` | Template: AI agent LangChain/ADK (Pattern C) |
| `teams/templates/data-pipeline.md` | Template: Data pipeline ETL (Pattern D) |
| `teams/templates/refactoring.md` | Template: Legacy refactoring (Pattern A) |
| `teams/playbook.md` | Team playbook: decision tree, anti-patterns, best practices |
| `docs/guides/guia-n8n-automation.md` | Guia: Automatizacion con n8n |
| `docs/guides/guia-fastapi-service.md` | Guia: Microservicio FastAPI |
| `docs/guides/guia-nextjs-saas.md` | Guia: SaaS con Next.js |
| `docs/guides/guia-cli-python.md` | Guia: CLI tool en Python |
| `docs/guides/guia-data-pipeline.md` | Guia: Pipeline de datos |
| `docs/guides/guia-refactoring-legacy.md` | Guia: Modernizar codigo legacy |
| `docs/guides/guia-ai-agent-adk.md` | Guia: AI Agent con Google ADK |

### Archivos modificados

| Archivo | Cambio |
|---------|--------|
| `BatutaClaude/skills/team-orchestrator/SKILL.md` | +Contract-First Protocol (~50 lineas) |
| `BatutaClaude/skills/sdd-design/SKILL.md` | +Security Threat Model section |
| `BatutaClaude/skills/sdd-verify/SKILL.md` | +Cross-Layer Security Check (Step 4.7) |
| `BatutaClaude/agents/infra-agent.md` | +security-audit en frontmatter skills |
| `docs/guides/guia-batuta-app.md` | +seccion seguridad, rutas actualizadas |
| `docs/guides/guia-temporal-io-app.md` | +seccion seguridad, rutas actualizadas |
| `docs/guides/guia-langchain-gmail-agent.md` | +seccion seguridad, rutas actualizadas |
| `docs/architecture/arquitectura-diagrama.md` | +diagramas hooks, pyramid, contracts |
| `docs/architecture/arquitectura-para-no-tecnicos.md` | +analogias: contratos, seguridad, templates |
| `README.md` | Estructura docs/, 15 skills, teams section |
| `README.es.md` | Mismos cambios en espanol |
| `skills/setup.sh` | Rutas actualizadas a docs/ |
| `skills/setup_test.sh` | Tests actualizados para docs/, teams/, 15 skills |
| `BatutaClaude/VERSION` | 8.0.0 → 9.0.0 |

### Rollback

```bash
git revert to v8.0.0 tag
# Restaurar estructura anterior:
git mv docs/architecture about
git mv docs/guides guides
git mv docs/qa qa
rmdir docs
rm -rf teams
rm BatutaClaude/skills/security-audit
```

### Decisiones de diseno

| Decision | Alternativa rechazada | Razon |
|----------|----------------------|-------|
| Monorepo con docs/ | Carpetas sueltas (about/, guides/, qa/) | Estructura estandar, escalable, un solo lugar para documentacion |
| Skill dedicado para seguridad | Solo integracion en sdd-verify | Skill permite invocacion on-demand ademas de integracion en pipeline |
| Templates + Playbook | Solo templates | Playbook captura conocimiento que no cabe en templates individuales |
| Contract-First Protocol | Spawn-and-hope | Previene incompatibilidades entre teammates, reduce retrabajo |

---

## v8.0 — Native Hooks + Agent Frontmatter + DRY Cleanup (2026-02-22)

### Contexto

Auditoria completa de batuta-dots v7 vs capacidades nativas de Claude Code. Se identificaron 5 conflictos de ejecucion (C1-C5), 7 oportunidades de integracion nativa (O1-O7), y se aplico DRY para eliminar triple duplicacion que causaba hallazgos recurrentes en QA.

### Problemas resueltos

| ID | Tipo | Titulo | Fix |
|----|------|--------|-----|
| C1 | CONFLICTO | Routing manual pelea con auto-invocacion nativa | Eliminado "How to route" de CLAUDE.md; skills se auto-invocan via description |
| C2 | CONFLICTO | Schemas JSON duplicados y conflictivos (CLAUDE.md vs observability-agent vs prompt-tracker) | Eliminados TODOS los JSON examples excepto en prompt-tracker (unica fuente de verdad) |
| C3 | CONFLICTO | Spawn Prompts redundantes con agent frontmatter nativo | Convertidos a body del agent con frontmatter nativo (skills, memory) |
| C4 | BUG | Hooks O.R.T.A. usan env vars como args pero Claude Code envia JSON via stdin | Reescritos para leer stdin con jq; corregido settings.json |
| C5 | MANTENIMIENTO | Triple duplicacion causa hallazgos recurrentes en QA | Aplicado DRY: CLAUDE.md = referencia, agents = dominio unico, SKILL.md = source of truth |

### Oportunidades nativas implementadas

| ID | Hook/Feature | Impacto |
|----|-------------|---------|
| O1 | PreToolUse prompt hook para Execution Gate | Enforcement determinístico (antes aspiracional) |
| O2 | SessionStart command hook | session.md se inyecta automaticamente como additionalContext |
| O3 | Stop prompt hook | Claude evalua si debe actualizar session.md antes de parar |
| O4 | Stop command hook | Logea session_end en prompt-log.jsonl |
| O7 | TaskCompleted hook corregido (stdin) | Quality gate funciona correctamente |

### Archivos creados (2)

| Archivo | Proposito |
|---------|-----------|
| `skills/hooks/session-start.sh` | SessionStart hook: inyecta session.md como additionalContext |
| `skills/hooks/session-save.sh` | Stop hook: logea session_end event |

### Archivos modificados (10)

| Archivo | Cambio | Razon |
|---------|--------|-------|
| `BatutaClaude/CLAUDE.md` | -92 lineas (252→160): eliminado routing manual, tabla AUTO-GENERATED, JSON examples, session compliance manual | C1, C2, C5: DRY + nativo |
| `BatutaClaude/settings.json` | +5 hooks nativos (SessionStart, PreToolUse, Stop x2, corregidos TeammateIdle/TaskCompleted) | C4, O1-O4 |
| `BatutaClaude/agents/pipeline-agent.md` | +frontmatter nativo, -tabla AUTO-GENERATED, -Spawn Prompt, -Allowed Tools (115→80) | C3, C5 |
| `BatutaClaude/agents/infra-agent.md` | +frontmatter nativo, -tabla AUTO-GENERATED, -Spawn Prompt, -Allowed Tools (132→87) | C3, C5 |
| `BatutaClaude/agents/observability-agent.md` | +frontmatter nativo, -tabla AUTO-GENERATED, -Spawn Prompt, -JSON examples, -Allowed Tools (148→86) | C2, C3, C5 |
| `BatutaClaude/skills/team-orchestrator/SKILL.md` | -Team Lifecycle, -Spawn template, -Platform Notes detallado (216→155) | C3: nativo en Claude Code |
| `BatutaClaude/skills/skill-sync/assets/sync.sh` | Ya no escribe en CLAUDE.md; valida agents con frontmatter nativo | C1: CLAUDE.md sin tabla |
| `BatutaClaude/skills/skill-sync/SKILL.md` | Actualizado para reflejar nuevo scope (sin CLAUDE.md) | Documentacion |
| `skills/hooks/orta-teammate-idle.sh` | Reescrito: lee JSON stdin con jq (antes usaba $1/$2) | C4: fix stdin protocol |
| `skills/hooks/orta-task-gate.sh` | Reescrito: lee JSON stdin con jq, extrae task_subject | C4: fix stdin protocol |

### Metricas

| Metrica | v7 | v8 |
|---------|----|----|
| CLAUDE.md | ~252 lineas | ~160 lineas (-37%) |
| Scope agents (3) | ~395 lineas | ~253 lineas (-36%) |
| team-orchestrator | ~216 lineas | ~155 lineas (-28%) |
| Hook scripts | 2 (ambos rotos) | 4 (todos funcionales) |
| Hooks en settings.json | 2 (TeammateIdle, TaskCompleted) | 5 (+SessionStart, PreToolUse, Stop) |
| JSON schema sources | 3 (conflictivos) | 1 (prompt-tracker SKILL.md) |
| Enforcement Execution Gate | Aspiracional (compliance) | Determinístico (PreToolUse hook) |
| Session continuity | Aspiracional (compliance) | Determinístico (SessionStart + Stop hooks) |

### Rollback

Para revertir v8 y volver a v7.1:
```bash
git checkout v7.1 -- BatutaClaude/CLAUDE.md BatutaClaude/settings.json \
  BatutaClaude/agents/ BatutaClaude/skills/team-orchestrator/SKILL.md \
  BatutaClaude/skills/skill-sync/ skills/hooks/ BatutaClaude/VERSION
# Eliminar hooks nuevos
rm -f skills/hooks/session-start.sh skills/hooks/session-save.sh
```

---

## v7.1 — Integration Test Fixes (12 Findings from Batuta APP) (2026-02-22)

### Contexto

Se ejecuto la guia-batuta-app.md completa como prueba de integracion del ecosistema v7. Se construyo un dashboard Next.js 15 con 29 archivos, build exitoso, 6/6 escenarios PASS. El analisis identifico 12 hallazgos (F-001 a F-012) con score 18.8/35 (53.7%). Esta version corrige TODOS los gaps detectados.

### Hallazgos corregidos

| ID | Severidad | Titulo | Fix |
|----|----------|--------|-----|
| F-001 | CRITICO | setup.sh no configura proyecto target | +`setup_project()` + flag `--project <path>` |
| F-002 | CRITICO | setup.sh requiere pasos manuales post-init | `--project` crea .batuta/, session.md, prompt-log.jsonl, git init, .gitignore |
| F-003 | ALTO | sdd-init no maneja proyectos vacios | +seccion "Empty Project Handling": preguntar al usuario en vez de adivinar |
| F-004 | ALTO | sdd-explore no activa Skill Gap Detection | +Step 2.5: deteccion activa, pregunta al usuario, invoca ecosystem-creator |
| F-005 | MEDIO | explore.md sin template estandarizado | Renombrado exploration.md → explore.md, +tabla "Skill Gap Analysis" obligatoria |
| F-006 | ALTO | Execution Gate no recomienda Agent Teams | +Step 6 en gate FULL: Team Assessment (scope > 1 AND files > 4 → Level 3) |
| F-008 | MEDIO | Guia permite nombres con espacios | Carpeta `Batuta APP` → `batuta-app`, +IMPORTANTE sobre naming conventions |
| F-010 | MEDIO | sdd-archive no reconcilia desvios de design | +Step 1.5: comparar design.md vs archivos reales, +seccion "Implementation Notes" |
| F-011 | ALTO | sdd-verify no ejecuta build | +Step 3.5: Build Verification (Mandatory) con deteccion automatica |
| F-012 | MEDIO | sdd-verify no sugiere validacion runtime | +Step 4.5: Runtime Validation (Playwright para webapps, health check para APIs) |
| O.R.T.A. | ALTO | SDD skills no logean a prompt-log.jsonl | +seccion "Auto-logging for SDD Skills (Mandatory)" en CLAUDE.md |

> F-007 y F-009 eran hallazgos informativos (no requerian fix en codigo).

### Archivos modificados (7)

| Archivo | Cambio | Razon |
|---------|--------|-------|
| `skills/setup.sh` | +`setup_project()` ~60 lineas, +`--project` flag | F-001/F-002: configurar proyecto target directamente |
| `BatutaClaude/skills/sdd-init/SKILL.md` | +seccion "Empty Project Handling" | F-003: no adivinar stack en proyectos vacios |
| `BatutaClaude/skills/sdd-explore/SKILL.md` | +Step 2.5 Skill Gap Detection activa, explore.md estandarizado | F-004/F-005: deteccion activa + template obligatorio |
| `BatutaClaude/skills/sdd-verify/SKILL.md` | +Step 3.5 Build, +Step 4 tests, +Step 4.5 Runtime | F-011/F-012: build obligatorio + runtime sugerido |
| `BatutaClaude/skills/sdd-archive/SKILL.md` | +Step 1.5 Reconcile Design Deviations | F-010: reconciliar design.md vs implementacion |
| `BatutaClaude/CLAUDE.md` | +Team Assessment en gate, +Auto-logging mandate | F-006: gate recomienda nivel + O.R.T.A. logging |
| `guides/guia-batuta-app.md` | Naming conventions, carpeta sin espacios | F-008: nombres lowercase con guiones |

### Metricas

| Metrica | Antes (v7) | Despues (v7.1) |
|---------|-----------|---------------|
| Hallazgos abiertos | 12 (2 criticos, 3 altos) | 0 |
| setup.sh flags | --claude/--sync/--all/--verify | +--project |
| Gate steps (FULL) | 5 | 6 (+Team Assessment) |
| SDD verify steps | 4 | 6.5 (+Build, +Runtime) |
| SDD archive steps | 4 | 5 (+Reconcile Deviations) |
| SDD explore steps | 4 | 5 (+Skill Gap Detection activa) |
| Auto-logging mandate | No (implicito) | Si (explicito en CLAUDE.md) |

### Rollback

Para revertir v7.1 y volver a v7:
```bash
git checkout HEAD~1 -- skills/setup.sh BatutaClaude/skills/sdd-init/SKILL.md \
  BatutaClaude/skills/sdd-explore/SKILL.md BatutaClaude/skills/sdd-verify/SKILL.md \
  BatutaClaude/skills/sdd-archive/SKILL.md BatutaClaude/CLAUDE.md guides/guia-batuta-app.md
```

---

## v7 — Agent Teams + 3-Level Execution Model (2026-02-22)

### Contexto

Claude Code lanzo una feature experimental llamada **Agent Teams**: sesiones REALES de Claude Code que trabajan en paralelo, cada una con su propio context window, comunicandose via mailbox y coordinandose con un task list compartido.

Se analizo la alineacion con el ecosistema Batuta y se diseno un modelo hibrido de 3 niveles.

### Decisiones arquitecturales

1. **Modelo hibrido de 3 niveles (no reemplazo, capa adicional)**:
   - Nivel 1 — Solo session (como antes): bug fix, pregunta, edicion simple. Sin overhead.
   - Nivel 2 — Subagents (Task tool, como antes): investigacion, verificacion, SDD phases individuales.
   - Nivel 3 — Agent Teams (NUEVO): feature multi-modulo, debugging complejo, SDD pipeline completo.

2. **Scope agents evolucionan, no se reemplazan**: Los `.md` ahora sirven dual-purpose — como referencia (niveles 1-2) y como spawn prompts (nivel 3). Se agrego seccion "Agent Team: Spawn Prompt" + "Team Context" a cada scope agent.

3. **O.R.T.A. via Hooks**: Se usan los hooks nativos de Agent Teams (`TeammateIdle`, `TaskCompleted`) para centralizar logging y quality gates. SOLO el lead escribe a `prompt-log.jsonl` durante teams (evita conflictos multi-writer).

4. **Plan Approval = Execution Gate para teams**: El plan approval de Agent Teams mapea al Execution Gate de Batuta a nivel de teammate.

5. **In-process mode only**: Windows/Git Bash no soporta split panes (requiere tmux/iTerm2). Se usa modo in-process con Shift+Down para navegar.

6. **Team event como 6to tipo de evento**: `prompt-log.jsonl` ahora registra eventos `team` con sub-eventos: `team_created`, `teammate_idle`, `task_completed`, `team_closed`.

7. **SDD Pipeline como Task List**: Las fases SDD mapean a tasks con dependencias — spec y design corren en paralelo, apply batches corren en paralelo.

8. **Dream Team on-the-go**: Skill Gap Detection + Auto-Update SPO = el roster de skills crece con cada proyecto. Cada nuevo proyecto agrega skills que quedan disponibles para futuros proyectos.

### Archivos nuevos (3)

| Archivo | Proposito |
|---------|-----------|
| `BatutaClaude/skills/team-orchestrator/SKILL.md` | Skill de orquestacion: decision tree (solo → subagent → team), spawn prompts, 4 patrones de composicion, lifecycle, metricas |
| `skills/hooks/orta-teammate-idle.sh` | Hook TeammateIdle: registra fin de teammate en prompt-log.jsonl |
| `skills/hooks/orta-task-gate.sh` | Hook TaskCompleted: quality gate (placeholder para Scope Rule, tests, SDD artifacts) |

### Archivos modificados (14)

| Archivo | Cambio | Razon |
|---------|--------|-------|
| `BatutaClaude/settings.json` | +env feature flag, +teammateMode, +hooks TeammateIdle/TaskCompleted | Habilitar Agent Teams + integrar O.R.T.A. |
| `BatutaClaude/CLAUDE.md` | +seccion Team Routing (~12 lineas) | Decision tree de cuando crear team en el router principal |
| `BatutaClaude/VERSION` | 5.0.0 → 7.0.0 | Version bump |
| `BatutaClaude/agents/pipeline-agent.md` | +Spawn Prompt, +Team Context | Scope agent como spawn prompt para teammates |
| `BatutaClaude/agents/infra-agent.md` | +Spawn Prompt, +Team Context | Scope agent como spawn prompt para teammates |
| `BatutaClaude/agents/observability-agent.md` | +Spawn Prompt, +Team Context, +Team Event Format | Scope agent + schema de eventos team |
| `BatutaClaude/skills/prompt-tracker/SKILL.md` | +evento type `team` (6to tipo) | Registrar lifecycle de Agent Teams |
| `guides/guia-batuta-app.md` | +seccion Agent Teams + metricas rendimiento | Ejemplos nivel avanzado con metricas para validacion humana |
| `guides/guia-temporal-io-app.md` | +seccion Agent Teams + metricas rendimiento | Ejemplos nivel avanzado con metricas para validacion humana |
| `guides/guia-langchain-gmail-agent.md` | +seccion Agent Teams + metricas rendimiento | Ejemplos nivel avanzado con metricas para validacion humana |
| `README.md` + `README.es.md` | +Agent Teams en features, tree, Core Concepts, skills table, line counts, test counts | Documentar v7 completo |
| `about/arquitectura-diagrama.md` | ~195 → ~228 lineas, infra-agent 3→4 skills | Consistencia numerica |
| `about/arquitectura-para-no-tecnicos.md` | 13→14 recetas basicas | Consistencia numerica |
| `skills/setup_test.sh` | +6 tests v7, fix "Five"→"Six" event types, total 33 tests | Cobertura de tests v7 |

### Metricas

| Metrica | Valor |
|---------|-------|
| Skills activos | 14 (13 + team-orchestrator) |
| Scope agents | 3 (todos extendidos con spawn prompts) |
| Tipos de evento prompt-log | 6 (prompt, gate, correction, follow-up, closed, team) |
| Hooks O.R.T.A. | 2 (TeammateIdle, TaskCompleted) |
| Lineas CLAUDE.md | ~228 |
| Patrones de composicion de team | 4 (SDD Pipeline, Parallel Review, Investigation, Cross-Layer) |
| Niveles de ejecucion | 3 (solo, subagent, team) |
| Tests en setup_test.sh | 33 (27 anteriores + 6 v7) |

### Rollback

Para revertir v7 y volver a v6:
1. Eliminar `BatutaClaude/skills/team-orchestrator/` directorio
2. Eliminar `skills/hooks/` directorio
3. Revertir `settings.json` a version sin `env`, `teammateMode`, `hooks`
4. Eliminar seccion "Team Routing" de `CLAUDE.md` (lineas ~81-92)
5. Eliminar secciones "Agent Team: Spawn Prompt" y "Team Context" de los 3 scope agents
6. Revertir evento #6 `team` en `prompt-tracker/SKILL.md`
7. Revertir secciones "Nivel Avanzado: Agent Teams" de las 3 guias
8. Revertir cambios v7 en READMEs

---

## v6 — Quality Audit + Folder Reorganization + Bug Fixes (2026-02-21/22)

### Problema detectado
Segundo test de calidad post-v5 identifico 13 hallazgos en 5 dimensiones:

1. **Consistencia numerica rota**: CLAUDE.md tiene 216 lineas pero READMEs decian "~195" en 6+ lugares. CHANGELOG y READMEs tenian conteos incorrectos de planned skills (17 vs 16 real) y archivos nuevos (9 vs 7 real).
2. **Carpeta guides/ mezclada**: `guides/` contenia guias de ejecucion Y documentacion de arquitectura. Deberian estar separadas.
3. **Bug critico en setup.sh --sync**: El flag `--sync` no llamaba `sync_agents()`, causando inconsistencia con el menu interactivo opcion 2.
4. **batuta-update.md incompleto**: Usaba `--sync` (incompleto post-v5) en vez de `--all`. No mencionaba agents ni routing tables.
5. **Inconsistencias menores**: observability-agent field name no coincidia con template, sync_test.sh faltaba en READMEs.

### Solucion implementada

1. **Reorganizacion de carpetas**: `guides/` solo guias de ejecucion (3 archivos). Nueva carpeta `about/` para arquitectura y diseno (2 archivos movidos via `git mv`).
2. **Bug fix setup.sh**: `--sync` ahora llama `sync_claude; sync_agents` (consistente con menu interactivo).
3. **Consistencia numerica**: Todos los line counts actualizados a ~216, planned skills a 16, file counts corregidos en CHANGELOG.
4. **batuta-update.md reescrito**: Usa `--all`, tabla incluye agents y routing tables, reporte completo.
5. **READMEs actualizados**: Arboles de arquitectura con about/, qa/, sync_test.sh. Secciones Guides separadas de About.

### Archivos nuevos (4)

| Archivo | Proposito |
|---------|-----------|
| `about/` (directorio) | Documentacion de arquitectura y diseno (separada de guides/) |
| `qa/BatutaTestCalidadV6.md` | Reporte de test de calidad v6 (13 hallazgos) |
| `qa/LogCorrecciones-V6.md` | Log de correcciones v6 (integridad de guias y READMEs) |

### Archivos modificados (8)

| Archivo | Cambio | Razon |
|---------|--------|-------|
| `skills/setup.sh` | **Bug fix** (L471) | `--sync` no llamaba `sync_agents()` — inconsistente con menu interactivo |
| `BatutaClaude/CLAUDE.md` | Planned skills 17 → 16 | Conteo real es 16 |
| `BatutaClaude/commands/batuta-update.md` | **Reescrito** | --sync → --all, +agents/routing en tabla y reporte |
| `BatutaClaude/agents/observability-agent.md` | Field name alineado | `last_batuta_update` → **Last batuta update** (formato template) |
| `CHANGELOG-refactor.md` | Conteos corregidos | 9 → 7 archivos, ~195 → ~216 lineas |
| `README.md` | **Ampliado** | Tree con about/qa/, line counts, guides/about separados |
| `README.es.md` | **Ampliado** | Mismos cambios que README.md en espanol |

### Archivos movidos (2)

| Origen | Destino |
|--------|---------|
| `guides/arquitectura-diagrama.md` | `about/arquitectura-diagrama.md` |
| `guides/arquitectura-para-no-tecnicos.md` | `about/arquitectura-para-no-tecnicos.md` |

### Criterio de separacion

| Carpeta | Proposito | Contenido |
|---------|-----------|-----------|
| `guides/` | Guias de ejecucion paso a paso | Como usar el ecosistema (prompts, workflows, lifecycle) |
| `about/` | Arquitectura y diseno | Como funciona el ecosistema internamente (diagramas, analogias) |

### Como revertir

```bash
# 1. Mover archivos de vuelta a guides/
git mv about/arquitectura-diagrama.md guides/
git mv about/arquitectura-para-no-tecnicos.md guides/
rmdir about/

# 2. Revertir setup.sh bug fix
# En skills/setup.sh linea 471, cambiar:
#   --sync)     sync_claude; sync_agents ;;
# a:
#   --sync)     sync_claude ;;

# 3. Revertir READMEs, CLAUDE.md, CHANGELOG, batuta-update.md
git checkout HEAD~1 -- README.md README.es.md BatutaClaude/CLAUDE.md CHANGELOG-refactor.md BatutaClaude/commands/batuta-update.md BatutaClaude/agents/observability-agent.md
```

### Metricas antes/despues

| Metrica | V5 post-fix | V6 post-fix |
|---------|------------|-------------|
| Hallazgos abiertos | 5 (aceptados) | 2 (aceptados, historicos) |
| Line count accuracy | Incorrecto (6+ lugares) | Correcto en todos los archivos |
| Folder organization | Mezclada (guides/) | Separada (guides/ + about/) |
| setup.sh --sync | Incompleto (sin agents) | Completo (skills + agents) |
| batuta-update completeness | Parcial (sin agents/sync) | Completo (--all + agents + routing) |
| Puntuacion promedio | 6.2/10 | 9.0/10 |

---

## v5 — Mix-of-Experts + Execution Gate + Standardized Frontmatter + Skill-Sync (2026-02-21)

### Problema detectado
Tres gaps identificados en v4, validados por analisis del ecosistema Prowler (prowler-cloud/prowler):

1. **O.R.T.A. sin capa preventiva**: El prompt-tracker es REACTIVO — registra DESPUES de que algo sale mal. La regla "just do it → PROCEED" permite saltar validacion. Auto-supervision debe significar que el agente se supervisa A SI MISMO antes de actuar.
2. **Frontmatter inconsistente en skills**: Solo 2 de 12 skills tenian `allowed-tools`. Ninguno tenia `scope` ni `auto_invoke`. Prowler tiene los tres campos en TODOS sus 31 skills.
3. **Agente principal sobrecargado**: CLAUDE.md contiene una tabla auto-invoke de 14 filas que el agente principal interpreta manualmente. No hay sub-agents para scopes fuera de SDD (infra, observability).

### Solucion implementada (4 pilares)

1. **Mix-of-Experts (MoE)**: Agente principal como router puro. 3 scope agents especializados: pipeline (SDD), infra (file org, ecosystem, skill-sync), observability (tracking, sessions).
2. **Execution Gate**: Pre-validacion obligatoria antes de cualquier cambio de codigo. Dos modos: LIGHT (1-line) y FULL (location plan + impact + SDD/skill compliance). Tambien es el punto de routing — clasifica scope y delega.
3. **Frontmatter estandarizado**: `scope`, `auto_invoke`, `allowed-tools` en TODOS los 13 skills. El scope es la clave de routing.
4. **Skill-Sync automatizado**: Script lee frontmatters de TODOS los SKILL.md → genera tablas en CLAUDE.md y scope agents automaticamente. Redundancia sin depender del usuario.

### Archivos nuevos (7)

| Archivo | Proposito |
|---------|-----------|
| `BatutaClaude/agents/pipeline-agent.md` | Scope agent: SDD Pipeline (9 skills) |
| `BatutaClaude/agents/infra-agent.md` | Scope agent: Infraestructura (3 skills) |
| `BatutaClaude/agents/observability-agent.md` | Scope agent: O.R.T.A. (1 skill) |
| `BatutaClaude/skills/skill-sync/SKILL.md` | Skill de sincronizacion de routing tables |
| `BatutaClaude/skills/skill-sync/assets/sync.sh` | Script de sincronizacion (~270 lineas) |
| `BatutaClaude/skills/skill-sync/assets/sync_test.sh` | Suite de tests para sync.sh (18 tests) |
| `BatutaClaude/commands/batuta-sync-skills.md` | Slash command /batuta:sync-skills |

### Archivos modificados (~25)

| Archivo | Cambio | Razon |
|---------|--------|-------|
| `BatutaClaude/CLAUDE.md` | **Reescrito** (~239 → ~216 lineas) | Router MoE: Scope Routing Table + Execution Gate + AUTO-GENERATED skills table. Removido: Follow Questions, auto-invoke manual, contenido movido a scope agents |
| 12 x `BatutaClaude/skills/*/SKILL.md` | **Frontmatter** | Agregados `metadata.scope`, `metadata.auto_invoke`, `allowed-tools` |
| `BatutaClaude/skills/ecosystem-creator/SKILL.md` | **Actualizado** | Templates con scope/auto_invoke, Registration Checklist con skill-sync |
| `BatutaClaude/skills/ecosystem-creator/assets/skill-template.md` | **Actualizado** | Campos scope y auto_invoke en metadata |
| `BatutaClaude/skills/prompt-tracker/SKILL.md` | **Ampliado** | 5to evento "gate", metricas de gate compliance, patrones y recomendaciones |
| `BatutaClaude/skills/sdd-apply/SKILL.md` | **Actualizado** | Step 0: verificacion de Execution Gate |
| `BatutaClaude/commands/batuta-analyze-prompts.md` | **Actualizado** | Metricas de gate compliance y distribucion de scopes |
| `skills/setup.sh` | **Ampliado** | +sync_agents(), +run_skill_sync(), flujo --all actualizado, verify con agents/skill-sync |
| `guides/arquitectura-diagrama.md` | **Ampliado** | +3 diagramas MoE, actualizado lazy loading 3 niveles, prompt tracking con gate |
| `guides/arquitectura-para-no-tecnicos.md` | **Ampliado** | +3 secciones (Jefes de Area, Checklist, Inventario), roles actualizados |
| `README.md` + `README.es.md` | **Actualizados** | v5 MoE + Gate + Skill-Sync docs, conteo 13 skills + 3 agents |

### Analisis Prowler como referencia

Se analizo el repositorio prowler-cloud/prowler (31 skills, multi-AGENTS.md). Patrones adoptados:
- `metadata.scope` en todos los skills → routing key
- `metadata.auto_invoke` string o lista → trigger documentation
- `allowed-tools` obligatorio → tool boundary enforcement
- skill-sync script → redundancia automatica del ecosistema

Patrones NO adoptados (Batuta tiene alternativas):
- Multi-AGENTS.md → Batuta usa `agents/` directory con scope agents
- Scope como path directo → Batuta usa scope como routing key a agent file

### Como revertir

```bash
# 1. Restaurar CLAUDE.md v4
git checkout HEAD~1 -- BatutaClaude/CLAUDE.md

# 2. Eliminar scope agents
rm -rf BatutaClaude/agents/

# 3. Eliminar skill-sync
rm -rf BatutaClaude/skills/skill-sync/

# 4. Eliminar comando
rm BatutaClaude/commands/batuta-sync-skills.md

# 5. Revertir frontmatters (remover scope, auto_invoke de metadata en cada SKILL.md)
# Nota: allowed-tools ya existia en 2 skills, no removerlo de esos

# 6. Revertir setup.sh, guides, READMEs
git checkout HEAD~1 -- skills/setup.sh guides/ README.md README.es.md
```

### Metricas antes/despues

| Metrica | v4 | v5 |
|---------|----|----|
| CLAUDE.md lineas | ~239 | ~216 |
| Skills con scope | 0 | 13 |
| Skills con auto_invoke | 0 | 13 |
| Skills con allowed-tools | 2 | 13 |
| Scope agents | 0 | 3 |
| Total skills | 12 | 13 (+ skill-sync) |
| Routing tables | Manual | Auto-generadas |
| Pre-validacion (Gate) | No | Si (LIGHT/FULL) |
| Lazy loading niveles | 2 (CLAUDE.md → skill) | 3 (CLAUDE.md → agent → skill) |

---

## v4 — Continuidad de Sesion + Prompt Satisfaction Tracker + Pipeline de Aprendizaje (2026-02-21)

### Problema detectado
Dos gaps criticos tras v3:
1. **Sin continuidad de sesion**: Cada nueva conversacion empieza de cero. Claude no recuerda decisiones, estado SDD, ni convenciones descubiertas en sesiones anteriores.
2. **Sin feedback loop**: Cuando un prompt genera un resultado incorrecto y el usuario corrige, esa leccion se pierde. No hay mecanismo para mejorar el comportamiento del agente basado en la experiencia real.

### Solucion implementada
Sistema de tres capas alineado con el framework O.R.T.A.:

1. **Directorio `.batuta/` por proyecto** — Archivos git-tracked para continuidad de sesion (`session.md`) y tracking de satisfaccion (`prompt-log.jsonl`).
2. **Skill `prompt-tracker`** — Motor de observabilidad que registra interacciones en formato JSONL y analiza patrones.
3. **Pipeline de analisis** — Comando `/batuta:analyze-prompts` que computa metricas y genera recomendaciones para mejorar reglas del agente, guia de prompting, y sub-agentes.
4. **Follow Questions** — Reglas de depuracion de prompts antes de ejecutar (tabla de decision). *(Reemplazado por Execution Gate en v5)*
5. **Separacion de preocupaciones en `/batuta-update`** — Comportamiento global (skills, CLAUDE.md) se actualiza; contexto local (`.batuta/`) nunca se toca.

### Archivos nuevos

| Archivo | Proposito |
|---------|-----------|
| `BatutaClaude/skills/prompt-tracker/SKILL.md` | Skill de observabilidad: logging JSONL + modo de analisis |
| `BatutaClaude/skills/prompt-tracker/assets/session-template.md` | Template para `.batuta/session.md` |
| `BatutaClaude/commands/batuta-analyze-prompts.md` | Slash command para analizar el log de satisfaccion |

### Archivos modificados

| Archivo | Cambio | Razon |
|---------|--------|-------|
| `BatutaClaude/CLAUDE.md` | **+34 lineas** (~193 → ~230) | Agregadas secciones: Follow Questions, Prompt Tracking (O.R.T.A.), Session Continuity. Registros en auto-invoke table, Available Skills, SDD Commands |
| `BatutaClaude/commands/batuta-init.md` | **ACTUALIZADO** | Agrega Step 2.5: crear `.batuta/` con session.md y prompt-log.jsonl |
| `BatutaClaude/commands/batuta-update.md` | **ACTUALIZADO** | Agrega tabla de separacion: que se actualiza (global) vs que se preserva (local) |
| `skills/setup_test.sh` | **AMPLIADO** | 5 tests nuevos: prompt-tracker skill, session template, analyze command, v4 sections, sync |
| `CHANGELOG-refactor.md` | **AMPLIADO** | Seccion v4 (este documento) |
| `README.md` | **ACTUALIZADO** | Skills 12 → 13, nuevo concepto Prompt Tracking, nuevo comando |
| `README.es.md` | **ACTUALIZADO** | Mismos cambios que README.md en espanol |
| `guides/arquitectura-diagrama.md` | **ACTUALIZADO** | +prompt-tracker en Vista General, +/batuta:analyze-prompts en Commands, +2 diagramas Mermaid (Session Continuity, Prompt Tracking), +.batuta/ en Flujo Completo, ~170→~230 lineas |
| `guides/arquitectura-para-no-tecnicos.md` | **ACTUALIZADO** | 12→13 recetas, +2 secciones (Cuaderno del Turno, Inspector de Calidad), +/batuta:analyze-prompts en Commands, +roles (bitacora, inspector), +FAQ sesion, FAQ O.R.T.A. ampliada |
| `guides/guia-batuta-app.md` | **ACTUALIZADO** | FAQ sesion automatica con session.md, +.batuta/ en Slide 3, +Extra C (analyze-prompts), Extra C→D renombrado, resumen visual actualizado |
| `guides/guia-temporal-io-app.md` | **ACTUALIZADO** | Nota sobre .batuta/ y continuidad de sesion en Slide 2 |
| `guides/guia-langchain-gmail-agent.md` | **ACTUALIZADO** | Nota sobre .batuta/ y continuidad de sesion en Slide 2 |

### Convencion `.batuta/`

```
proyecto/
  .batuta/
    session.md            # Contexto de sesion (Claude lo lee al iniciar, lo actualiza al terminar trabajo significativo)
    prompt-log.jsonl      # Log de satisfaccion (append-only, formato JSONL)
    analysis-report.md    # Generado por /batuta:analyze-prompts
    prompting-guide.md    # Generado por /batuta:analyze-prompts (guia para el usuario)
```

### Formato del Log JSONL

Cuatro tipos de evento: `prompt`, `correction`, `follow-up`, `closed`.
Seis tipos de correccion: `missing-requirement`, `wrong-approach`, `style-mismatch`, `scope-error`, `misunderstanding`, `other`.

### Como revertir si algo falla

1. **Restaurar CLAUDE.md pre-v4**: `git checkout HEAD~1 -- BatutaClaude/CLAUDE.md`
2. **Eliminar prompt-tracker**: `rm -rf BatutaClaude/skills/prompt-tracker/`
3. **Eliminar comando analyze**: `rm BatutaClaude/commands/batuta-analyze-prompts.md`
4. **Restaurar batuta-init/update**: `git checkout HEAD~1 -- BatutaClaude/commands/`
5. **Restaurar tests**: `git checkout HEAD~1 -- skills/setup_test.sh`

### Metricas

| Metrica | Antes (v3) | Despues (v4) |
|---------|-----------|-------------|
| Lineas que Claude lee al iniciar | ~193 | ~230 |
| Skills de infraestructura | 12 | 13 (+prompt-tracker) |
| Comandos slash | 2 (init, update) | 3 (+analyze-prompts) |
| Archivos por proyecto | CLAUDE.md + openspec/ | CLAUDE.md + openspec/ + .batuta/ |
| Feedback loop | Ninguno | JSONL log + analisis + recomendaciones |

---

## v3 — Eliminacion de AGENTS.md, CLAUDE.md como unico punto de entrada (2026-02-21)

### Problema detectado
`AGENTS.md` era declarado como "Single Source of Truth", pero Claude Code solo lee `CLAUDE.md` automaticamente. Esto significaba que:
1. `AGENTS.md` era un archivo muerto a menos que `CLAUDE.md` lo referenciara explicitamente
2. `setup.sh` combinaba ambos archivos en un CLAUDE.md gigante (~400+ lineas)
3. Claude cargaba todo al iniciar cada conversacion, desperdiciando tokens en contenido irrelevante para la tarea actual

### Solucion implementada
Patron **lazy-loading**: `CLAUDE.md` es el unico archivo que Claude lee, contiene solo lo esencial (~170 lineas), y los skills se cargan bajo demanda.

### Archivos modificados

| Archivo | Cambio | Razon |
|---------|--------|-------|
| `AGENTS.md` | **ELIMINADO** | Su contenido se distribuyo entre CLAUDE.md (resumen) y skills individuales (detalle) |
| `BatutaClaude/CLAUDE.md` | **REESCRITO** | Ahora es el unico punto de entrada. Contiene: personalidad, reglas, Scope Rule, Skill Gap Detection, Auto-Update SPO, tabla de routing de skills, comandos SDD, lista de skills disponibles |
| `skills/setup.sh` | **SIMPLIFICADO** | Ya no combina archivos. `--claude` hace un `cp` directo. `--verify` verifica que AGENTS.md no exista |
| `skills/setup_test.sh` | **ACTUALIZADO** | Tests adaptados a la nueva arquitectura sin AGENTS.md |
| `BatutaClaude/commands/batuta-init.md` | **ACTUALIZADO** | Ya no copia AGENTS.md. Solo copia CLAUDE.md |
| `BatutaClaude/commands/batuta-update.md` | **ACTUALIZADO** | Ya no menciona AGENTS.md. Solo actualiza CLAUDE.md y skills |
| `guides/guia-batuta-app.md` | **ACTUALIZADO** | Todas las referencias a AGENTS.md removidas |
| `guides/guia-temporal-io-app.md` | **ACTUALIZADO** | Referencias a AGENTS.md removidas |
| `guides/guia-langchain-gmail-agent.md` | **ACTUALIZADO** | Referencias a AGENTS.md removidas |
| `guides/arquitectura-diagrama.md` | **REESCRITO** | Diagramas actualizados: AGENTS.md ya no aparece, CLAUDE.md es el centro |
| `guides/arquitectura-para-no-tecnicos.md` | **REESCRITO** | Analogia actualizada: "Libro de Recetas" ahora es CLAUDE.md |
| `README.md` | **ACTUALIZADO** | Arquitectura y explicaciones sin AGENTS.md |
| `README.es.md` | **ACTUALIZADO** | Arquitectura y explicaciones sin AGENTS.md |

### Donde fue a parar el contenido de AGENTS.md

| Seccion de AGENTS.md | Nuevo hogar | Notas |
|----------------------|-------------|-------|
| Skills tables (infrastructure) | `CLAUDE.md` → "Available Skills" | Solo tabla resumen, no detalle completo |
| Skills tables (project/planned) | `CLAUDE.md` → "Planned project skills" | Lista compacta por categoria |
| Scope Rule | `CLAUDE.md` → "Scope Rule" section | Quick-reference. Detalle en `skills/scope-rule/SKILL.md` |
| Skill Gap Detection | `CLAUDE.md` → "Skill Gap Detection" section | Completo con prompt template |
| Auto-invoke table | `CLAUDE.md` → "Auto-invoke table" | Misma tabla, mismos paths |
| Auto-Update SPO | `CLAUDE.md` → "Ecosystem Auto-Update" | Resumen. Detalle en proceso de propagacion |
| SDD Orchestrator | `CLAUDE.md` → "SDD Commands" + "SDD Orchestrator Rules" | Reglas compactas + tabla de comandos |
| Sub-Agent Output Contract | `CLAUDE.md` → "Sub-Agent Output Contract" | Una linea compacta |
| Contributing / Extending | Eliminado de CLAUDE.md, vive en README.md | Claude no necesita saber como contribuir |
| Skill Structure diagram | Eliminado de CLAUDE.md, vive en README.md | Claude no necesita el tree diagram |

### Como revertir si algo falla

1. **Restaurar AGENTS.md**: `git checkout HEAD~1 -- AGENTS.md`
2. **Restaurar CLAUDE.md antiguo**: `git checkout HEAD~1 -- BatutaClaude/CLAUDE.md`
3. **Restaurar setup.sh antiguo**: `git checkout HEAD~1 -- skills/setup.sh`
4. **Regenerar CLAUDE.md combinado**: `./skills/setup.sh --claude` (version antigua combina los archivos)

### Metricas

| Metrica | Antes (v2) | Despues (v3) |
|---------|-----------|-------------|
| Lineas que Claude lee al iniciar | ~400+ (CLAUDE.md combinado) | ~170 (CLAUDE.md lean) |
| Archivos de configuracion | 2 (AGENTS.md + CLAUDE.md) | 1 (CLAUDE.md) |
| Paso de setup.sh --claude | Concatenar 2 archivos | Copiar 1 archivo |
| Skills cargados al iniciar | Todos (inline en AGENTS.md) | Ninguno (lazy-load on demand) |

---

## v2 — Simplificacion a Claude Code Only + Scope Rule + Auto-Update SPO (2026-02-21)

### Cambios principales
- Removidas todas las referencias a Gemini, Copilot, Codex, OpenCode del flujo principal
- Creado `replicate-platform.sh` para replicacion futura a otras plataformas
- Agregado skill `scope-rule` para organizacion de archivos
- Agregado Auto-Update SPO para propagacion de skills entre proyectos
- `setup.sh` simplificado a Claude Code only (--claude, --sync, --all, --verify)

### Archivos afectados
- `AGENTS.md` — Reescrito (Claude-only + Scope Rule + SPO)
- `BatutaClaude/CLAUDE.md` — Reescrito (Claude-only + Scope Rule awareness)
- `skills/setup.sh` — Reescrito (Claude-only)
- `skills/replicate-platform.sh` — NUEVO
- `BatutaClaude/skills/scope-rule/SKILL.md` — NUEVO
- `README.md`, `README.es.md` — Reescritos
- `skills/setup_test.sh` — Actualizado

---

## v1 — Bootstrap inicial del ecosistema (2026-02-21)

### Creacion
- 26 archivos, 5,404 lineas
- 12 skills de infraestructura (ecosystem-creator + 9 SDD + scope-rule)
- Pipeline SDD completo (9 fases)
- Skill Gap Detection
- Mirror OpenCode
- setup.sh multi-plataforma

---

> **Nota**: Este archivo es para humanos, no para Claude. Claude lee CLAUDE.md.
