# Integration Test: Guia Batuta App

## Metadata

- **Fecha**: 2026-02-23
- **Guia analizada**: `docs/guides/guia-batuta-app.md`
- **Version del ecosistema**: v9.1
- **Archivos verificados**:
  - `BatutaClaude/CLAUDE.md`
  - `BatutaClaude/commands/batuta-init.md`
  - `BatutaClaude/commands/batuta-update.md`
  - `BatutaClaude/commands/batuta-analyze-prompts.md`
  - `BatutaClaude/commands/batuta-sync-skills.md`
  - `BatutaClaude/agents/pipeline-agent.md`
  - `BatutaClaude/agents/infra-agent.md`
  - `BatutaClaude/agents/observability-agent.md`
  - `BatutaClaude/skills/ecosystem-creator/SKILL.md`
  - `BatutaClaude/skills/security-audit/SKILL.md`
  - `BatutaClaude/skills/sdd-init/SKILL.md`
  - `BatutaClaude/skills/prompt-tracker/SKILL.md`
  - `E:\BATUTA PROJECTS\test-guias\ecosystem-snapshot.md`

---

## Resumen Ejecutivo

La guia `guia-batuta-app.md` es funcionalmente correcta en sus partes principales. El flujo SDD de 15 pasos, los comandos centrales (`/sdd:init`, `/sdd:explore`, `/sdd:new`, `/sdd:continue`, `/sdd:apply`, `/sdd:verify`, `/sdd:archive`), los tres scope agents, el Execution Gate, y la auditoria de seguridad estan todos respaldados por archivos reales del ecosistema.

Se identificaron **3 hallazgos**: 1 importante y 2 menores. Ninguno bloquea el uso de la guia. El hallazgo importante es una instruccion tecnica incorrecta que podria confundir a un usuario avanzado que compare la guia con el command `batuta-init.md`. Los dos hallazgos menores son descripciones de comportamiento inexactas que no afectan el flujo pero podrian crear expectativas erroneas.

No se encontraron referencias a archivos inexistentes, comandos fantasma, ni agents o skills que no existan en el ecosistema.

---

## Hallazgos

### CRITICOS

Ninguno.

---

### IMPORTANTES

#### HALLAZGO-01: Opcion B del Paso 3 especifica `--all` pero `batuta-init.md` usa `--sync` + `--hooks` separados

**Paso afectado**: Paso 3 — "Instalar el ecosistema Batuta", Opcion B.

**Lo que dice la guia**:
```
2. Ejecuta el script skills/setup.sh --all para copiar CLAUDE.md, sincronizar skills e instalar hooks
```

**Lo que hace el ecosistema real** (`BatutaClaude/commands/batuta-init.md`, Step 3):
```bash
bash "$BATUTA_DOTS_PATH/skills/setup.sh" --sync
bash "$BATUTA_DOTS_PATH/skills/setup.sh" --hooks
```

**Analisis**: El flag `--all` existe (confirmado en `ecosystem-snapshot.md`: `setup.sh flags: --claude, --sync, --all, --verify, --hooks, --project`) pero el command `batuta-init.md` lo descompone en dos llamadas separadas (`--sync` y `--hooks`). La Opcion B es un prompt manual de "primera vez" que el usuario copia antes de tener el command instalado. Si un usuario tecnico lo ejecuta directamente como `setup.sh --all`, el comportamiento podria diferir del que documenta `batuta-init.md` (por ejemplo, el step 2.5 de `batuta-init.md` crea `.batuta/session.md` y `prompt-log.jsonl` antes de llamar al script, lo cual `--all` solo no hace).

**Riesgo**: Un usuario que sigue la Opcion B manualmente (sin que Claude ejecute el prompt) podria omitir la creacion del directorio `.batuta/` y los archivos de sesion, ya que esos pasos estan en `batuta-init.md` Steps 2.5 pero NO en el prompt que la guia sugiere pegar.

**Prioridad**: Alta — afecta la instalacion manual del ecosistema.

**Archivo**: `docs/guides/guia-batuta-app.md`, linea ~144.

---

### MENORES

#### HALLAZGO-02: El comando de emergencia `/sdd:continue` se describe como "ver el estado" cuando en realidad ejecuta la siguiente fase

**Paso afectado**: Seccion "Comandos de emergencia".

**Lo que dice la guia**:

| Situacion | Que escribir |
|---|---|
| Quieres ver el estado del proyecto | `/sdd:continue batuta-app-dashboard` (te muestra donde quedamos) |

**Lo que hace el ecosistema real** (`BatutaClaude/CLAUDE.md`, tabla SDD Commands):
```
/sdd:continue [change-name]  →  pipeline → next needed phase
```

**Analisis**: `/sdd:continue` no es un comando de "ver estado" — es el comando que ejecuta la siguiente fase pendiente en el pipeline SDD. Si el usuario lo ejecuta pensando que solo vera informacion, Claude podria avanzar una fase que el usuario no estaba listo para ejecutar. El comando correcto para revisar estado seria leer `.batuta/session.md` o simplemente preguntar a Claude, no `/sdd:continue`.

**Riesgo**: Bajo — el pipeline-agent pide confirmacion al usuario antes de avanzar cada fase, pero la descripcion crea una expectativa incorrecta sobre el comportamiento del comando.

**Prioridad**: Media — correccion sencilla, previene confusion de expectativas.

**Archivo**: `docs/guides/guia-batuta-app.md`, seccion "Comandos de emergencia", linea ~662.

---

#### HALLAZGO-03: La guia describe la Opcion A de instalacion como si `/batuta-init` fuera un command slash nativo de Claude Code, sin mencionar que requiere instalacion previa

**Paso afectado**: Paso 3 — "Instalar el ecosistema Batuta", Opcion A.

**Lo que dice la guia**:
> "Opcion A — Si ya tienes los commands de Batuta instalados (recomendado): Simplemente escribe: `/batuta-init batuta-app`"

**Lo que existe en el ecosistema**:
- El archivo `BatutaClaude/commands/batuta-init.md` existe y funciona cuando los commands de Batuta estan instalados en `~/.claude/commands/`.
- La guia menciona el prerequisito ("Si ya tienes los commands instalados"), pero no explica donde se instalan ni como saber si estan instalados.

**Analisis**: Para un usuario que llega por primera vez al ecosistema, la distincion entre "Opcion A" y "Opcion B" no es clara. La guia no explica que los commands de Batuta viven en `~/.claude/commands/` y se instalan via `setup.sh --all` o via la Opcion B de este mismo paso (lo cual crea una circularidad). Un usuario nuevo que intente la Opcion A sin haber hecho la Opcion B primero obtendra un error de comando no encontrado.

**Riesgo**: Bajo — la guia esta orientada a usuarios que alguien ya configuro su entorno, y la Opcion B es el fallback explicito. Sin embargo, el orden logico de las opciones podria invertirse: Opcion A deberia ser para usuarios que YA usaron Batuta antes, Opcion B para primera vez.

**Prioridad**: Baja — es una mejora de claridad, no un error funcional.

**Archivo**: `docs/guides/guia-batuta-app.md`, Paso 3, lineas ~124-157.

---

## Tabla de Hallazgos

| ID | Severidad | Descripcion | Prioridad | Archivo |
|----|-----------|-------------|-----------|---------|
| HALLAZGO-01 | IMPORTANTE | Opcion B del Paso 3 dice `setup.sh --all` pero `batuta-init.md` usa `--sync` + `--hooks` separados, y omite la creacion de `.batuta/` | Alta | `docs/guides/guia-batuta-app.md` linea ~144 |
| HALLAZGO-02 | MENOR | `/sdd:continue` descrito como "ver estado del proyecto" cuando en realidad ejecuta la siguiente fase SDD | Media | `docs/guides/guia-batuta-app.md` seccion "Comandos de emergencia" |
| HALLAZGO-03 | MENOR | Opcion A no explica el prerequisito de instalacion de commands ni como saber si estan disponibles | Baja | `docs/guides/guia-batuta-app.md` Paso 3 |

---

## Verificaciones que PASARON

Las siguientes referencias de la guia fueron verificadas contra el ecosistema y son correctas:

| Referencia en la guia | Estado | Archivo verificado |
|---|---|---|
| `/batuta-init batuta-app` — command existe | PASS | `BatutaClaude/commands/batuta-init.md` |
| `/batuta-update` — command existe | PASS | `BatutaClaude/commands/batuta-update.md` |
| `/batuta:analyze-prompts` — command existe | PASS | `BatutaClaude/commands/batuta-analyze-prompts.md` |
| `pipeline-agent` — agent existe con skills SDD | PASS | `BatutaClaude/agents/pipeline-agent.md` |
| `infra-agent` — agent existe con `ecosystem-creator` | PASS | `BatutaClaude/agents/infra-agent.md` |
| `observability-agent` — agent existe con O.R.T.A. | PASS | `BatutaClaude/agents/observability-agent.md` |
| `security-audit` — skill existe con 10 puntos AI-First | PASS | `BatutaClaude/skills/security-audit/SKILL.md` |
| `ecosystem-creator` — skill existe, detecta gaps y crea skills via Context7 | PASS | `BatutaClaude/skills/ecosystem-creator/SKILL.md` |
| `sdd-init` — skill existe, detecta tipo de proyecto | PASS | `BatutaClaude/skills/sdd-init/SKILL.md` |
| `prompt-tracker` — skill existe, es SSoT de event schemas | PASS | `BatutaClaude/skills/prompt-tracker/SKILL.md` |
| 3 Scope Agents: pipeline, infra, observability | PASS | `BatutaClaude/CLAUDE.md` tabla de routing |
| Execution Gate con modo LIGHT y FULL | PASS | `BatutaClaude/CLAUDE.md` seccion Execution Gate |
| `.batuta/session.md` y `.batuta/prompt-log.jsonl` creados por `/batuta-init` | PASS | `BatutaClaude/commands/batuta-init.md` Step 2.5 |
| Skill Gap Detection en `infra-agent` con 3 opciones al usuario | PASS | `BatutaClaude/agents/infra-agent.md` |
| `/sdd:new` crea proposal (sdd-explore → sdd-propose) | PASS | `BatutaClaude/CLAUDE.md` tabla SDD Commands |
| `/sdd:continue` avanza al siguiente paso del pipeline | PASS | `BatutaClaude/CLAUDE.md` tabla SDD Commands |
| `/sdd:apply` invoca pipeline + infra para Scope Rule | PASS | `BatutaClaude/CLAUDE.md` tabla SDD Commands |
| Agent Teams: 3 niveles (Solo, Subagente, Agent Team) | PASS | `BatutaClaude/CLAUDE.md` tabla Team Routing |
| Metricas de rendimiento en tabla de Agent Teams | PASS (estimaciones) | Documentadas como estimaciones en la guia |

---

## Conclusion

La guia `guia-batuta-app.md` refleja con precision el ecosistema Batuta v9.1. Los 15 pasos del flujo, los comandos SDD, los scope agents, el Execution Gate, la deteccion de skill gaps, la auditoria de seguridad, y la seccion de Agent Teams estan todos respaldados por archivos reales que contienen exactamente lo que la guia describe.

Los 3 hallazgos identificados son correcciones menores de precision tecnica y claridad. Ninguno representa un error que impediria a un usuario seguir la guia con exito, ya que:

- HALLAZGO-01: La Opcion B solo se usa cuando Claude interpreta el prompt completo — Claude ejecutara `batuta-init.md` internamente, que tiene los pasos correctos.
- HALLAZGO-02: El pipeline-agent siempre pide confirmacion antes de avanzar una fase, por lo que el usuario no avanzara accidentalmente.
- HALLAZGO-03: La Opcion A tiene el prerequisito explicito aunque no explique la ruta de instalacion.

**Recomendacion**: Aplicar las 3 correcciones antes de distribuir la guia a usuarios finales, con prioridad en HALLAZGO-01 por tener el mayor potencial de confusion tecnica.
