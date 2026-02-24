# Integration Test: guia-langchain-gmail-agent.md
**Fecha**: 2026-02-23
**Version ecosistema**: 9.1.0
**Agente**: A7
**Guia**: docs/guides/guia-langchain-gmail-agent.md

## Resumen Ejecutivo

La guia lleva a un usuario no tecnico desde cero hasta un agente de IA en produccion que clasifica correos de Gmail. El flujo general es correcto y los comandos SDD referenciados existen y producen los resultados esperados. Se identificaron 8 hallazgos: 1 critico (comando `/batuta-init` invocado con argumento pero el command real espera el argumento de forma diferente), 3 importantes (comando `/sdd-new` vs la tabla de comandos real, flujo `sdd:continue` que agrupa 3 fases sin explicar la interaccion, referencia a comando con formato inconsistente), y 4 menores.

## Hallazgos

### H1: El Paso 2 usa `/batuta-init batuta-email-agent` pero el command real requiere el argumento como `$ARGUMENTS`
- **Severidad**: CRITICO
- **Ubicacion**: Paso 2, linea 119
- **Lo que dice la guia**: `/batuta-init batuta-email-agent`
- **Lo que hace el ecosistema**: El command `batuta-init.md` (linea 8) define `argument-hint: "[project-name]"` y en el Step 5 (linea 120) menciona `$ARGUMENTS`. Sin embargo, el command NO usa el argumento para localizar batuta-dots ni para decidir el directorio destino. El `batuta-init` command copia CLAUDE.md al directorio ACTUAL (`./CLAUDE.md` en linea 35 del command), crea `.batuta/` en el directorio actual, y usa `$ARGUMENTS` solo para nombrar el proyecto en `session.md`. La guia implica que el argumento define el nombre del proyecto, lo cual es correcto segun el command, pero la guia NO dice que el usuario ya debe estar DENTRO del directorio del proyecto antes de ejecutar `/batuta-init`. El Paso 1 dice "Navega a la carpeta" y "Abre Claude Code", lo cual es correcto, pero la conexion causal entre estar en la carpeta correcta y que `/batuta-init` funcione no esta explicita. Para un usuario no tecnico, esto puede causar que los archivos de Batuta se instalen en el directorio equivocado si abre Claude Code desde otro lugar.
- **Impacto en el usuario**: Si el usuario abre Claude Code desde otro directorio (ej. su home), los archivos de ecosistema se crearian en el lugar equivocado. Para un usuario que sabe copiar y pegar pero no entiende el concepto de "directorio actual", esto es un riesgo real.

### H2: La guia describe que `/batuta-init` instala "skills" y "hooks" pero el command real solo hace `--sync` y `--hooks`
- **Severidad**: MENOR
- **Ubicacion**: Paso 2, linea 122
- **Lo que dice la guia**: "Esto instala las instrucciones del chef (CLAUDE.md), los jefes de area (scope agents), el sistema de calidad (.batuta/), todas las recetas (skills) y las alarmas automaticas (hooks)."
- **Lo que hace el ecosistema**: El command `batuta-init.md` ejecuta `setup.sh --sync` (que copia skills + agents + commands a `~/.claude/`) y `setup.sh --hooks` (que instala hooks + permisos). Esto ES lo que la guia describe en lenguaje simplificado. La descripcion es correcta en sustancia pero simplifica que `--sync` no ejecuta `skill-sync` (regeneracion de tablas de routing), a diferencia de `--all` que si lo hace. Sin embargo, dado que batuta-dots ya tiene las tablas pre-generadas, esto no deberia causar problemas en la practica.
- **Impacto en el usuario**: Ninguno significativo. La simplificacion es apropiada para la audiencia.

### H3: El Paso 6 usa `/sdd-new` pero la tabla SDD Commands lo define como `sdd-explore` seguido de `sdd-propose`
- **Severidad**: IMPORTANTE
- **Ubicacion**: Paso 6, linea 221
- **Lo que dice la guia**: `/sdd-new batuta-email-classifier`
- **Lo que hace el ecosistema**: En CLAUDE.md linea 104, `/sdd-new <change-name>` esta definido como `pipeline -> sdd-explore -> sdd-propose`. Esto significa que `/sdd-new` ejecuta exploracion Y propuesta en un solo comando. La guia usa `/sdd-new` despues de haber ejecutado `/sdd-explore` en el Paso 4. Esto implica que la exploracion se ejecutaria DOS VECES: una en Paso 4 con `/sdd-explore` (sin guardar archivo porque no tiene change-name), y otra en Paso 6 con `/sdd-new` que internamente invoca sdd-explore de nuevo. Esto es redundante y puede confundir a Claude si ya tiene el contexto de la exploracion previa.
- **Impacto en el usuario**: El usuario ejecutaria la exploracion dos veces. La primera vez (Paso 4) genera Skill Gap Detection y posiblemente crea skills (Paso 5). La segunda vez (Paso 6 via `/sdd-new`) volveria a explorar el mismo tema. Esto no rompe el flujo pero desperdicia tiempo y tokens. El flujo optimo seria: Paso 4 usa `/sdd-new batuta-email-classifier` directamente (combina explore + propose), o Paso 6 usa `/sdd-continue batuta-email-classifier` si la exploracion ya se guardo.

### H4: El Paso 7 usa `/sdd-continue` y dice que cubre "specs, design, tasks" pero no explica la interaccion entre fases paralelas
- **Severidad**: IMPORTANTE
- **Ubicacion**: Paso 7, linea 234-238
- **Lo que dice la guia**: `/sdd-continue batuta-email-classifier` — "Repite 'Se ve bien, continua' para cada fase (specs, design, tasks)."
- **Lo que hace el ecosistema**: En CLAUDE.md linea 105, `/sdd-continue` va a `pipeline -> next needed phase`. El pipeline-agent.md (linea 28-29) define que `specs` y `design` CAN run in parallel, y ambos MUST complete before `tasks`. El `/sdd-continue` es valido y ejecuta la siguiente fase pendiente. Sin embargo, la guia dice simplemente "repite para cada fase" sin explicar que specs y design pueden ocurrir en paralelo o que Claude podria pedir confirmacion en un orden diferente al listado. Para un usuario no tecnico, si Claude presenta design antes de specs (o en paralelo), puede causar confusion.
- **Impacto en el usuario**: Confusion menor si el orden de las fases no coincide con lo que la guia lista. El usuario podria pensar que algo salio mal cuando Claude presenta "design" antes de "specs".

### H5: La guia referencia `/batuta:analyze-prompts` con formato inconsistente
- **Severidad**: IMPORTANTE
- **Ubicacion**: Linea 511 y linea 591
- **Lo que dice la guia**: Linea 511 dice `/batuta:analyze-prompts` y linea 591 dice `/batuta:analyze-prompts`
- **Lo que hace el ecosistema**: En CLAUDE.md linea 113, el comando esta definido como `/batuta:analyze-prompts`. Sin embargo, el command file real se llama `batuta-analyze-prompts.md` (con guiones, no dos puntos). Los commands en Claude Code se invocan con `/` + nombre del archivo sin extension. Por lo tanto, el comando real es `/batuta-analyze-prompts` (con guion despues de "batuta"). La guia usa el formato `/batuta:analyze-prompts` (con dos puntos), que es el formato documentado en la tabla SDD Commands de CLAUDE.md. Ambos formatos deberian funcionar si Claude Code reconoce la intencion, pero tecnicamente el slash command se dispara por el nombre del archivo `.md` en `~/.claude/commands/`, que seria `/batuta-analyze-prompts`.
- **Impacto en el usuario**: Si el usuario copia y pega `/batuta:analyze-prompts`, Claude Code podria no encontrar el command file directamente. Claude Code busca commands por nombre de archivo, y el archivo se llama `batuta-analyze-prompts.md`, asi que el formato correcto del slash command seria `/batuta-analyze-prompts`. La tabla SDD en CLAUDE.md usa el formato con dos puntos como un routing hint para el modelo, no como el trigger del slash command nativo. Esto podria causar que el comando no se ejecute como command sino como texto libre que Claude interpreta.

### H6: La estructura esperada del proyecto usa `core/` y `features/` correctamente segun Scope Rule
- **Severidad**: MENOR (positivo)
- **Ubicacion**: Lineas 457-487
- **Lo que dice la guia**: Estructura con `core/config.py`, `core/auth/gmail_auth.py`, `features/classifier/`, `features/gmail/`, `features/agent/`
- **Lo que hace el ecosistema**: El scope-rule SKILL.md define exactamente este patron: `core/` para singletons (config, auth) y `features/{feature}/{type}/` para funcionalidad especifica. La estructura propuesta es 100% consistente con el Scope Rule.
- **Impacto en el usuario**: Positivo. Si Claude sigue la guia, la estructura sera correcta segun las reglas del ecosistema.

### H7: La seccion de seguridad describe correctamente el flujo de security-audit pero no menciona el trigger exacto
- **Severidad**: MENOR
- **Ubicacion**: Lineas 519-535
- **Lo que dice la guia**: "Ejecuta una revision de seguridad completa de este proyecto" — "Claude activara el skill de security-audit"
- **Lo que hace el ecosistema**: El security-audit SKILL.md tiene `auto_invoke` que incluye "Security review or audit of code". El prompt sugerido en la guia ("Ejecuta una revision de seguridad completa") deberia activar el skill automaticamente por coincidencia semantica con el trigger. La guia describe correctamente que el reporte tendra "Problemas encontrados (critico, alto, medio, bajo)" que coincide con los severity levels del skill (CRITICAL, HIGH, MEDIUM, LOW, INFO).
- **Impacto en el usuario**: Ninguno. El flujo descrito funciona como se espera.

### H8: La seccion Agent Teams describe correctamente los 3 niveles pero las metricas de rendimiento no tienen soporte en el ecosistema
- **Severidad**: MENOR
- **Ubicacion**: Lineas 554-601
- **Lo que dice la guia**: Tabla con metricas de rendimiento (tiempo estimado, costo tokens, calidad esperada) para cada escenario de Agent Teams.
- **Lo que hace el ecosistema**: El team-orchestrator SKILL.md define la decision tree y los 3 niveles (Solo, Subagent, Agent Team) pero no contiene benchmarks de tiempo, costo, o calidad. Las metricas en la guia son estimaciones razonables pero no estan respaldadas por datos del ecosistema. No hay mecanismo en el ecosistema para verificar estos numeros.
- **Impacto en el usuario**: Las expectativas de tiempo y costo podrian no coincidir con la realidad. Si el usuario espera "3-5 min" para ajustar un prompt y toma 15 min, podria frustrarse. Sin embargo, estas metricas son utiles como referencia orientativa.

## Metricas
| Metrica | Valor |
|---------|-------|
| Pasos de la guia | 15 (principales) + 3 secciones post-entrega + seguridad + Agent Teams |
| Pasos verificados | 15 principales + todas las secciones complementarias |
| Hallazgos totales | 8 |
| Criticos | 1 |
| Importantes | 3 |
| Menores | 4 |

## Detalle de Verificacion por Paso

| Paso | Comando/Referencia | Existe en ecosistema | Correcto | Notas |
|------|-------------------|---------------------|----------|-------|
| 1 | Crear carpeta + `claude` | N/A (preparacion) | Si | Flujo correcto |
| 2 | `/batuta-init` | batuta-init.md | Si (ver H1) | Argumento funcional pero contexto de directorio no explicito |
| 3 | `/sdd-init` | sdd-init SKILL.md | Si | Parametros correctos (nombre, tipo `ai-agent`, descripcion) |
| 4 | `/sdd-explore` | sdd-explore SKILL.md | Si | Skill Gap Detection se activara como describe la guia |
| 5 | Skill Gap → Opcion 1 | ecosystem-creator SKILL.md | Si | Auto-Discovery flow correcto |
| 6 | `/sdd-new` | CLAUDE.md SDD Commands | Si (ver H3) | Redundancia con explore previo |
| 7 | `/sdd-continue` | CLAUDE.md SDD Commands | Si (ver H4) | specs/design/tasks en secuencia |
| 8 | `/sdd-apply` | sdd-apply SKILL.md | Si | Execution Gate y batch pattern correctos |
| 9 | `/sdd-verify` | sdd-verify SKILL.md | Si | AI Validation Pyramid aplicable |
| 10 | Ejecucion manual | N/A (codigo generado) | Si | Dry-run es buena practica |
| 11 | Scheduler | N/A (codigo generado) | Si | APScheduler/cron mencionados correctamente |
| 12 | Coolify deploy | N/A (codigo generado) | Si | Dockerfile + health check correcto |
| 13 | GitHub + webhook | N/A (git ops) | Si | .gitignore incluye secretos |
| 14 | Verificacion prod | N/A (operaciones) | Si | Checklist razonable |
| 15 | `/sdd-archive` | sdd-archive SKILL.md | Si | Cierre completo con lessons learned |
