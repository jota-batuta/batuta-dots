# Guia: Batuta en Antigravity Lite

> Guia para trabajar con Batuta en Google Antigravity IDE. Companion de brainstorming y prototipado rapido.

---

## Que es Antigravity Lite

Antigravity Lite es el companion de exploracion rapida del ecosistema Batuta. Mientras Claude Code es para produccion seria (pipeline SDD completo, arquitectura, features complejas), Antigravity Lite es para **brainstorming, prototipado rapido, scripts, documentacion y tareas mecanicas**. Conserva el 100% del cerebro CTO (filosofia, gates estrategicos, 23 skills, reglas de comportamiento). Lo que cambia es el **rol**: exploracion y velocidad en lugar de precision y rigurosidad.

**Antigravity** es el IDE agent-first de Google, un fork de VS Code/Windsurf. Durante el preview es **gratuito** con Gemini 3 Pro. Soporta Rules (GEMINI.md), Workflows (prompts guardados con /trigger), Skills (.agent/skills/), y Manager View para multi-agente.

---

## Cuando usar cada plataforma

| Aspecto | Claude Code (Full) | Antigravity Lite |
|---------|-------------------|-------------------|
| **Arquitectura y SDD completo** | Si | Solo fases individuales |
| **Features complejas multi-modulo** | Si | No |
| **Brainstorming y prototipado** | Posible | Ideal (gratis, rapido) |
| **Scripts y automatizaciones** | Posible pero costoso | Ideal (gratis) |
| **n8n workflows** | Posible | Ideal |
| **Quick fixes y config** | Posible | Ideal |
| **Documentacion** | Posible | Ideal |
| **Agent Teams (paralelo)** | Si (nativo) | Manager View (nativo diferente) |
| **Hooks automaticos** | Si (nativos: SessionStart, Stop) | No — solo reglas de comportamiento |
| **Costo** | $200/mes (Max x20) | Gratis (preview) |

**Estrategia**: Claude Code para produccion seria que requiere potencia y precision. Antigravity Lite para exploracion rapida, brainstorming, y tareas mecanicas de alto volumen. Ambos en paralelo.

---

## Setup

### Opcion 1: Solo en un proyecto (workspace)

```bash
cd /path/to/your/project
bash /path/to/batuta-dots/BatutaAntigravity/setup-antigravity.sh --workspace
```

Esto copia los 23 skills compatibles a `.agent/skills/` dentro del proyecto.

### Opcion 2: Global (todos los proyectos)

```bash
bash /path/to/batuta-dots/BatutaAntigravity/setup-antigravity.sh --global
```

Copia skills a `~/.gemini/antigravity/skills/` para que esten disponibles en cualquier proyecto.

### Opcion 3: Completo (ambos + GEMINI.md + .batuta/)

```bash
cd /path/to/your/project
bash /path/to/batuta-dots/BatutaAntigravity/setup-antigravity.sh --all
```

Instala skills en ambas ubicaciones, copia GEMINI.md al proyecto y a `~/.gemini/GEMINI.md` (global), y crea `.batuta/` con session.md y ecosystem.json.

### Opcion 4: Actualizar un proyecto existente

```bash
cd /path/to/your/project
bash /path/to/batuta-dots/BatutaAntigravity/setup-antigravity.sh --update "$(pwd)"
```

Re-sincroniza skills y GEMINI.md (global + proyecto) sin tocar `.batuta/session.md` ni `openspec/`. Es lo que ejecuta `/batuta-update` internamente.

---

## Workflows disponibles

Los workflows son prompts guardados que se ejecutan con `/trigger` en Antigravity:

### Pipeline SDD

| Workflow | Trigger | Descripcion |
|----------|---------|-------------|
| `sdd-init.md` | `/sdd-init` | Inicializar contexto del proyecto |
| `sdd-explore.md` | `/sdd-explore` | Discovery y restricciones |
| `sdd-new.md` | `/sdd-new` | Propuesta de cambio |
| `sdd-continue.md` | `/sdd-continue` | Siguiente fase pendiente |
| `sdd-ff.md` | `/sdd-ff` | Fast-forward (propose → spec → design → tasks) |
| `sdd-apply.md` | `/sdd-apply` | Implementacion |
| `sdd-verify.md` | `/sdd-verify` | Validacion |
| `sdd-archive.md` | `/sdd-archive` | Cierre y aprendizaje |

### Gestion

| Workflow | Trigger | Descripcion |
|----------|---------|-------------|
| `save-session.md` | `/save-session` | Guardar estado en .batuta/session.md (reemplaza hook Stop) |
| `push-skill.md` | `/push-skill` | Propagar skill local al hub batuta-dots |
| `batuta-update.md` | `/batuta-update` | Actualizar skills desde el hub |

---

## Como crear y propagar skills

### Crear un skill en Antigravity

1. Crea el directorio: `.agent/skills/mi-nuevo-skill/`
2. Crea `SKILL.md` con frontmatter YAML (name, description, platforms, allowed-tools, metadata)
3. Usa el skill normalmente — Antigravity lo carga por su campo `description`

### Propagar al hub

**Opcion rapida** (recomendada): Un solo comando que importa, cross-syncs, commit y push:

```bash
bash /path/to/batuta-dots/infra/sync.sh --push /path/to/project
```

**Opcion interactiva**: Ejecuta el workflow `/push-skill` en Antigravity:
1. Antigravity detecta skills locales no presentes en batuta-dots
2. Te pregunta cuales propagar
3. Los copia a `batuta-dots/BatutaClaude/skills/` con el campo `platforms` adecuado

**Opcion manual** (solo importar, sin commit):
```bash
bash /path/to/batuta-dots/infra/sync.sh --from-project /path/to/project
```

---

## Diferencias tecnicas con Claude Code

### 1. No hay hooks automaticos

Claude Code tiene 2 hooks nativos (SessionStart, Stop). Antigravity no tiene hooks.

**Solucion**: GEMINI.md incluye reglas de comportamiento que replican los hooks criticos:
- "Al inicio de cada sesion, lee `.batuta/session.md`" (reemplaza SessionStart)
- "Antes de escribir o editar, muestra los cambios y espera aprobacion" (Execution Gate via regla)
- El workflow `/save-session` reemplaza el hook Stop

### 2. No hay Agent Teams

Claude Code puede crear sesiones paralelas independientes (Agent Teams). Antigravity tiene Manager View nativo que hace algo similar pero diferente.

**Solucion**: Usa Manager View de Antigravity directamente. No necesitas el skill `team-orchestrator` (es `platforms: [claude]` por esta razon).

### 3. No hay session tracking automatico

Claude Code usa hooks nativos (SessionStart, Stop) para leer/actualizar `.batuta/session.md` automaticamente. Sin hooks, no hay tracking automatico.

**Solucion**: GEMINI.md incluye una regla de tracking manual: al terminar una tarea significativa, el agente registra un resumen en `.batuta/session.md`.

### 4. No hay slash commands nativos

Claude Code tiene `/command` como feature nativa. Antigravity usa workflows (prompts guardados).

**Solucion**: Los 11 workflows en `BatutaAntigravity/workflows/` replican los commands mas importantes.

---

## Troubleshooting

### GEMINI.md conflict con Gemini CLI

Antigravity y Gemini CLI ambos escriben a `~/.gemini/GEMINI.md`. Si usas ambos, pueden haber conflictos.

**Solucion**: Usa el GEMINI.md de Batuta solo a nivel de proyecto (no global), o usa `--workspace` para instalar solo los skills sin tocar GEMINI.md global.

### Skills no se cargan

Verifica que los skills estan en la ubicacion correcta:
- Workspace: `.agent/skills/nombre-skill/SKILL.md`
- Global: `~/.gemini/antigravity/skills/nombre-skill/SKILL.md`

### Session no se restaura

Antigravity no tiene hook SessionStart. El agente debe leer `.batuta/session.md` como primera accion. Si no lo hace, recuerdalo con: "Lee .batuta/session.md para continuar donde quedamos."

### ecosystem.json desactualizado

Si el agente reporta que la version local esta desactualizada, ejecuta `/batuta-update` para sincronizar desde el hub.

---

## Quota y costos

| Plataforma | Costo | Modelo | Contexto |
|-----------|-------|--------|----------|
| Claude Code Max x20 | $200/mes | Claude Opus/Sonnet | 200K tokens |
| Antigravity Preview | Gratis | Gemini 3 Pro | Generoso (preview) |

**Estrategia recomendada**: Usa ambos en paralelo. Claude Code para produccion seria que requiere arquitectura, SDD completo, y precision. Antigravity Lite para brainstorming, prototipado rapido, scripts, configs, docs, y tareas mecanicas. El ahorro no es en dinero (Antigravity es gratis) sino en **throughput** — mas cosas hechas al mismo tiempo.
