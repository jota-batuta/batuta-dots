# Playbook de Agent Teams

> Guia practica para decidir cuando y como usar Agent Teams en proyectos construidos con Batuta.
> Referencia tecnica: `team-orchestrator` SKILL.md contiene las reglas formales. Este playbook las traduce a decisiones rapidas.

---

## Proposito

Agent Teams es el nivel mas alto de ejecucion en Batuta. Permite dividir tareas complejas entre multiples agentes que trabajan en paralelo, cada uno especializado en un dominio. Este playbook responde tres preguntas:

1. **Necesito un equipo?** (o basta con trabajar solo o con un subagente)
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
    → Subagent (Level 2). Un agente auxiliar resuelve.

  4+ archivos O multiples scopes?
    → Pregunta: los workers necesitan comunicarse?
        NO (tareas independientes) → Subagents en paralelo (Level 2)
        SI (decisiones compartidas, APIs cruzadas) → Agent Team (Level 3)
```

### Tabla por tipo de tarea

| Tarea | Nivel | Razon |
|-------|-------|-------|
| Corregir un bug en 1 archivo | Solo (L1) | Cambio aislado, sin coordinacion |
| Escribir documentacion | Solo (L1) | No hay dependencias cruzadas |
| Investigar un tema antes de proponer | Subagent (L2) | Tarea de lectura, no modifica archivos |
| Agregar un endpoint nuevo con test | Subagent (L2) | 2-3 archivos, mismo scope backend |
| Crear una CLI tool con tests | Subagent (L2) | Scope unico, archivos relacionados |
| Feature completa: API + UI + deploy | Team (L3) | Multi-scope, workers se coordinan |
| Refactoring de modulo legacy | Team (L3) | Multiples archivos, riesgo de conflictos |
| Debug complejo con hipotesis | Team (L3) | Investigacion paralela, comparar hallazgos |
| Pipeline de datos con ETL + API | Team (L3) | Capas cruzadas, contratos entre capas |

---

## Los 5 Errores Mas Comunes

### 1. Crear equipo para tareas simples

- **Sintoma**: Team de 3 agentes para editar 1 archivo.
- **Costo**: 3-5x tokens consumidos sin beneficio real. Mas overhead que valor.
- **Solucion**: Siempre pasa por Q1 del Decision Tree primero. Si la respuesta es "1 archivo", usa Solo. Sin excepciones.

### 2. File ownership overlap (dos editan lo mismo)

- **Sintoma**: 2 teammates intentan modificar el mismo archivo. Uno sobreescribe al otro.
- **Costo**: Conflictos silenciosos, trabajo perdido, bugs dificiles de rastrear.
- **Solucion**: Usa el Contract-First Protocol. Cada archivo tiene exactamente 1 dueno. Si dos teammates necesitan el mismo archivo, el Lead redisena la division de tareas.

### 3. Saltarse la definicion de contratos

- **Sintoma**: Frontend llama un endpoint que backend definio con otro nombre o formato.
- **Costo**: Retrabajo costoso, debugging que se pudo evitar. A veces hay que rehacer el trabajo de un teammate completo.
- **Solucion**: Antes de hacer spawn de cualquier teammate, define Input/Output Contracts. El Lead escribe el API schema y los tipos compartidos ANTES de que los teammates empiecen.

### 4. No hacer cross-review

- **Sintoma**: Backend produce un endpoint `/api/users` que retorna `{ data: [...] }`, pero frontend espera `{ users: [...] }`. Se descubre en testing.
- **Costo**: Bugs en interfaces descubiertos tarde, cuando ya hay codigo construido sobre suposiciones incorrectas.
- **Solucion**: Cross-Review Protocol obligatorio. Frontend revisa la API de backend. Backend revisa como frontend consume la API. Antes de marcar el equipo como "completado".

### 5. Equipos demasiado grandes (mas de 5 teammates)

- **Sintoma**: El Lead pasa mas tiempo coordinando que produciendo. Los teammates esperan decisiones.
- **Costo**: Overhead de coordinacion supera el beneficio del paralelismo.
- **Solucion**: Maximo 4-5 teammates por equipo. Si necesitas mas, divide en sub-equipos con un Lead intermedio. Recuerda: en Windows solo funciona modo in-process.

---

## Mejores Practicas por Tipo de Proyecto

| Tipo de Proyecto | Nivel Recomendado | Template | Patron |
|------------------|-------------------|----------|--------|
| SaaS web app | Team (Level 3) | `nextjs-saas` | Cross-Layer (D) |
| Microservicio API | Team o Subagent | `fastapi-service` | Cross-Layer (D) |
| Automatizacion n8n | Subagent (Level 2) | `n8n-automation` | SDD Pipeline (A) |
| AI Agent / Bot | Team (Level 3) | `ai-agent` | Investigation (C) |
| Data pipeline | Team (Level 3) | `data-pipeline` | Cross-Layer (D) |
| Refactoring legacy | Team (Level 3) | `refactoring` | SDD Pipeline (A) |
| Bug fix aislado | Solo (Level 1) | N/A | N/A |
| Documentacion | Solo (Level 1) | N/A | N/A |
| CLI tool | Subagent (Level 2) | N/A | SDD Pipeline (A) |

> Los templates viven en `teams/templates/{nombre}.md`. Si no existe el que necesitas, crea uno nuevo (ver seccion "Como Crear tu Propio Template").

---

## Como Elegir Template

```
Que tipo de proyecto es?

  Es una app web con frontend + backend?
    → nextjs-saas

  Es un API o microservicio sin frontend?
    → fastapi-service

  Es automatizacion o workflows (n8n, cron, etc.)?
    → n8n-automation

  Es un agente AI (LangChain, Claude SDK, LangGraph)?
    → ai-agent

  Es procesamiento de datos (ETL, pipelines, analytics)?
    → data-pipeline

  Es modernizar o reestructurar codigo existente?
    → refactoring

  Ninguno aplica?
    → Crea un template custom con /create-skill
      (ver seccion siguiente)
```

---

## Como Crear tu Propio Template

Cuando ningun template existente aplica, crea uno siguiendo estos pasos:

### Paso 1: Identifica el patron base

| Patron | Letra | Usa cuando... |
|--------|-------|---------------|
| SDD Pipeline | A | El trabajo sigue fases secuenciales (explore, propose, spec, design, apply, verify) |
| Parallel Review | B | Necesitas multiples revisores independientes (calidad, seguridad, performance) |
| Investigation | C | Necesitas explorar hipotesis en paralelo (debugging, research) |
| Cross-Layer | D | El cambio cruza capas arquitectonicas (frontend, backend, infra) |

### Paso 2: Define teammates con sus scope agents

Lista cada teammate con: nombre, scope agent asignado (`pipeline-agent`, `infra-agent`, `observability-agent`), responsabilidad principal, y archivos propios.

### Paso 3: Escribe contratos input/output

Para cada teammate: que recibe, de quien, que produce, y como se verifica que esta completo. Ver Contract-First Protocol en `team-orchestrator` SKILL.md.

### Paso 4: Define el file ownership map

Cada archivo del proyecto debe tener exactamente un dueno. El Lead posee los archivos de integracion (`package.json`, configs, README). Ningun archivo puede aparecer en dos listas.

### Paso 5: Agrega la seccion de lecciones aprendidas

Inicialmente vacia. Se llena despues de cada uso real del template. Esta seccion es el valor acumulativo del template.

### Paso 6: Guarda el template

Ubicacion: `teams/templates/{nombre}.md`
Formato: sigue la estructura de `nextjs-saas.md` como referencia.

### Paso 7: Referencia en este playbook

Agrega una fila en la tabla "Mejores Practicas por Tipo de Proyecto" para que el equipo lo encuentre facilmente.

---

## Referencia Rapida de Patrones

### Patron A: SDD Pipeline Team

Para implementaciones completas que siguen las fases SDD.

```
researcher    → explore, propose
architect     → spec, design
implementor-1 → apply (batch 1)    ─┐ PARALELO
implementor-2 → apply (batch 2)    ─┘
reviewer      → verify

Lead coordina: init, tasks (divide batches), archive
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

Regla de la Piramide: si la base esta rota (lint/types fallan), no se pasa a revision humana.

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

---

## Metricas de Exito

Despues de usar Agent Teams, evalua con estas metricas (referencia: team-orchestrator Metrics to Track):

| Metrica | Como se mide | Objetivo |
|---------|-------------|----------|
| Ratio team vs solo | Sesiones con team / total sesiones | 10-20% |
| Utilizacion de teammates | Tiempo activo / tiempo total por teammate | > 70% |
| Tasa de completitud | Tareas completadas / tareas asignadas | > 90% |
| Tasa de rechazo del gate | Rechazos TaskCompleted / completitudes | < 15% |
| Descubrimiento de skills | Skills nuevos creados por sesion de team | Rastrear, sin objetivo fijo |
| Eficiencia de tokens | Calidad resultado / tokens usados vs baseline solo | > 1.5x calidad por 3-5x tokens |

**Interpretacion practica**:
- Si el ratio team vs solo supera el 30%, probablemente estas sobre-usando equipos para tareas simples.
- Si la tasa de rechazo del gate supera el 15%, los contratos no estan bien definidos antes del spawn.
- Si la utilizacion de teammates es menor al 70%, hay teammates esperando sin hacer nada. Redisena la division de tareas.

---

## Evolucion del Playbook

Este playbook no es estatico. Crece con cada proyecto que usa Agent Teams:

1. **Despues de cada proyecto con teams**: actualiza la seccion "Lecciones Aprendidas" en el template que usaste. Un aprendizaje por proyecto es suficiente.

2. **Si descubres un patron nuevo**: si ningun patron (A-D) describe bien lo que hiciste, crea un template nuevo. Documentalo aqui.

3. **Ejecuta /batuta:analyze-prompts**: busca patrones en los eventos de tipo `team` en `prompt-log.jsonl`. Esto revela tendencias: equipos que tardan mucho, teammates infrautilizados, contratos que se rechazan repetidamente.

4. **El Lead documenta resultados**: al cerrar un equipo, el Lead actualiza `.batuta/session.md` con la composicion usada, que funciono y que se cambiaria la proxima vez.

5. **Revision periodica**: cada 5 proyectos con teams, revisa este playbook. Elimina lo que no se usa, refuerza lo que funciona.

---

## Que Significa Esto (Simply)

Agent Teams es como armar un equipo de especialistas para un proyecto grande. En vez de que una sola persona haga todo (frontend, backend, deploy), cada especialista trabaja en lo suyo al mismo tiempo. El Lead es el director que se asegura de que todos hablen el mismo idioma (contratos), no se pisen (file ownership), y revisen el trabajo del otro (cross-review).

La regla de oro: **si puedes hacerlo solo en menos de 5 minutos, no armes un equipo**. Los equipos brillan cuando hay complejidad real que justifica la coordinacion.

---

*Playbook v1.0 — Basado en team-orchestrator v2.0 y lecciones del template nextjs-saas.*
