# Changelog de Refactorizacion — Batuta.Dots

> Documento de traza. Registra CADA modificacion arquitectural, POR QUE se hizo, y como revertirla si es necesario.

---

## v3 — Eliminacion de AGENTS.md, CLAUDE.md como unico punto de entrada (2026-02-21)

### Problema detectado
`AGENTS.md` era declarado como "Single Source of Truth", pero Claude Code solo lee `CLAUDE.md` automaticamente. Esto significaba que:
1. `AGENTS.md` era un archivo muerto a menos que `CLAUDE.md` lo referenciara explicitamente
2. `setup.sh` combinaba ambos archivos en un CLAUDE.md gigante (~400+ lineas)
3. Claude cargaba todo al iniciar cada conversacion, desperdiciando tokens en contenido irrelevante para la tarea actual

### Solucion implementada
Patron **lazy-loading**: `CLAUDE.md` es el unico archivo que Claude lee, contiene solo lo esencial (~170 lineas), y los skills se cargan bajo demanda.

### Archivos modificados

| Archivo | Cambio | Razon |
|---------|--------|-------|
| `AGENTS.md` | **ELIMINADO** | Su contenido se distribuyo entre CLAUDE.md (resumen) y skills individuales (detalle) |
| `BatutaClaude/CLAUDE.md` | **REESCRITO** | Ahora es el unico punto de entrada. Contiene: personalidad, reglas, Scope Rule, Skill Gap Detection, Auto-Update SPO, tabla de routing de skills, comandos SDD, lista de skills disponibles |
| `skills/setup.sh` | **SIMPLIFICADO** | Ya no combina archivos. `--claude` hace un `cp` directo. `--verify` verifica que AGENTS.md no exista |
| `skills/setup_test.sh` | **ACTUALIZADO** | Tests adaptados a la nueva arquitectura sin AGENTS.md |
| `BatutaClaude/commands/batuta-init.md` | **ACTUALIZADO** | Ya no copia AGENTS.md. Solo copia CLAUDE.md |
| `BatutaClaude/commands/batuta-update.md` | **ACTUALIZADO** | Ya no menciona AGENTS.md. Solo actualiza CLAUDE.md y skills |
| `guides/guia-batuta-app.md` | **ACTUALIZADO** | Todas las referencias a AGENTS.md removidas |
| `guides/guia-temporal-io-app.md` | **ACTUALIZADO** | Referencias a AGENTS.md removidas |
| `guides/guia-langchain-gmail-agent.md` | **ACTUALIZADO** | Referencias a AGENTS.md removidas |
| `guides/arquitectura-diagrama.md` | **REESCRITO** | Diagramas actualizados: AGENTS.md ya no aparece, CLAUDE.md es el centro |
| `guides/arquitectura-para-no-tecnicos.md` | **REESCRITO** | Analogia actualizada: "Libro de Recetas" ahora es CLAUDE.md |
| `README.md` | **ACTUALIZADO** | Arquitectura y explicaciones sin AGENTS.md |
| `README.es.md` | **ACTUALIZADO** | Arquitectura y explicaciones sin AGENTS.md |

### Donde fue a parar el contenido de AGENTS.md

| Seccion de AGENTS.md | Nuevo hogar | Notas |
|----------------------|-------------|-------|
| Skills tables (infrastructure) | `CLAUDE.md` → "Available Skills" | Solo tabla resumen, no detalle completo |
| Skills tables (project/planned) | `CLAUDE.md` → "Planned project skills" | Lista compacta por categoria |
| Scope Rule | `CLAUDE.md` → "Scope Rule" section | Quick-reference. Detalle en `skills/scope-rule/SKILL.md` |
| Skill Gap Detection | `CLAUDE.md` → "Skill Gap Detection" section | Completo con prompt template |
| Auto-invoke table | `CLAUDE.md` → "Auto-invoke table" | Misma tabla, mismos paths |
| Auto-Update SPO | `CLAUDE.md` → "Ecosystem Auto-Update" | Resumen. Detalle en proceso de propagacion |
| SDD Orchestrator | `CLAUDE.md` → "SDD Commands" + "SDD Orchestrator Rules" | Reglas compactas + tabla de comandos |
| Sub-Agent Output Contract | `CLAUDE.md` → "Sub-Agent Output Contract" | Una linea compacta |
| Contributing / Extending | Eliminado de CLAUDE.md, vive en README.md | Claude no necesita saber como contribuir |
| Skill Structure diagram | Eliminado de CLAUDE.md, vive en README.md | Claude no necesita el tree diagram |

### Como revertir si algo falla

1. **Restaurar AGENTS.md**: `git checkout HEAD~1 -- AGENTS.md`
2. **Restaurar CLAUDE.md antiguo**: `git checkout HEAD~1 -- BatutaClaude/CLAUDE.md`
3. **Restaurar setup.sh antiguo**: `git checkout HEAD~1 -- skills/setup.sh`
4. **Regenerar CLAUDE.md combinado**: `./skills/setup.sh --claude` (version antigua combina los archivos)

### Metricas

| Metrica | Antes (v2) | Despues (v3) |
|---------|-----------|-------------|
| Lineas que Claude lee al iniciar | ~400+ (CLAUDE.md combinado) | ~170 (CLAUDE.md lean) |
| Archivos de configuracion | 2 (AGENTS.md + CLAUDE.md) | 1 (CLAUDE.md) |
| Paso de setup.sh --claude | Concatenar 2 archivos | Copiar 1 archivo |
| Skills cargados al iniciar | Todos (inline en AGENTS.md) | Ninguno (lazy-load on demand) |

---

## v2 — Simplificacion a Claude Code Only + Scope Rule + Auto-Update SPO (2026-02-21)

### Cambios principales
- Removidas todas las referencias a Gemini, Copilot, Codex, OpenCode del flujo principal
- Creado `replicate-platform.sh` para replicacion futura a otras plataformas
- Agregado skill `scope-rule` para organizacion de archivos
- Agregado Auto-Update SPO para propagacion de skills entre proyectos
- `setup.sh` simplificado a Claude Code only (--claude, --sync, --all, --verify)

### Archivos afectados
- `AGENTS.md` — Reescrito (Claude-only + Scope Rule + SPO)
- `BatutaClaude/CLAUDE.md` — Reescrito (Claude-only + Scope Rule awareness)
- `skills/setup.sh` — Reescrito (Claude-only)
- `skills/replicate-platform.sh` — NUEVO
- `BatutaClaude/skills/scope-rule/SKILL.md` — NUEVO
- `README.md`, `README.es.md` — Reescritos
- `skills/setup_test.sh` — Actualizado

---

## v1 — Bootstrap inicial del ecosistema (2026-02-21)

### Creacion
- 26 archivos, 5,404 lineas
- 12 skills de infraestructura (ecosystem-creator + 9 SDD + scope-rule)
- Pipeline SDD completo (9 fases)
- Skill Gap Detection
- Mirror OpenCode
- setup.sh multi-plataforma

---

> **Nota**: Este archivo es para humanos, no para Claude. Claude lee CLAUDE.md.
