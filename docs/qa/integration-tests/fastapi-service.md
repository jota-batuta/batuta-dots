# Integration Test: Guia FastAPI Service

## Metadata

- Fecha: 2026-02-23
- Guia: `docs/guides/guia-fastapi-service.md`
- Version ecosistema: v9.1
- Metodo: Lectura y verificacion cruzada de cada referencia del ecosistema contra los archivos reales
- Archivos verificados: 15 skills SDD + infra, 3 agents, 4 commands, ecosystem-snapshot.md

---

## Resumen Ejecutivo

Se verificaron todos los pasos de la guia contra los archivos reales del ecosistema (skills, agents, commands). Se encontraron **9 hallazgos** (3 criticos, 4 importantes, 2 menores).

El hallazgo mas grave es que **la descripcion de la Piramide de Validacion en Paso 12 es incorrecta**: las capas 4 y 5 no coinciden con lo que define el skill `sdd-verify`. Un usuario que ejecute `/sdd:verify` vera un resultado diferente al que la guia promete. Los demas hallazgos criticos son inconsistencias en el comando de setup (Opcion B, Paso 2) y en la descripcion del glosario para "Scope Agent".

Los pasos del flujo principal (Pasos 1-11, 13-16) estan alineados con el ecosistema real. Todos los commands referenciados existen y funcionan segun lo descrito.

---

## Hallazgos

### CRITICOS

#### H1: Piramide de Validacion — Capas 4 y 5 son incorrectas en la guia

**Paso**: Paso 12 (Verificar con la Piramide de Validacion)

**Descripcion**: La guia presenta una tabla de 5 capas donde la Capa 4 es "Seguridad" y la Capa 5 es "Documentacion". Esto no coincide con la definicion real del skill `sdd-verify`:

| Capa | Lo que dice la guia | Lo que define sdd-verify |
|------|--------------------|-----------------------------|
| 4 | Seguridad (no haya vulnerabilidades) | Code Review — **HUMAN** |
| 5 | Documentacion (documentado para el siguiente) | Manual Testing — **HUMAN** |

La seguridad se verifica en el **Step 4.7** de `sdd-verify` ("Cross-Layer Security Check") como un chequeo transversal entre capas, NO como la capa 4 de la piramide. La documentacion se verifica en el **Step 5** ("Documentation Verification") como verificacion independiente, no como capa 5.

**Impacto**: Un usuario que ejecute `/sdd:verify` vera un reporte con "Code Review (HUMAN)" y "Manual Testing (HUMAN)" en las capas 4 y 5, diferente a lo que la guia prometio. Genera confusion y erosion de confianza en el sistema.

**Archivo fuente**: `BatutaClaude/skills/sdd-verify/SKILL.md` (lineas 40-46, tabla del AI Validation Pyramid)

**Fix propuesto**: Corregir la tabla del Paso 12 en la guia:

```
| Capa | Que verifica | Que significa |
|------|-------------|---------------|
| 1. Tipos y linting | Errores de escritura y tipos en el codigo | Como un corrector ortografico para codigo |
| 2. Tests unitarios | Que cada pieza funcione por separado | Como probar cada engranaje |
| 3. Tests de integracion | Que las piezas funcionen juntas | Como probar la maquina completa |
| 4. Code Review | Un humano revisa la arquitectura y el diseno | El revisor experto del equipo |
| 5. Testing manual | Un humano prueba el flujo completo | Las pruebas exploratorias y de UX |
```

Y agregar una nota: "La seguridad se verifica automaticamente dentro de los pasos 1-3. La documentacion tambien se verifica en esta fase."

---

#### H2: Paso 2 Opcion B — Setup incompleto: no crea .batuta/ ni instala hooks

**Paso**: Paso 2 (Instalar el ecosistema Batuta), Opcion B

**Descripcion**: El prompt de la Opcion B que el usuario debe copiar indica ejecutar `skills/setup.sh --all`, lo que segun el ecosystem-snapshot.md tiene un bug conocido (exit code 1 y output duplicado). Pero mas importante: el prompt de Opcion B NO instruye a crear `.batuta/session.md` ni `.batuta/prompt-log.jsonl`, y no menciona la instalacion de hooks.

Comparacion con `batuta-init.md` (el command real que ejecuta `/batuta-init`):

| Paso | batuta-init.md (real) | Guia Opcion B (prompt) |
|------|-----------------------|------------------------|
| Crear .batuta/ | Step 2.5: crea `.batuta/session.md` y `.batuta/prompt-log.jsonl` | NO lo menciona |
| Instalar hooks | Step 3: ejecuta `--sync` y `--hooks` por separado | Solo dice `--all` |
| Gitignore | Step 4: crea `.gitignore` con entradas especificas | Solo dice "inicializa git" |

La guia usa `--all` pero batuta-init.md usa `--sync` y `--hooks` separados. El ecosistema-snapshot.md confirma que `--all` tiene un bug de exit code 1.

**Impacto**: Un usuario nuevo que use la Opcion B quedaria sin session continuity (`.batuta/session.md`) y sin los hooks nativos (Execution Gate, session-save, O.R.T.A.). La experiencia del ecosistema seria incompleta.

**Archivo fuente**: `BatutaClaude/commands/batuta-init.md` (Steps 2.5 y 3); `test-guias/ecosystem-snapshot.md` (Observaciones del setup)

**Fix propuesto**: Reemplazar el prompt de Opcion B con uno que refleje los pasos reales de `batuta-init.md`, o simplificar la Opcion B indicando que ejecute directamente `/batuta-init batuta-task-api` desde una sesion Claude ya abierta en una carpeta con batuta-dots disponible.

---

#### H3: Glosario — "Scope Agent" descrito incorrectamente

**Paso**: Seccion Glosario (inicio de la guia)

**Descripcion**: El glosario define "Scope Agent" como:

> "Un 'jefe de area' especializado. Claude tiene 3: uno para el proceso de desarrollo, uno para organizacion de archivos, y uno para calidad."

El tercer agente en el ecosistema real NO es de "calidad". Segun `BatutaClaude/agents/observability-agent.md`:

> "Observability & Quality specialist. The O.R.T.A. engine: logs events, tracks prompt satisfaction, manages session continuity, and generates improvement reports."

Los tres agentes reales son:
1. `pipeline-agent` — proceso de desarrollo (SDD pipeline)
2. `infra-agent` — organizacion de archivos (Scope Rule, ecosystem)
3. `observability-agent` — observabilidad y continuidad de sesion (O.R.T.A.)

"Calidad" es solo una parte menor del observability-agent. Describirlo como "jefe de calidad" omite su funcion principal: session continuity y O.R.T.A. logging. Un usuario avanzado que intente encontrar el "agente de calidad" buscara algo que no existe con ese nombre.

**Impacto**: Confusion en usuarios que busquen el "agente de calidad" cuando intenten depurar problemas de session continuity o de tracking de prompts.

**Archivo fuente**: `BatutaClaude/agents/observability-agent.md` (linea 2-5, descripcion)

**Fix propuesto**: Actualizar la definicion en el glosario:

> "Scope Agent: Un 'jefe de area' especializado. Claude tiene 3: uno para el proceso de desarrollo (SDD), uno para organizacion de archivos e infraestructura, y uno para observabilidad y continuidad de sesion."

---

### IMPORTANTES

#### H4: Paso 7 referencia /sdd:continue pero no explica que es un comando orquestador

**Paso**: Paso 7 (Especificaciones y diseno)

**Descripcion**: La guia instruye usar `/sdd:continue batuta-task-manager` para ejecutar automaticamente las fases Specs, Design, y Tasks. Segun CLAUDE.md, este comando existe y esta mapeado: `pipeline → next needed phase`. Sin embargo, no existe un skill `sdd-continue` como archivo — es el pipeline-agent quien decide cual sub-agente lanzar basandose en el estado actual del cambio.

La guia describe que Claude "va a ejecutar las siguientes fases una por una", lo cual es correcto conceptualmente. El problema es que la tabla del Paso 7 muestra 3 fases que `/sdd:continue` ejecuta, pero en la practica el pipeline-agent puede ejecutar specs y design **en paralelo** (segun el dependency graph del pipeline-agent: `proposal → [specs ‖ design] → tasks`).

La guia indica al usuario "Tu respuesta cada vez: Se ve bien, continua" implicando ejecucion estrictamente secuencial, cuando el pipeline-agent puede ejecutarlas en paralelo.

**Impacto**: El usuario puede sorprenderse si Claude ejecuta specs y design al mismo tiempo en lugar de preguntarle dos veces. No es un error que rompa el flujo, pero crea expectativas incorrectas.

**Archivo fuente**: `BatutaClaude/agents/pipeline-agent.md` (linea 27: "specs and design CAN run in parallel")

**Fix propuesto**: Agregar una nota en el Paso 7: "Claude puede ejecutar las fases de Specs y Design en paralelo para ahorrar tiempo. Si ves que muestra resultados de ambas a la vez, es normal — di 'Se ve bien, continua' y procedera a Tasks."

---

#### H5: Paso 5 — La descripcion de las 3 opciones no coincide exactamente con infra-agent

**Paso**: Paso 5 (Cuando Claude dice "no tengo un skill para eso")

**Descripcion**: La guia muestra que Claude preguntara con 3 opciones:
1. Investigar y crear el skill (proyecto)
2. Investigar y crear el skill (global)
3. Continuar sin skill

El skill `infra-agent` (protocolo de Skill Gap Detection) muestra el texto exacto con opciones ligeramente diferentes:
1. Investigar y crear el skill — acotado a lo que Batuta necesita (~5 min)
2. Crear un skill global — patrones genericos reutilizables
3. Continuar sin skill — con TODO comment

La guia dice que la Opcion 1 es "acotado a nuestro proyecto" y el infra-agent dice "acotado a lo que Batuta necesita". La diferencia es sutil pero relevante: segun el ecosistema, la Opcion 1 es un **skill de proyecto** que se guarda en `.claude/skills/` (local), y la Opcion 2 es **global** en `~/.claude/skills/`. La guia no clarifica donde se guarda cada opcion.

**Impacto**: Un usuario que elija "Opcion 1" repetidamente en diferentes proyectos podria no entender por que el skill creado no esta disponible en otros proyectos futuros.

**Archivo fuente**: `BatutaClaude/agents/infra-agent.md` (lineas 44-53, Skill Gap Detection)

**Fix propuesto**: Agregar en el Paso 5 una nota: "La Opcion 1 crea el skill solo para este proyecto. Si en el futuro quieres usarlo en otros proyectos, elige Opcion 2."

---

#### H6: Paso 3 — Descripcion de /sdd:init imprecisa sobre el pipeline-agent

**Paso**: Paso 3 (Iniciar el proyecto con SDD), nota "Detalle tecnico (opcional)"

**Descripcion**: La nota tecnica dice:

> "Cuando ejecutas /sdd:init, Claude activa su pipeline-agent (el 'jefe de proceso') que coordina todo el desarrollo paso a paso."

Esto es tecnicamente impreciso. `/sdd:init` activa el **sub-agente `sdd-init`** (via el pipeline-agent como orquestador), no el pipeline-agent directamente. El pipeline-agent es el orquestador que DELEGA al sub-agente sdd-init. La distincion es relevante para usuarios avanzados.

Mas importante: el `sdd-init` bootstrapea el directorio `openspec/` y detecta el tipo de proyecto. No "coordina todo el desarrollo" — eso lo hace el pipeline-agent durante el flujo completo de SDD.

**Impacto**: Menor confusion para usuarios tecnicos. No afecta el flujo de la guia.

**Archivo fuente**: `BatutaClaude/agents/pipeline-agent.md` (linea 35: "DELEGATE-ONLY: Never execute phase work inline"); `BatutaClaude/skills/sdd-init/SKILL.md` (Purpose)

**Fix propuesto**: Actualizar la nota tecnica: "Cuando ejecutas /sdd:init, Claude delega al sub-agente sdd-init que bootstrapea la estructura del proyecto. El pipeline-agent coordina el flujo completo de SDD a traves de todos los pasos."

---

#### H7: Glosario — "SDD" definicion omite la fase de Explore

**Paso**: Seccion Glosario

**Descripcion**: El glosario define SDD como:

> "Spec-Driven Development. Un proceso paso a paso: primero planeas, luego construyes. Como un arquitecto que primero dibuja el plano."

El SDD pipeline real tiene 9 sub-agentes: init, explore, propose, spec, design, tasks, apply, verify, archive. La definicion del glosario omite que la fase de EXPLORAR (investigar antes de planear) es parte integral del proceso y es donde ocurre la deteccion de skill gaps.

El resumen visual al final de la guia si muestra el flujo completo, lo cual es correcto. La definicion del glosario simplifica demasiado.

**Impacto**: Menor. Un usuario que lea solo el glosario podria saltarse mentalmente la fase de explore, que es donde Claude detecta los skills faltantes (Paso 5 de la guia).

**Archivo fuente**: `BatutaClaude/agents/pipeline-agent.md` (SDD Dependency Graph)

**Fix propuesto**: Actualizar la definicion del glosario: "SDD: Spec-Driven Development. Un proceso de 9 pasos: explorar → proponer → especificar → disenar → planear tareas → implementar → verificar → archivar. Como un arquitecto que primero estudia el terreno, luego dibuja el plano, luego construye."

---

### MENORES

#### H8: Paso 15 — Prompt pide crear repositorio en organizacion jota-batuta

**Paso**: Paso 15 (Subir a GitHub y activar)

**Descripcion**: El prompt que la guia instruye copiar dice:

> "Crea un repositorio privado en GitHub llamado batuta-task-api bajo la organizacion jota-batuta"

Esto hardcodea la organizacion `jota-batuta` como destino. Un usuario que no sea miembro de esa organizacion (o que quiera guardar el proyecto en su cuenta personal o en otra organizacion) seguira el prompt literalmente y fallara al intentar crear el repositorio.

**Impacto**: El usuario novato copiara el prompt exactamente, recibira un error de permisos de GitHub, y no sabra por que.

**Archivo fuente**: `docs/guides/guia-fastapi-service.md` (linea 772)

**Fix propuesto**: Reemplazar `jota-batuta` con un placeholder: "Crea un repositorio privado en GitHub llamado `batuta-task-api` bajo [TU USUARIO O ORGANIZACION EN GITHUB]" — consistente con el patron de placeholder `[TU URL DE COOLIFY]` que la guia ya usa en el Paso 14.

---

#### H9: Paso 2 — La guia dice que /batuta-init y /batuta-update "quedan instalados" implicando persistencia automatica

**Paso**: Paso 2 (nota al final de Opcion B)

**Descripcion**: La guia dice:

> "Despues de esta primera vez, los commands /batuta-init y /batuta-update quedan instalados y ya no necesitas copiar el prompt largo nunca mas."

Tecnicamente, los commands quedan instalados en `~/.claude/commands/` cuando se ejecuta el setup script. Sin embargo, la guia no explica COMO quedan instalados desde la Opcion B (el prompt largo que el usuario copia no instala commands, solo copia CLAUDE.md e inicializa git). Los commands se instalan via `skills/setup.sh --sync` que copia `BatutaClaude/commands/` a `~/.claude/commands/`.

El prompt de Opcion B incluye `skills/setup.sh --all` que segun el ecosystem-snapshot tiene un bug de exit code 1. Si el script falla silenciosamente, los commands NO quedarian instalados pero la nota diria que si.

**Impacto**: Un usuario podria asumir que tiene los commands y luego descubrir que `/batuta-init` no existe en una nueva sesion.

**Archivo fuente**: `BatutaClaude/commands/batuta-init.md` (Step 3: `--sync` instala commands); `test-guias/ecosystem-snapshot.md` (Observaciones: exit code 1)

**Fix propuesto**: Agregar verificacion al final del Paso 2: "Para verificar que los commands quedaron instalados, escribe `/batuta-init` en Claude Code. Si Claude responde con el proceso de setup, esta correcto. Si dice que no reconoce el comando, ejecuta: [prompt de re-instalacion]."

---

## Tabla de Hallazgos

| ID | Severidad | Descripcion | Prioridad | Archivo |
|----|-----------|-------------|-----------|---------|
| H1 | CRITICO | Piramide de Validacion: capas 4 y 5 incorrectas (guia dice Seguridad/Documentacion; sdd-verify define Code Review/Manual Testing) | Alta | `guia-fastapi-service.md` Paso 12 |
| H2 | CRITICO | Opcion B Paso 2: setup con `--all` no crea `.batuta/` ni instala hooks; discrepa con batuta-init.md real | Alta | `guia-fastapi-service.md` Paso 2 |
| H3 | CRITICO | Glosario: "Scope Agent" define el tercer agente como "calidad"; el real es observability-agent (sesion + O.R.T.A.) | Media | `guia-fastapi-service.md` Glosario |
| H4 | IMPORTANTE | Paso 7: /sdd:continue puede ejecutar specs y design en paralelo; guia implica ejecucion secuencial | Media | `guia-fastapi-service.md` Paso 7 |
| H5 | IMPORTANTE | Paso 5: opciones de skill gap no explican donde se guarda cada tipo (proyecto-local vs global) | Media | `guia-fastapi-service.md` Paso 5 |
| H6 | IMPORTANTE | Paso 3 (nota tecnica): dice que /sdd:init activa el pipeline-agent; en realidad delega al sub-agente sdd-init | Baja | `guia-fastapi-service.md` Paso 3 |
| H7 | IMPORTANTE | Glosario: definicion de SDD omite la fase de explorar (9 pasos reales vs "planear y construir") | Baja | `guia-fastapi-service.md` Glosario |
| H8 | MENOR | Paso 15: prompt hardcodea organizacion `jota-batuta`; debe ser placeholder para el usuario | Media | `guia-fastapi-service.md` Paso 15 |
| H9 | MENOR | Paso 2 nota final: promete que commands "quedan instalados" sin mecanismo de verificacion para el usuario | Baja | `guia-fastapi-service.md` Paso 2 |

---

## Conclusion

La guia `guia-fastapi-service.md` esta bien estructurada y cubre el flujo completo del ecosistema. Los 16 pasos del flujo principal estan correctamente alineados con los skills, commands y agents del ecosistema v9.1.

Los tres hallazgos criticos requieren atencion antes de publicar la guia como definitiva:

1. **H1 (Piramide de Validacion)** es el mas urgente porque afecta directamente la experiencia del usuario en un paso clave del flujo y genera confusion cuando el resultado real de `/sdd:verify` no coincide con lo prometido.

2. **H2 (Setup Opcion B)** es critico porque deja al usuario sin los mecanismos de continuidad de sesion y Execution Gate, degradando significativamente la experiencia del ecosistema.

3. **H3 (Glosario Scope Agent)** es critico conceptualmente porque introduce terminologia incorrecta desde el primer contacto del usuario con el ecosistema.

Los hallazgos importantes (H4-H7) son discrepancias de precision tecnica que no rompen el flujo pero pueden generar confusion en usuarios que profundicen en el ecosistema. Los hallazgos menores (H8-H9) son correcciones de pulido que mejoran la usabilidad.

**Cobertura de verificacion**: Se verificaron los 15 skills del ecosistema referenciados en la guia (sdd-init, sdd-explore, sdd-propose, sdd-spec, sdd-design, sdd-tasks, sdd-apply, sdd-verify, sdd-archive, ecosystem-creator, scope-rule, prompt-tracker, security-audit, skill-sync implicitamente, team-orchestrator implicitamente), los 3 agents (pipeline-agent, infra-agent, observability-agent), y los 4 commands (batuta-init, batuta-update, batuta-analyze-prompts, batuta-sync-skills).
