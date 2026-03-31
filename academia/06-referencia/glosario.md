# Glosario

Terminos del ecosistema Batuta Dots explicados en lenguaje simple.

---

## A

**Agent Auto-Invocation (Auto-invocacion de agentes)**: Mecanismo por el cual CLAUDE.md (el router) detecta senales tecnologicas en la peticion del usuario y delega automaticamente al domain agent correspondiente. No requiere intervencion manual — el usuario describe su problema y Batuta invoca al experto correcto. Ver: Router (MoE).

**Agent Lifecycle (Ciclo de vida del agente)**: Las 5 etapas de un agente: crear (ecosystem-creator) → clasificar (ecosystem-lifecycle, generico vs proyecto) → sincronizar al global (setup.sh --sync) → provisionar a proyectos (sdd-init) → sincronizar de vuelta al hub (si el agente es util para todos). Mismo mecanismo que los skills.

**Agent Provisioning**: Proceso automatico de copiar agents del hub a un proyecto basado en tecnologias detectadas. Lo ejecuta `sdd-init` en Step 3.9, comparando el tech stack del proyecto con la tabla de provisioning.

**Agent Team (Equipo de agentes)**: Nivel 3 de ejecucion. Multiples agentes trabajando en paralelo con comunicacion bidireccional. Los domain agents se integran como teammates con contratos formales. Para tareas complejas de 4+ archivos.

**AI Validation Pyramid (Piramide de Validacion)**: 5 capas de verificacion. L1: linting/tipos/build. L2: tests unitarios. L3: tests integracion. L4: revision humana. L5: pruebas manuales. Regla: base rota = no hay revision humana.

**always_agents**: Agents que se provisionan a todo proyecto sin importar su tech stack. Actualmente solo quality-agent tiene este flag — todo proyecto necesita calidad.

**Apply**: Fase 7 del pipeline SDD. Implementar codigo siguiendo las tareas definidas. Los domain agents se auto-invocan durante esta fase segun las tecnologias de cada tarea.

**Archive**: Fase 9 del pipeline SDD. Cerrar un cambio, sincronizar specs, documentar lecciones.

## B

**Benchmark (Skill Eval)**: Modo que ejecuta eval para multiples skills y genera un reporte de salud del ecosistema. Comando: `/skill:benchmark`. Util para verificar que ningun skill se rompio despues de cambios.

## C

**Change (Cambio)**: Unidad de trabajo en SDD. Cada cambio tiene su carpeta en `openspec/changes/{nombre}/` con todos los artefactos.

**CLAUDE.md**: Archivo principal de configuracion. Define personalidad, reglas, Scope Rule, Execution Gate, y comandos SDD.

**Compliance**: Cumplimiento de regulaciones. En contexto colombiano: Ley 1581 (datos personales), SIC (IA), Art. 632 (tributario).

**Contract-First Protocol**: Regla de Agent Teams. Antes de crear un equipo, se definen contratos explicitos: que recibe, que produce, y que archivos toca cada teammate.

**Coolify**: Plataforma de deploy. Como Heroku pero en tu propio servidor.

## D

**defer_loading**: Configuracion SDK que habilita Tool Search para descubrir herramientas on-demand en vez de cargarlas todas al inicio. Reduce consumo de tokens ~85%. Se configura en el bloque `sdk:` de los agents.

**Design**: Fase 5 del pipeline SDD. Definir arquitectura, componentes, y decisiones tecnicas.

**Discovery Completeness**: 5 preguntas obligatorias antes de proponer: todos los tipos? excepciones? categorias externas? participantes? ramas?

**Discovery Depth (Profundidad de discovery)**: Principio que exige que la exploracion verifique flujos de codigo reales en vez de asumir comportamiento por nombres de funciones o estructura de carpetas. La discovery superficial causa el modo de fallo mas caro del pipeline: asumir mal → implementar → usuario corrige → reimplementar. Reglas: leer codigo antes de asumir, verificar flujos de datos reales, reformular con datos especificos, incluir "Technical Assumptions" en la propuesta. Ver: Discovery Completeness, Technical Assumptions.

**Domain Agent**: Agente especializado en un dominio (backend, quality, data) con thick persona (80-120 lineas de expertise embebido). Se auto-invoca cuando el router detecta senales tecnologicas en la peticion del usuario. A diferencia de los scope agents que siempre estan cargados, los domain agents se activan bajo demanda y cargan sus skills dinamicamente (`defer_loading`). Actualmente hay 3, con capacidad de crecer a 8. Ver: Agent Auto-Invocation, Thick Persona.

**Domain Experts**: Configuracion por proyecto en `openspec/domain-experts.md`. Expertos de dominio (finanzas, RRHH, legal) con reglas de negocio especificas.

## E

**Ecosystem Creator**: Skill para crear nuevos skills, agentes, y workflows.

**Execution Gate**: Validacion obligatoria antes de escribir codigo. Modo LIGHT (1 linea) o FULL (plan completo).

**Expert (MoE)**: En la analogia Mixture of Experts, un Expert es un domain agent (backend-agent, quality-agent, data-agent) que ejecuta tareas dentro de su area de especialidad. El router (CLAUDE.md) decide que expert atiende cada peticion. Ver: Router (MoE).

**Explore**: Fase 2 del pipeline SDD. Investigar el problema antes de proponer soluciones.

## F

**Fast-forward (FF)**: Comando `/sdd-ff`. Ejecuta propose + spec + design + tasks en secuencia rapida.

## G

**Gate**: Punto de control entre fases SDD. G0.5 (Discovery Complete), G1 (Solution Worth Building), G2 (Ready for Production).

**Gate Status (Estado del gate)**: Campo `AWAITING_APPROVAL` en la seccion `## Gate Status` de session.md que registra si hay una aprobacion pendiente. Valores posibles: `proposal` (propuesta presentada, esperando aprobacion), `task_plan` (plan de tareas presentado, esperando aprobacion), `none` (sin gate pendiente). El auto-router lee este campo en Step 0, ANTES de clasificar el intent del usuario. Si hay un gate pendiente, solo se aceptan tokens de aprobacion o feedback. Ver: Step 0 (Gate Check).

## H

**Hook**: Automatismo que se ejecuta cuando algo pasa. 2 hook types: SessionStart, Stop.

## I

**Init**: Fase 1 del pipeline SDD. Preparar la estructura de documentacion del proyecto.

**Infra Agent**: Agente que maneja organizacion de archivos, creacion de herramientas, y seguridad.

## L

**Learning Loop**: 6 preguntas en sdd-archive para mejorar el ecosistema despues de cada cambio.

## O

**O.R.T.A.**: Framework de calidad. Observabilidad, Repetibilidad, Trazabilidad, Auto-supervision.

**Observability Agent**: Agente que maneja registro de eventos, calidad, y sesiones.

**openspec/**: Carpeta raiz de SDD en cada proyecto. Contiene config, specs, y cambios.

## P

**Pipeline Agent**: Agente que coordina el flujo SDD completo (9 fases).

**Pipeline SDD**: Flujo de 9 fases: init, explore, propose, spec, design, tasks, apply, verify, archive.

**Process Analyst**: Skill CTO que mapea variantes de un proceso (10 preguntas, arbol de variantes).

**Propose**: Fase 3 del pipeline SDD. Presentar propuesta con costos, beneficios, y comunicacion al cliente.

## R

**Recursion Designer**: Skill CTO que disena mecanismos para manejar cambio externo (4 mecanismos).

**RLS (Row-Level Security)**: Seguridad a nivel de fila en PostgreSQL. Cada tenant solo ve sus datos.

**Router (MoE)**: En la analogia Mixture of Experts, el Router es CLAUDE.md — el agente principal que clasifica la intencion del usuario y delega al domain agent correcto. No ejecuta tareas de dominio directamente, sino que las enruta. Analogia: el director de orquesta que senala al musico correcto. Ver: Expert (MoE), Agent Auto-Invocation.

## S

**Scope Agent**: Agente de infraestructura del hub (pipeline, infra, observability) que siempre esta cargado. Coordina el proceso pero no aporta expertise de dominio. Ver: Domain Agent para el tipo complementario.

**Scope Rule**: Regla de organizacion. 1 feature -> features/{name}/. 2+ -> shared/. Toda app -> core/. Nunca utils/ o helpers/ en raiz.

**SDK Block (sdk:)**: Bloque YAML en frontmatter de agents que habilita deployment programatico via Claude Agent SDK. Define model, max_turns, tools, defer_loading y otras configuraciones para ejecutar el agente como servicio.

**SDD (Spec-Driven Development)**: Metodologia. Primero especificar, luego implementar.

**Security Audit**: Skill que revisa seguridad (OWASP 10 puntos, secrets, dependencies, threat model).

**Skill**: Archivo SKILL.md que le ensena a Claude una especialidad. 39 skills en v14.3.

**Skill Eval**: Framework para testing comportamental de skills usando sub-agentes y criterios de calidad. Ejecuta escenarios reales definidos en SKILL.eval.yaml y evalua si el skill responde correctamente. Comando: `/skill:eval nombre`.

**SKILL.eval.yaml**: Archivo de test cases para un skill. Contiene escenarios con input, expected behavior, quality_criteria (lo que debe pasar) y anti_criteria (lo que no debe pasar). Vive junto al SKILL.md del skill que evalua.

**Skill Gap Detection**: Mecanismo que detecta cuando falta un skill para una tecnologia y ofrece crearlo.

**Spec**: Fase 4 del pipeline SDD. Escribir requisitos exactos en Given/When/Then.

**Step 0 (Gate Check)**: Verificacion pre-routing que ejecuta el auto-router ANTES de clasificar el intent del usuario. Lee el campo `AWAITING_APPROVAL` de session.md. Si hay un gate pendiente (proposal o task_plan), el router bloquea cualquier intent que no sea aprobacion ("dale", "proceed", "si") o feedback ("ajusta X", "cambia Y") — impidiendo que la clasificacion de intent confunda una aprobacion con un comando de continuacion. Principio: "Los gates viven en el router, no en las skills". Ver: Gate Status, Auto-Routing.

**Subagente**: Nivel 2 de ejecucion. Un agente delegado para una tarea especifica (via Task tool).

## T

**Tasks**: Fase 6 del pipeline SDD. Dividir el trabajo en tareas concretas con dependencias.

**Team Orchestrator**: Skill que decide el nivel de ejecucion (solo/subagente/team) y coordina equipos.

**Technical Assumptions (Supuestos Tecnicos)**: Seccion obligatoria en las propuestas (sdd-propose) que lista explicitamente los supuestos de arquitectura que el agente hizo durante la exploracion. Cada supuesto es algo que el agente CREE que es verdad pero que el usuario debe confirmar antes de avanzar a especificacion. Ejemplo: "Asumo que `processOrder()` calcula impuestos internamente" o "Asumo que la API del ERP acepta JSON". Introducido como parte de Discovery Depth para prevenir implementaciones basadas en suposiciones incorrectas. Ver: Discovery Depth.

**Temporal.io**: Sistema de orquestacion de workflows. Garantiza completitud y reintento de tareas.

**Thick Persona (Persona densa)**: Un domain agent con 80-120 lineas de expertise embebido — no solo sabe que herramientas usar, sino que tiene criterio propio sobre como usarlas. Ejemplo: backend-agent no solo sabe que existe FastAPI, sino que tiene convenciones sobre versionado de APIs, formatos de error, y patrones de validacion. Esto lo distingue de un skill suelto que solo sigue instrucciones.

**Tombstoning**: Patron de borrado logico. Marcar datos como eliminados sin borrarlos fisicamente (para compliance).

## V

**Verify**: Fase 8 del pipeline SDD. Ejecutar la Piramide de Validacion.

## W

**Worker**: Proceso en segundo plano que ejecuta tareas (procesamiento, sincronizacion, etc.).

**Worker Scaffold**: Skill CTO que genera estructura de workers con Temporal, Docker, y Coolify.
