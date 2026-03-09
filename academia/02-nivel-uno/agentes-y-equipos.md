# Agentes y equipos

Los skills son los especialistas. Los agentes son los **coordinadores** que deciden que especialista trabaja en que tarea.

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

### Domain Agents — Los especialistas que viajan al proyecto

Estos 3 agentes se provisionan a cada proyecto segun las tecnologias que detecta `sdd-init`. No estan siempre presentes — viajan al proyecto que los necesita.

#### Backend Agent — El chef de platos fuertes

Expertise en APIs, bases de datos, y servicios backend. Se provisiona cuando el proyecto tiene FastAPI, Express, Django, o frameworks similares. Lleva consigo punteros a skills como fastapi-crud, jwt-auth, sqlalchemy-models, y api-design.

#### Quality Agent — El catador oficial

Testing, validacion, y buenas practicas de calidad. **Siempre se provisiona** — todo proyecto necesita calidad, sin excepcion. Coordina tdd-workflow, e2e-testing, debugging-systematic, y la Piramide de Validacion.

#### Data Agent — El chef de ingredientes

Expertise en pipelines de datos, ETL, y procesamiento. Se provisiona cuando el proyecto maneja datos complejos, integraciones con ERPs, o pipelines de IA. Lleva punteros a data-pipeline-design, llm-pipeline-design, y vector-db-rag.

---

## Scope vs Domain: cuando se usa cada tipo

| Aspecto | Scope Agents | Domain Agents |
|---------|-------------|---------------|
| **Presencia** | Siempre cargados | Provisionados por proyecto |
| **Funcion** | Coordinan el proceso (SDD, archivos, calidad) | Aportan expertise de dominio |
| **Analogia** | El gerente del restaurante | El chef especializado en cocina japonesa |
| **Quien los activa** | Automatico — son la maquinaria base | `sdd-init` detecta tecnologias y los copia |
| **Excepcion** | — | quality-agent siempre se provisiona |

**Cuando importa la diferencia**: Al crear Agent Teams (Nivel 3), los scope agents coordinan el equipo mientras los domain agents aportan conocimiento especializado. Un equipo puede tener un pipeline-agent como lead y un backend-agent como implementor experto.

### Formato deployable: el bloque `sdk:`

Todos los agentes (scope y domain) tienen un bloque `sdk:` en su definicion. Este bloque permite deployar el agente como un `AgentDefinition` programatico via Claude Agent SDK — util para CI/CD y deployment automatizado. No necesitas entender esto para usar Batuta, pero es la razon por la que los agentes son portables entre el hub y los proyectos.

---

## 3 niveles de ejecucion

No todo requiere un equipo. Batuta tiene 3 niveles:

| Nivel | Cuando | Costo | Ejemplo |
|-------|--------|-------|---------|
| 1 — Solo | 1 archivo, bug, pregunta | Normal | "Arregla typo en README" |
| 2 — Subagente | Investigar, verificar, 1 fase SDD | 1.2-1.5x | `/sdd-explore` lanza sub-agente |
| 3 — Agent Team | 4+ archivos, multi-scope, comunicacion | 3-5x | Feature frontend + backend + BD |

### Como decide Batuta

```
Archivos a cambiar?
  1       -> Nivel 1 (solo)
  2-3     -> Nivel 2 (subagente)
  4+      -> Necesitan comunicarse?
             No -> Nivel 2 (subagentes en paralelo)
             Si -> Nivel 3 (equipo)
                   Scope agents coordinan + domain agents aportan expertise
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

Nota como los domain agents enriquecen el equipo: en vez de un implementor generico, tienes uno que sabe de APIs (backend-agent) o de datos (data-agent).

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
