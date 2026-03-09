# Agentes y equipos

Los skills son los especialistas. Los agentes son los **coordinadores** que deciden que especialista trabaja en que tarea.

---

## La orquesta inteligente: como Batuta delega

Imagina una orquesta. El director (CLAUDE.md) no toca ningun instrumento — escucha lo que pide el publico y senala al musico correcto. En inteligencia artificial, este patron se llama **Mixture of Experts (MoE)**: un router decide que experto atiende cada tarea.

En Batuta funciona asi:

| Rol MoE | En Batuta | Que hace |
|---------|-----------|---------|
| **Router** | CLAUDE.md (agente principal) | Clasifica la intencion del usuario y delega |
| **Experts** | Domain agents (backend, quality, data) | Ejecutan la tarea con conocimiento especializado |
| **Parameters** | Skills (fastapi-crud, tdd-workflow, etc.) | Los instrumentos que cada experto toca |

No necesitas activar nada manualmente. Batuta detecta las senales en tu peticion (APIs, tests, datos) y delega al agente correcto de forma automatica. A esto le llamamos **auto-invocacion**.

---

## Los 6 agentes

Batuta tiene dos tipos de agentes: los que manejan la cocina (scope) y los que aportan expertise al plato (domain).

### Scope Agents — Los coordinadores de la cocina

Estos 3 agentes siempre estan cargados. Son la maquinaria del hub — sin ellos, nada funciona.

#### Pipeline Agent — El director de obra

Coordina el flujo SDD completo (explorar a archivar). Maneja: sdd-init, sdd-explore, sdd-propose, sdd-spec, sdd-design, sdd-tasks, sdd-apply, sdd-verify, sdd-archive. Nunca ejecuta logica directamente — siempre delega a los skills.

#### Infra Agent — El arquitecto de la casa

Coordina organizacion de archivos, creacion de herramientas, seguridad. Maneja: ecosystem-creator, scope-rule, team-orchestrator, security-audit, skill-eval. Cada archivo que se crea pasa por el Scope Rule.

#### Observability Agent — El inspector de calidad

Coordina registro de eventos, calidad, y continuidad de sesion. Es el motor O.R.T.A.:
- **O**bservabilidad: Registra cada accion importante
- **R**epetibilidad: Mismo input = mismo resultado
- **T**razabilidad: Cada decision se puede rastrear
- **A**uto-supervision: Detecta problemas antes de que escalen

### Domain Agents — Los especialistas que llegan automaticamente

Estos agentes se auto-invocan cuando Batuta detecta senales tecnologicas en tu peticion. No tienes que llamarlos — el router (CLAUDE.md) los activa por ti.

Cada domain agent tiene lo que llamamos **thick persona** (persona densa): entre 80 y 120 lineas de expertise embebido. Piensa en un chef que no solo sabe recetas, sino que tiene criterio propio sobre sabores, texturas y presentacion. Eso es lo que distingue a un domain agent de un skill suelto: no solo ejecuta, sino que toma decisiones informadas dentro de su dominio.

#### Backend Agent — El chef de platos fuertes

Expertise en APIs, bases de datos, y servicios backend. Se auto-invoca cuando detecta FastAPI, Express, Django, endpoints REST, autenticacion, o modelos de base de datos. Sus skills (fastapi-crud, jwt-auth, sqlalchemy-models, api-design) se cargan bajo demanda — solo cuando los necesita.

**Senales que lo activan**: endpoints API, flujos de autenticacion, modelos ORM, migraciones, diseno REST.

#### Quality Agent — El catador oficial

Testing, validacion, y buenas practicas de calidad. Es el unico domain agent que siempre se provisiona — todo proyecto necesita calidad, sin excepcion. Coordina tdd-workflow, e2e-testing, debugging-systematic, y la Piramide de Validacion.

**Senales que lo activan**: estrategia de tests, debugging, revision de seguridad, calidad de codigo, tests E2E.

#### Data Agent — El chef de ingredientes

Expertise en pipelines de datos, ETL, IA y procesamiento. Se auto-invoca cuando detecta pandas, Temporal, LangChain, bases vectoriales, o integraciones con ERPs. Sus skills (data-pipeline-design, llm-pipeline-design, vector-db-rag) se cargan bajo demanda.

**Senales que lo activan**: pipelines ETL, transformaciones de datos, clasificadores LLM, RAG, bases vectoriales.

### Como funciona la auto-invocacion

Cuando le pides algo a Batuta durante la implementacion (`sdd-apply`):

1. El router (CLAUDE.md) examina la tarea y detecta senales tecnologicas
2. Si una senal coincide con un domain agent, lo invoca automaticamente via Task tool
3. El domain agent trabaja de forma autonoma — carga sus skills bajo demanda (`defer_loading: true`)
4. El agente principal recibe el resultado y continua con la siguiente tarea

Esto ahorra tokens: el agente principal se mantiene liviano mientras los expertos hacen el trabajo pesado.

**Cuando NO se delega** (el agente principal actua directamente):
- Preguntas sobre el dominio ("deberia usar JWT o sesiones?") — necesitan dialogo
- Cambios de una sola linea o configuracion — el costo de invocar un agente supera el beneficio
- Creacion de artefactos SDD (propuestas, specs) — eso lo maneja pipeline-agent + skills
- Organizacion de archivos — eso lo maneja infra-agent + scope-rule

---

## Scope vs Domain: cuando se usa cada tipo

| Aspecto | Scope Agents | Domain Agents |
|---------|-------------|---------------|
| **Presencia** | Siempre cargados | Auto-invocados por senales tecnologicas |
| **Funcion** | Coordinan el proceso (SDD, archivos, calidad) | Aportan expertise de dominio |
| **Persona** | Ligera (coordinacion pura) | Densa (80-120 lineas de expertise embebido) |
| **Analogia** | El gerente del restaurante | El chef especializado en cocina japonesa |
| **Quien los activa** | Automatico — son la maquinaria base | El router detecta senales y los invoca |
| **Skills** | No cargan skills propios | Cargan skills bajo demanda (`defer_loading`) |
| **Excepcion** | — | quality-agent siempre se provisiona |

**Cuando importa la diferencia**: Al crear Agent Teams (Nivel 3), los scope agents coordinan el equipo mientras los domain agents aportan conocimiento especializado. Un equipo puede tener un pipeline-agent como lead y un backend-agent como implementor experto.

### Cuantos agentes tiene Batuta

| Tipo | Cantidad | Ejemplos | Crecimiento |
|------|----------|----------|-------------|
| **Scope** (fijos) | 3 | pipeline, infra, observability | No crece — son la maquinaria base |
| **Domain** (expandibles) | 3-8 | backend, quality, data | Crece cuando un dominio nuevo lo justifica (mobile, DevOps, frontend) |
| **Proyecto** (locales) | Variable | mi-agente-erp | Se quedan en el proyecto, no se sincronizan al hub |

Un domain agent nuevo solo se justifica cuando tiene: (1) convenciones propias que difieren de los agentes existentes, (2) 3 o mas skills que le pertenecen, y (3) limites de scope claros.

### Formato deployable: el bloque `sdk:`

Todos los agentes (scope y domain) tienen un bloque `sdk:` en su definicion. Este bloque permite deployar el agente como un `AgentDefinition` programatico via Claude Agent SDK — util para CI/CD y deployment automatizado. No necesitas entender esto para usar Batuta, pero es la razon por la que los agentes son portables entre el hub y los proyectos.

---

## 3 niveles de ejecucion

No todo requiere un equipo. Batuta tiene 3 niveles de complejidad, y elige automaticamente:

| Nivel | Cuando | Quien trabaja | Costo | Ejemplo |
|-------|--------|---------------|-------|---------|
| 1 — Solo | 1 archivo, bug, pregunta | Agente principal | Normal | "Arregla typo en README" |
| 2 — Subagente | 2-3 archivos, 1 fase SDD | Principal + domain agents auto-invocados | 1.2-1.5x | `sdd-apply` invoca backend-agent para implementar API |
| 3 — Agent Team | 4+ archivos, multi-scope | Equipo coordinado con domain agents como teammates | 3-5x | Feature frontend + backend + BD |

En Nivel 2, los domain agents entran y salen de forma transparente. No necesitas pedirlo — si la tarea involucra APIs, backend-agent se activa; si involucra tests, quality-agent se activa. Es como si el director de la orquesta senalara al musico correcto en el momento preciso.

### Como decide Batuta

```
Archivos a cambiar?
  1       -> Nivel 1 (solo — agente principal)
  2-3     -> Nivel 2 (subagentes — domain agents auto-invocados)
  4+      -> Necesitan comunicarse?
             No -> Nivel 2 (subagentes en paralelo)
             Si -> Nivel 3 (equipo coordinado)
                   Scope agents coordinan + domain agents como teammates
```

---

## Agent Teams en accion

Si Batuta determina Nivel 3, te pregunta antes de crear:

```
"Cambio complejo (8 archivos, 2 scopes). Recomiendo Agent Team:
- researcher: explore + propose
- architect: spec + design (con backend-agent para expertise API)
- implementor-1: apply (batch 1)
- implementor-2: apply (batch 2)
- reviewer: verify (con quality-agent para validacion)
Creo el equipo?"
```

Nota como los domain agents enriquecen el equipo: en Nivel 2 se invocan como subagentes (entran, hacen su tarea, salen), pero en Nivel 3 se integran como teammates con contratos y comunicacion entre ellos. En vez de un implementor generico, tienes uno que sabe de APIs (backend-agent) o de datos (data-agent).

### Contract-First Protocol

Antes de que cada teammate empiece, se define:
- **Que recibe**: datos e instrucciones
- **Que produce**: archivos y resultados especificos
- **Que archivos toca**: ownership exclusivo (cada archivo pertenece a 1 solo teammate)

### Cuando NO usar equipos

- Ediciones simples (1 archivo)
- Tareas secuenciales (una depende de la otra)
- Menos de 3 archivos
- Commits, formateo, documentacion rutinaria

---

-> [La capa CTO](la-capa-cto.md) — Los expertos estrategicos
