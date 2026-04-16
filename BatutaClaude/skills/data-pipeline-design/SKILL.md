---
name: data-pipeline-design
description: >
  Use when designing ETL pipelines, ERP integrations, or data processing.
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-02-23"
  source: "CTO Layer skill 02"
  bucket: build
  auto_invoke: false
  platforms: [claude, antigravity]
allowed-tools: Read Glob Grep WebSearch
---

# Data Pipeline Design — Integration Specialist

## Purpose

Disenar y construir pipelines de datos robustos que extraigan informacion de cualquier fuente — APIs, ERPs colombianos, archivos planos, scraping, bancos — y la entreguen limpia, validada y lista para consumo.

**Mantra**: Data is never clean. Plan for that.

## When to Invoke

- sdd-design incluye seccion "Data Pipeline Design"
- Nueva integracion con ERP colombiano
- Procesamiento de archivos bancarios o DIAN
- Diseno de schema PostgreSQL con RLS
- Pipeline de extraccion/transformacion/carga

## Does NOT Handle

- Arquitectura de alto nivel (→ sdd-design)
- ML/LLM pipeline design (→ llm-pipeline-design)
- PII protection policy (→ security-audit / compliance-colombia)
- Interpretacion tributaria (→ domain-experts.md Finance)

## Framework: Data Pipeline Design

### 1. Source Assessment

Para cada fuente de datos:

| Dimension | Pregunta |
|-----------|----------|
| Tipo | API REST? Archivo plano? CSV download? Scraping? DB directa? |
| Autenticacion | Token? OAuth? Cookie session? Sin auth (archivo)? |
| Frecuencia | Real-time? Diario? Mensual? On-demand? |
| Volumen | Registros por extraccion. Tamano en MB/GB |
| Calidad | Datos limpios? Campos faltantes? Formatos inconsistentes? |
| Estabilidad | La fuente cambia sin aviso? Hay versionamiento? |
| Rate limits | Limites de API? Bloqueo por scraping? |

### 2. ERP Integration Patterns (Colombia)

| ERP | Metodo principal | Fallback | Notas |
|-----|-----------------|----------|-------|
| WorldOffice | Archivos planos + DB SQL Server | Scraping web UI | API limitada |
| Siigo | API REST (mejorada 2024) | CSV export | Rate limits |
| SAP Business One | Service Layer API | DI API / archivos | Auth compleja |
| Alegra | API REST | CSV export | Paginacion |
| Helisa | Archivos planos | Scraping | Sin API real |
| Loggro | API REST basica | CSV | Cambios frecuentes |
| Defontana | API REST | Archivos | API chilena adaptada |

### 3. Data Quality Rules

Cada pipeline DEBE implementar:

```
CHECK de calidad por campo:
- Completeness: campos requeridos presentes?
- Format: formato esperado? (NIT con digito de verificacion, fechas ISO)
- Range: valores dentro de rango logico? (montos >0, fechas no futuras)
- Uniqueness: duplicados? (facturas, consecutivos)
- Referential: referencias validas? (cuenta contable existe)
- Freshness: data del periodo esperado?

Acciones por fallo:
- WARN: Loguear, continuar, incluir en reporte
- BLOCK: Detener registro, mover a cola de revision
- FAIL: Detener pipeline, alertar stakeholder
```

### 4. Schema Design Convention

```sql
-- Toda tabla lleva:
CREATE TABLE {domain}_{entity} (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    -- campos de dominio
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    source VARCHAR(100),  -- de donde vino este dato
    batch_id UUID,        -- a que extraccion pertenece
    quality_score FLOAT   -- resultado del quality check
);

-- RLS obligatorio:
ALTER TABLE {domain}_{entity} ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON {domain}_{entity}
    USING (tenant_id = current_setting('app.tenant_id')::UUID);
```

## Output Files

- `source-assessment-{nombre}-{fecha}.md`
- `pipeline-design-{nombre}-{fecha}.md`
- `schema-{domain}-{entity}.sql`

## Handoff

- **sdd-design**: Pipeline design como seccion condicional en design.md
- **sdd-verify**: Data quality rules como criterios de verificacion
- **compliance-colombia**: Datos personales en pipeline → assessment requerido
- **recursion-designer**: Si el pipeline procesa categorias externas (conceptos bancarios, cuentas contables)

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "Quality checks slow the pipeline — we'll add them later" | Bad data discovered in production costs 100x more to fix than at ingestion. Quality checks ARE the pipeline; without them you have a transport layer, not a pipeline. |
| "Skip idempotency keys for now — we can add them in v2" | The first failed re-run will corrupt data. Adding idempotency after the fact requires backfilling every existing record and is far more expensive than including it from day one. |
| "The source data is clean enough — we can skip validation" | Data is never clean. ERPs change field semantics silently, manual entry produces typos, source bugs leak nulls. Validation is the contract that protects downstream consumers. |

## Red Flags

- Pipeline writes to production tables without a `batch_id` or `source` column — impossible to trace which extraction produced which row.
- No quality_score field on output rows — downstream consumers cannot distinguish trusted from suspect data.
- Retry logic that re-processes the entire batch instead of failed records — exponential cost growth on partial failures.
- Schema lacks `tenant_id` + RLS — multi-tenant data leakage waiting to happen.
- "We'll handle duplicates in the dashboard" — wrong layer; duplicates must die at ingestion.
- No DLQ for records that fail validation — failed rows disappear silently.
- Hardcoded credentials or connection strings in pipeline code instead of secrets manager.

## Verification Checklist

- [ ] Source assessment table completed for every data source (type, auth, frequency, volume, quality, stability, rate limits)
- [ ] Quality checks defined per field (completeness, format, range, uniqueness, referential, freshness) with WARN/BLOCK/FAIL actions
- [ ] Schema includes mandatory columns: `id`, `tenant_id`, `created_at`, `updated_at`, `source`, `batch_id`, `quality_score`
- [ ] Row-Level Security policy enabled on every table with `tenant_id`
- [ ] Idempotency key defined and enforced (natural key or generated `batch_id` + position)
- [ ] DLQ table created for records that fail validation, with error context
- [ ] Retry strategy uses exponential backoff with jitter (never immediate retry)
- [ ] Secrets stored in environment or secrets manager — never in code or git
- [ ] Pipeline emits structured logs with `tenant_id`, `batch_id`, and trace context
- [ ] Re-running the pipeline on the same input produces identical output (idempotency verified)
