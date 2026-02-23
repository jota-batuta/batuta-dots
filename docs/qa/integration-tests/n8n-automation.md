# Integration Test: guia-n8n-automation.md
**Fecha**: 2026-02-23
**Version ecosistema**: 9.1.0
**Agente**: A8
**Guia**: docs/guides/guia-n8n-automation.md

## Resumen Ejecutivo

La guia es exhaustiva, bien redactada para un publico no tecnico, y sigue fielmente el flujo SDD del ecosistema Batuta v9.1. Los comandos SDD, la Scope Rule, el Execution Gate, la Piramide de Validacion y el flujo de Skill Gap Detection estan correctamente referenciados. Se encontraron 7 hallazgos: 0 criticos, 3 importantes y 4 menores. Los hallazgos importantes giran en torno a inconsistencias en nombres de comandos (formato slash) y una descripcion simplificada de la Piramide de Validacion que no coincide con las 5 capas reales del ecosistema. La guia llevaria a un usuario de idea a producto con exito, con fricciones menores.

## Hallazgos

### H1: Comando `/sdd:new` presentado como creador de propuesta, pero en el ecosistema ejecuta explore + propose
- **Severidad**: MENOR
- **Ubicacion**: Paso 6, linea ~321
- **Lo que dice la guia**: `"/sdd:new batuta-email-automator"` y describe que "Claude va a crear un documento llamado 'proposal'"
- **Lo que hace el ecosistema**: En CLAUDE.md (linea 104), `/sdd:new <change-name>` esta mapeado a `pipeline -> sdd-explore -> sdd-propose`. Es decir, primero ejecuta explore y LUEGO propose. La guia omite que explore se ejecuta como parte de `/sdd:new`, lo cual podria generar confusion porque en el Paso 4 el usuario ya ejecuto `/sdd:explore` por separado.
- **Impacto en el usuario**: El usuario habra ejecutado explore manualmente en el Paso 4 y luego `/sdd:new` ejecutara explore de nuevo internamente. Esto es redundante pero no bloqueante. El pipeline-agent puede detectar que el explore ya existe y saltar al propose. Impacto: posible confusion menor o tiempo duplicado.

### H2: Comando `/batuta:analyze-prompts` difiere del command real `/batuta-analyze-prompts`
- **Severidad**: IMPORTANTE
- **Ubicacion**: Seccion "Mejorar tus instrucciones", linea ~866
- **Lo que dice la guia**: `"/batuta:analyze-prompts"`
- **Lo que hace el ecosistema**: En CLAUDE.md (linea 113), el comando se llama `/batuta:analyze-prompts` (con dos puntos). Sin embargo, el command real en `BatutaClaude/commands/` se llama `batuta-analyze-prompts.md` (con guion). Claude Code invoca commands con el formato `/nombre-del-command`, es decir, `/batuta-analyze-prompts` (guion, no dos puntos). La tabla de SDD Commands en CLAUDE.md usa el formato con dos puntos para los comandos SDD (`/sdd:init`, etc.) pero para los commands reales el formato de invocacion es con guion.
- **Impacto en el usuario**: Si el usuario escribe `/batuta:analyze-prompts` (como dice la guia y CLAUDE.md), podria funcionar si Claude lo interpreta como un comando SDD que se enruta via la tabla. Pero el command real se invoca como `/batuta-analyze-prompts`. Hay una inconsistencia de naming entre la tabla de CLAUDE.md y los archivos reales de commands. Esto podria causar que el comando no se encuentre.

### H3: Piramide de Validacion simplificada a 5 capas con nombres diferentes a las del ecosistema
- **Severidad**: IMPORTANTE
- **Ubicacion**: Paso 12, lineas ~610-617
- **Lo que dice la guia**:
  - Capa 1: "Que el codigo no tenga errores de sintaxis"
  - Capa 2: "Que los tests pasen"
  - Capa 3: "Que todo funcione junto"
  - Capa 4: "Revision de seguridad"
  - Capa 5: "Que la documentacion este completa"
- **Lo que hace el ecosistema**: En sdd-verify SKILL.md, la Piramide de Validacion real tiene:
  - Layer 1 (AGENT): Type Checking / Linting / Build
  - Layer 2 (AGENT): Unit Tests
  - Layer 3 (AGENT): Integration / E2E Tests
  - Layer 4 (HUMAN): Code Review
  - Layer 5 (HUMAN): Manual Testing
  - Ademas existe un Step 4.7 de Cross-Layer Security Check y un Step 5 de Documentation Verification, que son pasos separados, no capas de la piramide.
- **Impacto en el usuario**: La guia presenta la seguridad y la documentacion como "capas" de la piramide cuando en realidad son verificaciones separadas que se ejecutan despues de la piramide. El usuario pensara que estas son capas formales del proceso, pero la realidad es distinta. No es bloqueante (sdd-verify ejecutara las verificaciones correctas automaticamente), pero genera una expectativa incorrecta sobre la estructura del proceso de verificacion.

### H4: Paso 2, Opcion B describe instrucciones incorrectas para setup.sh
- **Severidad**: IMPORTANTE
- **Ubicacion**: Paso 2, lineas ~168-177
- **Lo que dice la guia**: "Ejecuta el script skills/setup.sh --all para copiar CLAUDE.md, sincronizar skills e instalar hooks"
- **Lo que hace el ecosistema**: El script `setup.sh --all` (linea 447-468 de setup.sh) ejecuta en este orden: (1) sync skills+agents+commands a `~/.claude/`, (2) run skill-sync para regenerar tablas, (3) install hooks+permissions, (4) copy CLAUDE.md al root del proyecto. Pero este script opera dentro del repositorio batuta-dots, no dentro del proyecto del usuario. El flag `--project <path>` es el que configura un proyecto externo (linea 105-207 de setup.sh), copiando CLAUDE.md al proyecto, creando `.batuta/`, inicializando git, e instalando hooks.
- **Impacto en el usuario**: Si el usuario sigue la Opcion B al pie de la letra (clonar repo + ejecutar `--all`), configurara batuta-dots como proyecto pero no el proyecto del usuario. El usuario deberia usar `setup.sh --project <ruta-del-proyecto>` o seguir los pasos manuales que la guia describe (copiar CLAUDE.md manualmente). En la practica, la Opcion A (`/batuta-init`) es la recomendada y funciona correctamente, asi que la mayoria de usuarios no se toparan con este problema.

### H5: Referencia a "Scope Agent" como "jefe de area" describe 3 agentes pero la guia solo menciona 2 roles
- **Severidad**: MENOR
- **Ubicacion**: Glosario, linea ~32
- **Lo que dice la guia**: "Claude tiene 3: uno para el proceso de desarrollo, uno para organizacion de archivos, y uno para calidad."
- **Lo que hace el ecosistema**: Los 3 scope agents son: (1) pipeline-agent (SDD pipeline), (2) infra-agent (organizacion de archivos, skills, seguridad), (3) observability-agent (calidad, prompt tracking, session). La descripcion de la guia es correcta en lo esencial. Sin embargo, "organizacion de archivos" es solo una parte de lo que hace infra-agent (tambien crea skills, hace security audit, y coordina teams). La simplificacion es aceptable para el publico objetivo.
- **Impacto en el usuario**: Ninguno funcional. La simplificacion es adecuada para el publico no tecnico.

### H6: Paso 7 usa `/sdd:continue` que ejecuta la "siguiente fase necesaria", pero la guia dice que ejecuta "Specs -> Design -> Tasks" en secuencia
- **Severidad**: MENOR
- **Ubicacion**: Paso 7, lineas ~351-354
- **Lo que dice la guia**: `/sdd:continue batuta-email-automator` ejecuta "Specs -> Design -> Tasks" y toma 7-13 min total, con el usuario aprobando cada fase.
- **Lo que hace el ecosistema**: En CLAUDE.md (linea 105), `/sdd:continue [change-name]` esta mapeado a `pipeline -> next needed phase`. El pipeline-agent revisa el grafo de dependencias (`proposal -> [specs || design] -> tasks -> apply -> verify -> archive`) y ejecuta la SIGUIENTE fase pendiente, no todas a la vez. Segun el dependency graph, specs y design PUEDEN ejecutarse en paralelo. La guia presenta las fases como estrictamente secuenciales.
- **Impacto en el usuario**: El usuario esperara que con UN solo comando se ejecuten las 3 fases. En realidad, tendra que ejecutar `/sdd:continue` multiples veces (una por fase) o Claude podria pedirle confirmacion entre fases. El resultado final es el mismo, pero el numero de interacciones podria ser diferente al esperado.

### H7: Seccion "Agent Teams" no menciona el team template `n8n-automation` existente
- **Severidad**: MENOR
- **Ubicacion**: Seccion "Nivel Avanzado: Agent Teams", lineas ~1018-1083
- **Lo que dice la guia**: Describe Agent Teams de forma generica con ejemplos de como pedir equipos, pero no referencia el template pre-construido `teams/templates/n8n-automation.md` que existe en el ecosistema.
- **Lo que hace el ecosistema**: Existe un archivo `teams/templates/n8n-automation.md` con una composicion pre-definida (2 teammates: `workflow-dev` + `integration-tester`), contratos, file ownership, cross-review, y lecciones aprendidas especificas para proyectos n8n. Este template es exactamente lo que necesitaria un usuario de esta guia al escalar con Agent Teams.
- **Impacto en el usuario**: El usuario desconocera que existe un template optimizado para su caso exacto. Cuando pida un equipo, Claude tendra que derivar la composicion desde cero en lugar de usar el template pre-construido, lo cual podria resultar en una composicion menos optima y mayor consumo de tokens.

## Metricas

| Metrica | Valor |
|---------|-------|
| Pasos de la guia | 15 (principales) + 6 secciones complementarias |
| Pasos verificados | 15 principales + glosario + secciones de seguridad + emergencia + Agent Teams |
| Hallazgos totales | 7 |
| Criticos | 0 |
| Importantes | 3 |
| Menores | 4 |

## Verificacion de Comandos SDD

| Comando en la guia | Existe en CLAUDE.md | Skill real | Funciona? |
|--------------------|--------------------|------------|-----------|
| `/sdd:init` | Si (linea 102) | sdd-init | Si |
| `/sdd:explore <topic>` | Si (linea 103) | sdd-explore | Si |
| `/sdd:new <change-name>` | Si (linea 104) | sdd-explore + sdd-propose | Si (pero hace explore redundante tras Paso 4) |
| `/sdd:continue [change-name]` | Si (linea 105) | next needed phase | Si |
| `/sdd:apply [change-name]` | Si (linea 107) | sdd-apply + infra (Scope Rule) | Si |
| `/sdd:verify [change-name]` | Si (linea 108) | sdd-verify | Si |
| `/sdd:archive [change-name]` | Si (linea 109) | sdd-archive | Si |
| `/batuta-init` | Si (command file exists) | batuta-init.md | Si |
| `/batuta-update` | Si (command file exists) | batuta-update.md | Si |
| `/batuta:analyze-prompts` | Si en tabla CLAUDE.md (linea 113) | batuta-analyze-prompts.md (guion) | Potencial inconsistencia (H2) |

## Verificacion de Conceptos del Ecosistema

| Concepto en la guia | Coincide con ecosistema? | Notas |
|---------------------|------------------------|-------|
| Scope Rule (features/{name}/{type}/) | Si | Estructura esperada del proyecto sigue la regla correctamente |
| Execution Gate | Si | Descrito correctamente como checklist pre-cambio |
| Skill Gap Detection | Si | El flujo "no tengo skill" -> "Opcion 1/2/3" coincide con infra-agent |
| Session Continuity (.batuta/session.md) | Si | Funciona via hooks SessionStart y Stop |
| Prompt Tracking (.batuta/prompt-log.jsonl) | Si | Se crea automaticamente |
| Piramide de Validacion | Parcial (H3) | Capas correctas pero la guia reorganiza el contenido |
| Agent Teams (3 niveles) | Si | Solo/Subagent/Team correctamente explicados |
| O.R.T.A. | No mencionado directamente | La guia simplifica y no nombra O.R.T.A.; aceptable para el publico |

## Verificacion de Estructura de Proyecto Propuesta

La estructura esperada del proyecto (lineas 889-931) sigue correctamente la Scope Rule:
- `core/` para singletons (config.js, logger.js) -- correcto
- `features/classifier/` para la feature de clasificacion -- correcto
- `features/webhook/` para la feature de webhook -- correcto
- `features/responder/` para la feature de respuesta automatica -- correcto
- `features/shared/email-parser/` para logica compartida -- correcto
- `n8n/workflows/` para archivos de n8n -- aceptable (n8n es externo al scope rule backend)

Unica observacion: no hay `features/shared/` con `middleware/` para rate-limiter y auth que son usados por el webhook, lo cual sugiere que la guia asume que auth y rate-limiter son exclusivos de la feature webhook. Esto es consistente con la Scope Rule (empezar feature-scoped, promover cuando un segundo consumidor aparezca).

## Notas Finales

La guia es una de las mas completas del ecosistema. El glosario inicial, las analogias constantes, y el flujo paso a paso la hacen genuinamente accesible para el publico objetivo (personas no tecnicas como la hermana de 15 anos mencionada en MEMORY.md). Los hallazgos encontrados son de baja criticidad y no impediran que un usuario complete el proyecto con exito siguiendo la guia.
