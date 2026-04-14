# Playbook de Agent Teams

> Guia practica para decidir cuando y como usar Agent Teams en proyectos construidos con Batuta.
> Referencia tecnica: `team-orchestrator` SKILL.md contiene las reglas formales. Este playbook las traduce a decisiones rapidas.

---

## Proposito

Agent Teams es el nivel mas alto de ejecucion en Batuta. Permite dividir tareas complejas entre multiples agentes contratados que trabajan en paralelo, cada uno especializado en un dominio. Este playbook responde tres preguntas:

1. **Necesito un equipo?** (o basta con trabajar solo o con un agente contratado)
2. **Como lo armo?** (que patron, que roles, que contratos)
3. **Como evito errores comunes?** (lecciones aprendidas de uso real)

---

## Cuando Usar Teams vs Solo vs Subagent

### Arbol de decision rapido

```
Tu tarea modifica...

  1 archivo?
    → Solo (Level 1). No necesitas equipo.

  2-3 archivos, mismo scope?
    → Contrata un agente especializado (Level 2).
      El main agent NUNCA implementa — contrata un agente de
      `.claude/agents/` o `~/.claude/agents/` para que ejecute.

  4+ archivos O multiples scopes?
    → Pregunta: los agentes necesitan comunicarse?
        NO (tareas independientes) → Agentes contratados en paralelo (Level 2)
        SI (decisiones compartidas, APIs cruzadas) → Agent Team (Level 3)
```

### Tabla por tipo de tarea

| Tarea | Nivel | Razon |
|-------|-------|-------|
| Corregir un bug en 1 archivo | Solo (L1) | Cambio aislado, sin coordinacion |
| Escribir documentacion | Solo (L1) | No hay dependencias cruzadas |
| Investigar un tema antes de disenar | Agente contratado (L2) | Tarea de lectura, no modifica archivos |
| Agregar un endpoint nuevo con test | Agente contratado (L2) | 2-3 archivos, mismo scope backend |
| Crear una CLI tool con tests | Agente contratado (L2) | Scope unico, archivos relacionados |
| Feature completa: API + UI + deploy | Team (L3) | Multi-scope, workers se coordinan |
| Refactoring de modulo legacy | Team (L3) | Multiples archivos, riesgo de conflictos |
| Debug complejo con hipotesis | Team (L3) | Investigacion paralela, comparar hallazgos |
| Pipeline de datos con ETL + API | Team (L3) | Capas cruzadas, contratos entre capas |

---

## Los 5 Errores Mas Comunes

### 1. Crear equipo para tareas simples
- **Sintoma**: Team de 3 agentes para editar 1 archivo.
- **Costo**: 3-5x tokens consumidos sin beneficio real.
- **Solucion**: Pasa por Q1 del Decision Tree. Si la respuesta es "1 archivo", usa Solo.

### 2. File ownership overlap (dos editan lo mismo)
- **Sintoma**: 2 teammates intentan modificar el mismo archivo.
- **Costo**: Conflictos silenciosos, trabajo perdido.
- **Solucion**: Contract-First Protocol. Cada archivo tiene exactamente 1 dueno.

### 3. Saltarse la definicion de contratos
- **Sintoma**: Frontend llama un endpoint que backend definio con otro nombre.
- **Costo**: Retrabajo costoso.
- **Solucion**: Antes de spawn, define Input/Output Contracts. El Lead escribe el API schema ANTES de que los teammates empiecen.

### 4. No hacer cross-review
- **Sintoma**: Backend retorna `{ data: [...] }`, frontend espera `{ users: [...] }`.
- **Costo**: Bugs de interfaz descubiertos tarde.
- **Solucion**: Cross-Review Protocol obligatorio antes de marcar como completado.

### 5. Equipos demasiado grandes (mas de 5 teammates)
- **Sintoma**: El Lead pasa mas tiempo coordinando que produciendo.
- **Solucion**: Maximo 4-5 teammates por equipo. Si necesitas mas, divide en sub-equipos.

---

## Mejores Practicas por Tipo de Proyecto

| Tipo de Proyecto | Nivel | Template | Patron | Agentes Recomendados |
|------------------|-------|----------|--------|----------------------|
| SaaS web app | Team (L3) | `nextjs-saas` | Cross-Layer (D) | quality-agent |
| Microservicio API | Team o L2 | `fastapi-service` | Cross-Layer (D) | backend-agent, quality-agent |
| Automatizacion n8n | L2 | `n8n-automation` | Pipeline (A) | quality-agent |
| AI Agent / Bot | Team (L3) | `ai-agent` | Investigation (C) | data-agent, quality-agent |
| Data pipeline | Team (L3) | `data-pipeline` | Cross-Layer (D) | data-agent, quality-agent |
| Temporal.io app | Team (L3) | `temporal-io-app` | Cross-Layer (D) | backend-agent, quality-agent |
| Refactoring legacy | Team (L3) | `refactoring` | Pipeline (A) | quality-agent |
| Bug fix aislado | Solo (L1) | N/A | N/A | N/A |
| Documentacion | Solo (L1) | N/A | N/A | N/A |
| CLI tool | L2 | N/A | Pipeline (A) | quality-agent |

> Los templates viven en `teams/templates/{nombre}.md`.
>
> **v15**: 5 agentes contratables (pipeline, infra, backend, data, quality). El main agent NUNCA ejecuta — solo contrata agentes de `.claude/agents/`.

---

## Referencia Rapida de Patrones

### Patron A: Pipeline Team

Para implementaciones que siguen el flujo SPRINT o COMPLETO.

```
researcher    → explore (subagentes en paralelo)
implementor-1 → apply (batch 1)    ─┐ PARALELO
implementor-2 → apply (batch 2)    ─┘
reviewer      → verify

Lead coordina: PRD, contratos, division de batches
```

### Patron B: Parallel Review Team

Para revision de calidad con multiples perspectivas simultaneas.

```
static-reviewer   → lint, types, formato, codigo muerto
test-reviewer     → tests unitarios, edge cases, E2E
security-reviewer → OWASP, auth, validacion, secrets
perf-reviewer     → N+1 queries, bundle size, memory leaks

Lead sintetiza: hallazgos, prioriza, asigna correcciones
```

### Patron C: Investigation Team

Para debugging complejo con multiples hipotesis.

```
hypothesis-1 → investiga causa posible A (ej: red/network)
hypothesis-2 → investiga causa posible B (ej: estado/state)
hypothesis-3 → investiga causa posible C (ej: config/entorno)

Lead compara: evidencia, identifica causa raiz, propone fix
```

### Patron D: Cross-Layer Team

Para cambios que cruzan capas arquitectonicas.

```
backend-dev  → rutas API, logica de negocio, modelos, migraciones
frontend-dev → componentes, paginas, estado del cliente
infra-dev    → Docker, CI/CD, variables de entorno, despliegue

Lead coordina: API contracts, puntos de integracion, cross-review
```

**Con agentes contratados (v15)**: Cada teammate hereda expertise del agente que se le asigna. `backend-dev` usa `backend-agent` para expertise en FastAPI, auth, DB. El teammate de datos usa `data-agent` para pipelines LLM, RAG, embeddings.

---

## Metricas de Exito

| Metrica | Como se mide | Objetivo |
|---------|-------------|----------|
| Ratio team vs solo | Sesiones con team / total sesiones | 10-20% |
| Utilizacion de teammates | Tiempo activo / tiempo total por teammate | > 70% |
| Tasa de completitud | Tareas completadas / tareas asignadas | > 90% |
| Descubrimiento de skills | Skills nuevos creados por sesion de team | Rastrear |
| Eficiencia de tokens | Calidad resultado / tokens usados vs baseline solo | > 1.5x calidad por 3-5x tokens |

---

## Evolucion del Playbook

1. **Despues de cada proyecto con teams**: actualiza "Lecciones Aprendidas" en el template que usaste.
2. **Si descubres un patron nuevo**: crea un template nuevo y documentalo aqui.
3. **El Lead documenta resultados**: al cerrar un equipo, actualiza `.batuta/session.md` con la composicion usada.
4. **Revision periodica**: cada 5 proyectos con teams, revisa este playbook.

---

*Playbook v2.0 — Basado en team-orchestrator, delegation por contrato v15, y 5 agentes contratables.*
