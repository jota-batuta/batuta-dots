# Templates de equipo

Batuta Dots incluye 7 composiciones de equipo pre-configuradas. En vez de armar un equipo desde cero, eliges el template que mejor se adapte a tu proyecto.

---

## Los 7 templates

### 1. nextjs-saas
Para: Aplicaciones SaaS con Next.js
Equipo: frontend-dev, api-dev, db-dev
Skills pre-cargados: scope-rule, security-audit

### 2. fastapi-service
Para: Servicios backend con FastAPI
Equipo: api-dev, db-dev, test-dev
Skills pre-cargados: fastapi-crud, jwt-auth, sqlalchemy-models
Domain agent disponible: **backend-agent** — aporta expertise en patrones API y autenticacion

### 3. n8n-automation
Para: Automatizaciones con n8n
Equipo: workflow-dev, integration-dev
Skills pre-cargados: data-pipeline-design

### 4. ai-agent
Para: Agentes de IA con LangChain/LangGraph
Equipo: agent-dev, pipeline-dev, eval-dev
Skills pre-cargados: llm-pipeline-design, security-audit
Domain agent disponible: **data-agent** — aporta expertise en pipelines de datos y procesamiento IA

### 5. data-pipeline
Para: Pipelines de datos y ETL
Equipo: etl-dev, db-dev, quality-dev
Skills pre-cargados: data-pipeline-design, compliance-colombia

### 6. refactoring
Para: Refactorizar codigo existente
Equipo: analyst, implementor, reviewer
Skills pre-cargados: scope-rule, security-audit

### 7. temporal-io-app
Para: Aplicaciones con Temporal.io
Equipo: workflow-dev, worker-dev, infra-dev
Skills pre-cargados: worker-scaffold

---

## Cada template incluye

| Componente | Descripcion |
|-----------|------------|
| **Composicion** | Que teammates y cuantos |
| **Contratos** | Input/output por teammate |
| **File ownership** | Que archivos toca cada uno |
| **Lessons learned** | Errores comunes y como evitarlos |
| **Pre-spawn checklist** | Verificaciones antes de crear el equipo |

---

## Como usar un template

El team-orchestrator lo sugiere automaticamente cuando detecta que tu proyecto encaja con un template:

```
"Este proyecto es una API FastAPI con base de datos.
Sugiero template: fastapi-service
Composicion: api-dev + db-dev + test-dev
Creo el equipo?"
```

O puedes pedirlo directamente:
```
Quiero usar el template nextjs-saas para este proyecto
```

---

## Personalizando templates

Los templates son un punto de partida. Puedes:
- Agregar teammates (ej: agregar security-reviewer al template fastapi)
- Remover teammates que no necesitas
- Cambiar file ownership segun tu estructura
- Agregar skills adicionales

Los templates viven en `teams/templates/` dentro del repositorio batuta-dots.

> **Nota**: El **quality-agent** esta disponible para cualquier template — no es exclusivo de uno. Todo equipo puede beneficiarse de un especialista en testing y validacion.

---

-> [Integrando con infra](integrando-con-infra.md) — Workers, Docker, y deploy
