# Anatomia de un comando

Normalmente no necesitas escribir comandos — Batuta detecta lo que necesitas y actua automaticamente (ver [auto-routing](el-pipeline-sdd.md#auto-routing-conversacion-natural)). Pero entender como funcionan internamente te da control total cuando quieras usarlos como override manual.

---

## Dos formas de activar una fase

### Forma 1: Conversacion natural (auto-routing)

```
Tu escribes: "Necesito investigar la conciliacion bancaria"
         |
         v
[0] CLAUDE.md clasifica tu intent (Auto-Routing)
    → Intent: "Build / Feature / Problem"
    → Estado: openspec existe, no hay change activo
    → Accion: ejecutar sdd-explore automaticamente
```

### Forma 2: Comando explicito (override manual)

```
Tu escribes: /sdd-explore conciliacion-bancaria
         |
         v
[0] CLAUDE.md reconoce el slash command
    → Override manual: ejecutar sdd-explore directamente
```

Ambas formas activan la misma cadena interna:

## Que pasa internamente

```
Main agent decide ejecutar sdd-explore
         |
         v
[1] CLAUDE.md (105 lineas) identifica que necesita
    → Determina: necesito investigar → contratar agente pipeline
         |
         v
[2] Main agent CONTRATA pipeline-agent (via agent-hiring)
    → pipeline-agent lee session.md (estado actual del proyecto)
    → pipeline-agent carga el skill sdd-explore
         |
         v
[3] sdd-explore ejecuta su SKILL.md
    → Paso 1: Entiende la solicitud
    → Paso 2: Investiga (Notion KB → skills → WebFetch → WebSearch)
    → Paso 3: Analiza opciones
    → Paso 4: Guarda exploracion
    → Paso 5: Retorna analisis estructurado
         |
         v
[4] pipeline-agent reporta al main agent
    → FINDINGS / FAILURES / DECISIONS / GOTCHAS
    → Muestra resumen al usuario
         |
         v
[5] session.md se actualiza (en CADA interaccion)
```

---

## Los actores involucrados

| Actor | Rol | Archivo |
|-------|-----|---------|
| **CLAUDE.md** | Gestor (nunca ejecuta, solo contrata) | `CLAUDE.md` (105 lineas) |
| **pipeline-agent** | Agente contratado para flujo SDD | `.claude/agents/pipeline-agent.md` |
| **sdd-explore** | Skill del agente pipeline | `.claude/skills/sdd-explore/SKILL.md` |
| **session.md** | Fuente de verdad del estado | `.claude/session.md` |
| **CHECKPOINT.md** | Seguro anti-compaction | `.claude/CHECKPOINT.md` |

---

## La cadena de delegacion

Batuta funciona con un patron de **delegacion por contrato**:

1. **Tu** le das una instruccion al sistema
2. **Main agent** (CLAUDE.md — gestor puro) decide que agente contratar
3. **El agente contratado** ejecuta con sus skills especializados
4. **El agente reporta** con FINDINGS / FAILURES / DECISIONS / GOTCHAS
5. **session.md** se actualiza con el resultado

Es como una empresa: tu hablas con el gerente general (main agent), el gerente NUNCA ejecuta directamente — contrata al especialista adecuado (agente), y el especialista trae su propio equipo (skills). El main agent no tiene skills cargados — solo sabe a quien contratar.

---

## Diferencia entre comandos

No todos los comandos funcionan igual:

### Comandos simples (1 fase)
```
/sdd-init     → Ejecuta sdd-init directamente
/sdd-apply    → Ejecuta sdd-apply directamente
/sdd-verify   → Ejecuta sdd-verify directamente
```

### Comandos compuestos (multiples fases)
```
/sdd-new      → explore + design (2 fases)
/sdd-continue → Lee session.md y avanza desde donde quedaste
```

### Comandos de ecosistema (no SDD)
```
/create <type> <name> → infra-agent → ecosystem-creator
/batuta-sync          → Sync skills: subir al hub, traer del hub, o ambos
/batuta-init          → Setup Batuta en un proyecto nuevo
```

---

## El Execution Gate en detalle

El Execution Gate es una validacion que se ejecuta automaticamente antes de que Batuta escriba o modifique cualquier archivo.

### Como funciona

```
Batuta quiere escribir un archivo
         |
         v
Execution Gate se activa
         |
         v
Pregunta: "Este cambio fue validado?"
    |                    |
   SI                   NO
    |                    |
    v                    v
Permite escribir    Bloquea y pide
                    que ejecutes el gate
```

### Dos modos

| Modo | Cuando | Que muestra |
|------|--------|-------------|
| **LIGHT** | 1 archivo, tarea clara | "Modifico {archivo}. Procedo?" |
| **FULL** | Multiples archivos, decision arquitectural | Location plan + impacto + scope + compliance |

### Que valida el modo FULL

1. **Scope**: Que area del sistema afecta?
2. **Location Plan**: Donde iran los archivos? (Scope Rule)
3. **Impact**: Que archivos cambian? Hay breaking changes?
4. **SDD Check**: Hay una especificacion activa?
5. **Skill Check**: Tenemos skills para las tecnologias involucradas?
6. **Pyramid Check**: Estan configuradas las herramientas de validacion?
7. **Team Assessment**: Es tan complejo que necesitamos un equipo?

---

## Que significa esto para ti

- **No necesitas memorizar comandos** — describe lo que necesitas y Batuta actua
- **Los comandos existen como override** — si quieres controlar un paso especifico, puedes usar el slash command directamente
- **La cadena interna es la misma** — ya sea que hables naturalmente o uses un comando, el proceso es identico
- **Si necesitas entender** por que Batuta te pregunta ciertas cosas (los gates, el Execution Gate), esta pagina lo explica

---

→ [El pipeline SDD](el-pipeline-sdd.md) — Los 2 modos (SPRINT y COMPLETO) explicados con analogia
