# Team Template: Next.js SaaS

> Pattern D (Cross-Layer) — Para aplicaciones multi-tenant con frontend, backend y despliegue coordinados.

---

## Cuando Usar

- App multi-tenant con autenticacion, dashboard y billing (facturacion recurrente).
- El cambio toca 4+ archivos distribuidos entre frontend, backend e infraestructura.
- Los teammates necesitan comunicarse: el frontend consume la API que el backend produce.

**No usar si**: el cambio es solo frontend (usa solo session) o solo un endpoint nuevo (usa subagent).

---

## Composicion del Equipo

| Teammate | Scope Agent | Responsabilidad | Archivos Propios |
|----------|-------------|-----------------|------------------|
| `backend-dev` | pipeline-agent | API routes, middleware, modelos Prisma, logica de negocio | `src/app/api/**`, `prisma/**`, `src/lib/server/**` |
| `frontend-dev` | pipeline-agent | Componentes, paginas, estado del cliente, UI/UX | `src/app/(dashboard)/**`, `src/components/**`, `src/lib/client/**` |
| `infra-dev` | infra-agent | Docker, CI/CD, configuracion de entorno, despliegue | `Dockerfile`, `docker-compose.yml`, `.github/**`, `.env.example` |

**Lead coordina**: `package.json`, `tsconfig.json`, `next.config.js`, `README.md`, puntos de integracion.

---

## Contratos

### Input (lo que recibe cada teammate)

| Teammate | Recibe | De quien |
|----------|--------|----------|
| Todos | SDD spec + design artifacts | Lead |
| `backend-dev` | API schema: endpoints, request/response types, auth requirements | Lead |
| `frontend-dev` | Descripciones de UI o wireframes + API schema (para consumir endpoints) | Lead |
| `infra-dev` | Requisitos de despliegue + lista de variables de entorno | Lead |

### Output (lo que debe producir cada teammate)

| Teammate | Produce | Criterio de exito |
|----------|---------|-------------------|
| `backend-dev` | API routes funcionales + migraciones Prisma + tests de API | Endpoints responden con los shapes definidos en el schema |
| `frontend-dev` | Paginas y componentes funcionales + tests client-side | UI renderiza correctamente y consume la API sin errores |
| `infra-dev` | Config Docker + pipeline CI + template de variables de entorno | `docker compose up` levanta el entorno completo |

---

## File Ownership Map

```
LEAD (integracion):
  package.json, tsconfig.json, next.config.js, README.md

backend-dev:
  src/app/api/**          (API routes)
  prisma/**               (schema, migraciones, seed)
  src/lib/server/**       (utilidades server-side, auth helpers)

frontend-dev:
  src/app/(dashboard)/**  (paginas del dashboard)
  src/components/**       (componentes React)
  src/lib/client/**       (hooks, stores, utilidades client-side)

infra-dev:
  Dockerfile              (imagen de produccion)
  docker-compose.yml      (orquestacion local)
  .github/**              (workflows CI/CD)
  .env.example            (plantilla de variables de entorno)
```

**Regla**: si dos teammates necesitan el mismo archivo, el Lead redisena la division de tareas.

---

## Cross-Review

Una vez que cada teammate produce sus outputs, se cruzan revisiones para atrapar errores de integracion:

| Revisor | Revisa a | Verifica |
|---------|----------|----------|
| `frontend-dev` | `backend-dev` | Las respuestas de la API tienen los shapes correctos para el frontend |
| `backend-dev` | `frontend-dev` | Las llamadas del frontend usan los endpoints y parametros correctos |
| `infra-dev` | Ambos | Uso correcto de variables de entorno (nombres, valores esperados) |

El Lead revisa todos los outputs contra la SDD spec original.

---

## Orden de Ejecucion Recomendado

```
1. Lead define API schema (endpoints, types, auth)
2. backend-dev implementa API routes + Prisma    ─┐
3. infra-dev configura Docker + CI + env template ─┤ PARALELO
4. frontend-dev arranca con mocks del API schema  ─┘
5. frontend-dev integra contra API real (cuando backend-dev termina)
6. Cross-review entre todos
7. Lead verifica integracion + actualiza session
```

---

## Lecciones Aprendidas

- **API contracts primero**: define los endpoints y sus tipos antes de que frontend empiece a consumir. Evita retrabajo.
- **Prisma schema = punto de coordinacion**: cualquier cambio al schema de base de datos pasa por el Lead. Un cambio en un modelo puede romper API y frontend simultaneamente.
- **Variables de entorno**: `infra-dev` define los nombres y valores por defecto. Los otros teammates consumen, nunca inventan variables nuevas sin coordinar.
- **Auth middleware es compartido**: vive en `src/lib/server/` pero afecta a `backend-dev` y potencialmente a `frontend-dev`. El Lead coordina cambios.
- **Migraciones antes de UI**: `backend-dev` debe completar las migraciones de Prisma antes de que `frontend-dev` integre contra la API real.

---

## Checklist Pre-Spawn

Antes de crear el equipo, verifica que estos prerequisitos estan listos:

- [ ] SDD spec y design completados (fases explore, propose, spec, design)
- [ ] API schema definido (lista de endpoints, tipos de request/response)
- [ ] Wireframes o descripciones de UI disponibles
- [ ] Target de despliegue decidido (Coolify, Vercel, Docker standalone)
- [ ] Estrategia de auth decidida (NextAuth, Clerk, auth custom)
- [ ] Variables de entorno conocidas listadas (DB_URL, AUTH_SECRET, etc.)

---

*Template basado en Pattern D (Cross-Layer) del team-orchestrator. Ajusta segun las necesidades especificas de tu proyecto.*
