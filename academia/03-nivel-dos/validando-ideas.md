# Validando ideas

`/sdd-explore` no es solo para empezar proyectos. Es una de las herramientas mas poderosas de Batuta Dots para **pensar mejor**.

---

## sdd-explore como herramienta de pensamiento

Puedes usar explore sin comprometerte a construir nada:

```
/sdd-explore "Es buena idea migrar de REST a GraphQL?"
```

Batuta investiga tu codebase actual, compara opciones, y te da un analisis estructurado — sin escribir una sola linea de codigo.

---

## 5 formas de usar explore

### 1. Validar una idea antes de invertir tiempo

```
/sdd-explore "Deberiamos agregar cache con Redis?"
```

Batuta analiza tu proyecto, mide donde hay cuellos de botella, y te dice si Redis resolveria el problema o si es over-engineering.

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

Batuta lee el codigo, traza el flujo, y te explica como funciona — util cuando heredas un proyecto.

### 5. Detectar riesgos antes de que sean problemas

```
/sdd-explore "Que riesgos tiene nuestro manejo de datos personales?"
```

Batuta activa security-audit y compliance-colombia para darte un panorama completo.

---

## La estructura de un explore

Siempre obtienes:

1. **Estado actual** — Como funciona hoy
2. **Areas afectadas** — Que archivos/modulos cambiarian
3. **Skill Gap Analysis** — Tienes las herramientas para esto?
4. **Discovery Completeness** — Entendemos bien el problema?
5. **Complejidad del proceso** — Necesitamos especialistas?
6. **Impacto en stakeholders** — A quien afecta?
7. **Opciones** — Con pros, contras, y esfuerzo
8. **Recomendacion** — La opinion informada de Batuta
9. **Riesgos** — Que podria salir mal
10. **Resumen simple** — Para quien no es tecnico

---

## Explore standalone vs explore con cambio

| Modo | Comando | Crea archivos? | Avanza a propose? |
|------|---------|---------------|-------------------|
| Standalone | `/sdd-explore "tema"` | No | No |
| Con cambio | `/sdd-new nombre-cambio` | Si (`explore.md`) | Si (automaticamente) |

Usa standalone para pensar. Usa con cambio cuando ya decidiste construir.

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
