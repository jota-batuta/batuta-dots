# Integration Test: guia-temporal-io-app.md
**Fecha**: 2026-02-23
**Version ecosistema**: 9.1.0
**Agente**: A9
**Guia**: docs/guides/guia-temporal-io-app.md

## Resumen Ejecutivo

La guia lleva al usuario de idea a producto con un flujo coherente y bien estructurado que sigue el pipeline SDD completo. Todos los comandos y skills referenciados existen y funcionan como la guia describe, con hallazgos menores en nomenclatura de comandos, un flujo SDD simplificado que omite pasos intermedios, y una referencia cruzada incompleta al fallback de la guia principal.

## Hallazgos

### H1: Comando /sdd:new no ejecuta explore+propose sino solo propose
- **Severidad**: IMPORTANTE
- **Ubicacion**: Paso 6, linea ~186
- **Lo que dice la guia**: `"/sdd:new batuta-workers-onboarding"` seguido de "Lee el resumen que Claude te muestra"
- **Lo que hace el ecosistema**: Segun CLAUDE.md linea 104, `/sdd:new <change-name>` mapea a `pipeline -> sdd-explore -> sdd-propose`. Esto significa que `/sdd:new` ya incluye la fase de explore internamente. Sin embargo, en el Paso 4 la guia ya ejecuto `/sdd:explore batuta-workers-onboarding` explicitamente. El usuario ejecutaria explore DOS veces: una en Paso 4 con `/sdd:explore` y otra implicitamente dentro de `/sdd:new` en Paso 6.
- **Impacto en el usuario**: Duplicacion de trabajo. El usuario esperaria que Paso 6 solo genere la propuesta ya que la exploracion se hizo en Paso 4, pero `/sdd:new` volveria a ejecutar explore. Esto no es un error critico porque el resultado final es correcto, pero consume tiempo y tokens innecesariamente.

### H2: Paso 7 usa /sdd:continue que ejecuta la "siguiente fase necesaria", no las 3 fases secuenciales
- **Severidad**: MENOR
- **Ubicacion**: Paso 7, lineas ~199-208
- **Lo que dice la guia**: `"/sdd:continue batuta-workers-onboarding"` y luego "Repite 'Se ve bien, continua' para cada fase (specs, design, tasks). Claude ejecuta estas 3 fases en orden"
- **Lo que hace el ecosistema**: Segun CLAUDE.md linea 105, `/sdd:continue [change-name]` mapea a `pipeline -> next needed phase`. Esto ejecuta UNA fase a la vez (la siguiente que falte), no las 3 de golpe. El usuario tendria que ejecutar `/sdd:continue` tres veces separadas (una para specs, una para design, una para tasks) o usar `/sdd:ff` (fast-forward, linea 106) que si ejecuta `propose -> spec -> design -> tasks` de corrido.
- **Impacto en el usuario**: Confusion menor. La guia dice "Repite", lo cual implica que el usuario entiende que debe ejecutar el comando varias veces. El flujo funciona, pero la explicacion podria ser mas clara sobre que debe ejecutar el comando 3 veces. Alternativamente, podria sugerir `/sdd:ff` para hacerlo de una sola vez.

### H3: Referencia cruzada a guia-batuta-app.md Paso 3 Opcion B es correcta pero fragil
- **Severidad**: MENOR
- **Ubicacion**: Paso 2, linea ~98
- **Lo que dice la guia**: "Si no tienes el comando instalado, usa el prompt largo de la guia principal (docs/guides/guia-batuta-app.md, Paso 3 Opcion B)."
- **Lo que hace el ecosistema**: Verificado: guia-batuta-app.md Paso 3 Opcion B (lineas 134-147) efectivamente contiene el prompt largo para instalar el ecosistema sin el command `/batuta-init`. La referencia es correcta.
- **Impacto en el usuario**: Si la guia principal cambia la numeracion de pasos o elimina la Opcion B, esta referencia se rompe. Es un riesgo menor de mantenimiento, no un bug actual.

### H4: Comando /batuta:analyze-prompts usa dos puntos, la guia usa el formato correcto pero la tabla de tips usa otro
- **Severidad**: MENOR
- **Ubicacion**: Seccion "Tips especificos de Temporal", linea ~429
- **Lo que dice la guia**: `/batuta:analyze-prompts` en la tabla de tips
- **Lo que hace el ecosistema**: En CLAUDE.md linea 113, el comando se define como `/batuta:analyze-prompts`. El command file real se llama `batuta-analyze-prompts.md` (con guiones, sin dos puntos). Hay una discrepancia de nomenclatura: el command file usa guiones (`batuta-analyze-prompts`) mientras que la tabla de comandos SDD en CLAUDE.md usa dos puntos (`/batuta:analyze-prompts`). Ambas convenciones coexisten en el ecosistema, pero la guia referencia el formato con dos puntos que es el que aparece en CLAUDE.md.
- **Impacto en el usuario**: Ninguno inmediato. Claude Code resuelve ambos formatos. Sin embargo, si el usuario busca el archivo del command, encontrara `batuta-analyze-prompts.md` (con guiones), no `batuta:analyze-prompts.md`.

### H5: La seccion de Seguridad no invoca explicitamente el skill security-audit
- **Severidad**: MENOR
- **Ubicacion**: Seccion "Seguridad", lineas ~433-447
- **Lo que dice la guia**: Un prompt libre que pide "Ejecuta una auditoria de seguridad del proyecto. Revisa: 1. Que no haya claves... 2. Que los endpoints... 3. Que las dependencias... 4. Que los datos sensibles..."
- **Lo que hace el ecosistema**: El skill `security-audit` (SKILL.md) tiene auto_invoke triggers como "Security review or audit of code", "Scanning for hardcoded secrets", "Auditing dependencies for known vulnerabilities". El prompt de la guia deberia disparar el skill automaticamente gracias a estos triggers. El skill define un checklist de 10 puntos (OWASP-style), threat model template, secrets scanning protocol, y dependency audit.
- **Impacto en el usuario**: El prompt de la guia cubre solo 4 de los 10 puntos del checklist del security-audit skill. Sin embargo, como el skill se auto-invoca, Claude deberia ejecutar el checklist completo de 10 puntos aunque el prompt solo mencione 4. El resultado esperado de la guia ("Claude revisara tu codigo con el checklist de seguridad AI-First") es correcto.

### H6: La guia describe 3 opciones de skill gap pero el ecosistema ofrece 3 con nombres diferentes
- **Severidad**: MENOR
- **Ubicacion**: Paso 5, linea ~173-177
- **Lo que dice la guia**: `"Opcion 1 -- Investiga y crea el skill acotado a nuestro proyecto"` como unica opcion mostrada
- **Lo que hace el ecosistema**: El infra-agent.md (lineas 44-53) presenta 3 opciones al usuario: (1) "Investigar y crear el skill" (proyecto local), (2) "Crear un skill global" (reutilizable), (3) "Continuar sin skill". La guia solo muestra la opcion 1 como respuesta sugerida, lo cual es correcto como recomendacion, pero no menciona que Claude ofrecera 3 opciones.
- **Impacto en el usuario**: Confusion minima. El usuario vera 3 opciones en pantalla pero la guia solo menciona la opcion 1. El usuario podria no saber que hacer si quiere elegir otra opcion. Sin embargo, la guia dice "Tu respuesta cada vez:" sugiriendo que es una respuesta predefinida, lo cual es una simplificacion aceptable para una audiencia no tecnica.

### H7: La estructura esperada del proyecto es correcta con la Scope Rule
- **Severidad**: N/A (VERIFICACION POSITIVA)
- **Ubicacion**: Seccion "Estructura esperada del proyecto", lineas ~384-415
- **Lo que dice la guia**: Estructura con `core/`, `features/onboarding/`, `features/payments/`, `features/dashboard/`, `features/shared/`
- **Lo que hace el ecosistema**: El skill scope-rule (SKILL.md) define exactamente este patron: 1 feature -> `features/{feature}/{type}/`, 2+ features -> `features/shared/{type}/`, entire app -> `core/{type}/`. La estructura de la guia es perfectamente consistente con la Scope Rule. El `core/config.py`, `core/database.py`, `core/temporal_client.py` son singletons correctos. Los workflows/activities/workers dentro de `features/onboarding/` siguen el patron de feature scope. `features/shared/notifications/` es correcto si multiples features lo usan.
- **Impacto en el usuario**: Positivo. La estructura es un ejemplo educativo excelente de la Scope Rule aplicada a un proyecto Temporal.io.

### H8: Paso 3 sdd:init pregunta "Tipo de proyecto" pero el skill usa deteccion automatica
- **Severidad**: MENOR
- **Ubicacion**: Paso 3, lineas ~103-115
- **Lo que dice la guia**: Cuando Claude pregunte "Tipo de proyecto", responder `automation`
- **Lo que hace el ecosistema**: El skill sdd-init (SKILL.md, Step 1) primero intenta DETECTAR automaticamente el tipo de proyecto. Si el proyecto esta vacio (caso comun despues de `/batuta-init`), entonces SI pregunta al usuario. El skill clasifica como `automation` o `data-pipeline` para proyectos con Temporal workflows (linea 64 de sdd-init: "ETL scripts, Temporal workflows, data transforms, pipeline DAGs" -> data-pipeline). Un proyecto de Temporal.io podria ser clasificado como `data-pipeline` en vez de `automation` dependiendo del uso.
- **Impacto en el usuario**: Si el usuario responde `automation` como dice la guia, Claude lo aceptara. Pero si Claude sugiere `data-pipeline` basado en la deteccion heuristica (Temporal workflows aparecen en la heuristica de data-pipeline), podria haber confusion. En la practica, para un proyecto vacio Claude preguntara directamente, asi que la guia es correcta.

### H9: La seccion Agent Teams es precisa y bien alineada con team-orchestrator
- **Severidad**: N/A (VERIFICACION POSITIVA)
- **Ubicacion**: Seccion "Nivel Avanzado: Agent Teams", lineas ~451-498
- **Lo que dice la guia**: Tres niveles (Solo, Subagente, Agent Team) con ejemplos especificos de Temporal
- **Lo que hace el ecosistema**: El skill team-orchestrator (SKILL.md) define exactamente estos 3 niveles con el decision tree: Q1 (files), Q2 (communication), Q3 (conflicts). Los patterns SDD Pipeline Team, Investigation Team, y Cross-Layer Team coinciden con los ejemplos de la guia (multiples workflows en paralelo, debugging complejo, migracion). Las metricas de rendimiento son estimaciones razonables.
- **Impacto en el usuario**: Positivo. La seccion es informativa y bien calibrada para la audiencia.

### H10: El Paso 12 pide crear repo GitHub bajo organizacion jota-batuta -- accion prohibida
- **Severidad**: IMPORTANTE
- **Ubicacion**: Paso 12, lineas ~313-319
- **Lo que dice la guia**: "Crea un repositorio privado en GitHub llamado batuta-workers bajo la organizacion jota-batuta, sube todo el codigo, y configura el webhook de Coolify para despliegue automatico."
- **Lo que hace el ecosistema**: CLAUDE.md (linea 3) dice "Never build after changes unless explicitly asked." y los permissions en settings.json (linea 64) requieren confirmacion para `git commit` y `git push`. Sin embargo, el prompt de la guia SI pide explicitamente estas acciones, asi que Claude procederia correctamente con confirmacion.
- **Impacto en el usuario**: El paso funciona pero asume que el usuario tiene: (1) GitHub CLI (`gh`) configurado, (2) acceso a la organizacion jota-batuta, (3) Coolify configurado con webhook. Si cualquiera de estos no esta listo, el paso fallara. La guia no menciona estos prerequisitos. Ademas, crear el repositorio bajo una organizacion especifica puede no aplicar a todos los usuarios -- la guia deberia usar un placeholder como `[tu-organizacion]`.

### H11: El Paso 10 pide levantar Docker Compose -- Claude no puede verificar contenedores corriendo
- **Severidad**: MENOR
- **Ubicacion**: Paso 10, lineas ~256-278
- **Lo que dice la guia**: "Levanta todo el sistema con Docker Compose para que pueda probarlo." + "Claude va a ejecutar docker-compose up"
- **Lo que hace el ecosistema**: Los permisos en settings.json incluyen `Bash(docker:*)` y `Bash(docker-compose:*)` en allow (lineas 98-99), asi que Claude PUEDE ejecutar docker-compose. Sin embargo, Claude no puede verificar visualmente que el dashboard carga correctamente en `localhost:3000`. Las instrucciones de prueba manual (puntos 1-4) son correctas como guia para el usuario.
- **Impacto en el usuario**: Ninguno real. El usuario entiende que debe probar manualmente. Claude puede ejecutar `docker-compose up` y verificar logs, pero la prueba visual es responsabilidad del usuario.

### H12: Glosario define "Scope Agent" correctamente pero no menciona los 3 nombres
- **Severidad**: MENOR
- **Ubicacion**: Glosario, linea ~42
- **Lo que dice la guia**: "Scope Agent -- Un 'jefe de area' especializado de Claude. Coordina un grupo de tareas relacionadas."
- **Lo que hace el ecosistema**: Existen 3 scope agents: pipeline-agent, infra-agent, observability-agent. Cada uno con skills especificos. La definicion del glosario es correcta como abstraccion, pero para un usuario curioso que quiera entender mas, podria ser util saber que son 3 y que hacen.
- **Impacto en el usuario**: Ninguno practico. La guia es para usuarios no tecnicos que no necesitan conocer los nombres internos.

## Metricas
| Metrica | Valor |
|---------|-------|
| Pasos de la guia | 14 (principales) + 4 secciones post-entrega |
| Pasos verificados | 18/18 |
| Hallazgos totales | 12 |
| Criticos | 0 |
| Importantes | 2 |
| Menores | 8 |
| Verificaciones positivas | 2 |

## Resumen de Acciones Recomendadas

### Prioridad Alta
1. **H1**: Considerar cambiar Paso 6 para que use solo `/sdd:propose batuta-workers-onboarding` (sin re-ejecutar explore) o eliminar el Paso 4 separado y dejar que `/sdd:new` haga explore+propose de una vez. Alternativamente, documentar que la segunda exploracion es intencional (refinamiento).
2. **H10**: Reemplazar `jota-batuta` con un placeholder generico `[tu-organizacion]` y agregar prerequisitos de GitHub CLI y Coolify.

### Prioridad Media
3. **H2**: Aclarar que `/sdd:continue` se ejecuta una vez por fase (3 veces total) o sugerir `/sdd:ff` como alternativa rapida.

### Prioridad Baja
4. **H3**: Considerar usar un deep link o ancla en la referencia cruzada.
5. **H6**: Agregar una nota breve: "Claude te ofrecera varias opciones. Elige la primera."
6. **H8**: Mencionar que Claude podria sugerir `data-pipeline` como tipo alternativo y que ambos son validos.
