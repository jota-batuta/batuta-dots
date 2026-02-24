# La capa CTO

En la version 10.0, Batuta Dots integro una **capa de estrategia CTO** — 6 expertos especialistas que se activan automaticamente cuando tu proyecto lo necesita. No tienes que llamarlos; el sistema detecta cuando hacen falta.

---

## Que es la capa CTO

Imagina que tienes acceso a un equipo de consultores expertos. No estan sentados en tu oficina todo el tiempo — solo aparecen cuando su especialidad es relevante:

- Si tu proyecto toca datos personales → aparece el **experto en compliance**
- Si tu proceso tiene muchas variantes → aparece el **analista de procesos**
- Si necesitas integrar con un ERP → aparece el **ingeniero de datos**
- Si tu solucion usa IA → aparece el **ingeniero de LLM**

---

## Los 6 especialistas

### 1. Process Analyst (Analista de Procesos)

**Cuando aparece**: El sistema detecta 3+ variantes en tu proceso, excepciones frecuentes, o multiples actores con roles diferentes.

**Que hace**: Mapea el universo completo de variantes ANTES de disenar. Usa 10 preguntas universales y construye un arbol donde cada caso tiene su lugar.

**Ejemplo**: Para "automatizar conciliacion bancaria", identifica 4 tipos de conciliacion, 7 excepciones, y 3 fuentes de datos que nadie habia mencionado.

**Valor**: Evita construir solo para el caso ideal y descubrir los otros 15 casos en produccion.

### 2. Recursion Designer (Disenador de Recursion)

**Cuando aparece**: El sistema detecta taxonomias externas — categorias controladas por alguien fuera de tu sistema (un banco, un regulador, un proveedor).

**Que hace**: Disena 4 mecanismos para que tu sistema maneje cambio externo sin romperse:
1. Deteccion de desconocidos (valor nuevo → no clasificar, escalar)
2. Aprobacion humana (sistema propone, humano decide)
3. Propagacion controlada (aplicar hacia adelante o hacia atras)
4. Versionado inmutable (cada version del diccionario es permanente)

**Ejemplo**: El banco agrega un nuevo concepto en el extracto. Tu sistema lo detecta, lo marca como "desconocido", y lo escala al tesorero para clasificacion.

**Valor**: Tu sistema no se rompe cuando algo externo cambia.

### 3. Compliance Colombia

**Cuando aparece**: Tu proyecto toca datos personales, IA sobre datos personales, transferencias internacionales, o retencion tributaria.

**Que hace**: Valida contra Ley 1581/2012, Circular SIC 002/2024, Art. 632 ET. Incluye patron tombstoning (borrado logico), test de proporcionalidad, y roadmap de certificacion.

**Ejemplo**: Si tu CRM almacena nombres y emails, compliance verifica consentimiento, derecho de supresion, y politica de retencion.

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

Los especialistas se integran en fases especificas:

| Fase SDD | Enriquecimiento CTO |
|----------|---------------------|
| **sdd-explore** | Discovery Completeness (5 preguntas), consulta domain experts, detecta complejidad de proceso |
| **sdd-propose** | Cost-Benefit Analysis obligatorio, seccion Client Communication en lenguaje no-tecnico |
| **sdd-design** | Secciones condicionales (LLM/Data/Infra), Architecture Validation Checklist (7 items) |
| **sdd-verify** | Testing diferenciado por tipo: pure auto, auto+LLM, o agent |
| **sdd-archive** | Learning Loop (6 preguntas para mejorar el ecosistema) |

---

## Que significa para ti

No necesitas saber cuando llamar a cada experto. Solo describe tu problema y el sistema:

1. Detecta las senales (variantes, taxonomias, datos personales, LLM)
2. Sugiere el especialista apropiado
3. Integra su analisis en el flujo SDD

Tu rol: confirmar que las sugerencias tienen sentido y aportar el contexto de negocio que la IA no puede adivinar.

---

-> [Scope Rule](scope-rule.md) — Donde va cada archivo
