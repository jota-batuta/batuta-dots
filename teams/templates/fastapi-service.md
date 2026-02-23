# Team Template: FastAPI Microservice

> Pattern D (Cross-Layer) — Para microservicios Python con API, tests dedicados e infraestructura de despliegue.

---

## Cuando Usar

- Microservicio con endpoints REST, logica de negocio y persistencia en base de datos.
- El cambio toca 4+ archivos entre rutas, servicios, tests y configuracion de infra.
- Se necesita cobertura de tests como entregable independiente (no "tests al final").

**No usar si**: es un script simple (usa solo session) o un CRUD de un solo recurso (usa subagent).

---

## Composicion del Equipo

| Teammate | Scope Agent | Responsabilidad | Archivos Propios |
|----------|-------------|-----------------|------------------|
| `api-dev` | pipeline-agent | Rutas, servicios, modelos Pydantic, logica de negocio | `app/api/**`, `app/services/**`, `app/models/**` |
| `test-dev` | pipeline-agent | Suite de tests, fixtures, mocks, cobertura | `tests/**`, `conftest.py` |
| `infra-dev` | infra-agent | Docker, CI/CD, migraciones Alembic, configuracion | `Dockerfile`, `docker-compose.yml`, `alembic/**`, `.github/**` |

**Lead coordina**: `pyproject.toml`, `app/main.py`, `app/config.py`, `README.md`, integracion general.

---

## Contratos

### Input (lo que recibe cada teammate)

| Teammate | Recibe | De quien |
|----------|--------|----------|
| Todos | SDD spec + design artifacts | Lead |
| `api-dev` | Definicion de endpoints (paths, metodos, schemas de request/response) | Lead |
| `test-dev` | OpenAPI spec generada por `api-dev` + criterios de aceptacion del SDD | Lead + `api-dev` |
| `infra-dev` | Requisitos de despliegue + dependencias de sistema + lista de env vars | Lead |

### Output (lo que debe producir cada teammate)

| Teammate | Produce | Criterio de exito |
|----------|---------|-------------------|
| `api-dev` | Endpoints funcionales + modelos Pydantic + OpenAPI spec auto-generada | `/docs` muestra todos los endpoints con schemas correctos |
| `test-dev` | Tests unitarios + tests de integracion + fixtures reutilizables | `pytest` pasa al 100%, cobertura > 80% en rutas criticas |
| `infra-dev` | Dockerfile + compose + migraciones Alembic + pipeline CI | `docker compose up` levanta servicio + DB, migraciones aplican limpio |

---

## File Ownership Map

```
LEAD (integracion):
  pyproject.toml          (dependencias, config de herramientas)
  app/main.py             (FastAPI app factory, startup/shutdown)
  app/config.py           (settings con Pydantic BaseSettings)
  README.md

api-dev:
  app/api/**              (routers, dependencias de inyeccion)
  app/services/**         (logica de negocio, casos de uso)
  app/models/**           (modelos Pydantic, schemas SQLAlchemy)

test-dev:
  tests/**                (unit, integration, e2e)
  conftest.py             (fixtures globales, test DB, mocks)

infra-dev:
  Dockerfile              (imagen multi-stage)
  docker-compose.yml      (servicio + PostgreSQL + Redis si aplica)
  alembic/**              (config, versions, env.py)
  .github/**              (CI workflows)
```

**Regla**: si dos teammates necesitan el mismo archivo, el Lead redisena la division.

---

## Cross-Review

| Revisor | Revisa a | Verifica |
|---------|----------|----------|
| `test-dev` | `api-dev` | Endpoints cubren todos los casos de la spec, validaciones Pydantic correctas |
| `api-dev` | `test-dev` | Tests reflejan el comportamiento real de los endpoints (no tests triviales) |
| `infra-dev` | `api-dev` | Variables de entorno usadas correctamente, no hay secrets hardcodeados |
| `infra-dev` | `test-dev` | Tests pueden correr en CI (no dependen de recursos locales) |

El Lead revisa todos los outputs contra la SDD spec original.

---

## Orden de Ejecucion Recomendado

```
1. Lead define endpoints y schemas (API schema)
2. api-dev implementa rutas + servicios + modelos     ─┐
3. infra-dev configura Docker + Alembic + CI           ─┤ PARALELO
4. test-dev prepara fixtures + estructura de tests     ─┘
5. api-dev produce OpenAPI spec (auto-generada por FastAPI)
6. test-dev genera tests contra la OpenAPI spec real
7. Cross-review entre todos
8. Lead verifica integracion + ejecuta suite completa
```

---

## Flujo de la OpenAPI Spec

Este equipo tiene un flujo especial: la OpenAPI spec es un artefacto intermedio que conecta a `api-dev` con `test-dev`.

```
api-dev implementa endpoints
    ↓
FastAPI genera OpenAPI spec (/openapi.json)
    ↓
test-dev consume la spec para:
    - Generar tests de contrato (response shapes)
    - Validar edge cases por endpoint
    - Crear mocks realistas para tests unitarios
```

Esto significa que `test-dev` puede arrancar con fixtures y estructura, pero los tests finales dependen del output de `api-dev`.

---

## Lecciones Aprendidas

- **Pydantic models son el contrato**: define los modelos de request/response antes de implementar logica. Son la fuente de verdad para API y tests.
- **Alembic migrations coordinadas**: `infra-dev` gestiona la carpeta `alembic/`, pero los cambios a modelos SQLAlchemy los hace `api-dev`. Coordinar via Lead cuando hay cambios de schema.
- **Fixtures compartidas via conftest.py**: `test-dev` es dueno de `conftest.py`. Si `api-dev` necesita una fixture, la pide a `test-dev` o la propone y `test-dev` la integra.
- **Health check primero**: `api-dev` implementa `/health` como primer endpoint. `infra-dev` lo usa en Docker y CI para verificar que el servicio arranca.
- **No hardcodear env vars**: usar `app/config.py` con `BaseSettings`. `infra-dev` define las variables, `api-dev` las consume via config.

---

## Checklist Pre-Spawn

Antes de crear el equipo, verifica que estos prerequisitos estan listos:

- [ ] SDD spec y design completados
- [ ] Lista de endpoints definida (paths, metodos HTTP, schemas)
- [ ] Modelo de datos decidido (entidades principales, relaciones)
- [ ] Base de datos seleccionada (PostgreSQL, SQLite para dev)
- [ ] Estrategia de auth decidida (JWT, API keys, OAuth2)
- [ ] Requisitos de despliegue claros (Coolify, Docker standalone, Kubernetes)

---

*Template basado en Pattern D (Cross-Layer) del team-orchestrator. Ajusta la composicion si tu servicio no necesita infra dedicada (por ejemplo, un servicio interno puede prescindir de `infra-dev`).*
