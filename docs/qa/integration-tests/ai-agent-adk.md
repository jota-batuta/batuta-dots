# Integration Test: guia-ai-agent-adk.md
**Fecha**: 2026-02-23
**Version ecosistema**: 9.1.0
**Agente**: A6
**Guia**: docs/guides/guia-ai-agent-adk.md

## Resumen Ejecutivo

La guia es funcional y lleva a un usuario no tecnico desde cero hasta un agente de IA operativo. Sin embargo, contiene discrepancias en la sintaxis de comandos SDD (usa `/sdd-new` para proposal cuando el ecosistema define este comando como explore+propose, no solo propose), una referencia a un comando inexistente como slash command (`/batuta:analyze-prompts` vs el real `/batuta-analyze-prompts`), y la estructura de proyecto sugerida viola parcialmente la Scope Rule al poner `features/security/` separado de `features/agent/`. Son problemas menores e importantes pero ninguno es critico: el usuario puede completar el proyecto entero si Claude interpreta correctamente la intencion.

## Hallazgos

### H1: Comando /batuta-init acepta argumento pero la guia no usa la sintaxis real
- **Severidad**: MENOR
- **Ubicacion**: Paso 2, linea 169
- **Lo que dice la guia**: `/batuta-init batuta-ai-agent`
- **Lo que hace el ecosistema**: El command `batuta-init.md` tiene frontmatter `argument-hint: "[project-name]"` y en el Step 5 dice "If a project name was provided as argument ($ARGUMENTS), mention it in the confirmation". El comando acepta el argumento.
- **Impacto en el usuario**: Ninguno negativo. La sintaxis es correcta. El comando funciona con o sin argumento. Solo se documenta para completitud.

### H2: La guia dice que /batuta-init crea archivos, pero falta mencionar skills sincronizados y hooks
- **Severidad**: MENOR
- **Ubicacion**: Paso 2, lineas 172-176
- **Lo que dice la guia**: "Crea: CLAUDE.md, .batuta/session.md"
- **Lo que hace el ecosistema**: El command `batuta-init.md` hace mucho mas: copia CLAUDE.md, crea .batuta/, sincroniza skills con `--sync`, instala hooks con `--hooks`, e inicializa git. La confirmacion final del comando dice "Skills sincronizados a ~/.claude/skills/ (X skills)" y "Hooks instalados en ~/.claude/settings.json (6 hooks + permissions)".
- **Impacto en el usuario**: Menor. El usuario se sorprendera de que pasan mas cosas de las que la guia dice. No es un error — es una subestimacion. Claude seguira el command spec real internamente.

### H3: La guia alternativa al /batuta-init sugiere setup.sh --all, que no sincroniza solo skills
- **Severidad**: MENOR
- **Ubicacion**: Paso 2, lineas 179-188
- **Lo que dice la guia**: "Ejecuta el script skills/setup.sh --all para copiar CLAUDE.md, sincronizar skills e instalar hooks"
- **Lo que hace el ecosistema**: `setup.sh --all` ejecuta `do_all()` que hace: sync_claude (skills + commands), sync_agents, run_skill_sync, install_hooks, generate_claude. Esto es correcto y completo. Sin embargo, la guia luego dice "Copia el archivo BatutaClaude/CLAUDE.md a la raiz de este proyecto como CLAUDE.md" como paso separado, pero `--all` ya hace eso (`generate_claude` al final). Paso redundante pero no danino.
- **Impacto en el usuario**: El usuario ejecutaria una copia redundante del CLAUDE.md. Sin consecuencias negativas.

### H4: /sdd-new en Paso 4 esta documentado para propose, pero el ecosistema lo define como explore + propose
- **Severidad**: IMPORTANTE
- **Ubicacion**: Paso 4, linea 282
- **Lo que dice la guia**: `/sdd-new batuta-ai-agent` — "Crea una propuesta que incluye que framework eligio y por que"
- **Lo que hace el ecosistema**: En CLAUDE.md, la tabla SDD Commands dice: `/sdd-new <change-name>` -> `pipeline -> sdd-explore -> sdd-propose`. Es decir, `/sdd-new` NO solo crea la propuesta: primero ejecuta explore y LUEGO propose. Esto significa que si el usuario ya ejecuto `/sdd-explore` en el Paso 3, `/sdd-new` en el Paso 4 repetira la exploracion.
- **Impacto en el usuario**: El usuario duplicaria la fase de exploracion. Claude ejecutaria explore de nuevo (gastando tokens y tiempo) y luego propose. La guia deberia usar `/sdd-continue batuta-ai-agent` en el Paso 4 (que ejecuta "next needed phase", es decir propose despues de explore) o directamente indicar que se salte el Paso 3 si se va a usar `/sdd-new` en el Paso 4.

### H5: /sdd-continue en Paso 5 es correcto y ejecuta las fases pendientes
- **Severidad**: (No es hallazgo negativo)
- **Ubicacion**: Paso 5, linea 306
- **Lo que dice la guia**: `/sdd-continue batuta-ai-agent` — "Ejecuta tres fases seguidas: Specs, Design, Tasks"
- **Lo que hace el ecosistema**: CLAUDE.md: `/sdd-continue [change-name]` -> `pipeline -> next needed phase`. El pipeline-agent ejecuta las fases pendientes segun el dependency graph `proposal -> [specs || design] -> tasks`. Si proposal ya esta completa, ejecutara specs, design, y tasks. La guia es correcta.
- **Impacto en el usuario**: Positivo. Funciona como se describe.

### H6: Paso 6 describe Skill Gap Detection con "Opcion 1" pero el ecosistema tiene 3 opciones con texto distinto
- **Severidad**: IMPORTANTE
- **Ubicacion**: Paso 6, lineas 336-348
- **Lo que dice la guia**: "Tu respuesta siempre debe ser: Opcion 1 -- Investiga y crea el skill acotado a nuestro proyecto"
- **Lo que hace el ecosistema**: El `infra-agent.md` dice que cuando se detecta un gap, el mensaje ofrece: "1. Investigar y crear el skill (...) 2. Crear un skill global (...) 3. Continuar sin skill". El `sdd-explore` SKILL.md dice: "(1) Proyecto local, (2) Global batuta-dots, (3) Continuar sin skill". El texto exacto que Claude presentara al usuario dice "Cual prefieres?" y las opciones son: 1 = skill acotado a Batuta, 2 = skill global generico, 3 = continuar sin skill.
- **Impacto en el usuario**: El texto de la guia ("Opcion 1 -- Investiga y crea el skill acotado a nuestro proyecto") es una simplificacion valida. Sin embargo, el usuario necesita saber que Claude presentara las opciones con texto ligeramente distinto al de la guia. Si el usuario no lee el texto de Claude y solo dice "Opcion 1", funcionara correctamente. Impacto bajo pero la discrepancia en la descripcion podria confundir.

### H7: /sdd-apply en Paso 7 es correcto
- **Severidad**: (No es hallazgo negativo)
- **Ubicacion**: Paso 7, linea 359
- **Lo que dice la guia**: `/sdd-apply batuta-ai-agent` — "Antes de escribir codigo, ejecuta el Execution Gate"
- **Lo que hace el ecosistema**: CLAUDE.md: `/sdd-apply [change-name]` -> `pipeline -> sdd-apply (+ infra for Scope Rule)`. El sdd-apply SKILL.md Step 0 dice "Verify Execution Gate ran for this task". El PreToolUse hook en settings.json valida con matcher `Write|Edit`. La descripcion es correcta.
- **Impacto en el usuario**: Positivo. Funciona como se describe.

### H8: Pasos 8-9-10 usan prompts en lenguaje natural en lugar de comandos SDD
- **Severidad**: MENOR
- **Ubicacion**: Pasos 8-10, lineas 410-506
- **Lo que dice la guia**: Prompts largos en lenguaje natural para implementar tools, memoria, y optimizar prompts
- **Lo que hace el ecosistema**: Estos pasos NO usan comandos SDD. Son instrucciones directas a Claude. Esto es valido: Claude interpreta lenguaje natural. Sin embargo, estos pasos podrian conflictar con el Execution Gate que requiere validacion antes de escribir archivos. Claude pedira confirmacion del gate antes de cada cambio significativo, lo cual la guia no menciona explicitamente en estos pasos (solo lo menciona en el Paso 7).
- **Impacto en el usuario**: El usuario vera el Execution Gate activarse en los Pasos 8-10 (no solo en Paso 7). La guia solo advierte sobre el gate en Paso 7 pero en realidad aparecera en CADA paso que modifique archivos. Un usuario no preparado podria confundirse al ver la pregunta "Procedo?" repetidamente.

### H9: Paso 11 sugiere auditoria de seguridad como prompt manual, no invoca security-audit skill
- **Severidad**: MENOR
- **Ubicacion**: Paso 11, lineas 528-558
- **Lo que dice la guia**: Un prompt largo manual de 5 puntos de seguridad
- **Lo que hace el ecosistema**: Existe el skill `security-audit` con 10 puntos (no 5), un Threat Model Template, Secrets Scanning Protocol, Dependency Audit Protocol, y Claude Security section. El security-audit es un skill formal con auto_invoke triggers como "Security review or audit of code". Claude deberia auto-invocar el skill cuando el usuario pida una auditoria de seguridad.
- **Impacto en el usuario**: El prompt manual de 5 puntos funcionara pero es menos completo que el security-audit skill (10 puntos). Claude probablemente cargara el skill automaticamente dado el trigger, pero seguira las instrucciones del prompt del usuario que solo pide 5 puntos. El resultado sera una auditoria mas limitada de lo que el ecosistema puede ofrecer. Idealmente la guia deberia decir "Claude ejecutara su skill de seguridad automaticamente" o simplemente pedir "Ejecuta una auditoria de seguridad completa del proyecto".

### H10: /sdd-verify en Paso 12 es correcto
- **Severidad**: (No es hallazgo negativo)
- **Ubicacion**: Paso 12, linea 574
- **Lo que dice la guia**: `/sdd-verify batuta-ai-agent`
- **Lo que hace el ecosistema**: CLAUDE.md: `/sdd-verify [change-name]` -> `pipeline -> sdd-verify`. El sdd-verify SKILL.md implementa el AI Validation Pyramid completo (5 capas), verificacion de specs, design, documentacion, y O.R.T.A. Correcto.
- **Impacto en el usuario**: Positivo. Funciona como se describe.

### H11: /batuta:analyze-prompts usa sintaxis diferente al comando real
- **Severidad**: IMPORTANTE
- **Ubicacion**: Seccion "Despues de la entrega", linea 836
- **Lo que dice la guia**: `/batuta:analyze-prompts`
- **Lo que hace el ecosistema**: En CLAUDE.md el comando se lista como `/batuta:analyze-prompts` (con dos puntos). PERO el command file real es `BatutaClaude/commands/batuta-analyze-prompts.md` (con guiones). Claude Code registra los commands como slash commands usando el nombre del archivo sin extension: `/batuta-analyze-prompts` (con guiones, no dos puntos). La tabla de SDD Commands en CLAUDE.md muestra `/batuta:analyze-prompts` como mapping conceptual, pero el archivo de comando real se llama `batuta-analyze-prompts.md`.
- **Impacto en el usuario**: Si el usuario escribe `/batuta:analyze-prompts` (con dos puntos), Claude Code buscara un command con ese nombre. Los commands de Claude Code se invocan por nombre de archivo, no por la tabla de mapping. El archivo se llama `batuta-analyze-prompts.md`, asi que el slash command real seria `/batuta-analyze-prompts`. El usuario podria obtener un error "command not found" o Claude podria interpretar el `:` como parte de la sintaxis SDD y rutearlo diferente. Sin embargo, este problema existe en el CLAUDE.md principal tambien, no solo en la guia. La guia hereda la discrepancia del propio ecosistema.

### H12: Estructura de proyecto sugerida tiene tensiones con la Scope Rule
- **Severidad**: IMPORTANTE
- **Ubicacion**: Seccion "Estructura esperada del proyecto", lineas 843-883
- **Lo que dice la guia**: `features/tools/` como carpeta separada de `features/agent/` y `features/security/` como carpeta separada
- **Lo que hace el ecosistema**: La Scope Rule dice: "1 feature -> features/{feature}/{type}/". Las tools del agente (document_search, web_search, calculator, etc.) son consumidas SOLO por el agente. Segun la Scope Rule, deberian estar en `features/agent/tools/` (una subcarpeta del feature agent), no en `features/tools/` como carpeta hermana del agente. Lo mismo con `features/memory/` y `features/security/` — si solo el agente los usa, deberian estar dentro de `features/agent/`. Si 2+ features los usan, deberian estar en `features/shared/`.
- **Impacto en el usuario**: Cuando Claude ejecute la Scope Rule (via el skill scope-rule o el Execution Gate), podria proponer una estructura diferente a la que muestra la guia. Esto generaria confusion: el usuario espera la estructura de la guia pero Claude propone otra. Claude seguira la Scope Rule (es "ALWAYS enforce" segun CLAUDE.md), que tiene prioridad sobre la guia.

### H13: La referencia al team template ai-agent.md es correcta
- **Severidad**: (No es hallazgo negativo)
- **Ubicacion**: Seccion "Agent Teams", linea 751
- **Lo que dice la guia**: "Referencia completa del equipo para agentes de IA: teams/templates/ai-agent.md"
- **Lo que hace el ecosistema**: El archivo `teams/templates/ai-agent.md` existe y contiene la composicion (agent-dev, prompt-engineer, security-reviewer), contratos, file ownership map, cross-review, y flujo de ejecucion. La referencia es correcta.
- **Impacto en el usuario**: Positivo.

### H14: El team template usa `src/` como raiz, la guia usa `features/`
- **Severidad**: MENOR
- **Ubicacion**: Seccion "Agent Teams" + ai-agent.md template
- **Lo que dice la guia**: Estructura con `features/agent/`, `features/tools/`, `core/`, etc.
- **Lo que hace el ecosistema**: El template `teams/templates/ai-agent.md` define file ownership con `src/agent/**`, `src/tools/**`, `src/chains/**`, `prompts/**`, `security/**`. Usa `src/` como prefijo, no `features/`. Si un usuario intenta combinar la guia + el template de equipo, vera discrepancias en las rutas.
- **Impacto en el usuario**: Confusion si el usuario lee ambos documentos. La guia propone `features/`, el template propone `src/`. Claude resolvera esto con la Scope Rule que no usa `src/` como convencion. Menor porque pocos usuarios llegaran a usar Agent Teams como primera vez.

### H15: /sdd-new en seccion "Despues de la entrega" es correcto para nuevas features
- **Severidad**: (No es hallazgo negativo)
- **Ubicacion**: Seccion "Despues de la entrega", linea 811
- **Lo que dice la guia**: `/sdd-new ai-agent-translator` para agregar herramientas nuevas
- **Lo que hace el ecosistema**: `/sdd-new` ejecuta explore + propose, correcto para una feature nueva. En este contexto (post-entrega, feature nueva), el uso es correcto.
- **Impacto en el usuario**: Positivo.

### H16: Troubleshooting referencia /sdd-continue para "ver el estado del proyecto"
- **Severidad**: MENOR
- **Ubicacion**: Troubleshooting, linea 947
- **Lo que dice la guia**: "Ver el estado del proyecto: /sdd-continue batuta-ai-agent"
- **Lo que hace el ecosistema**: `/sdd-continue` ejecuta la SIGUIENTE fase pendiente del pipeline. No es un comando para "ver estado" — es un comando para EJECUTAR. Si el usuario lo usa para ver el estado, Claude avanzara al siguiente paso del pipeline. Para ver estado, el usuario deberia leer `.batuta/session.md` o simplemente preguntar "En que estado esta el proyecto?".
- **Impacto en el usuario**: El usuario podria avanzar involuntariamente en el pipeline SDD cuando solo queria ver el estado actual. Podria ser sorpresivo pero Claude pedira confirmacion antes de ejecutar cambios.

## Metricas
| Metrica | Valor |
|---------|-------|
| Pasos de la guia | 13 (mas secciones extras: seguridad, teams, troubleshooting, FAQ) |
| Pasos verificados | 13/13 pasos + 4 secciones complementarias |
| Hallazgos totales | 12 (excluyendo hallazgos positivos) |
| Criticos | 0 |
| Importantes | 4 (H4, H6, H11, H12) |
| Menores | 8 (H1, H2, H3, H8, H9, H14, H16, H13-nota) |

## Resumen de Hallazgos Importantes

| ID | Titulo | Recomendacion |
|----|--------|---------------|
| H4 | /sdd-new duplica explore si ya se ejecuto | Cambiar Paso 4 para usar `/sdd-continue` en lugar de `/sdd-new`, o eliminar el Paso 3 standalone |
| H6 | Texto de Skill Gap Detection simplificado | Alinear el texto de la guia con las 3 opciones reales o agregar nota de que Claude mostrara opciones similares |
| H11 | /batuta:analyze-prompts vs /batuta-analyze-prompts | Verificar la sintaxis del slash command real en Claude Code y actualizar guia (y CLAUDE.md) para que coincidan |
| H12 | Estructura de proyecto vs Scope Rule | Ajustar la estructura sugerida para que `tools/`, `memory/`, `security/` esten dentro de `features/agent/` si solo el agente los consume |
