# La capa CTO

En v15, la capa CTO se integra con Notion. El CTO escribe directivas y PRDs en Notion; Claude Code los lee via MCP y los ejecuta.

---

## Que es la capa CTO

Imagina que tienes acceso a un equipo de consultores expertos. No estan sentados en tu oficina todo el tiempo — solo aparecen cuando su especialidad es relevante. En v15, estos expertos son **skills especializados** que se asignan a los agentes contratados:

- Si tu proyecto toca datos personales → el agente contratado carga **compliance-colombia**
- Si tu proceso tiene muchas variantes → carga **process-analyst**
- Si necesitas integrar con un ERP → carga **data-pipeline-design**
- Si tu solucion usa IA → carga **llm-pipeline-design**

---

## El flujo CTO-Code

El cambio mas grande de v15 es como fluye la informacion entre el CTO (humano) y Code (agentes):

```
CTO escribe en Notion          Code lee via MCP
  |                               |
  PRD / Directiva                 Busca proyecto por nombre
  |                               |
  Pagina hija del proyecto        Lee PRD/directiva activa
  |                               |
  Contexto de negocio             Ejecuta con agentes contratados
```

### PRD como artefacto unico de planificacion

En versiones anteriores, habia multiples artefactos de planificacion (explore, propose, spec, design, tasks). En v15, el **PRD** (Product Requirements Document) es el unico artefacto de planificacion. El CTO lo escribe en Notion y Code lo lee para ejecutar.

- **Modo SPRINT**: El CTO da una directiva simple. Code investiga y ejecuta directamente.
- **Modo COMPLETO**: El CTO escribe un PRD detallado en Notion. Code lo lee, explora, disena (con aprobacion), e implementa.

### Notion via MCP (nunca hardcodear IDs)

Code busca el proyecto por el **nombre del directorio de trabajo** en la base de datos de Proyectos. Nunca se hardcodean IDs de paginas o bases de datos — los IDs cambian, los nombres persisten.

```
Interaction 0 (automatica):
1. Buscar proyecto por nombre del directorio → Proyectos DB
2. Seguir relacion a Clientes → inyectar contexto en session.md
3. Buscar PRD/directiva activa en paginas hijas del proyecto
4. Si existe → ejecutar
```

---

## Los 6 especialistas (skills CTO)

### 1. Process Analyst (Analista de Procesos)

**Cuando aparece**: El agente contratado detecta 3+ variantes en tu proceso, excepciones frecuentes, o multiples actores con roles diferentes.

**Que hace**: Mapea el universo completo de variantes ANTES de disenar. Usa 10 preguntas universales y construye un arbol donde cada caso tiene su lugar.

**Ejemplo**: Para "automatizar conciliacion bancaria", identifica 4 tipos de conciliacion, 7 excepciones, y 3 fuentes de datos que nadie habia mencionado.

### 2. Recursion Designer (Disenador de Recursion)

**Cuando aparece**: El agente detecta taxonomias externas — categorias controladas por alguien fuera de tu sistema (un banco, un regulador, un proveedor).

**Que hace**: Disena 4 mecanismos para que tu sistema maneje cambio externo sin romperse:
1. Deteccion de desconocidos (valor nuevo → no clasificar, escalar)
2. Aprobacion humana (sistema propone, humano decide)
3. Propagacion controlada (aplicar hacia adelante o hacia atras)
4. Versionado inmutable (cada version del diccionario es permanente)

### 3. Compliance Colombia

**Cuando aparece**: Tu proyecto toca datos personales, IA sobre datos personales, transferencias internacionales, o retencion tributaria.

**Que hace**: Valida contra Ley 1581/2012, Circular SIC 002/2024, Art. 632 ET. Incluye patron tombstoning (borrado logico), test de proporcionalidad, y roadmap de certificacion.

### 4. Data Pipeline Design (Ingeniero de Datos)

**Cuando aparece**: Necesitas ETL, integrar con ERPs colombianos (WorldOffice, Siigo, SAP B1), procesar archivos planos, o conectar con DIAN.

**Que hace**: Disena pipelines de extraccion, transformacion, y carga. Define reglas de calidad de datos, esquemas PostgreSQL con RLS, y conectores por tipo de fuente.

### 5. LLM Pipeline Design (Ingeniero de IA)

**Cuando aparece**: Tu solucion usa clasificadores de IA, prompts, o necesita detectar cuando el modelo se equivoca.

**Que hace**: Disena el pipeline de inteligencia en 6 fases: ingestion, clasificacion, enrutamiento, procesamiento, validacion, y retroalimentacion. Incluye scoring de confianza y deteccion de drift.

### 6. Worker Scaffold (Ingeniero de Plataforma)

**Cuando aparece**: Necesitas workers (procesos en segundo plano), deploy con Docker, o configurar Coolify.

**Que hace**: Scaffolds para el ciclo de vida de workers: estructura de directorios, configuracion Temporal, Docker containerization, deploy en Coolify, y monitoreo.

---

## Como interactuan con el pipeline SDD

En v15, los especialistas se integran segun el modo:

| Modo | Enriquecimiento CTO |
|------|---------------------|
| **SPRINT** | Research-first obligatorio. El agente contratado carga el skill especialista si detecta la senal (datos personales, variantes, taxonomias). Sin gates formales. |
| **COMPLETO** | Los skills especialistas enriquecen el design artifact que el CTO aprueba (1 gate en Design). Process-analyst durante explore, compliance durante design, etc. |

---

## Que significa para ti

No necesitas saber cuando llamar a cada experto. Solo describe tu problema y el sistema:

1. Contrata al agente correcto para la tarea
2. El agente carga los skills especializados que necesita
3. Si detecta senales CTO (variantes, compliance, IA), los integra automaticamente

Tu rol: confirmar la contratacion del agente, aprobar el diseno cuando es modo COMPLETO, y aportar el contexto de negocio que la IA no puede adivinar.

---

-> [Scope Rule](scope-rule.md) — Donde va cada archivo
