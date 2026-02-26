# Integration Test: guia-nextjs-saas.md (REVALIDACION v9.1)

**Fecha**: 2026-02-23
**Version ecosistema**: 9.1.0
**Agente**: A10
**Guia**: docs/guides/guia-nextjs-saas.md
**Reporte anterior**: docs/qa/integration-tests/nextjs-saas.md

## Resumen de Revalidacion

De los **12 hallazgos originales**, se revalidaron todos contra el estado actual del ecosistema v9.1:

| Categoria | Cantidad |
|-----------|----------|
| Corregidos | 8 |
| Parcialmente corregidos | 2 |
| Persisten sin cambios | 2 |
| Nuevos hallazgos | 3 |
| **Total abiertos** | **7** |

Las correcciones mas significativas de v9.1 fueron: `setup.sh --hooks` (nuevo flag), `setup.sh --project <path>` (nuevo flag con creacion de .batuta/), dual-path gap detection en infra-agent, y 3 destinos en ecosystem-creator. Sin embargo, persisten discrepancias entre lo que la guia promete y lo que el ecosistema realmente hace para ciertos flujos.

---

## Estado de Hallazgos Anteriores

### H1 (original): La guia no dice que hacer si la carpeta ya existe con contenido
- **Estado**: CORREGIDO
- **Evidencia**: La guia ahora incluye en Paso 1 (linea 135):
  > "Nota: Si la carpeta ya tiene archivos de un intento anterior, borra su contenido primero o usa otra carpeta vacia."
- **Archivo verificado**: `docs/guides/guia-nextjs-saas.md` linea 135

---

### H2 (original): setup.sh --all NO copia CLAUDE.md al proyecto destino
- **Estado**: PARCIALMENTE CORREGIDO
- **Evidencia**:
  - `setup.sh --all` ahora ejecuta `generate_claude()` que copia `BatutaClaude/CLAUDE.md` a `$REPO_ROOT/CLAUDE.md` (la raiz de batuta-dots). Esto es correcto para el flujo `--all` cuando se ejecuta desde batuta-dots.
  - Se agrego el flag `--project <path>` que SI copia CLAUDE.md al directorio destino del usuario (`$target_dir/CLAUDE.md`, linea 129 de setup.sh).
  - **El problema parcial**: La guia Opcion A (`/batuta-init`) funciona correctamente — el command `batuta-init.md` tiene Step 2 que copia `BatutaClaude/CLAUDE.md` a `./CLAUDE.md` del proyecto. Sin embargo, la guia Opcion B (el prompt manual en Paso 2) dice "Ejecuta el script skills/setup.sh --all" que copia CLAUDE.md a batuta-dots root, NO al proyecto del usuario. Aunque el prompt tambien dice "Copia el archivo BatutaClaude/CLAUDE.md a la raiz de este proyecto como CLAUDE.md" (paso 3), esto depende de que Claude interprete correctamente la instruccion en el contexto del proyecto del usuario.
- **Archivos verificados**: `skills/setup.sh` lineas 86-99 (generate_claude), 105-207 (setup_project), `BatutaClaude/commands/batuta-init.md` lineas 33-37

---

### H3 (original): setup.sh --all NO crea .batuta/ directory
- **Estado**: PARCIALMENTE CORREGIDO
- **Evidencia**:
  - Se agrego el flag `--project <path>` que SI crea `.batuta/session.md` (lineas 136-176 de setup.sh).
  - El command `/batuta-init` tambien crea `.batuta/` en su Step 2.5 (lineas 39-59 de batuta-init.md).
  - **El problema parcial**: `setup.sh --all` sigue SIN crear `.batuta/`. La guia Opcion B dice "Ejecuta el script skills/setup.sh --all" pero `--all` ejecuta: `sync_claude` + `sync_agents` + `run_skill_sync` + `install_hooks` + `generate_claude`. Ninguna de estas funciones crea `.batuta/`. La guia promete que se creara `.batuta/session.md` (lineas 202-203), pero para un usuario que sigue Opcion B, este archivo NO se crearia a menos que Claude interprete el paso 3 del prompt manual como una instruccion para crearlos.
  - La Opcion A (`/batuta-init`) SI funciona correctamente para este caso.
- **Archivos verificados**: `skills/setup.sh` lineas 447-468 (do_all), 105-207 (setup_project), `BatutaClaude/commands/batuta-init.md` lineas 39-59

---

### H4 (original): setup.sh --all NO instala hooks nativos
- **Estado**: CORREGIDO
- **Evidencia**:
  - `setup.sh --all` ahora llama a `install_hooks` (linea 462 de setup.sh) que merge los 6 hooks de `BatutaClaude/settings.json` al `~/.claude/settings.json` del usuario.
  - La funcion `install_hooks` (lineas 213-250) hace backup del settings.json existente, merge via jq o python3, y preserva hooks/env/permissions existentes del usuario.
  - Se agrego tambien el flag `--hooks` para instalacion independiente.
  - Los 6 hooks estan definidos en `BatutaClaude/settings.json`: SessionStart, PreToolUse (Execution Gate), PostToolUse (prompt-tracker), Stop (2 hooks: command + prompt), TeammateIdle, TaskCompleted.
- **Archivos verificados**: `skills/setup.sh` lineas 213-318 (install_hooks, _merge_settings_jq, _merge_settings_python), linea 462 (llamada desde do_all), `BatutaClaude/settings.json` lineas 12-44

---

### H5 (original): sdd-init referencia artifact_store.mode sin documentar donde viene
- **Estado**: CORREGIDO
- **Evidencia**:
  - `pipeline-agent.md` ahora documenta el Artifact Store en lineas 73-75:
    > "The SDD pipeline stores artifacts in `openspec/` by default (`artifact_store.mode = openspec`). Each change gets its own directory: `openspec/changes/{change-name}/`. This is used by all 9 SDD phase skills and should not be changed unless migrating to a different artifact backend."
  - Ademas, el `ecosystem-creator/SKILL.md` documenta los 4 modos en la seccion "Sub-Agent Persistence Rules" (lineas 326-333): `openspec`, `engram`, `none`, `auto`.
  - 12 archivos del ecosistema referencian `artifact_store` de forma consistente.
- **Archivos verificados**: `BatutaClaude/agents/pipeline-agent.md` lineas 73-75, `BatutaClaude/skills/ecosystem-creator/SKILL.md` lineas 326-333

---

### H6 (original): sdd-explore tiene Stack Awareness hardcodeado del stack Batuta
- **Estado**: CORREGIDO
- **Evidencia**:
  - `sdd-explore/SKILL.md` ahora incluye la nota en linea 26:
    > "Note: The table below shows the default Batuta stack. If the project has an `openspec/config.yaml` with a `stack` field, adapt the exploration to the project's actual stack instead."
  - El skill tambien recibe `openspec/config.yaml` como input del orquestador (linea 51).
  - Los demas skills (sdd-propose, sdd-design, sdd-apply) tambien referencian `openspec/config.yaml` con reglas como `rules.proposal`, `rules.design`, `rules.apply`.
  - Cada skill tiene un comentario `<!-- Stack Awareness: contextualized for this phase. See sdd-explore for base reference. -->` que establece sdd-explore como la referencia canonica.
- **Archivos verificados**: `BatutaClaude/skills/sdd-explore/SKILL.md` lineas 24-26, 49-51. Skills sdd-propose, sdd-design, sdd-apply todos referencian `openspec/config.yaml`.

---

### H7 (original): .batuta/ no se crea hasta que hooks lo hagan
- **Estado**: CORREGIDO
- **Evidencia**: Este hallazgo estaba cubierto por H3. Con la adicion de `--project <path>` y el command `/batuta-init` (Step 2.5), `.batuta/` se crea durante el setup inicial, antes de que los hooks necesiten ejecutarse. La misma advertencia parcial de H3 aplica para Opcion B.
- **Archivo verificado**: `BatutaClaude/commands/batuta-init.md` lineas 39-59, `skills/setup.sh` lineas 136-176

---

### H8 (original): Skill Gap Detection solo checkea ~/.claude/skills/ (global), no .claude/skills/ (local)
- **Estado**: CORREGIDO
- **Evidencia**:
  - `infra-agent.md` ahora dice en linea 40:
    > "Before writing code that uses a technology, framework, or pattern, CHECK if a skill exists in `~/.claude/skills/` (global) OR `.claude/skills/` (project-local)."
  - La seccion "When to trigger" (lineas 58-59) tambien especifica ambas rutas:
    > "Technology not in `~/.claude/skills/` (global) nor `.claude/skills/` (project-local)"
  - El CLAUDE.md router (linea 89) solo dice `~/.claude/skills/` pero referencia al infra-agent para el flujo completo, donde si se documentan ambas rutas.
- **Archivos verificados**: `BatutaClaude/agents/infra-agent.md` lineas 40, 58-59

---

### H9 (original): ecosystem-creator Registration Checklist no menciona ruta de destino
- **Estado**: CORREGIDO
- **Evidencia**:
  - `ecosystem-creator/SKILL.md` ahora tiene una tabla de destino explicita en la seccion "Skill Registration Checklist" (lineas 386-393):
    | Scope | Destination | When to use |
    |-------|-------------|-------------|
    | Project-local | `.claude/skills/{skill-name}/SKILL.md` | Only this project needs it |
    | Global | `~/.claude/skills/{skill-name}/SKILL.md` | All projects benefit from it |
    | Batuta repo | `BatutaClaude/skills/{skill-name}/SKILL.md` | Developing the ecosystem itself |
  - La seccion "Auto-Discovery Flow" (lineas 496-502) tambien documenta los 3 destinos en el paso REGISTER.
- **Archivo verificado**: `BatutaClaude/skills/ecosystem-creator/SKILL.md` lineas 386-402, 496-502

---

### H10 (original): ecosystem-creator no distingue ruta de destino (local vs global vs batuta-dots)
- **Estado**: CORREGIDO
- **Evidencia**: Cubierto por H9. El ecosystem-creator ahora tiene:
  1. Tabla de 3 destinos en Registration Checklist (lineas 386-393)
  2. Scope Decision como paso 2 del Auto-Discovery Flow (linea 475)
  3. Auto-Discovery Scope Options table (lineas 507-510) distinguiendo project-specific vs global
  4. El paso REGISTER del Auto-Discovery (lineas 498-502) mapea destino a scope decision
- **Archivo verificado**: `BatutaClaude/skills/ecosystem-creator/SKILL.md` lineas 386-402, 460-502

---

### H11 (original): Stack Awareness duplicado en 7 archivos (DRY violation)
- **Estado**: PERSISTE
- **Evidencia**:
  - Stack Awareness sigue presente en 7 archivos: sdd-explore, sdd-propose, sdd-design, sdd-init, sdd-apply, scope-rule, sub-agent-template.md.
  - Sin embargo, se agrego una mitigacion: cada instancia tiene un comentario HTML `<!-- Stack Awareness: contextualized for this phase. See sdd-explore for base reference. -->` que establece sdd-explore como referencia canonica.
  - Las tablas NO son identicas entre skills — cada una esta contextualizada para su fase:
    - sdd-explore: tabla basica con Layers/Technology
    - sdd-propose: tabla con Layers/Technologies/Common Considerations
    - sdd-design: tabla con Layer/Technology/Notes
    - sdd-apply: tabla con Technology/Domain/Key Considerations
    - sdd-init: formato lista sin tabla
    - scope-rule: tabla con Stack Component/Scope Rule Application
    - sub-agent-template: tabla generica placeholder
  - **El DRY violation es intencional**: cada skill contextualiza la misma informacion de forma diferente para su fase. Sin embargo, si se agrega una nueva tecnologia al stack (ej. Supabase), habria que actualizar 7 archivos manualmente.
- **Archivos verificados**: Los 7 archivos listados arriba, confirmado via grep.

---

### H12 (original): /sdd-continue no documenta el dependency graph
- **Estado**: CORREGIDO
- **Evidencia**:
  - `pipeline-agent.md` ahora documenta el SDD Dependency Graph (lineas 24-30):
    ```
    proposal -> [specs || design] -> tasks -> apply -> verify -> archive
    ```
  - Incluye la nota: "specs and design CAN run in parallel. Both MUST complete before tasks."
  - Tambien documenta que "Each phase produces artifacts that feed downstream phases" y que "apply also invokes infra-agent for Scope Rule file placement."
  - Ademas, el Sub-Agent Output Contract (lineas 43-53) incluye `next_recommended` que ayuda al orquestador a determinar la siguiente fase.
- **Archivo verificado**: `BatutaClaude/agents/pipeline-agent.md` lineas 24-30, 43-53

---

## Nuevos Hallazgos

### N1: Guia Opcion B (prompt manual) no crea .batuta/ porque usa --all en vez de --project
- **Severidad**: IMPORTANTE
- **Ubicacion**: Paso 2 de la guia, Opcion B (lineas 186-194)
- **Lo que dice la guia**: El prompt manual dice "Ejecuta el script skills/setup.sh --all para copiar CLAUDE.md, sincronizar skills e instalar hooks". Luego la guia promete (lineas 200-203): "Cuando termine, te dira que archivos creo, incluyendo: `.batuta/session.md`"
- **Lo que hace el ecosistema**: `setup.sh --all` ejecuta sync_claude + sync_agents + run_skill_sync + install_hooks + generate_claude. NINGUNA de estas funciones crea `.batuta/`. Solo `setup.sh --project <path>` crea `.batuta/`. El `generate_claude` copia CLAUDE.md a `$REPO_ROOT` (batuta-dots), no al proyecto del usuario.
- **Impacto en el usuario**: Un usuario que sigue Opcion B (primera vez sin commands) y Claude ejecuta literalmente el prompt, no obtendria `.batuta/session.md`. La session continuity no funcionaria hasta que los hooks lo crearan. El fix es cambiar el prompt de Opcion B para que diga `setup.sh --project <path>` en vez de `--all`, o agregar pasos explicitos para crear `.batuta/`.
- **Nota**: La Opcion A (`/batuta-init`) SI funciona correctamente porque el command `batuta-init.md` tiene Step 2.5 que crea `.batuta/` y Step 3 que ejecuta `--sync` + `--hooks`.

---

### N2: /sdd-continue descrito como "ver estado del proyecto" en Comandos de Emergencia
- **Severidad**: IMPORTANTE
- **Ubicacion**: Seccion "Comandos de emergencia" (linea 1118)
- **Lo que dice la guia**:
  | Quieres ver el estado del proyecto | `/sdd-continue mi-saas-app` (te muestra donde quedamos) |
- **Lo que hace el ecosistema**: Segun CLAUDE.md linea 105: `/sdd-continue [change-name]` -> `pipeline -> next needed phase`. Segun pipeline-agent.md: el comando ejecuta la SIGUIENTE fase pendiente del dependency graph (`proposal -> [specs || design] -> tasks -> apply -> verify -> archive`). No es un comando de consulta — es un comando de EJECUCION.
- **Impacto en el usuario**: Un usuario no tecnico que quiere "ver donde quedo" ejecuta `/sdd-continue` y Claude avanza una fase del pipeline SDD que el usuario no estaba listo para ejecutar. Esto podria crear artifacts no deseados o avanzar el pipeline prematuramente. El comando correcto para ver estado seria leer `.batuta/session.md` o preguntar a Claude directamente.
- **Nota**: Este mismo problema fue encontrado en los integration tests de guia-batuta-app (HALLAZGO-02) y guia-cli-python (hallazgo 3), pero NO fue corregido en guia-nextjs-saas.

---

### N3: Paso 3 y Paso 5 pueden causar doble exploracion innecesaria
- **Severidad**: MENOR
- **Ubicacion**: Paso 3 (lineas 218-232) y Paso 5 (lineas 330-333)
- **Lo que dice la guia**:
  - Paso 3: "Primero, inicializa el proyecto SDD: `/sdd-init`". Luego: "Ahora, explora los requisitos: `/sdd-explore mi-saas-app`"
  - Paso 5: "Copia y pega: `/sdd-new mi-saas-app`"
- **Lo que hace el ecosistema**: Segun CLAUDE.md linea 104: `/sdd-new <change-name>` -> `pipeline -> sdd-explore -> sdd-propose`. Es decir, `/sdd-new` INCLUYE una exploracion automatica seguida de la propuesta. Si el usuario ya ejecuto `/sdd-explore` en Paso 3, el `/sdd-new` en Paso 5 re-ejecutaria la exploracion.
- **Impacto en el usuario**: El usuario pierde 3-5 minutos en una exploracion duplicada. No rompe nada, pero es ineficiente y puede confundir al usuario que ya vio la exploracion. El fix seria: (a) en Paso 5, usar directamente el skill sdd-propose en vez de /sdd-new, o (b) documentar que /sdd-new re-usa la exploracion existente si ya hay un `explore.md`, o (c) en Paso 3 no usar /sdd-explore por separado y dejar que /sdd-new lo haga todo.

---

## Metricas

| Metrica | Valor |
|---------|-------|
| Hallazgos anteriores | 12 |
| Corregidos | 8 |
| Parcialmente corregidos | 2 |
| Persisten sin cambios | 2 |
| Nuevos hallazgos | 3 |
| Total abiertos | 7 |

### Desglose de abiertos

| # | Hallazgo | Severidad | Tipo |
|---|----------|-----------|------|
| H2 | setup.sh --all copia CLAUDE.md a batuta-dots root, no al proyecto (Opcion B) | IMPORTANTE | Parcial |
| H3 | setup.sh --all no crea .batuta/ (Opcion B) | IMPORTANTE | Parcial |
| H11 | Stack Awareness duplicado en 7 archivos (DRY) | MENOR | Persiste (mitigado con comentarios) |
| N1 | Opcion B prompt manual no logra crear .batuta/ | IMPORTANTE | Nuevo |
| N2 | /sdd-continue descrito como "ver estado" cuando ejecuta la siguiente fase | IMPORTANTE | Nuevo |
| N3 | Paso 3 + Paso 5 causan doble exploracion | MENOR | Nuevo |

**Nota**: H2 parcial, H3 parcial, y N1 estan relacionados — todos apuntan al mismo problema: la Opcion B del Paso 2 usa `setup.sh --all` en vez de `setup.sh --project <path>`. Corregir N1 resolveria H2 parcial y H3 parcial simultaneamente.

### Fix propuesto consolidado

| Prioridad | Fix | Archivos | Esfuerzo |
|-----------|-----|----------|----------|
| P0 | Cambiar Opcion B prompt para usar `--project` o agregar pasos de .batuta/ | `docs/guides/guia-nextjs-saas.md` | Bajo |
| P1 | Corregir entrada de /sdd-continue en Comandos de Emergencia | `docs/guides/guia-nextjs-saas.md` | Bajo |
| P2 | Resolver doble exploracion Paso 3 + Paso 5 | `docs/guides/guia-nextjs-saas.md` | Bajo |
| P3 | Evaluar centralizacion de Stack Awareness (DRY) | 7 skills | Alto |

---

## Conclusion

El ecosistema v9.1 resolvio correctamente los 4 hallazgos criticos mas importantes del reporte original: hooks ahora se instalan con `--all` (H4), `.batuta/` se puede crear con `--project` (H3), gap detection chequea ambas rutas (H8), y ecosystem-creator tiene 3 destinos (H10).

El gap principal restante es que la **Opcion B de la guia** (prompt manual para primera vez) no aprovecha los nuevos flags de v9.1. Usa `--all` cuando deberia usar `--project <path>` o el command `/batuta-init`. Este es un problema de documentacion, no de codigo.

El hallazgo N2 (`/sdd-continue` como "ver estado") es un problema recurrente detectado en 3 guias diferentes (batuta-app, cli-python, nextjs-saas) y aun no se ha corregido en ninguna de ellas.

La calidad general de la guia es alta: el glosario es excelente para usuarios no tecnicos, los pasos son claros y secuenciales, y las secciones de troubleshooting y seguridad agregan valor real. Los problemas pendientes son todos de baja complejidad de correccion.
