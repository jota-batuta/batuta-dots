# Glosario

Terminos del ecosistema Batuta Dots explicados en lenguaje simple.

---

## A

**Agent Team (Equipo de agentes)**: Nivel 3 de ejecucion. Multiples agentes trabajando en paralelo con comunicacion bidireccional. Para tareas complejas de 4+ archivos.

**AI Validation Pyramid (Piramide de Validacion)**: 5 capas de verificacion. L1: linting/tipos/build. L2: tests unitarios. L3: tests integracion. L4: revision humana. L5: pruebas manuales. Regla: base rota = no hay revision humana.

**Apply**: Fase 7 del pipeline SDD. Implementar codigo siguiendo las tareas definidas.

**Archive**: Fase 9 del pipeline SDD. Cerrar un cambio, sincronizar specs, documentar lecciones.

## C

**Change (Cambio)**: Unidad de trabajo en SDD. Cada cambio tiene su carpeta en `openspec/changes/{nombre}/` con todos los artefactos.

**CLAUDE.md**: Archivo principal de configuracion. Define personalidad, reglas, Scope Rule, Execution Gate, y comandos SDD.

**Compliance**: Cumplimiento de regulaciones. En contexto colombiano: Ley 1581 (datos personales), SIC (IA), Art. 632 (tributario).

**Contract-First Protocol**: Regla de Agent Teams. Antes de crear un equipo, se definen contratos explicitos: que recibe, que produce, y que archivos toca cada teammate.

**Coolify**: Plataforma de deploy. Como Heroku pero en tu propio servidor.

## D

**Design**: Fase 5 del pipeline SDD. Definir arquitectura, componentes, y decisiones tecnicas.

**Discovery Completeness**: 5 preguntas obligatorias antes de proponer: todos los tipos? excepciones? categorias externas? participantes? ramas?

**Domain Experts**: Configuracion por proyecto en `openspec/domain-experts.md`. Expertos de dominio (finanzas, RRHH, legal) con reglas de negocio especificas.

## E

**Ecosystem Creator**: Skill para crear nuevos skills, agentes, y workflows.

**Execution Gate**: Validacion obligatoria antes de escribir codigo. Modo LIGHT (1 linea) o FULL (plan completo). Implementado como hook PreToolUse.

**Explore**: Fase 2 del pipeline SDD. Investigar el problema antes de proponer soluciones.

## F

**Fast-forward (FF)**: Comando `/sdd-ff`. Ejecuta propose + spec + design + tasks en secuencia rapida.

## G

**Gate**: Punto de control entre fases SDD. G0.5 (Discovery Complete), G1 (Solution Worth Building), G2 (Ready for Production).

## H

**Hook**: Automatismo que se ejecuta cuando algo pasa. 6 hooks: SessionStart, PreToolUse, PostToolUse, Stop, TeammateIdle, TaskCompleted.

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

**Prompt Tracker**: Skill que registra interacciones y genera recomendaciones de mejora.

**Propose**: Fase 3 del pipeline SDD. Presentar propuesta con costos, beneficios, y comunicacion al cliente.

## R

**Recursion Designer**: Skill CTO que disena mecanismos para manejar cambio externo (4 mecanismos).

**RLS (Row-Level Security)**: Seguridad a nivel de fila en PostgreSQL. Cada tenant solo ve sus datos.

## S

**Scope Rule**: Regla de organizacion. 1 feature -> features/{name}/. 2+ -> shared/. Toda app -> core/. Nunca utils/ o helpers/ en raiz.

**SDD (Spec-Driven Development)**: Metodologia. Primero especificar, luego implementar.

**Security Audit**: Skill que revisa seguridad (OWASP 10 puntos, secrets, dependencies, threat model).

**Skill**: Archivo SKILL.md que le ensena a Claude una especialidad. 24 skills en v11.0.

**Skill Gap Detection**: Mecanismo que detecta cuando falta un skill para una tecnologia y ofrece crearlo.

**Skill Sync**: Proceso de regenerar tablas de ruteo despues de crear/modificar skills.

**Spec**: Fase 4 del pipeline SDD. Escribir requisitos exactos en Given/When/Then.

**Subagente**: Nivel 2 de ejecucion. Un agente delegado para una tarea especifica (via Task tool).

## T

**Tasks**: Fase 6 del pipeline SDD. Dividir el trabajo en tareas concretas con dependencias.

**Team Orchestrator**: Skill que decide el nivel de ejecucion (solo/subagente/team) y coordina equipos.

**Temporal.io**: Sistema de orquestacion de workflows. Garantiza completitud y reintento de tareas.

**Tombstoning**: Patron de borrado logico. Marcar datos como eliminados sin borrarlos fisicamente (para compliance).

## V

**Verify**: Fase 8 del pipeline SDD. Ejecutar la Piramide de Validacion.

## W

**Worker**: Proceso en segundo plano que ejecuta tareas (procesamiento, sincronizacion, etc.).

**Worker Scaffold**: Skill CTO que genera estructura de workers con Temporal, Docker, y Coolify.
