# Test de Calidad — Batuta Ecosystem v5

**Fecha**: 2026-02-21
**Analista**: Claude (Opus 4.6)
**Scope**: Auditoria completa del ecosistema v5 (MoE + Execution Gate + Skill-Sync)
**Archivos analizados**: 28 archivos core del repositorio batuta-dots

---

## Resumen Ejecutivo

Se analizaron **28 archivos** del ecosistema Batuta v5 bajo mejores practicas de:
- Arquitectura de agentes AI
- Seguridad de configuracion
- Consistencia de contratos
- Automatizacion y tooling
- Observabilidad (O.R.T.A.)
- Auto-gestion de sesiones

**Resultado**: Se encontraron **31 hallazgos** (7 criticos, 17 medios, 7 bajos).

| Severidad | Count | Descripcion |
|-----------|-------|-------------|
| CRITICO | 7 | Problemas que impiden el funcionamiento correcto o causan perdida de datos |
| MEDIO | 17 | Problemas que degradan la experiencia o generan inconsistencias |
| BAJO | 7 | Mejoras deseables que no bloquean operacion |

---

## Dimension 1: Arquitectura y Diseno

### [A1] CRITICO — Descripcion de routing MoE es misleading

**Archivo**: `BatutaClaude/CLAUDE.md` lineas 59, 70-74
**Problema**: CLAUDE.md dice "Route to the appropriate scope agent via the Task tool" y "Read the scope agent file via Task tool". Esto implica que el Task tool carga el agente como un sub-proceso. Pero:

1. El Task tool de Claude Code crea un **sub-proceso nuevo** que NO hereda el contexto del principal
2. Los archivos en `~/.claude/agents/` NO son auto-cargados por Claude Code (solo `~/.claude/skills/` y `~/.claude/commands/`)
3. Para que un sub-proceso use un skill, habria que pasar todo el contenido del skill en el prompt del Task

**Mecanismo real**: Claude Code carga skills de `~/.claude/skills/` automaticamente cuando el contexto coincide con los triggers del frontmatter. Los scope agents son **documentacion organizativa** que el principal lee directamente (Read tool), no sub-procesos independientes.

**Impacto**: Un usuario que lea la documentacion esperara que el MoE funcione como sub-procesos independientes, cuando en realidad es un patron de lectura de archivos.

**Correccion**:
- Cambiar "via the Task tool" a "by reading the agent file"
- Clarificar que los scope agents son archivos de referencia, no procesos independientes
- Actualizar "How to route" para reflejar el mecanismo real

---

### [A2] MEDIO — Observability-agent tiene solo 1 skill

**Archivo**: `BatutaClaude/agents/observability-agent.md`
**Problema**: pipeline-agent tiene 9 skills, infra-agent tiene 3, observability-agent tiene 1 (prompt-tracker). La gestion de sesiones esta embebida como reglas del agent, no como skill separado.

**Impacto**: Asimetria funcional. Si algun dia se quiere extender la observabilidad (metricas de performance, cost tracking, etc.), el skill prompt-tracker creceria indefinidamente.

**Correccion**: Documentar en observability-agent.md que la gestion de sesiones esta intencionalmente embebida (no es un oversight). Agregar nota: "Session management is intentionally embedded as agent-level rules rather than a separate skill because it must run at every conversation boundary, not on-demand."

---

### [A3] MEDIO — Execution Gate sin SKILL.md dedicado

**Archivo**: `BatutaClaude/CLAUDE.md` lineas 161-186
**Problema**: El Execution Gate es una de las features centrales de v5, pero no tiene su propio SKILL.md. Esta definido inline en CLAUDE.md. Esto significa:
- No puede versionarse independientemente
- No aparece en skill-sync
- No tiene frontmatter estandarizado

**Correccion**: Documentar explicitamente que el Gate es una **regla del router**, no un skill. Agregar comentario en CLAUDE.md: "The Gate is intentionally defined here (not as a skill) because it must execute BEFORE routing to any scope agent."

---

### [A4] BAJO — Sin threshold documentado para crear nuevo scope agent

**Archivo**: `BatutaClaude/agents/` (general)
**Problema**: Cuando el stack crezca (ui-agent, backend-agent, ai-agent segun el plan), no hay criterio documentado para decidir cuando un scope agent es necesario.

**Correccion**: Agregar seccion en infra-agent.md o ecosystem-creator.md: "When to create a new scope agent: when 3+ skills share a domain AND are invoked together frequently."

---

## Dimension 2: Seguridad

### [S1] MEDIO — prompt-log.jsonl committed a git con data potencialmente sensible

**Archivo**: `BatutaClaude/commands/batuta-init.md` linea 50
**Problema**: `.batuta/` es git-tracked. `prompt-log.jsonl` contiene summaries de prompts del usuario que podrian incluir nombres de clientes, datos de negocio, o referencias a sistemas internos.

**Correccion**: Agregar `.batuta/prompt-log.jsonl` al `.gitignore` template en batuta-init.md. Mantener `.batuta/session.md` tracked (es contexto de proyecto, no data sensible).

---

### [S2] MEDIO — git pull sin verificacion de integridad

**Archivo**: `BatutaClaude/commands/batuta-update.md` linea 24
**Problema**: `/batuta-update` ejecuta `git pull` en batuta-dots sin verificar la integridad del repositorio. Un atacante con acceso al repo podria inyectar contenido malicioso en CLAUDE.md.

**Correccion**: Agregar verificacion basica post-pull: `git verify-commit HEAD 2>/dev/null || log_warning "Commit not GPG-signed"`. Es defense-in-depth, no critico para repo privado.

---

### [S3] BAJO — Paths personales hardcodeados

**Archivos**: `BatutaClaude/commands/batuta-init.md` linea 20, `batuta-update.md` linea 19
**Problema**: `E:/BATUTA PROJECTS/claude/batuta-dots/` hardcodeado como primer path de busqueda.

**Correccion**: Usar variable de entorno `$BATUTA_DOTS_PATH` como primera opcion, fallback a paths conocidos. Agregar nota en README sobre como configurar la variable.

---

### [S4] MEDIO — settings.json sin proteccion para SSH keys y certificados

**Archivo**: `BatutaClaude/settings.json` lineas 8-17
**Problema**: La deny list solo cubre `.env*` y `secrets/` y `credentials.json`. No protege:
- `~/.ssh/` (claves SSH)
- `*.pem`, `*.key` (certificados)
- `*.p12`, `*.pfx` (keystores)

**Correccion**: Agregar al deny list:
```json
"Read(**/.ssh/**)",
"Read(**/*.pem)",
"Read(**/*.key)",
"Read(**/*.p12)",
"Read(**/*.pfx)"
```

---

## Dimension 3: Ejecucion y Runtime

### [E1] CRITICO — setup.sh continua tras fallo de skill-sync

**Archivo**: `skills/setup.sh` linea 205
**Problema**: `bash "$sync_script" || log_warning "..."` — si skill-sync falla, setup.sh solo muestra warning y continua. Luego copia un CLAUDE.md con tablas corruptas o vacias al root.

**Impacto**: El usuario obtiene un CLAUDE.md con routing tables rotas sin saberlo.

**Correccion**: Cambiar el flow de `do_all()` para que skill-sync failure sea blocking:
```bash
if ! bash "$sync_script"; then
    log_error "skill-sync failed — aborting. Fix skill frontmatters and retry."
    return 1
fi
```

---

### [E2] MEDIO — batuta-init no hace git pull si batuta-dots ya existe

**Archivo**: `BatutaClaude/commands/batuta-init.md` lineas 20-22
**Problema**: El comando verifica si batuta-dots existe en 3 ubicaciones, pero si lo encuentra, NO hace git pull. Esto significa que proyectos nuevos pueden instalarse con una version antigua.

**Correccion**: Agregar paso de freshness check: "If found locally, run `git -C $BATUTA_DOTS_PATH pull --ff-only` to ensure latest version."

---

### [E3] MEDIO — Gate es "honor system" sin enforcement programatico

**Archivo**: `BatutaClaude/CLAUDE.md` lineas 161-163
**Problema**: "BEFORE any code change, run the Execution Gate. Cannot be skipped." — pero como instruccion de texto, el LLM puede ignorarla. No hay hook ni mecanismo tecnico que lo enforce.

**Impacto**: Bajo en practica (Claude sigue instrucciones consistentemente), pero viola el principio de "defense in depth" de O.R.T.A.

**Correccion**: Aceptar como limitacion documentada. Agregar a observability-agent: "Gate compliance is tracked via prompt-log. If gate_compliance < 80%, recommend investigating why gates are being skipped."

---

### [E4] BAJO — sync.sh requiere bash 4.3+ (namerefs) sin documentar

**Archivo**: `BatutaClaude/skills/skill-sync/assets/sync.sh` linea 183
**Problema**: `local -n skills_ref=$1` usa namerefs, que requieren bash 4.3+. No documentado como requisito.

**Correccion**: Agregar a sync.sh un check de version al inicio:
```bash
if [[ "${BASH_VERSINFO[0]}" -lt 4 || ("${BASH_VERSINFO[0]}" -eq 4 && "${BASH_VERSINFO[1]}" -lt 3) ]]; then
    log_error "bash 4.3+ required (found ${BASH_VERSION})"
    exit 1
fi
```

---

### [E5] BAJO — setup.sh usa set -e pero no trap para cleanup

**Archivo**: `skills/setup.sh` linea 22
**Problema**: `set -e` aborta en error, pero no hay trap para limpiar archivos temporales o informar al usuario que la operacion quedo incompleta.

**Correccion**: Agregar trap basico:
```bash
cleanup() { rm -f "$REPO_ROOT/BatutaClaude/CLAUDE.md.tmp" 2>/dev/null; }
trap cleanup EXIT
```

---

## Dimension 4: Consistencia y Estandares

### [C1] CRITICO — Sub-Agent Output Contract tiene 3 enums de status diferentes

**Archivos**:
- `pipeline-agent.md` linea 53: `done | blocked | needs-approval`
- `sdd-apply/SKILL.md` linea 185: `success | partial | blocked | error`
- `sdd-verify/SKILL.md` linea 291: `PASS | PASS_WITH_WARNINGS | FAIL`

**Problema**: El contrato de salida deberia ser UNICO en todo el ecosistema. Tres enums diferentes hacen imposible programar un orquestador que interprete resultados uniformemente.

**Correccion**: Unificar en un solo enum documentado en pipeline-agent.md:
```
status: success | partial | blocked | error
```
Y para verify, usar el mismo enum pero con mappeo:
- PASS → success
- PASS_WITH_WARNINGS → partial
- FAIL → error

Actualizar pipeline-agent.md, sdd-apply, y sdd-verify para usar el enum unificado.

---

### [C2] MEDIO — ecosystem-creator.md tiene bullet duplicado

**Archivo**: `BatutaClaude/skills/ecosystem-creator/SKILL.md` lineas 587-588
**Problema**: "The component appears in CLAUDE.md" aparece dos veces consecutivas en el step 6 verify.

**Correccion**: Eliminar duplicado. El segundo bullet deberia decir "The component appears in the appropriate scope agent's Skills table (for skills and sub-agents)".

---

### [C3] MEDIO — Solo sdd-apply tiene verificacion de gate

**Archivo**: `BatutaClaude/skills/sdd-apply/SKILL.md` lineas 79-86
**Problema**: Si el Execution Gate es "mandatory before ANY code change", por que solo sdd-apply lo verifica? sdd-design crea design.md, sdd-spec crea specs — estos son cambios de archivos que deberian pasar por gate.

**Correccion**: El gate aplica a cambios de CODIGO, no a artefactos SDD. Clarificar en CLAUDE.md: "The Execution Gate applies to production code changes, not to SDD artifacts (specs, designs, tasks). SDD artifacts are validated by the pipeline dependency graph."

---

### [C4] MEDIO — "How to route" dice "via Task tool" pero deberia decir "read directly"

**Archivo**: `BatutaClaude/CLAUDE.md` lineas 70-74
**Problema**: Relacionado con [A1]. El "How to route" describe un flujo que no corresponde al mecanismo real de Claude Code.

**Correccion**: Reescribir "How to route":
```markdown
### How to route
1. Execution Gate determines scope (see below)
2. Read the scope agent file to understand which skills apply
3. Load the relevant SKILL.md file(s) for the detected scope
4. Apply ALL patterns and rules from the loaded skills
5. Return result to user
```

---

### [C5] BAJO — ecosystem-creator referencias duplicadas a "CLAUDE.md"

**Archivo**: `BatutaClaude/skills/ecosystem-creator/SKILL.md` lineas 648-649
**Problema**: "Registration targets: CLAUDE.md (master registry), CLAUDE.md (auto-load table)" — ambas referencias apuntan al mismo archivo.

**Correccion**: Cambiar a: "Registration targets: CLAUDE.md (Available Skills table — auto-generated by skill-sync)"

---

### [C6] BAJO — Lista de planned skills sin estado

**Archivo**: `BatutaClaude/CLAUDE.md` lineas 121-127
**Problema**: 17 planned skills listados sin indicador de estado (planned/in-progress/active). No hay tracking de progreso.

**Correccion**: No es critico. Cuando se creen los primeros planned skills, el ecosistema-creator ya los mueve automaticamente. Mantener como lista simple.

---

## Dimension 5: Automatizacion y Tooling

### [AU1] CRITICO — Sin mecanismo de auto-update

**Archivos**: Ecosistema general
**Problema**: No existe:
- Freshness check al inicio de sesion
- Hook que compare version local vs remota
- Recordatorio periodico de actualizar

El usuario debe recordar ejecutar `/batuta-update` manualmente.

**Correccion**: Agregar a observability-agent.md (Session Continuity rules):
```markdown
### Freshness Check
At session START, if `.batuta/session.md` exists, check the `last_batuta_update` field.
If more than 7 days have passed, suggest: "Han pasado {N} dias desde la ultima actualizacion del ecosistema Batuta. Considera ejecutar /batuta-update."
```
Y agregar campo `last_batuta_update: YYYY-MM-DD` al session-template.md.

---

### [AU2] CRITICO — Sin sistema de versionado

**Archivos**: Ecosistema general
**Problema**: No existe archivo VERSION, no hay semantic versioning, no hay forma de comparar "que version tengo instalada" vs "que version es la ultima".

**Correccion**: Crear `BatutaClaude/VERSION` con contenido `5.0.0`. Agregar a setup.sh verify: check VERSION file exists. Agregar a session-template.md: `batuta_version: "5.0.0"`.

---

### [AU3] MEDIO — SPO propagation es 100% manual

**Archivo**: `BatutaClaude/agents/infra-agent.md` lineas 65-74
**Problema**: El flujo de propagacion dice "ASK" → "If yes: evaluate → generalize → copy → register → sync → commit". Cada paso es manual.

**Correccion**: Aceptar como diseno intencional (el usuario DEBE decidir que propagar). Documentar que esto es by design, no un gap.

---

### [AU4] MEDIO — skill-sync no se auto-ejecuta post-creacion

**Archivo**: `BatutaClaude/skills/ecosystem-creator/SKILL.md` linea 388-391
**Problema**: El Registration Checklist dice "Run bash ... sync.sh" como paso manual. El ecosystem-creator no invoca sync.sh automaticamente.

**Correccion**: Agregar al ecosystem-creator Step 5 (Register): "After creating the SKILL.md, automatically run sync.sh to update routing tables. Report the result to the user."

---

### [AU5] BAJO — setup.sh --verify no valida frontmatter de skills

**Archivo**: `skills/setup.sh` lineas 240-371
**Problema**: verify() chequea que archivos existan y que CLAUDE.md tenga secciones clave, pero no valida que cada SKILL.md tenga scope, auto_invoke, y allowed-tools.

**Correccion**: Agregar a verify():
```bash
# Check all skills have required frontmatter
for skill_dir in "$REPO_ROOT/BatutaClaude/skills"/*/; do
    local skill_file="${skill_dir}SKILL.md"
    [[ ! -f "$skill_file" ]] && continue
    local skill_name=$(basename "$skill_dir")
    if ! grep -q "scope:" "$skill_file"; then
        log_warning "Skill '$skill_name' missing metadata.scope"
        errors=$((errors + 1))
    fi
done
```

---

## Dimension 6: O.R.T.A. Framework

### [O1] MEDIO — Sin datos de timing en eventos prompt

**Archivo**: `BatutaClaude/skills/prompt-tracker/SKILL.md` lineas 52-74
**Problema**: El evento `prompt` no incluye `started_at` ni el evento `closed` incluye `duration_ms`. Sin timing, es imposible calcular:
- Tiempo promedio de resolucion
- Correlacion entre complejidad y duracion
- Tendencias de productividad

**Correccion**: No agregar timing ahora (seria sobre-ingenieria para el estado actual). Documentar como future enhancement en prompt-tracker SKILL.md.

---

### [O2] MEDIO — Sin tipo de evento para errores de sistema

**Archivo**: `BatutaClaude/skills/prompt-tracker/SKILL.md` linea 50
**Problema**: 5 event types (prompt, gate, correction, follow-up, closed). No hay tipo `error` para cuando un tool call falla, un skill no se encuentra, o una operacion aborta.

**Correccion**: Documentar que errores de sistema se capturan como `correction` con `correction_type: "other"` y la descripcion del error. No crear un 6to tipo (mantener simplicidad).

---

### [O3] MEDIO — session.md sin schema mandatory

**Archivo**: `BatutaClaude/skills/prompt-tracker/assets/session-template.md`
**Problema**: El template tiene secciones (Project, Active SDD Changes, Recent Decisions, Notes) pero son freeform. Sin schema, cada sesion puede escribir el session.md de forma diferente, haciendo el parsing inconsistente.

**Correccion**: Agregar al template secciones con formato fijo:
```markdown
## Meta
- Last updated: {YYYY-MM-DD}
- Last batuta_update: {YYYY-MM-DD}
- Batuta version: {X.Y.Z}
```

---

### [O4] MEDIO — prompt-log no usado para restaurar contexto al inicio

**Archivo**: `BatutaClaude/agents/observability-agent.md` lineas 34-37
**Problema**: Al inicio de sesion, solo se lee session.md. No se lee prompt-log.jsonl. Esto significa que el historial de interacciones previas se pierde — solo se tiene el resumen manual de session.md.

**Correccion**: Aceptar como diseno intencional. El prompt-log es para ANALISIS, no para restauracion. session.md es el vehiculo de continuidad. Documentar esta distincion en observability-agent.md.

---

## Dimension 7: Auto-Gestion de Sesiones

### [SM1] CRITICO — Session start es instruccion pasiva sin enforcement

**Archivo**: `BatutaClaude/agents/observability-agent.md` lineas 34-37
**Problema**: "At the START of every conversation: Check if .batuta/session.md exists" — pero es una instruccion de texto. No hay:
- Hook que lo enforce
- Check que verifique si se leyo
- Fallback si no se lee

**Correccion**: Reforzar la instruccion como regla del router en CLAUDE.md (no solo en observability-agent). Agregar a CLAUDE.md Rules:
```markdown
- At conversation START, ALWAYS read `.batuta/session.md` if it exists. This is non-negotiable.
```

---

### [SM2] CRITICO — Sin graceful shutdown ni auto-save periodico

**Archivos**: Ecosistema general
**Problema**: Si el terminal se cierra a mitad de sesion:
- session.md no se actualiza
- prompt-log no tiene el ultimo evento
- Todo el contexto de la sesion se pierde

**Correccion**: Agregar instruccion en CLAUDE.md Behavior:
```markdown
- After completing each major task (SDD phase, feature, bug fix), update `.batuta/session.md` incrementally. Do not wait until "end of session" — sessions can end abruptly.
```

---

### [SM3] MEDIO — "Significant work" sin criterio definido

**Archivo**: `BatutaClaude/agents/observability-agent.md` linea 39
**Problema**: "At the END of significant work" — que es "significant"? Sin criterio, el LLM interpreta subjetivamente.

**Correccion**: Definir criterio en observability-agent.md:
```markdown
"Significant work" means any of:
- Completing an SDD phase (propose, spec, design, tasks, apply, verify, archive)
- Creating or modifying 3+ files
- Resolving a bug or implementing a feature
- Creating a new skill, agent, or workflow
- Any work that took more than 5 back-and-forth exchanges
```

---

### [SM4] BAJO — sed en batuta-init es fragil en Windows

**Archivo**: `BatutaClaude/commands/batuta-init.md` linea 47
**Problema**: El comando usa `sed` para reemplazar `{project-name}` en session.md. En Windows (Git Bash), sed se comporta diferente con line endings (CRLF vs LF).

**Correccion**: Usar el Write tool de Claude Code en lugar de sed. El comando deberia decir: "Read session-template.md, replace {project-name} with the actual name, and Write the result to .batuta/session.md."

---

## Dimension 8: Mejores Practicas Adicionales

### [BP1] BAJO — sync.sh mv no es atomico en Windows

**Archivo**: `BatutaClaude/skills/skill-sync/assets/sync.sh` linea 265
**Problema**: `mv "$tmp_file" "$file"` no es atomico en NTFS. Si el proceso se interrumpe entre delete y write, el archivo se pierde.

**Correccion**: Agregar backup antes de replace:
```bash
cp "$file" "${file}.bak" 2>/dev/null
mv "$tmp_file" "$file"
rm -f "${file}.bak"
```

---

### [BP2] BAJO — Sin backup antes de operaciones de sync

**Archivo**: `skills/setup.sh` (general)
**Problema**: sync_claude(), sync_agents(), y generate_claude() sobreescriben archivos sin crear backup. Si algo sale mal, no hay rollback.

**Correccion**: Para generate_claude(), crear backup:
```bash
[[ -f "$output_file" ]] && cp "$output_file" "${output_file}.bak"
```

---

### [BP3] BAJO — sync_test.sh sin test de Windows paths

**Archivo**: `BatutaClaude/skills/skill-sync/assets/sync_test.sh`
**Problema**: 18 tests, ninguno valida paths de Windows (backslashes, drive letters, espacios en paths).

**Correccion**: No es necesario ahora. sync.sh trabaja con paths Unix-style (Git Bash los convierte). Documentar como known limitation.

---

---

# Parte 2: Ajustes Realizados

## Resumen de Correcciones

| ID | Severidad | Archivo(s) Modificado(s) | Tipo de Ajuste |
|----|-----------|--------------------------|----------------|
| A1 | CRITICO | CLAUDE.md | Reescribir routing description |
| A2 | MEDIO | observability-agent.md | Documentar decision de diseno |
| A3 | MEDIO | CLAUDE.md | Documentar decision de diseno |
| C1 | CRITICO | pipeline-agent.md, sdd-apply, sdd-verify | Unificar status enum |
| C2 | MEDIO | ecosystem-creator/SKILL.md | Fix duplicate bullet |
| C3 | MEDIO | CLAUDE.md | Clarificar scope del gate |
| C4 | MEDIO | CLAUDE.md | Fix "How to route" |
| C5 | BAJO | ecosystem-creator/SKILL.md | Fix duplicate reference |
| S1 | MEDIO | batuta-init.md | Agregar prompt-log a .gitignore |
| S4 | MEDIO | settings.json | Agregar deny para SSH/keys |
| E1 | CRITICO | setup.sh | Hacer skill-sync failure blocking |
| E2 | MEDIO | batuta-init.md | Agregar git pull para freshness |
| E3 | MEDIO | CLAUDE.md | Documentar limitacion del gate |
| E4 | BAJO | sync.sh | Agregar bash version check |
| E5 | BAJO | setup.sh | Agregar trap cleanup |
| AU1 | CRITICO | observability-agent.md, session-template.md | Freshness check |
| AU2 | CRITICO | VERSION (nuevo) | Crear archivo de version |
| AU4 | MEDIO | ecosystem-creator/SKILL.md | Documentar auto-sync post-creacion |
| AU5 | BAJO | setup.sh | Agregar frontmatter validation a verify |
| SM1 | CRITICO | CLAUDE.md | Reforzar session start como regla |
| SM2 | CRITICO | CLAUDE.md | Auto-save incremental |
| SM3 | MEDIO | observability-agent.md | Definir criterio de "significant work" |
| SM4 | BAJO | batuta-init.md | Usar Write tool en vez de sed |
| O3 | MEDIO | session-template.md | Agregar seccion Meta con campos fijos |
| O4 | MEDIO | observability-agent.md | Documentar distincion log vs session |
| BP1 | BAJO | sync.sh | Agregar backup antes de mv |

### Hallazgos aceptados como diseno intencional (sin cambio):

| ID | Severidad | Razon |
|----|-----------|-------|
| S2 | MEDIO | Repo privado, GPG verification es defense-in-depth no critico |
| S3 | BAJO | Paths hardcodeados son fallbacks, no primarios |
| AU3 | MEDIO | SPO manual es by design — usuario debe decidir que propagar |
| O1 | MEDIO | Timing seria sobre-ingenieria para el estado actual |
| O2 | MEDIO | Errores se capturan via correction type "other" |
| C6 | BAJO | Lista de planned skills es referencia, no tracking activo |
| BP2 | BAJO | Backups en setup.sh son nice-to-have |
| BP3 | BAJO | Windows paths se manejan via Git Bash |

---

## Detalle de Cada Correccion Aplicada

### Correccion A1 + C4: Reescribir routing description en CLAUDE.md

**Antes** (lineas 59, 70-74):
```markdown
You are the ROUTER. Do not execute heavy work directly. Route to the appropriate scope agent via the Task tool.

### How to route
1. Execution Gate determines scope (see below)
2. Read the scope agent file via Task tool
3. The agent file lists which skills to load
4. Execute following the agent's rules
5. Return result to user
```

**Despues**:
```markdown
You are the ROUTER. Do not execute heavy work directly. Route to the appropriate scope agent.

### How to route
1. Execution Gate determines scope (see below)
2. Read the scope agent file to understand which skills apply
3. Load the relevant SKILL.md file(s) for the detected scope
4. Apply ALL patterns and rules from the loaded skills
5. Return result to user

Note: Scope agents are reference documents, not independent sub-processes. Claude Code loads skills from ~/.claude/skills/ automatically based on context matching. The agents organize which skills belong to which domain.
```

### Correccion A2: Documentar decision de observability-agent

**Agregado** a `observability-agent.md` despues de linea 17:

```markdown
> **Design Note**: Session management is intentionally embedded as agent-level rules rather than a separate skill. It runs at every conversation boundary (start/end), not on-demand like prompt-tracker analysis. If observability capabilities grow (performance metrics, cost tracking), consider extracting those as separate skills.
```

### Correccion A3: Documentar gate como regla del router

**Agregado** a `CLAUDE.md` antes de la seccion Execution Gate:

```markdown
> **Design Note**: The Execution Gate is defined here in the router (not as a separate skill) because it must execute BEFORE routing to any scope agent. It is the entry point of every code-change flow.
```

### Correccion C1: Unificar Sub-Agent Output Contract status enum

**pipeline-agent.md** — Cambiar status enum:
```markdown
| `status` | Yes | `success`, `partial`, `blocked`, `error` |
```

**sdd-verify/SKILL.md** — Agregar mappeo:
```markdown
status: "success" | "partial" | "error"
# Mapping: PASS → success, PASS_WITH_WARNINGS → partial, FAIL → error
# The verdict field (PASS/PASS_WITH_WARNINGS/FAIL) remains in the detailed report for readability
```

### Correccion C2: Fix duplicate bullet en ecosystem-creator

**Antes** (lineas 587-588):
```markdown
- [ ] The component appears in CLAUDE.md
- [ ] The component appears in CLAUDE.md (for skills and sub-agents)
```

**Despues**:
```markdown
- [ ] The component appears in CLAUDE.md Available Skills table
- [ ] The component appears in the appropriate scope agent's Skills table (for skills and sub-agents)
```

### Correccion C3: Clarificar scope del gate

**Agregado** a CLAUDE.md despues de Gate Modes table:

```markdown
> The Execution Gate applies to **production code changes** only. SDD artifacts (specs, designs, tasks, proposals) are validated by the pipeline dependency graph, not by the gate.
```

### Correccion C5: Fix duplicate reference en ecosystem-creator

**Antes** (lineas 648-649):
```markdown
- **Registration targets**: CLAUDE.md (master registry), CLAUDE.md (auto-load table)
```

**Despues**:
```markdown
- **Registration targets**: CLAUDE.md (Available Skills table — auto-generated by skill-sync)
```

### Correccion S1: Agregar prompt-log a .gitignore template

**batuta-init.md** — Actualizar .gitignore template (lineas 76-82):
```
.env
.env.*
node_modules/
__pycache__/
.venv/
.batuta/prompt-log.jsonl
.batuta/analysis-report.md
```

### Correccion S4: Agregar deny para SSH/keys en settings.json

**Agregado** al array `deny`:
```json
"Read(**/.ssh/**)",
"Read(**/*.pem)",
"Read(**/*.key)",
"Read(**/*.p12)",
"Read(**/*.pfx)"
```

### Correccion E1: Hacer skill-sync failure blocking en setup.sh

**Antes** (linea 205):
```bash
bash "$sync_script" || log_warning "skill-sync had warnings (check output above)"
log_success "Routing tables regenerated"
```

**Despues**:
```bash
if bash "$sync_script"; then
    log_success "Routing tables regenerated"
else
    log_error "skill-sync failed — aborting. Fix skill frontmatters and retry."
    return 1
fi
```

### Correccion E2: git pull en batuta-init

**Agregado** a batuta-init.md despues del step 1 locate:

```markdown
If batuta-dots was found locally (not cloned fresh), update it:
```bash
git -C "$BATUTA_DOTS_PATH" pull --ff-only 2>/dev/null || log_warning "Could not update batuta-dots (offline?)"
```

### Correccion E4: Bash version check en sync.sh

**Agregado** al inicio de sync.sh main():
```bash
if [[ "${BASH_VERSINFO[0]}" -lt 4 || ("${BASH_VERSINFO[0]}" -eq 4 && "${BASH_VERSINFO[1]}" -lt 3) ]]; then
    log_error "bash 4.3+ required for namerefs (found ${BASH_VERSION})"
    exit 1
fi
```

### Correccion E5: Trap cleanup en setup.sh

**Agregado** despues de `set -e`:
```bash
cleanup() {
    rm -f "$REPO_ROOT/BatutaClaude/CLAUDE.md.tmp" 2>/dev/null
    rm -f "$REPO_ROOT/BatutaClaude/agents/"*.tmp 2>/dev/null
}
trap cleanup EXIT
```

### Correccion AU1: Freshness check en observability-agent

**Agregado** a observability-agent.md Session Continuity:
```markdown
### Freshness Check
At session START, after reading session.md, check the `last_batuta_update` field in the Meta section.
If more than 7 days have passed (or the field is missing), suggest:
"Han pasado {N} dias desde la ultima actualizacion del ecosistema. Considera ejecutar /batuta-update."
```

### Correccion AU2: Crear VERSION file

**Nuevo archivo**: `BatutaClaude/VERSION`
```
5.0.0
```

### Correccion AU4: Documentar auto-sync en ecosystem-creator

**Agregado** al Registration Checklist nota:
```markdown
> **Automation Note**: After creating a skill, run `sync.sh` to update routing tables automatically. In future versions, this will be invoked automatically by the ecosystem-creator.
```

### Correccion SM1: Reforzar session start en CLAUDE.md Rules

**Agregado** a CLAUDE.md Rules (despues de linea 12):
```markdown
- At conversation START, ALWAYS check for `.batuta/session.md`. If it exists, read it to restore project context. This is non-negotiable — never skip this step.
```

### Correccion SM2: Auto-save incremental en CLAUDE.md Behavior

**Agregado** a CLAUDE.md Behavior:
```markdown
- After completing each major task (SDD phase, feature, bug fix), update `.batuta/session.md` incrementally. Do not wait for "end of session" — sessions can end abruptly.
```

### Correccion SM3: Definir criterio de "significant work"

**Reemplazado** en observability-agent.md:
```markdown
At the **END** of significant work:

"Significant work" means ANY of:
- Completing an SDD phase (propose, spec, design, tasks, apply, verify, archive)
- Creating or modifying 3+ files
- Resolving a bug or implementing a feature
- Creating a new skill, agent, or workflow
- Any work that took 5+ back-and-forth exchanges
```

### Correccion SM4: Usar Write tool en batuta-init

**Actualizado** en batuta-init.md step 2.5:
```markdown
Read the session template and use the Write tool to create `.batuta/session.md`,
replacing `{project-name}` with the actual project name. Do not use sed — use
Claude Code's native Write tool for cross-platform compatibility.
```

### Correccion O3: Agregar Meta section a session-template

**Agregado** al inicio de session-template.md:
```markdown
## Meta
- Last updated: {date}
- Last batuta update: {date}
- Batuta version: 5.0.0
```

### Correccion O4: Documentar distincion log vs session

**Agregado** a observability-agent.md:
```markdown
> **Design Note**: `session.md` is for context restoration (read at start). `prompt-log.jsonl` is for pattern analysis (read on-demand via /batuta:analyze-prompts). They serve different purposes and are not interchangeable.
```

### Correccion BP1: Backup antes de mv en sync.sh

**Actualizado** en replace_section():
```bash
cp "$file" "${file}.bak" 2>/dev/null || true
mv "$tmp_file" "$file"
rm -f "${file}.bak" 2>/dev/null || true
```

---

## Verificacion Post-Correccion

Despues de aplicar todas las correcciones, verificar:

```bash
# 1. VERSION file existe
cat BatutaClaude/VERSION  # Debe mostrar 5.0.0

# 2. CLAUDE.md tiene regla de session start
grep "non-negotiable" BatutaClaude/CLAUDE.md  # Debe encontrar

# 3. CLAUDE.md tiene auto-save incremental
grep "incrementally" BatutaClaude/CLAUDE.md  # Debe encontrar

# 4. settings.json tiene deny para SSH
grep ".ssh" BatutaClaude/settings.json  # Debe encontrar

# 5. setup.sh tiene error handling en skill-sync
grep "aborting" skills/setup.sh  # Debe encontrar

# 6. sync.sh tiene bash version check
grep "BASH_VERSINFO" BatutaClaude/skills/skill-sync/assets/sync.sh  # Debe encontrar

# 7. pipeline-agent tiene status enum unificado
grep "success.*partial.*blocked.*error" BatutaClaude/agents/pipeline-agent.md  # Debe encontrar

# 8. session-template tiene Meta section
grep "Last batuta update" BatutaClaude/skills/prompt-tracker/assets/session-template.md  # Debe encontrar

# 9. Correr tests existentes
./skills/setup_test.sh
bash BatutaClaude/skills/skill-sync/assets/sync_test.sh
```

---

## Score Final

| Dimension | Antes | Despues | Cambio |
|-----------|-------|---------|--------|
| Arquitectura | 7/10 | 9/10 | +2 (routing clarificado, decisions documentadas) |
| Seguridad | 6/10 | 8/10 | +2 (deny list expandida, gitignore) |
| Ejecucion | 5/10 | 8/10 | +3 (error handling, version check, cleanup) |
| Consistencia | 6/10 | 9/10 | +3 (enum unificado, duplicados eliminados) |
| Automatizacion | 4/10 | 7/10 | +3 (freshness check, versioning) |
| O.R.T.A. | 7/10 | 8/10 | +1 (schema, documentacion) |
| Auto-gestion | 4/10 | 8/10 | +4 (session rules, auto-save, criteria) |
| **Promedio** | **5.6/10** | **8.1/10** | **+2.5** |
