# Changelog de Refactorizacion — Batuta.Dots

> Documento de traza. Registra CADA modificacion arquitectural, POR QUE se hizo, y como revertirla si es necesario.

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
