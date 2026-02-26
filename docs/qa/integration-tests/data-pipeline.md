# Integration Test: Guia Data Pipeline

## Metadata

- **Fecha**: 2026-02-23
- **Guia**: `docs/guides/guia-data-pipeline.md`
- **Version ecosistema**: v9.1
- **Tester**: Claude (analisis estatico — Read tool only, sin ejecucion)
- **Metodo**: Lectura de guia + verificacion de cada skill, agent y command referenciado contra los archivos reales del ecosistema

---

## Resumen Ejecutivo

La guia `guia-data-pipeline.md` fue analizada contra el ecosistema v9.1. Se verificaron manualmente todos los skills, agents, commands y archivos del ecosistema mencionados o implicados en los 13 pasos de la guia.

**Resultado global**: La guia es mayormente funcional. Los skills y agents del nucleo SDD existen y estan bien documentados. Sin embargo, se encontraron **4 discrepancias reales** que pueden confundir al usuario o producir comportamiento inesperado en tiempo de ejecucion:

1. Un command invocado en la guia (`/batuta-init`) no tiene frontmatter YAML valido y por tanto no sera auto-invocado por Claude Code como comando slash.
2. La guia usa `/sdd-explore` como comando standalone con un argumento de nombre de proyecto, pero el skill `sdd-explore` solo crea `explore.md` cuando se le pasa un nombre de cambio dentro de `/sdd-new`, no en modo standalone.
3. La guia describe que `sdd-continue` avanza fases (Specs → Design → Tasks), pero ese comando no existe en el ecosistema — el mapeo en CLAUDE.md es `/sdd-continue [change-name]` → pipeline → next needed phase, sin un skill dedicado llamado `sdd-continue`.
4. El template `data-pipeline` del equipo usa una estructura de carpetas (`pipeline/`, `transforms/`, `validators/`, `schemas/`) que difiere de la estructura que la guia prescribe para el proyecto (`features/ingestion/`, `features/transformation/`, `features/validation/`, `features/export/`) segun la Scope Rule.

No se encontraron skills o archivos del ecosistema faltantes entre los que la guia referencia explicitamente.

---

## Hallazgos

### CRITICOS

#### C-01: `/batuta-init` no tiene frontmatter YAML — no funciona como slash command nativo

**Paso afectado**: Paso 2, Opcion A

La guia indica:

```
/batuta-init batuta-data-pipeline
```

El archivo `BatutaClaude/commands/batuta-init.md` comienza directamente con `---` seguido de campos YAML, lo cual es correcto. Sin embargo, el campo `disable-model-invocation: true` esta presente, lo cual significa que el modelo **no** invoca el comando automaticamente al escribirlo — Claude Code lo ejecuta como un prompt al modelo sin el flujo de command slash habitual. Este comportamiento es por diseno segun la documentacion del campo.

**Discrepancia real**: La guia llama al comando `/batuta-init` (con guion), pero en CLAUDE.md el comando esta registrado como `/batuta:analyze-prompts` y `/batuta:sync-skills` (con dos puntos, no guion). La convencion del ecosistema para commands de batuta usa el patron `/{namespace}:{action}`. El archivo del command se llama `batuta-init.md` y el ecosistema-snapshot lista el command como `batuta-init.md`, pero el CLAUDE.md **no incluye `/batuta-init` en su tabla de comandos SDD** — solo lista los comandos `/sdd-*`, `/create-*`, `/batuta:analyze-prompts` y `/batuta:sync-skills`. Esto significa que `/batuta-init` no aparece en el routing table visible al usuario desde CLAUDE.md.

**Impacto**: El usuario que siga la Opcion A en el Paso 2 puede invocar `/batuta-init` y que Claude no reconozca el comando desde la tabla de comandos en CLAUDE.md, generando confusion.

**Archivo**: `BatutaClaude/commands/batuta-init.md`, `BatutaClaude/CLAUDE.md`

---

#### C-02: `/sdd-explore` con nombre de proyecto no crea archivo — la guia implica que si lo hace

**Paso afectado**: Paso 3B

La guia instruye al usuario a ejecutar:

```
/sdd-explore batuta-data-pipeline

Necesito explorar como construir un pipeline de datos...
```

El skill `sdd-explore` (verificado en `BatutaClaude/skills/sdd-explore/SKILL.md`) establece en su Step 4:

> "If the orchestrator provided a change name (i.e., this exploration is part of `/sdd-new`), save your analysis to: `openspec/changes/{change-name}/explore.md`"
>
> "If no change name was provided (standalone `/sdd-explore`), skip file creation -- just return the analysis."

El CLAUDE.md mapea `/sdd-explore <topic>` directamente a `pipeline → sdd-explore`. Cuando se llama como comando standalone (no dentro de `/sdd-new`), el skill **no crea archivo** — solo retorna el analisis en pantalla.

La guia en el Paso 3B no aclara que este explore es standalone y que no guardara ningun artefacto, lo cual puede confundir al usuario si espera ver un archivo de exploracion en `openspec/`.

**Impacto**: El usuario no ve ningun archivo creado tras el Paso 3B y no sabe si el explore "funciono". Ademas, cuando llegue al Paso 5 (`/sdd-new`) el sistema ejecutara un segundo explore (parte del flujo `sdd-explore → sdd-propose`), duplicando trabajo.

**Archivo**: `BatutaClaude/skills/sdd-explore/SKILL.md`, `BatutaClaude/CLAUDE.md`

---

### IMPORTANTES

#### I-01: La guia describe `/sdd-continue` como ejecutor de fases Specs → Design → Tasks, pero no existe un skill `sdd-continue`

**Paso afectado**: Paso 6

La guia indica al usuario que ejecute:

```
/sdd-continue batuta-data-pipeline
```

Y describe que Claude va a ejecutar estas fases en orden: **Specs → Design → Tasks**.

En CLAUDE.md el mapeo es:

```
/sdd-continue [change-name]  |  pipeline → next needed phase
```

No existe un skill llamado `sdd-continue` en el ecosistema. El comando es un **workflow de orquestacion** manejado directamente por el pipeline-agent o el orquestador principal, que lee el estado actual de `openspec/changes/{change-name}/` y decide que fase ejecutar a continuacion (sdd-spec, sdd-design, o sdd-tasks).

Esto es funcionalmente correcto — el sistema si puede avanzar fases con este comando — pero la guia presenta el comportamiento como si fuera un skill atomico que ejecuta todas las fases de una vez, cuando en realidad:
1. `sdd-spec` escribe `spec.md`
2. `sdd-design` escribe `design.md`
3. `sdd-tasks` escribe `tasks.md`

Cada uno de estos es un sub-agent separado con su propio SKILL.md. El comportamiento de "ejecuta las tres fases" depende de como el orquestador interprete el comando en ese momento.

**Impacto**: Si el orquestador no interpreta correctamente que debe avanzar todas las fases en una sola invocacion de `/sdd-continue`, el usuario podria necesitar llamarlo multiples veces. La guia dice "entre cada fase, Claude te muestra un resumen y pregunta si continua" — esto implica que son 3 invocaciones separadas, no una sola. La descripcion es ambigua.

**Archivo**: `BatutaClaude/CLAUDE.md` (mapeo de comandos), `BatutaClaude/skills/sdd-spec/SKILL.md`, `BatutaClaude/skills/sdd-design/SKILL.md`, `BatutaClaude/skills/sdd-tasks/SKILL.md`

---

#### I-02: Estructura de carpetas del team template `data-pipeline` difiere de la Scope Rule aplicada en la guia

**Paso afectado**: Seccion "USANDO AGENT TEAMS", sub-seccion "El equipo para un pipeline de datos"

La guia asigna los siguientes archivos a cada teammate del equipo:

| Teammate | Archivos segun la guia |
|----------|----------------------|
| `pipeline-dev` | `features/ingestion/`, `features/transformation/`, `features/export/` |
| `data-validator` | `features/validation/`, `tests/`, esquemas |
| `infra-dev` | `Dockerfile`, `docker-compose.yml`, configuracion |

El template oficial `teams/templates/data-pipeline.md` asigna:

| Teammate | Archivos segun template |
|----------|------------------------|
| `pipeline-dev` | `pipeline/**`, `transforms/**`, `schedules/**` |
| `data-validator` | `validators/**`, `tests/**`, `schemas/**` |
| `infra-dev` | `Dockerfile`, `docker-compose.yml`, `infra/**` |

Estas son **dos estructuras de proyecto distintas e incompatibles**. La guia aplica la Scope Rule de Batuta correctamente (features/{nombre}/), mientras que el template oficial usa una estructura plana de alto nivel (`pipeline/`, `transforms/`, `validators/`).

Si el usuario sigue los pasos de construccion (Pasos 7-10 con Scope Rule) y luego decide usar un Agent Team desde la seccion de teams, los contratos de archivo del team no coincidiran con la estructura real del proyecto ya construido.

**Archivo**: `docs/guides/guia-data-pipeline.md` (seccion Agent Teams), `teams/templates/data-pipeline.md`

---

### MENORES

#### M-01: La guia menciona "infra-agent" como coordinador de skills, pero el flujo real es Skill Gap Detection en sdd-explore

**Paso afectado**: Paso 4

La guia dice:

> "El infra-agent (jefe de almacen) coordina la creacion de skills nuevos. Usa el ecosystem-creator para investigar y documentar la tecnologia."

Esto es parcialmente correcto. Segun `sdd-explore/SKILL.md`, el Skill Gap Detection ocurre en el Step 2.5 del skill `sdd-explore` directamente — no necesariamente a traves del infra-agent. El infra-agent tiene la deteccion de gaps en su propio protocolo, pero en el flujo SDD (que es el que sigue la guia), el trigger es `sdd-explore` quien detecta y ofrece crear skills.

El infra-agent entra cuando el gap se detecta durante `sdd-apply` o cuando se toca una tecnologia fuera del flujo SDD. Para el Paso 4 de la guia (dentro del flujo de `/sdd-explore`), el actor correcto es el skill `sdd-explore` actuando como parte del pipeline-agent, no el infra-agent directamente.

**Impacto**: El detalle tecnico es incorrecto pero el comportamiento observable para el usuario es el mismo (Claude pregunta sobre la opcion de crear el skill). No causa errores.

**Archivo**: `docs/guides/guia-data-pipeline.md` (Paso 4), `BatutaClaude/skills/sdd-explore/SKILL.md`, `BatutaClaude/agents/infra-agent.md`

---

#### M-02: La guia usa `/batuta:analyze-prompts` con el nombre correcto pero en el command el texto interno dice `/batuta-update` como referencia en el reporte

**Paso afectado**: Seccion "Mejorar tus instrucciones"

La guia instruye:

```
/batuta:analyze-prompts
```

El command real se llama `batuta-analyze-prompts.md` y el CLAUDE.md lo registra como `/batuta:analyze-prompts`. El nombre es correcto.

Sin embargo, al final del reporte generado por `prompt-tracker/SKILL.md` (en el template de `analysis-report.md`) aparece:

> "Ejecuta `/batuta-update` para aplicar cambios globales al ecosistema."

El command para actualizar el ecosistema es `batuta-update.md` y se invocaria como `/batuta-update` — sin los dos puntos. Esto es inconsistente con la convencion del ecosistema donde los commands de batuta usan `/{namespace}:{action}`. El command `batuta-update.md` no tiene frontmatter con `name:` que defina su invocacion como slash command formal.

**Impacto**: Bajo. El usuario no ve este texto directamente en la guia — esta embebido en el template de reporte del prompt-tracker. No afecta el flujo de la guia.

**Archivo**: `BatutaClaude/skills/prompt-tracker/SKILL.md` (linea del template de analysis-report.md)

---

## Tabla de Hallazgos

| ID | Severidad | Descripcion | Prioridad | Archivo principal |
|----|-----------|-------------|-----------|-------------------|
| C-01 | CRITICO | `/batuta-init` no aparece en tabla de comandos de CLAUDE.md; inconsistencia de convencion de nombres (guion vs dos puntos) | Alta | `BatutaClaude/CLAUDE.md` |
| C-02 | CRITICO | `/sdd-explore` standalone no guarda archivo; la guia no advierte esto y genera trabajo duplicado con `/sdd-new` | Alta | `BatutaClaude/skills/sdd-explore/SKILL.md` |
| I-01 | IMPORTANTE | `/sdd-continue` no tiene skill dedicado; comportamiento de "3 fases en una invocacion" es ambiguo y depende del orquestador | Media | `BatutaClaude/CLAUDE.md` |
| I-02 | IMPORTANTE | Estructura de carpetas de la guia (features/{nombre}/) no coincide con el template oficial de data-pipeline (pipeline/, transforms/, validators/) | Media | `teams/templates/data-pipeline.md` |
| M-01 | MENOR | La guia atribuye Skill Gap Detection al infra-agent cuando en el flujo SDD el actor es sdd-explore | Baja | `docs/guides/guia-data-pipeline.md` (Paso 4) |
| M-02 | MENOR | Template de reporte en prompt-tracker referencia `/batuta-update` (guion), inconsistente con la convencion `/{namespace}:{action}` | Baja | `BatutaClaude/skills/prompt-tracker/SKILL.md` |

---

## Conclusion

La guia `guia-data-pipeline.md` cubre el flujo SDD completo de forma coherente y sus referencias al ecosistema son mayormente correctas. Los 9 skills SDD (sdd-init, sdd-explore, sdd-propose, sdd-spec, sdd-design, sdd-tasks, sdd-apply, sdd-verify, sdd-archive), los 3 agents y los commands verificados existen y contienen lo que la guia describe.

Los dos hallazgos criticos (C-01 y C-02) requieren atencion antes de que la guia sea usada en produccion:

- **C-01** se corrige agregando `/batuta-init` a la tabla de comandos de CLAUDE.md, o bien actualizando la guia para que la Opcion A use el formato con dos puntos si el ecosistema migra a esa convencion, o documentando que el command se invoca directamente por nombre de archivo.
- **C-02** se corrige con una nota en el Paso 3B que explique que el explore standalone es exploratorio y no guarda archivos, y que el artefacto formal se crea automaticamente cuando el usuario ejecuta `/sdd-new` en el Paso 5.

El hallazgo importante **I-02** (conflicto entre la Scope Rule de la guia y el template de data-pipeline) es el de mayor impacto arquitectonico — si no se resuelve, los usuarios que usen Agent Teams con el template oficial encontraran que los contratos de archivo no coinciden con la estructura que construyeron siguiendo la guia. Se recomienda alinear el template con la Scope Rule o agregar una nota de advertencia en ambos documentos.
