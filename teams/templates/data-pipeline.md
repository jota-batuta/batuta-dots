# Team Template: Data Pipeline (ETL/ELT)

> **Patron**: D (Cross-Layer) — cada teammate posee una capa arquitectonica distinta.
> **Stack**: Python (pandas, Polars, dbt), Airflow/Prefect, Docker, PostgreSQL/BigQuery/S3.
> **Nivel recomendado**: 3 (Agent Team) cuando hay transformaciones + validacion + infraestructura simultaneas.

---

## Cuando Usar

- Pipeline de datos que extrae de una o mas fuentes, transforma, y carga en un destino.
- Se necesitan validaciones de calidad de datos como paso formal (no solo "a ver si funciona").
- La infraestructura de orquestacion (Airflow, Prefect, cron) y contenedores requiere configuracion dedicada.
- Esquemas de entrada y salida deben estar definidos contractualmente antes de implementar.

### Cuando NO Usar

- Script simple de transformacion (un archivo, sin orquestador) — usa solo session.
- Solo necesitas agregar un paso a un pipeline existente — usa subagent.
- No hay requisitos de validacion de datos — evalua si el equipo completo es necesario.

---

## Composicion

| Teammate | Scope Agent | Responsabilidad | Archivos Propios |
|----------|-------------|-----------------|------------------|
| `pipeline-dev` | data-agent (recomendado) o pipeline-agent | Logica ETL/ELT, transformaciones, scheduling | `features/ingestion/**`, `features/transformation/**`, `features/loading/**`, `core/scheduling/**` |
| `data-validator` | quality-agent (recomendado) o pipeline-agent | Checks de calidad, validacion de esquemas, tests | `features/validation/**`, `tests/**`, `core/schemas/**` |
| `infra-dev` | infra-agent | Docker, configuracion de orquestador, almacenamiento | `Dockerfile`, `docker-compose.yml`, `infra/**` |

**Lead owns**: `main.py` / `run.py`, configuracion global, `README.md`, integracion entre capas.

---

## Contratos

### Input Contracts

| Teammate | Recibe | Formato | De quien |
|----------|--------|---------|----------|
| `pipeline-dev` | Esquemas de fuentes de datos + reglas de transformacion + destino esperado | JSON Schema en `schemas/` + Markdown (PRD o brief) | Lead |
| `data-validator` | Esquemas de entrada/salida + reglas de negocio para validacion | JSON Schema en `schemas/` + reglas en Markdown | Lead |
| `infra-dev` | Requisitos de orquestacion + dependencias + volumenes de datos esperados | Markdown (PRD o brief) + lista de servicios | Lead |

### Output Contracts

| Teammate | Produce | Formato | Criterio de exito |
|----------|---------|---------|-------------------|
| `pipeline-dev` | Pipeline funcional que transforma datos segun spec | Codigo en `features/ingestion/` + `features/transformation/` + `features/loading/` | Datos de prueba transformados correctamente (comparacion con expected output) |
| `data-validator` | Suite de validacion que detecta anomalias | Codigo en `features/validation/` + tests en `tests/` | 100% de reglas de negocio cubiertas; datos invalidos rechazados correctamente |
| `infra-dev` | Infraestructura lista para ejecutar el pipeline | `Dockerfile` + `docker-compose.yml` + configs en `infra/` | Pipeline ejecuta end-to-end en contenedor local |

---

## File Ownership Map

```
pipeline-dev OWNS:
  features/ingestion/**        (extractores, conectores a fuentes)
  features/transformation/**   (funciones de transformacion)
  features/loading/**          (loaders a destinos)
  core/scheduling/**           (definiciones de schedule/DAG)

data-validator OWNS:
  features/validation/**       (checks de calidad de datos)
  tests/**                     (unit tests + integration tests)
  core/schemas/**              (JSON Schema de entrada/salida)

infra-dev OWNS:
  Dockerfile
  docker-compose.yml
  infra/**           (configs de Airflow/Prefect, scripts de deploy, storage)

Lead OWNS:
  main.py / run.py
  config files (.env.example, pyproject.toml)
  README.md
```

> Regla critica: `core/schemas/` pertenece a `data-validator`, pero `pipeline-dev` los lee como referencia. Si `pipeline-dev` necesita cambiar un esquema, lo solicita a traves del Lead.

---

## Cross-Review

| Reviewer | Revisa | Pregunta clave |
|----------|--------|----------------|
| `data-validator` | Transformaciones de `pipeline-dev` | "Los datos de salida cumplen con los esquemas definidos? Hay edge cases no cubiertos?" |
| `pipeline-dev` | Reglas de validacion de `data-validator` | "Las validaciones reflejan las reglas de negocio reales? Hay falsos positivos?" |
| `infra-dev` | Dependencias de `pipeline-dev` y `data-validator` | "Los contenedores tienen todas las dependencias? Los volumenes estan mapeados correctamente?" |
| `data-validator` | Configuracion de `infra-dev` | "El scheduling es correcto? Los timeouts son suficientes para el volumen de datos?" |

---

## Flujo de Ejecucion

```
1. Lead define esquemas de entrada/salida (contratos de datos)
2. Tres teammates trabajan en PARALELO:
   - pipeline-dev: implementa extractores, transformaciones, loaders
   - data-validator: implementa validaciones y tests basados en esquemas
   - infra-dev: configura Docker, orquestador, storage
3. Integracion: Lead conecta pipeline + validadores + infraestructura
4. data-validator ejecuta suite completa sobre datos de prueba
5. Cross-review entre los tres teammates
6. Lead verifica ejecucion end-to-end en contenedor
```

---

## Enfoque en Esquemas (Contract-First para Datos)

En pipelines de datos, los **esquemas son los contratos**. Antes de escribir una linea de codigo:

```
SCHEMA CONTRACT:
  Input Schema:  core/schemas/source_{name}.json          — define estructura de cada fuente
  Output Schema: core/schemas/target_{name}.json          — define estructura del destino
  Transform Rules: features/transformation/rules.md       — reglas de negocio para transformacion
  Validation Rules: features/validation/rules.md          — que hace que un registro sea invalido
```

Estos cuatro artefactos se definen ANTES del spawn. Los teammates los reciben como input inmutable. Si un teammate descubre que un esquema necesita cambio, lo escala al Lead.

---

## Lecciones Aprendidas

- **Esquemas primero, codigo despues** — sin esquemas claros, cada teammate asume formatos diferentes y la integracion falla.
- **Datos de prueba representativos son criticos** — incluir edge cases (nulls, duplicados, formatos inesperados) desde el dia uno.
- **Validacion no es opcional** — un pipeline sin validacion es una bomba de tiempo. Los datos malos se propagan silenciosamente.
- **Docker desde el inicio** — "funciona en mi maquina" es especialmente peligroso en pipelines de datos por las dependencias de sistema.
- **Idempotencia** — disenar cada paso del pipeline para que pueda re-ejecutarse sin efectos secundarios. Esto simplifica debugging y recovery.
- **Logging estructurado** — cada paso del pipeline debe emitir logs con timestamp, registros procesados, y errores encontrados.

---

## Checklist Pre-Spawn

Antes de crear el equipo, el Lead verifica:

- [ ] Fuentes de datos identificadas (APIs, bases de datos, archivos, streams)
- [ ] Esquemas de entrada definidos (JSON Schema o equivalente)
- [ ] Esquema de salida definido (estructura del destino final)
- [ ] Reglas de transformacion documentadas (que se hace con cada campo)
- [ ] Reglas de validacion documentadas (que hace que un registro sea invalido)
- [ ] Orquestador seleccionado (Airflow, Prefect, cron, manual)
- [ ] Datos de prueba preparados (incluir edge cases: nulls, duplicados, tipos incorrectos)
- [ ] Volumen estimado (afecta decisiones de batch vs stream, timeouts, recursos)

---

**v15**: 5 agentes contratables (pipeline, infra, backend, data, quality). data-agent es recomendado para `pipeline-dev` (expertise en ETL, pandas/polars, data quality). quality-agent disponible en todo proyecto. El main agent contrata agentes de `.claude/agents/` — nunca implementa directamente.
