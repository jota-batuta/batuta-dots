# Glosario

Terminos del ecosistema Batuta Dots v15 explicados en lenguaje simple.

---

## A

**Agent Auto-Invocation (Auto-invocacion de agentes)**: Mecanismo por el cual CLAUDE.md (el router) detecta senales tecnologicas en la peticion del usuario y delega automaticamente al domain agent correspondiente. No requiere intervencion manual — el usuario describe su problema y Batuta invoca al experto correcto. Ver: Router (MoE).

**Agent Contract (Contrato de agente)**: Definicion formal de un agente que especifica: que recibe, que produce, que archivos toca, y que skills carga. En v15, NUNCA se crean agentes inline — siempre se crea el archivo en `.claude/agents/` primero. El skill `agent-hiring` gestiona este proceso.

**Agent Hiring (Contratacion de agentes)**: Skill que implementa el protocolo de delegacion por contrato del main agent. Antes de ejecutar cualquier tarea, verifica si ya existe un agente, propone contratacion si no existe (USER STOP obligatorio), y crea el archivo de agente con contrato formal. Ver: Delegacion por Contrato.

**Agent Lifecycle (Ciclo de vida del agente)**: Las 5 etapas de un agente: crear (ecosystem-creator) → clasificar (ecosystem-lifecycle, generico vs proyecto) → sincronizar al global (setup.sh --sync o /batuta-sync) → provisionar a proyectos (sdd-init) → sincronizar de vuelta al hub. Mismo mecanismo que los skills.

**Agent Provisioning**: Proceso automatico de copiar agents del hub a un proyecto basado en tecnologias detectadas. Lo ejecuta `sdd-init` en Step 3.9, comparando el tech stack del proyecto con la tabla de provisioning.

**Agent Team (Equipo de agentes)**: Nivel 3 de ejecucion. Multiples agentes trabajando en paralelo con comunicacion bidireccional. Los domain agents se integran como teammates con contratos formales. Para tareas complejas de 4+ archivos.

**AI Validation Pyramid (Piramide de Validacion)**: 5 capas de verificacion. L1: linting/tipos/build. L2: tests unitarios. L3: tests integracion. L4: revision humana. L5: pruebas manuales. Regla: base rota = no hay revision humana.

**always_agents**: Agents que se provisionan a todo proyecto sin importar su tech stack. Actualmente solo quality-agent tiene este flag — todo proyecto necesita calidad.

**Apply**: Fase de implementacion del pipeline SDD. Implementar codigo siguiendo el PRD o design. El main agent contrata agentes especializados segun las tecnologias — no ejecuta directamente.

## B

**Benchmark (Skill Eval)**: Modo que ejecuta eval para multiples skills y genera un reporte de salud del ecosistema. Comando: `/skill:benchmark`. Util para verificar que ningun skill se rompio despues de cambios.

## C

**Change (Cambio)**: Unidad de trabajo en SDD. Cada cambio tiene su carpeta en `openspec/changes/{nombre}/` con todos los artefactos.

**CLAUDE.md**: Archivo principal de configuracion. Define reglas (Research-First, Self-Awareness, Skill Loading, Delegacion por Contrato, State, Scope Rule), el pipeline SDD (2 modos), y comandos.

**COMPLETO (modo)**: Modo del pipeline SDD activado cuando el CTO escribe un PRD en Notion. Flujo: Research → Explore (subagentes en paralelo) → Design (USER STOP) → Apply → Verify. Mas riguroso que SPRINT, incluye design formal con aprobacion.

**Compliance**: Cumplimiento de regulaciones. En contexto colombiano: Ley 1581 (datos personales), SIC (IA), Art. 632 (tributario).

**Contract-First Protocol**: Regla de Agent Teams. Antes de crear un equipo, se definen contratos explicitos: que recibe, que produce, y que archivos toca cada teammate.

**Coolify**: Plataforma de deploy. Como Heroku pero en tu propio servidor.

## D

**defer_loading**: Configuracion SDK que habilita Tool Search para descubrir herramientas on-demand en vez de cargarlas todas al inicio. Reduce consumo de tokens ~85%. Se configura en el bloque `sdk:` de los agents.

**Delegacion por Contrato**: Principio fundamental de v15. El main agent es un GESTOR — no implementa, no investiga directamente, no escribe codigo. Para toda tarea, contrata un agente especializado via el skill `agent-hiring`. NUNCA crear agentes inline. Ver: Agent Hiring.

**Design**: Fase del pipeline SDD (modo COMPLETO). Definir arquitectura, componentes, y decisiones tecnicas. Requiere USER STOP para aprobacion.

**Discovery Completeness**: 5 preguntas obligatorias antes de proponer: todos los tipos? excepciones? categorias externas? participantes? ramas?

**Discovery Depth (Profundidad de discovery)**: Principio que exige que la exploracion verifique flujos de codigo reales en vez de asumir comportamiento por nombres de funciones o estructura de carpetas. La discovery superficial causa el modo de fallo mas caro del pipeline: asumir mal → implementar → usuario corrige → reimplementar. Reglas: leer codigo antes de asumir, verificar flujos de datos reales, reformular con datos especificos, incluir "Technical Assumptions" en la propuesta. Ver: Discovery Completeness, Technical Assumptions.

**Domain Agent**: Agente especializado en un dominio (backend, quality, data) con thick persona. Se contrata cuando el main agent detecta que una tarea requiere expertise de dominio. A diferencia de trabajar con skills sueltos, los domain agents tienen criterio propio sobre como usar las herramientas. Actualmente hay 3. Ver: Agent Hiring, Thick Persona.

**Domain Experts**: Configuracion por proyecto en `openspec/domain-experts.md`. Expertos de dominio (finanzas, RRHH, legal) con reglas de negocio especificas.

## E

**Ecosystem Creator**: Skill para crear nuevos skills, agentes, y workflows.

**Execution Gate**: Validacion obligatoria antes de escribir codigo. Modo LIGHT (1 linea) o FULL (plan completo).

**Expert (MoE)**: En la analogia Mixture of Experts, un Expert es un domain agent (backend-agent, quality-agent, data-agent) que ejecuta tareas dentro de su area de especialidad. El router (CLAUDE.md) decide que expert atiende cada peticion. Ver: Router (MoE).

**Explore**: Fase del pipeline SDD (modo COMPLETO). Investigar el problema con subagentes en paralelo antes de disenar.

## F

**Fast-forward (FF)**: Comando `/sdd-ff`. Ejecuta explore + design en secuencia (2 pasos). Se detiene para aprobacion despues del design.

## G

**Gate**: Punto de aprobacion en el pipeline SDD. En v15, el principal es el USER STOP despues de design (modo COMPLETO). El usuario aprueba explicitamente antes de avanzar a apply.

## H

**Hook**: Automatismo que se ejecuta cuando algo pasa. 2 hook types: SessionStart, Stop.

## I

**Init**: Fase 1 del pipeline SDD. Preparar la estructura de documentacion del proyecto.

**Infra Agent**: Agente que maneja organizacion de archivos, creacion de herramientas, y seguridad.

## L

**Learning Loop**: 6 preguntas en sdd-archive para mejorar el ecosistema despues de cada cambio.

## O

**O.R.T.A.**: Framework de calidad. Observabilidad, Repetibilidad, Trazabilidad, Auto-supervision.

**openspec/**: Carpeta raiz de SDD en cada proyecto. Contiene config, specs, y cambios.

## P

**Pipeline Agent**: Agente que coordina el flujo SDD.

**Pipeline SDD**: Flujo de desarrollo con 2 modos: SPRINT (Research → Apply → Verify) y COMPLETO (Research → Explore → Design → Apply → Verify). Research-First aplica en ambos modos.

**PRD (Product Requirements Document)**: Artefacto unico de planificacion en v15. El CTO lo escribe en Notion. Code lo lee via MCP. La presencia de un PRD activa el modo COMPLETO.

**Process Analyst**: Skill CTO que mapea variantes de un proceso (10 preguntas, arbol de variantes).

## R

**Recursion Designer**: Skill CTO que disena mecanismos para manejar cambio externo (4 mecanismos).

**RLS (Row-Level Security)**: Seguridad a nivel de fila en PostgreSQL. Cada tenant solo ve sus datos.

**Research-First**: Regla NO NEGOCIABLE de v15 que aplica en TODO modo, incluyendo SPRINT. Siempre investigar antes de implementar: (1) Notion KB via MCP, (2) skill relevante, (3) WebFetch docs oficiales, (4) WebSearch. Research se hace con subagentes en paralelo.

**Router (MoE)**: En la analogia Mixture of Experts, el Router es CLAUDE.md — el agente principal que clasifica la intencion del usuario y contrata al agente correcto. No ejecuta tareas de dominio directamente, sino que las delega. Analogia: el director de orquesta que senala al musico correcto. Ver: Expert (MoE), Delegacion por Contrato.

## S

**Scope Agent**: Agente de infraestructura del hub (pipeline, infra, observability) que siempre esta cargado. Coordina el proceso pero no aporta expertise de dominio. Ver: Domain Agent para el tipo complementario.

**Scope Rule**: Regla de organizacion. 1 feature -> features/{name}/. 2+ -> shared/. Toda app -> core/. Nunca utils/ o helpers/ en raiz.

**SDK Block (sdk:)**: Bloque YAML en frontmatter de agents que habilita deployment programatico via Claude Agent SDK. Define model, max_turns, tools, defer_loading y otras configuraciones para ejecutar el agente como servicio.

**SDD (Spec-Driven Development)**: Metodologia con 2 modos: SPRINT (rapido, sin gates formales) y COMPLETO (con PRD, design formal, y aprobacion). Research-First aplica en ambos.

**Security Audit**: Skill que revisa seguridad (OWASP 10 puntos, secrets, dependencies, threat model).

**Self-Awareness**: Regla de v15. Antes de ejecutar cualquier tarea, preguntarse: "que necesito saber que NO se?". Buscar en skills del proyecto, luego en hub global, luego en web. NUNCA usar conocimiento generalista donde deberia haber conocimiento especifico.

**Skill**: Archivo SKILL.md que le ensena a Claude una especialidad. 43 skills en v15. Se distribuyen en dos niveles: global (~/.claude/skills/) y proyecto (.claude/skills/).

**SPRINT (modo)**: Modo default del pipeline SDD. Flujo: Research → Apply → Verify. Sin gates formales, pero research es obligatorio. El modo rapido para la mayoria de tareas.

**Skill Eval**: Framework para testing comportamental de skills usando sub-agentes y criterios de calidad. Ejecuta escenarios reales definidos en SKILL.eval.yaml y evalua si el skill responde correctamente. Comando: `/skill:eval nombre`.

**SKILL.eval.yaml**: Archivo de test cases para un skill. Contiene escenarios con input, expected behavior, quality_criteria (lo que debe pasar) y anti_criteria (lo que no debe pasar). Vive junto al SKILL.md del skill que evalua.

**Skill Gap Detection**: Mecanismo que detecta cuando falta un skill para una tecnologia y ofrece crearlo.

**State (una fuente de verdad)**: Regla de v15. session.md = UNICA fuente de verdad del estado del proyecto (80 lineas max). CHECKPOINT.md = seguro anti-compaction. Notion KB = memoria empresarial. Todos se actualizan constantemente.

**Subagente**: Nivel 2 de ejecucion. Un agente delegado para una tarea especifica (via Task tool).

**Team Orchestrator**: Skill que decide el nivel de ejecucion (solo/subagente/team) y coordina equipos.

**Temporal.io**: Sistema de orquestacion de workflows. Garantiza completitud y reintento de tareas.

**Thick Persona (Persona densa)**: Un domain agent con 80-120 lineas de expertise embebido — no solo sabe que herramientas usar, sino que tiene criterio propio sobre como usarlas. Ejemplo: backend-agent no solo sabe que existe FastAPI, sino que tiene convenciones sobre versionado de APIs, formatos de error, y patrones de validacion. Esto lo distingue de un skill suelto que solo sigue instrucciones.

**Tombstoning**: Patron de borrado logico. Marcar datos como eliminados sin borrarlos fisicamente (para compliance).

## V

**Verify**: Fase de verificacion del pipeline SDD. Ejecutar la Piramide de Validacion (5 capas).

## W

**Worker**: Proceso en segundo plano que ejecuta tareas (procesamiento, sincronizacion, etc.).

**Worker Scaffold**: Skill CTO que genera estructura de workers con Temporal, Docker, y Coolify.
