# Team Template: n8n Workflow Automation

> Pattern A (SDD Pipeline, simplificado) — Para automatizaciones con workflows n8n, nodos custom y tests de integracion.

---

## Cuando Usar

- Automatizacion con multiples workflows conectados (webhooks, transformaciones de datos, integraciones externas).
- El cambio toca 4+ archivos entre workflows JSON, nodos custom y tests.
- Se necesita validar que los datos fluyen correctamente entre pasos del workflow.

**No usar si**: es un workflow simple de 3-4 nodos (usa solo session) o un ajuste a un workflow existente (usa subagent).

---

## Por Que Pattern A (y no Pattern D)

En automatizaciones n8n, el flujo es mas secuencial que en una app web:

1. Primero se disenan los contratos de datos (que entra, que sale).
2. Luego se construyen los workflows que transforman esos datos.
3. Finalmente se valida que todo funciona de punta a punta.

Esto se alinea mejor con el Pipeline (Pattern A) que con Cross-Layer (Pattern D), porque no hay capas independientes sino una cadena de transformacion.

---

## Composicion del Equipo

| Teammate | Scope Agent | Responsabilidad | Archivos Propios |
|----------|-------------|-----------------|------------------|
| `workflow-dev` | pipeline-agent | Workflows n8n (JSON), nodos custom, logica de transformacion | `workflows/**`, `nodes/**` |
| `integration-tester` | pipeline-agent | Escenarios de prueba, respuestas mock, validacion de datos | `tests/**`, `mocks/**` |

**Lead coordina**: `package.json`, `README.md`, `docker-compose.yml` (si aplica), contratos de webhook, configuracion general.

Este equipo es intencionalmente pequeno. Dos teammates bien coordinados son mas eficientes que tres para automatizaciones.

---

## Contratos

### Input (lo que recibe cada teammate)

| Teammate | Recibe | De quien |
|----------|--------|----------|
| Ambos | PRD o brief del cambio | Lead |
| `workflow-dev` | Contratos de webhook (payload de entrada, formato de salida esperado) + credenciales/API keys necesarias (como referencia, no valores reales) | Lead |
| `integration-tester` | Schemas de datos por paso del workflow + lista de escenarios criticos | Lead + `workflow-dev` |

### Output (lo que debe producir cada teammate)

| Teammate | Produce | Criterio de exito |
|----------|---------|-------------------|
| `workflow-dev` | Workflows JSON exportados + nodos custom funcionales + documentacion de cada workflow | Workflows importan limpio en n8n y ejecutan sin error con datos de prueba |
| `integration-tester` | Escenarios de test + mocks de APIs externas + reporte de validacion | Todos los escenarios pasan con datos mock, edge cases cubiertos |

---

## File Ownership Map

```
LEAD (integracion):
  package.json            (dependencias de nodos custom)
  README.md               (documentacion del proyecto)
  docker-compose.yml      (n8n + servicios auxiliares, si aplica)

workflow-dev:
  workflows/**            (archivos JSON exportados de n8n)
  nodes/**                (nodos custom TypeScript/JavaScript)

integration-tester:
  tests/**                (escenarios de prueba, scripts de validacion)
  mocks/**                (respuestas mock de APIs externas)
```

---

## Cross-Review

| Revisor | Revisa a | Verifica |
|---------|----------|----------|
| `integration-tester` | `workflow-dev` | Los workflows manejan correctamente datos vacios, errores de API y timeouts |
| `workflow-dev` | `integration-tester` | Los mocks reflejan las respuestas reales de las APIs (shapes, codigos HTTP, headers) |

El Lead revisa que los contratos de webhook esten alineados entre ambos teammates.

---

## Contratos de Webhook

Los webhooks son el punto de integracion critico en automatizaciones n8n. El Lead define estos contratos antes de que el equipo empiece:

```
WEBHOOK CONTRACT:
  Nombre:      {nombre-descriptivo}
  Metodo:      POST | GET
  Path:        /webhook/{path}
  Payload de entrada:
    {campo}: {tipo} — {descripcion}
  Respuesta esperada:
    {campo}: {tipo} — {descripcion}
  Codigos HTTP:
    200: Procesado correctamente
    400: Payload invalido (campos faltantes o tipos incorrectos)
    500: Error interno del workflow
```

`workflow-dev` implementa el webhook segun este contrato. `integration-tester` genera tests contra el.

---

## Schemas de Transformacion de Datos

Cada paso del workflow transforma datos. El Lead documenta el flujo:

```
Paso 1 (Webhook Trigger):
  Input:  { order_id: string, items: array }
  Output: { order_id: string, items: array, received_at: datetime }

Paso 2 (Enrichment - API externa):
  Input:  { order_id: string }
  Output: { order_id: string, customer: object, total: number }

Paso 3 (Transformacion):
  Input:  { order_id, customer, total, items }
  Output: { notification: { to: string, subject: string, body: string } }
```

`workflow-dev` implementa cada paso. `integration-tester` valida que la salida de cada paso cumple el schema.

---

## Orden de Ejecucion Recomendado

```
1. Lead define contratos de webhook + schemas de transformacion
2. workflow-dev construye workflows + nodos custom          ─┐
3. integration-tester prepara mocks + estructura de tests   ─┘ PARALELO
4. workflow-dev exporta workflows finales (JSON)
5. integration-tester ejecuta escenarios contra los workflows
6. Cross-review entre ambos
7. Lead verifica flujo completo punta a punta
```

---

## Lecciones Aprendidas

- **Webhook contracts primero**: sin contratos claros de entrada/salida, el workflow-dev y el tester trabajan con suposiciones diferentes. Definirlos antes es obligatorio.
- **Mocks realistas**: las APIs externas fallan, responden lento o cambian formatos. `integration-tester` debe incluir escenarios de error, no solo el happy path.
- **Workflows como JSON**: siempre exportar los workflows como JSON versionable. Nunca depender solo de la instancia de n8n como fuente de verdad.
- **Nodos custom con tipos**: si se crean nodos custom, usar TypeScript y definir tipos de entrada/salida. Son el contrato del nodo.
- **Timeouts y reintentos**: cada llamada a API externa debe tener timeout y politica de reintento. `workflow-dev` los configura, `integration-tester` los valida.
- **Idempotencia**: los workflows deben poder re-ejecutarse sin duplicar efectos. Esto es especialmente critico en workflows con webhooks.

---

## Checklist Pre-Spawn

Antes de crear el equipo, verifica que estos prerequisitos estan listos:

- [ ] PRD completado o SPRINT mode con research hecho
- [ ] Contratos de webhook definidos (payloads de entrada y salida)
- [ ] APIs externas identificadas (documentacion disponible, credenciales de test listas)
- [ ] Schemas de transformacion documentados (que datos entran y salen en cada paso)
- [ ] Instancia de n8n disponible para pruebas (local con Docker o instancia de desarrollo)
- [ ] Politica de errores decidida (reintentos, notificaciones, fallback)

---

**v15**: 5 agentes contratables (pipeline, infra, backend, data, quality). quality-agent recomendado para `integration-tester` (TDD, debugging, testing). El main agent contrata agentes de `.claude/agents/` — nunca implementa directamente.

*Template basado en Pattern A (Pipeline, simplificado) del team-orchestrator. Para automatizaciones mas complejas con infraestructura dedicada (e.g., n8n auto-hosted con monitoreo), considera agregar un tercer teammate `infra-dev` y escalar a Pattern D.*
