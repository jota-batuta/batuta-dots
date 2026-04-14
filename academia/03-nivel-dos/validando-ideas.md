# Validando ideas

`/sdd-explore` no es solo para empezar proyectos. Es una de las herramientas mas poderosas de Batuta Dots para **pensar mejor**. En v15, explore usa subagentes en paralelo para investigar en minutos.

---

## sdd-explore como herramienta de pensamiento

Puedes usar explore sin comprometerte a construir nada:

```
/sdd-explore "Es buena idea migrar de REST a GraphQL?"
```

Batuta contrata agentes que investigan tu codebase actual en paralelo, comparan opciones, y te dan un analisis estructurado — sin escribir una sola linea de codigo.

---

## 5 formas de usar explore

### 1. Validar una idea antes de invertir tiempo

```
/sdd-explore "Deberiamos agregar cache con Redis?"
```

Los agentes analizan tu proyecto, miden donde hay cuellos de botella, y te dicen si Redis resolveria el problema o si es over-engineering.

### 2. Comparar opciones tecnicas

```
/sdd-explore "Temporal vs Celery para nuestros workers"
```

Obtienes una tabla de comparacion con pros, contras, complejidad, y que tan bien encaja con tu stack actual.

### 3. Investigar antes de una reunion

```
/sdd-explore "Que implicaciones tiene agregar multi-tenancy?"
```

Llegas a la reunion con un analisis de impacto: archivos afectados, riesgos, y esfuerzo estimado.

### 4. Entender codigo existente

```
/sdd-explore "Como funciona el sistema de autenticacion actual?"
```

Los agentes leen el codigo, trazan el flujo, y te explican como funciona — util cuando heredas un proyecto.

### 5. Detectar riesgos antes de que sean problemas

```
/sdd-explore "Que riesgos tiene nuestro manejo de datos personales?"
```

Se contratan agentes con security-audit y compliance-colombia para darte un panorama completo.

---

## Research-first: la base de explore en v15

En v15, research-first es **obligatorio en TODO modo**, incluyendo SPRINT. Antes de que cualquier agente implemente, investiga:

1. **Notion KB via MCP**: Ya resolvimos algo similar?
2. **Skill relevante**: Leerlo, verificar que este al dia
3. **WebFetch docs oficiales**: Los frameworks cambian constantemente
4. **WebSearch**: Buscar soluciones actuales

Explore lleva esto al maximo: lanza subagentes en paralelo para cada area de investigacion. 5 subagentes investigando = resultados en minutos.

---

## La estructura de un explore

Siempre obtienes:

1. **Estado actual** — Como funciona hoy
2. **Areas afectadas** — Que archivos/modulos cambiarian
3. **Skill Gap Analysis** — Tienes las herramientas para esto?
4. **Discovery Completeness** — Entendemos bien el problema?
5. **Complejidad del proceso** — Necesitamos especialistas?
6. **Opciones** — Con pros, contras, y esfuerzo
7. **Recomendacion** — La opinion informada de los agentes
8. **Riesgos** — Que podria salir mal

---

## Explore en los 2 modos SDD

| Modo | Comando | Crea artefactos? | Siguiente paso |
|------|---------|-----------------|----------------|
| **SPRINT** | Research integrado en `/sdd-apply` | No formales | Implementar directo |
| **COMPLETO** | `/sdd-explore "tema"` o `/sdd-new nombre` | Si (explore.md, design.md) | Design → USER STOP → Apply |

### Explore standalone vs explore con cambio

- **Standalone**: `/sdd-explore "tema"` — Para pensar. No crea archivos formales. No avanza a disenar.
- **Con cambio**: `/sdd-new nombre-cambio` — Explore + Design. Crea artefactos en `openspec/changes/`. Avanza al gate de diseno.

---

## Tip: Explore como coach de negocio

No limites explore a preguntas tecnicas:

```
/sdd-explore "Cual seria el MVP minimo para validar esta idea con clientes?"
```

```
/sdd-explore "Que deberia cobrar por este servicio de automatizacion?"
```

Batuta no reemplaza tu criterio de negocio, pero te da estructura para pensar mejor.

---

-> [Equipos de agentes](equipos-de-agentes.md) — Cuando escalar la complejidad
