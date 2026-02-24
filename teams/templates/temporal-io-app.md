# Team Template: Temporal.io Application

> Pattern D (Cross-Layer) — Para aplicaciones de orquestacion con Temporal.io: workflows, activities, workers y API.

---

## Cuando Usar

- Aplicacion con workflows Temporal, activities de negocio, workers y API de control.
- El cambio toca 4+ archivos entre workflows, activities, API, tests e infraestructura Docker.
- Los workflows tienen compensacion (saga pattern) o coordinan multiples servicios.

**No usar si**: es un workflow simple con 2 activities (usa subagent) o un script one-shot.

---

## Composicion del Equipo

| Teammate | Scope Agent | Responsabilidad | Archivos Propios |
|----------|-------------|-----------------|------------------|
| `workflow-dev` | pipeline-agent | Workflows, signal handlers, queries, workflow tests | `features/*/workflows/**` |
| `activity-dev` | pipeline-agent | Activities de negocio, modelos de datos, logica de dominio | `features/*/activities/**`, `features/*/models/**` |
| `api-dev` | pipeline-agent | API de control (iniciar workflows, consultar estado), health checks | `features/*/api/**`, `core/main.py` |
| `infra-dev` | infra-agent | Docker, docker-compose (Temporal server + workers), configuracion | `Dockerfile`, `docker-compose.yml`, `core/config.py` |

**Lead coordina**: `requirements.txt`/`pyproject.toml`, `core/database.py`, `core/temporal_client.py`, `README.md`, integracion general.

---

## Contratos

### Input (lo que recibe cada teammate)

| Teammate | Recibe | De quien |
|----------|--------|----------|
| Todos | SDD spec + design artifacts | Lead |
| `workflow-dev` | Definicion de flujos (steps, retry policies, compensacion, timeouts) | Lead |
| `activity-dev` | Interfaces de activities (input/output types, side effects, idempotencia) | Lead + `workflow-dev` |
| `api-dev` | Workflow IDs, metodos de inicio, formatos de consulta de estado | Lead + `workflow-dev` |
| `infra-dev` | Task queues, requisitos de Temporal server, worker config | Lead |

### Output (lo que debe producir cada teammate)

| Teammate | Produce | Criterio de exito |
|----------|---------|-------------------|
| `workflow-dev` | Workflows con retry policies, compensacion, signal/query handlers | Workflows se registran sin errores, tests de replay pasan |
| `activity-dev` | Activities idempotentes + modelos + logica de negocio testeable | Unit tests pasan sin Temporal SDK (logica pura) |
| `api-dev` | Endpoints para iniciar/consultar workflows + health check | API responde con status correcto, workflow IDs validos |
| `infra-dev` | docker-compose con Temporal server + worker + API + UI | `docker compose up` levanta todo el stack |

---

## File Ownership Map

```
LEAD (integracion):
  requirements.txt / pyproject.toml  (dependencias)
  core/database.py                   (conexion DB, session)
  core/temporal_client.py            (cliente Temporal singleton)
  README.md

workflow-dev:
  features/*/workflows/**           (workflow definitions, @workflow.defn)
  features/*/workers/**             (worker registration, task queues)

activity-dev:
  features/*/activities/**          (activity implementations, @activity.defn)
  features/*/models/**              (dataclasses, input/output types)

api-dev:
  features/*/api/**                 (FastAPI routers, endpoints de control)
  core/main.py                      (app factory, startup events)

infra-dev:
  Dockerfile                        (imagen multi-stage para worker + API)
  docker-compose.yml                (Temporal server + temporal-ui + worker + API)
  .github/**                        (CI workflows)
```

**Regla**: si dos teammates necesitan el mismo archivo, el Lead redisena la division.

---

## Cross-Review

| Revisor | Revisa a | Verifica |
|---------|----------|----------|
| `workflow-dev` | `activity-dev` | Activities son idempotentes, tipos input/output coinciden con workflow |
| `activity-dev` | `workflow-dev` | Retry policies son razonables, compensacion cubre todos los side effects |
| `api-dev` | `workflow-dev` | Workflow IDs son deterministas (para idempotencia), status es consultable |
| `infra-dev` | Todos | No hay secrets hardcodeados, task queues coinciden entre worker y workflow |

El Lead revisa todos los outputs contra la SDD spec original.

---

## Orden de Ejecucion Recomendado

```
1. Lead define flujos, interfaces y modelos de datos
2. activity-dev implementa activities + modelos              ─┐
3. infra-dev configura Docker + Temporal server + compose     ─┤ PARALELO
4. api-dev prepara endpoints + health check                   ─┘
5. workflow-dev implementa workflows usando activities (depende de #2)
6. workflow-dev configura workers con activities registradas
7. Cross-review entre todos
8. Lead verifica integracion + ejecuta suite completa con docker compose
```

**Nota**: `workflow-dev` depende de `activity-dev` porque los workflows invocan activities. Sin embargo, `workflow-dev` puede empezar con stubs mientras `activity-dev` completa la implementacion real.

---

## Patrones Clave de Temporal

### Idempotencia de Workflows

```python
# WHY: Usar email o ID externo como workflow_id garantiza que
# ejecutar la misma solicitud dos veces no crea un workflow duplicado
workflow_id = f"onboarding-{customer_email}"
```

### Testing de Activities (sin Temporal SDK)

```python
# WHY: Las activities contienen logica de negocio pura.
# Testearlas directamente (sin decoradores Temporal) es mas rapido
# y aislado. Los decoradores @activity.defn son solo metadata.
def test_validate_customer_data():
    result = validate_data_impl(CustomerData(name="Ana", email="ana@test.com"))
    assert result.is_valid
```

### Retry Policies

```python
# WHY: No todas las fallas son iguales.
# - Validacion: NO reintentar (el dato esta mal, reintentar no ayuda)
# - Email: SI reintentar (el servidor puede estar temporalmente caido)
# - DB: SI reintentar con backoff (congestion temporal)
DEFAULT_RETRY_POLICY = RetryPolicy(
    maximum_attempts=3,
    initial_interval=timedelta(seconds=1),
    backoff_coefficient=2.0,
)
```

---

## Lecciones Aprendidas

- **Activities son logica pura**: la logica de negocio vive en las activities, no en los workflows. Esto permite testear sin Temporal SDK y reutilizar logica.
- **Workflows son orquestacion**: los workflows solo deciden el ORDEN y manejan errores. No contienen logica de negocio directa.
- **Scope Rule mapea bien a Temporal**: `features/{domain}/workflows/`, `features/{domain}/activities/`, `features/{domain}/api/` refleja la separacion natural de Temporal.
- **Docker compose para dev**: Temporal necesita un server corriendo. `docker-compose.yml` con `temporalio/auto-setup` es la forma mas simple de levantar todo el stack localmente.
- **Compensacion explicita**: para cada activity con side effects, definir que pasa si falla un paso posterior. Documentar la estrategia de compensacion en el design.md.

---

## Checklist Pre-Spawn

Antes de crear el equipo, verifica que estos prerequisitos estan listos:

- [ ] SDD spec y design completados
- [ ] Flujos de workflow definidos (steps, orden, compensacion)
- [ ] Activities identificadas (una por side effect externo)
- [ ] Task queues nombradas
- [ ] Retry policies definidas por tipo de falla
- [ ] Base de datos seleccionada (PostgreSQL para produccion, SQLite para tests)
- [ ] Requisitos de Docker claros (Temporal server, worker, API)

---

*Template basado en Pattern D (Cross-Layer) del team-orchestrator. La composicion incluye `infra-dev` porque Temporal requiere infraestructura dedicada (server + workers). Para aplicaciones que usan Temporal Cloud en vez de self-hosted, `infra-dev` puede simplificarse.*
