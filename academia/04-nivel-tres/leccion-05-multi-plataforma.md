# Leccion 05: Trabajo Multi-Plataforma (Claude Code + Antigravity)

> Aprende a trabajar con dos plataformas AI en paralelo, compartiendo skills y conocimiento via el modelo Hub & Spoke.

---

## Objetivo

Al terminar esta leccion podras:
- Configurar Google Antigravity IDE con el ecosistema Batuta
- Ejecutar workflows SDD desde Antigravity
- Sincronizar skills bidireccionalmente entre plataformas y proyectos
- Decidir que plataforma usar para cada tipo de tarea

## Prerequisitos

- Leccion 01-04 del Nivel Tres (extender ecosistema, templates, infra, recursion)
- batuta-dots clonado y configurado
- Antigravity IDE instalado

---

## Concepto clave: Hub & Spoke

batuta-dots es el **hub central** (libro maestro de recetas). Cada proyecto y plataforma es un **spoke** (sucursal).

```
Proyecto A (Claude Code)  ←→  batuta-dots (hub)  ←→  Proyecto B (Antigravity)
                                    ↕
                           Proyecto C (cualquiera)
```

**Flujo de skills**:
1. Un skill se crea en cualquier spoke (proyecto/plataforma)
2. Se propaga al hub (via `/batuta-sync` desde el agente, o `sync.sh --push` desde terminal)
3. Del hub se distribuye a todos los spokes (via `install.sh` para usuarios, o `/batuta-update` / `setup.sh --update` para desarrolladores)

El campo `platforms` en el frontmatter de SKILL.md determina que plataformas reciben cada skill:
- `platforms: [claude, antigravity]` — va a ambas (21 de 23 skills)
- `platforms: [claude]` — solo Claude Code (2 skills que requieren hooks o Agent Teams)

---

## Que es Antigravity

Google Antigravity es un IDE agent-first (fork de VS Code/Windsurf). Durante el preview es gratuito con Gemini 3 Pro.

| Feature | En Claude Code | En Antigravity |
|---------|---------------|----------------|
| Reglas del agente | CLAUDE.md | GEMINI.md (Rules) |
| Comandos | Slash commands (/sdd-init) | Workflows (prompts guardados con /trigger) |
| Skills | `~/.claude/skills/` | `.agent/skills/` o `~/.gemini/antigravity/skills/` |
| Hooks automaticos | 2 hooks nativos (SessionStart, Stop) | No hay — reglas de comportamiento en GEMINI.md |
| Multi-agente | Agent Teams (spawn sessions) | Manager View (nativo) |

---

## Setup paso a paso

### 1. Instalar Antigravity (usuarios)

La forma mas sencilla es usar el instalador:

```bash
cd /path/to/mi-proyecto
git clone --depth 1 https://github.com/jota-batuta/batuta-dots.git /tmp/batuta-install && bash /tmp/batuta-install/infra/install.sh --antigravity && rm -rf /tmp/batuta-install
```

### 2. Instalar Antigravity (desarrolladores con clon local)

Si tienes un clon persistente de batuta-dots:

```bash
cd ~/batuta-dots && git pull origin main
cd /path/to/mi-proyecto
bash ~/batuta-dots/BatutaAntigravity/setup-antigravity.sh --all
```

Esto:
- Copia 22 skills a `.agent/skills/` (workspace) y `~/.gemini/antigravity/skills/` (global)
- Copia GEMINI.md al proyecto
- Crea `.batuta/session.md` y `.batuta/ecosystem.json`

### 3. Verificar

Abre Antigravity en el proyecto. El agente deberia:
- Leer `.batuta/session.md` al iniciar (regla en GEMINI.md)
- Tener acceso a los workflows via `/trigger`
- Cargar skills por su campo `description`

---

## Workflow de trabajo en paralelo

La estrategia no es "uno despues del otro" — es **ejecucion simultanea**:

```
Claude Code                          Antigravity
─────────────                        ───────────
Arquitectura de feature X            Script de migracion Y
SDD completo (9 fases)               Configuracion n8n
Feature multi-modulo                  Fix de docs
Agent Teams para refactoring          Quick fixes en 3 archivos
```

**Regla de decision**:
- Si necesitas pensar mucho → Claude Code
- Si necesitas hacer mucho → Antigravity
- Si es critico y no puede fallar → Claude Code
- Si es mecanico y repetitivo → Antigravity

---

## Sincronizacion bidireccional

### Opcion recomendada: /batuta-sync (zero-bash, v12)

Desde Claude Code o Antigravity, simplemente di:

```
"Sincroniza mis skills al hub"
```

O usa el comando explícito:
```
/batuta-sync
```

El agente internamente:
1. Localiza batuta-dots (misma logica que `/batuta-update`)
2. Escanea skills locales no presentes en el hub
3. Te presenta el plan de sync
4. Si apruebas: copia al hub, cross-syncs a Antigravity, commit + push

**Nunca necesitas abrir terminal.**

### Opcion alternativa: terminal (para desarrolladores del hub)

Si trabajas directamente en batuta-dots y prefieres terminal:

```bash
# Un solo comando: importa skills, cross-syncs a Antigravity, commit + push
bash infra/sync.sh --push /path/to/mi-proyecto
```

Opciones granulares para control fino:

```bash
# Solo importar del proyecto (sin commit ni push)
bash infra/sync.sh --from-project /path/to/mi-proyecto

# Solo cross-sync al subfolder Antigravity
bash infra/sync.sh --to-antigravity

# Ambos pasos juntos (sin commit ni push)
bash infra/sync.sh --all --from-project /path/to/mi-proyecto
```

---

## ecosystem.json

Cada proyecto tiene `.batuta/ecosystem.json` que registra:

```json
{
  "batuta_version": "10.2",
  "platform": "antigravity",
  "last_sync": "2026-02-24T15:30:00Z",
  "skills_local": [],
  "skills_shared": []
}
```

- **batuta_version**: Version de batuta-dots al momento del setup
- **platform**: `claude` o `antigravity`
- **last_sync**: Fecha del ultimo sync con el hub

El hook SessionStart de Claude Code y las reglas de GEMINI.md comparan la version local con la del hub. Si hay drift, te avisan:

> "La version local (10.1) difiere del hub (10.2). Ejecuta /batuta-update para sincronizar."

---

## Ejercicio practico

### Crear un skill en Antigravity y propagarlo

1. **En Antigravity**, crea un skill simple:

```
mkdir -p .agent/skills/mi-utilidad/
```

Crea `.agent/skills/mi-utilidad/SKILL.md`:
```yaml
---
name: mi-utilidad
description: >
  Descripcion de lo que hace el skill.
  Trigger: palabras clave que lo activan.
license: MIT
metadata:
  author: Tu nombre
  version: "1.0"
  scope: [infra]
  auto_invoke: false
allowed-tools: Read, Glob, Grep
platforms: [claude, antigravity]
---

# Mi Utilidad

## Purpose

Descripcion detallada del skill...
```

2. **Propaga al hub** — en Claude Code o Antigravity, di:

```
"Sincroniza mis skills al hub"
```

O usa `/batuta-sync`. El agente importa el skill al hub, cross-syncs a Antigravity, y te pide confirmacion antes de commit + push.

> **Nota**: Si eres desarrollador del hub y prefieres terminal: `bash ~/batuta-dots/infra/sync.sh --push /path/to/mi-proyecto`

3. **Verifica** que aparece en `batuta-dots/BatutaClaude/skills/mi-utilidad/SKILL.md`

4. **Actualiza Claude Code** en cualquier proyecto — di `/batuta-update` o:

```bash
bash ~/batuta-dots/infra/setup.sh --update /path/to/mi-otro-proyecto
```

5. Abre Claude Code — el skill estara disponible globalmente.

---

## Resumen

- **Hub & Spoke**: batuta-dots es el hub, proyectos son spokes. Skills fluyen en ambas direcciones.
- **Full Brain, Adapted Body**: GEMINI.md tiene el 100% del cerebro CTO. Solo la ejecucion se adapta (rules en vez de hooks, workflows en vez de commands).
- **Paralelo, no secuencial**: Claude Code y Antigravity trabajan al mismo tiempo en tareas diferentes.
- **`platforms` field**: Controla que plataformas reciben cada skill durante el sync.
- **`ecosystem.json`**: Detecta version drift entre el hub y los proyectos.
- **Gratis**: Antigravity es gratuito durante preview. Agrega capacidad sin costo adicional.

---

← [Leccion 04: Recursion y Aprendizaje](recursion-y-aprendizaje.md) | [Nivel Tres completo — Siguiente: Casos de Uso](../../05-casos-de-uso/)
