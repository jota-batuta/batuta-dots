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
Batuta decide ejecutar sdd-explore
         |
         v
[1] CLAUDE.md identifica el scope
    → Determina: scope = pipeline
         |
         v
[2] pipeline-agent se activa
    → Lee el contexto del proyecto (openspec/config.yaml)
    → Prepara el sub-agente sdd-explore
         |
         v
[3] sdd-explore ejecuta su SKILL.md
    → Paso 1: Entiende la solicitud
    → Paso 2: Investiga el codebase (lee archivos, busca patrones)
    → Paso 2.5: Detecta gaps de skills
    → Paso 2.7: Consulta domain experts (si existen)
    → Paso 3: Analiza opciones
    → Paso 4: Guarda exploracion (si hay change name)
    → Paso 4.5: Discovery Completeness (5 preguntas)
    → Paso 4.6: Detecta complejidad del proceso
    → Paso 5: Retorna analisis estructurado
         |
         v
[4] pipeline-agent recibe resultado
    → Muestra resumen al usuario
    → Prepara Gate G0.5 si aplica
         |
         v
[5] O.R.T.A. registra el evento
    → Tipo "prompt", scope "pipeline"
```

---

## Los actores involucrados

| Actor | Rol | Archivo |
|-------|-----|---------|
| **CLAUDE.md** | Router principal | `~/.claude/CLAUDE.md` |
| **pipeline-agent** | Coordinador del flujo SDD | `~/.claude/agents/pipeline-agent.md` |
| **sdd-explore** | Especialista en investigacion | `~/.claude/skills/sdd-explore/SKILL.md` |
| **Execution Gate** | Validador de cambios | Hook en `settings.json` |

---

## La cadena de delegacion

Batuta funciona con un patron de **delegacion en cascada**:

1. **Tu** le das una instruccion al sistema
2. **CLAUDE.md** (el router) decide que agente maneja esto
3. **El agente** decide que skill ejecutar
4. **El skill** ejecuta su logica especializada
5. **El resultado** vuelve por la cadena hasta ti

Es como una empresa: tu hablas con el CEO (CLAUDE.md), el CEO le pasa al director de area (agente), y el director le pasa al especialista (skill).

---

## Diferencia entre comandos

No todos los comandos funcionan igual:

### Comandos simples (1 fase)
```
/sdd-init     → Ejecuta sdd-init directamente
/sdd-verify   → Ejecuta sdd-verify directamente
/sdd-archive  → Ejecuta sdd-archive directamente
```

### Comandos compuestos (multiples fases)
```
/sdd-new      → explore + propose (2 fases)
/sdd-ff       → propose + spec + design + tasks (4 fases)
/sdd-continue → Detecta donde quedaste y ejecuta la siguiente fase
```

### Comandos de ecosistema (no SDD)
```
/create-skill     → infra-agent → ecosystem-creator
/create-sub-agent → infra-agent → ecosystem-creator
/batuta-sync      → infra-agent → ecosystem-lifecycle (sync skills al hub)
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

→ [El pipeline SDD](el-pipeline-sdd.md) — Las 9 fases explicadas con analogia
