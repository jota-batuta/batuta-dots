# Agentes y equipos

En v15, Batuta cambio fundamentalmente como funcionan los agentes. El agente principal ya no ejecuta nada — es un **gestor** que contrata especialistas para cada tarea.

---

## El modelo de contratacion

Imagina una empresa. El CEO (agente principal) no programa, no investiga, no escribe codigo. Para cada tarea, contrata al profesional correcto. Si no existe, propone la contratacion al usuario.

| Concepto | Que es | Ejemplo |
|----------|--------|---------|
| **Agente principal** | El gestor que coordina | Recibe "agrega autenticacion JWT" y decide a quien contratar |
| **Agente contratado** | Archivo `.md` con un contrato permanente | `backend-agent.md` con sus skills, modelo, y limites |
| **Skill** | Conocimiento especializado que pertenece a un agente | `jwt-auth` pertenece a `backend-agent`, NO al agente principal |
| **Contrato** | Que recibe, que produce, que archivos toca | "Recibe: spec.md. Produce: routes/. NO toca: tests/" |

**Regla fundamental**: El agente principal NO tiene skills cargados. Solo sabe a quien contratar.

---

## Los 5 agentes del hub

Batuta v15 tiene 5 agentes pre-construidos en el hub. Cada uno tiene un contrato con skills asignados, un modelo recomendado, y limites claros.

### Pipeline Agent — El director de obra

Coordina el flujo SDD. Dos modos: SPRINT (implementar directo) y COMPLETO (explorar, disenar, aprobar, implementar). Nunca escribe codigo — delega a los demas agentes.

| Aspecto | Detalle |
|---------|---------|
| **Skills** | sdd-explore, sdd-design, sdd-apply, sdd-verify, prd-generator |
| **Modelo** | sonnet (orquestacion, no razonamiento pesado) |
| **Entregable** | Reportes de fase, session.md actualizado, artefactos SDD |

### Backend Agent — El ingeniero de APIs

Expertise en APIs, bases de datos, servicios backend. Se contrata cuando la tarea involucra FastAPI, Express, endpoints REST, autenticacion, o modelos de base de datos.

| Aspecto | Detalle |
|---------|---------|
| **Skills** | fastapi-crud, jwt-auth, sqlalchemy-models, api-design, message-queues, typescript-node |
| **Modelo** | sonnet (implementacion estandar) u opus (arquitectura critica) |
| **Archivos** | Solo toca `src/api/**`, `src/services/**`, `src/models/**` |

### Data Agent — El ingeniero de datos

Pipelines ETL, IA, procesamiento de datos. Se contrata cuando hay pandas, Temporal, LangChain, bases vectoriales, o integraciones con ERPs.

| Aspecto | Detalle |
|---------|---------|
| **Skills** | data-pipeline-design, llm-pipeline-design, vector-db-rag, prefect-flows |
| **Modelo** | sonnet (pipelines) u opus (arquitectura de datos compleja) |
| **Archivos** | Solo toca `src/pipelines/**`, `src/etl/**`, `src/ai/**` |

### Quality Agent — El ingeniero de calidad

Testing, validacion, seguridad. Se contrata para verificar que todo funcione correctamente.

| Aspecto | Detalle |
|---------|---------|
| **Skills** | tdd-workflow, e2e-testing, debugging-systematic, security-audit, accessibility-audit, performance-testing |
| **Modelo** | sonnet (tests estandar) u opus (debugging profundo) |
| **Archivos** | Solo toca `tests/**`, archivos de configuracion de testing |

### Infra Agent — El ingeniero de plataforma

Organizacion de archivos, Docker, CI/CD, deployment. Se contrata para decisiones de estructura y despliegue.

| Aspecto | Detalle |
|---------|---------|
| **Skills** | scope-rule, ecosystem-creator, ecosystem-lifecycle, ci-cd-pipeline, coolify-deploy, worker-scaffold |
| **Modelo** | sonnet (configuraciones deterministas) |
| **Archivos** | Dockerfiles, `.github/workflows/**`, configs de deploy |

---

## Como funciona la contratacion (agent-hiring)

Cuando le pides algo a Batuta, el agente principal sigue 5 pasos:

### Paso 1: Detectar necesidad

"Que expertise necesito?" — mapea la tarea a capacidades: tecnologia, dominio, herramientas.

### Paso 2: Buscar agentes existentes

Busca en `.claude/agents/` (proyecto) y `~/.claude/agents/` (global). Si encuentra uno adecuado, verifica que sus skills esten al dia.

### Paso 3: Proponer contratacion (USER STOP)

Si no existe un agente adecuado, presenta una propuesta al usuario:

```
PROPUESTA DE CONTRATACION:

Agente: auth-specialist
Rol: Implementar autenticacion JWT con refresh tokens
Skills: jwt-auth, fastapi-crud, security-audit
Modelo: sonnet
Max turns: 15
Entregable: Endpoints /login, /register, /refresh + tests

Apruebas esta contratacion?
```

**Nunca se salta este paso**. El usuario es el "consejo directivo".

### Paso 4: Crear archivo de agente

Con la aprobacion, crea `.claude/agents/auth-specialist.md` con el contrato formal.

### Paso 5: Invocar

Lanza el agente con la tarea especifica, los archivos que puede tocar, y la referencia al PRD o diseno si aplica.

---

## Skills pertenecen a los agentes

Este es el cambio mas importante de v15. Antes, el agente principal cargaba skills directamente. Ahora:

| Antes (v14) | Ahora (v15) |
|-------------|-------------|
| Agente principal cargaba skills | Agente principal NO tiene skills |
| Skills disponibles para todos | Skills asignados a agentes especificos |
| 39 skills todos visibles | 43 skills en el hub, solo se cargan los del agente contratado |
| Domain agents opcionales | Agentes son el unico camino de ejecucion |

**Por que importa**: Cada agente solo ve los skills que necesita. Un backend-agent no carga skills de testing. Un quality-agent no carga skills de FastAPI. Esto mantiene el contexto limpio y el agente enfocado.

---

## 3 niveles de ejecucion

No todo requiere un equipo. Batuta elige automaticamente:

| Nivel | Cuando | Quien trabaja | Costo |
|-------|--------|---------------|-------|
| 1 — Solo | 1 archivo, bug trivial | Agente principal contrata 1 agente | Normal |
| 2 — Subagentes | 2-3 archivos, 1 dominio | Principal contrata agentes que trabajan en secuencia | 1.2-1.5x |
| 3 — Agent Team | 4+ archivos, multi-dominio | Principal contrata equipo coordinado con contratos formales | 3-5x |

### Como decide Batuta

```
Archivos a cambiar?
  1       -> Nivel 1 (contratar 1 agente)
  2-3     -> Nivel 2 (contratar agentes en secuencia o paralelo)
  4+      -> Necesitan comunicarse?
             No -> Nivel 2 (agentes en paralelo, independientes)
             Si -> Nivel 3 (equipo coordinado con contratos)
```

---

## Agent Teams en v15

Si Batuta determina Nivel 3, te pregunta antes de crear el equipo. Cada teammate se contrata con el protocolo de agent-hiring:

```
"Cambio complejo (8 archivos, 2 dominios). Recomiendo Agent Team:
- researcher: sdd-explore (pipeline-agent)
- implementor-api: backend (backend-agent, archivos: src/api/**)
- implementor-data: ETL (data-agent, archivos: src/pipelines/**)
- reviewer: verificacion (quality-agent, archivos: tests/**)
Creo el equipo?"
```

### Contract-First Protocol

Antes de que cada teammate empiece, se define:
- **Que recibe**: datos e instrucciones
- **Que produce**: archivos y resultados especificos
- **Que archivos toca**: ownership exclusivo (cada archivo pertenece a 1 solo teammate)

Si un teammate intenta tocar archivos que no le pertenecen, el sistema lo detecta.

### Cuando NO usar equipos

- Ediciones simples (1 archivo)
- Tareas secuenciales (una depende de la otra)
- Menos de 3 archivos
- Commits, formateo, documentacion rutinaria

---

## Agentes en paralelo: investigacion en minutos

Uno de los superpoderes de v15: 5 agentes investigando en paralelo resuelven en minutos lo que un solo agente tardaria horas. Research-first es obligatorio en todos los modos (incluso SPRINT), y los agentes se lanzan en paralelo para maximizar velocidad.

```
Tarea: "Agrega integracion con Siigo"

Agente principal contrata en paralelo:
  - data-agent: investiga API de Siigo
  - backend-agent: investiga endpoints necesarios
  - quality-agent: investiga como testear integraciones ERP

Resultado: en 3 minutos tienes un panorama completo
```

---

## Resumen del modelo v15

| Aspecto | v14 | v15 |
|---------|-----|-----|
| Agente principal | Ejecutaba tareas | Solo gestiona y contrata |
| Agentes en hub | 6 (3 scope + 3 domain) | 5 con contrato (pipeline, backend, data, quality, infra) |
| Skills | Pertenecian al main agent | Pertenecen a los agentes |
| Contratacion | Automatica/invisible | Explicita con aprobacion del usuario |
| Agentes nuevos | Solo si justificaban 3+ skills | Cualquier tarea puede crear un agente via agent-hiring |
| Ejecucion inline | Permitida para tareas simples | Prohibida. Siempre archivo primero. |

---

-> [La capa CTO](la-capa-cto.md) — Los expertos estrategicos
