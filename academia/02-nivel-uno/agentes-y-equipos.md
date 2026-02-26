# Agentes y equipos

Los skills son los especialistas. Los agentes son los **coordinadores** que deciden que especialista trabaja en que tarea.

---

## Los 3 agentes

### Pipeline Agent — El director de obra

Coordina el flujo SDD completo (explorar a archivar). Maneja: sdd-init, sdd-explore, sdd-propose, sdd-spec, sdd-design, sdd-tasks, sdd-apply, sdd-verify, sdd-archive. Nunca ejecuta logica directamente — siempre delega a los skills.

### Infra Agent — El arquitecto de la casa

Coordina organizacion de archivos, creacion de herramientas, seguridad. Maneja: ecosystem-creator, scope-rule, team-orchestrator, security-audit. Cada archivo que se crea pasa por el Scope Rule.

### Observability Agent — El inspector de calidad

Coordina registro de eventos, calidad, y continuidad de sesion. Es el motor O.R.T.A.:
- **O**bservabilidad: Registra cada accion importante
- **R**epetibilidad: Mismo input = mismo resultado
- **T**razabilidad: Cada decision se puede rastrear
- **A**uto-supervision: Detecta problemas antes de que escalen

---

## 3 niveles de ejecucion

No todo requiere un equipo. Batuta tiene 3 niveles:

| Nivel | Cuando | Costo | Ejemplo |
|-------|--------|-------|---------|
| 1 — Solo | 1 archivo, bug, pregunta | Normal | "Arregla typo en README" |
| 2 — Subagente | Investigar, verificar, 1 fase SDD | 1.2-1.5x | `/sdd-explore` lanza sub-agente |
| 3 — Agent Team | 4+ archivos, multi-scope, comunicacion | 3-5x | Feature frontend + backend + BD |

### Como decide Batuta

```
Archivos a cambiar?
  1       -> Nivel 1 (solo)
  2-3     -> Nivel 2 (subagente)
  4+      -> Necesitan comunicarse?
             No -> Nivel 2 (subagentes en paralelo)
             Si -> Nivel 3 (equipo)
```

---

## Agent Teams en accion

Si Batuta determina Nivel 3, te pregunta antes de crear:

```
"Cambio complejo (8 archivos, 2 scopes). Recomiendo Agent Team:
- researcher: explore + propose
- architect: spec + design
- implementor-1: apply (batch 1)
- implementor-2: apply (batch 2)
- reviewer: verify
Creo el equipo?"
```

### Contract-First Protocol

Antes de que cada teammate empiece, se define:
- **Que recibe**: datos e instrucciones
- **Que produce**: archivos y resultados especificos
- **Que archivos toca**: ownership exclusivo (cada archivo pertenece a 1 solo teammate)

### Cuando NO usar equipos

- Ediciones simples (1 archivo)
- Tareas secuenciales (una depende de la otra)
- Menos de 3 archivos
- Commits, formateo, documentacion rutinaria

---

-> [La capa CTO](la-capa-cto.md) — Los expertos estrategicos
