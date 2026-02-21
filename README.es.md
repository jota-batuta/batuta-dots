# Batuta.Dots

**Ecosistema de agentes IA para fabricas de software — Claude Code primero, replicable a cualquier plataforma.**

[![Licencia: MIT](https://img.shields.io/badge/Licencia-MIT-blue.svg)](LICENSE)

---

## Que es Batuta?

Batuta es un ecosistema de agentes IA que le da a Claude Code un conjunto completo de skills, workflows y metodologia de desarrollo. Escribes tus convenciones una vez en `CLAUDE.md`, y los skills se cargan bajo demanda segun el contexto. Cuando estes listo para extender a otras plataformas, un script de replicacion genera el equivalente para Gemini, Copilot, Codex u OpenCode.

Inspirado en [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots), pero adaptado para:

- **Fabrica de software multi-proyecto**.
- **Personalidad CTO/Mentor** que educa y documenta para personas no tecnicas.
- **Regla de Alcance (Scope Rule)** que organiza archivos por quien los usa, no por tipo.
- **Auto-deteccion de gaps en skills** con investigacion automatica via Context7.
- **Carga lazy de skills** — Claude lee ~170 lineas al iniciar, el resto se carga bajo demanda.
- **Auto-actualizacion del ecosistema** — skills nuevos fluyen de vuelta a batuta-dots.
- **Framework O.R.T.A.** (Observabilidad, Repetibilidad, Trazabilidad, Auto-supervision).

---

## Inicio Rapido

```bash
# 1. Clonar el repositorio
git clone https://github.com/jota-batuta/batuta-dots.git
cd batuta-dots

# 2. Copiar CLAUDE.md y sincronizar skills
./skills/setup.sh --all

# 3. Verificar
./skills/setup.sh --verify
```

O ejecuta `./skills/setup.sh` sin argumentos para un menu interactivo.

### Opciones del script

| Flag | Descripcion |
|------|-------------|
| `--claude` | Copia `BatutaClaude/CLAUDE.md` a la raiz del proyecto |
| `--sync` | Copia skills a `~/.claude/skills/` |
| `--all` | Copia + sincroniza (recomendado) |
| `--verify` | Verifica que todo este configurado correctamente |

### Otras plataformas (futuro)

```bash
./skills/replicate-platform.sh --all    # Genera GEMINI.md, CODEX.md, copilot-instructions.md
```

---

## Arquitectura

```
batuta-dots/
├── BatutaClaude/
│   ├── CLAUDE.md                       # Punto de entrada unico (personalidad + reglas + routing)
│   ├── settings.json                   # Configuracion de Claude Code
│   ├── mcp-servers.template.json       # Plantilla de servidores MCP
│   ├── output-styles/batuta.md         # Estilo de salida
│   ├── commands/                       # Slash commands globales
│   │   ├── batuta-init.md              # /batuta-init
│   │   └── batuta-update.md            # /batuta-update
│   └── skills/                         # Skills instalables (carga lazy)
│       ├── ecosystem-creator/          # Skill bootstrap
│       │   ├── SKILL.md
│       │   └── assets/                 # Plantillas
│       ├── scope-rule/SKILL.md         # Regla de Alcance
│       ├── sdd-init/SKILL.md           # Pipeline SDD (9 fases)
│       ├── ...
│       └── sdd-archive/SKILL.md
├── guides/                             # Guias paso a paso
│   ├── guia-batuta-app.md              # Guia de dashboard app
│   ├── guia-temporal-io-app.md         # Guia de Temporal.io
│   ├── guia-langchain-gmail-agent.md   # Guia de agente LangChain + Gmail
│   ├── arquitectura-diagrama.md        # Diagramas Mermaid
│   └── arquitectura-para-no-tecnicos.md # Arquitectura sin tecnicismos
├── CHANGELOG-refactor.md               # Documento de traza de refactorizaciones
└── skills/
    ├── setup.sh                        # Script principal (Claude Code)
    ├── replicate-platform.sh           # Replicacion a otras plataformas
    └── setup_test.sh                   # Tests de verificacion
```

### Como funciona

1. **CLAUDE.md** es el unico punto de entrada. Contiene personalidad, reglas, Scope Rule, Skill Gap Detection, y la tabla de routing de skills.
2. **setup.sh** copia CLAUDE.md a la raiz del proyecto y sincroniza skills a `~/.claude/skills/`.
3. **Claude Code** lee CLAUDE.md al iniciar (~170 lineas), luego carga skills bajo demanda segun el contexto.

```
BatutaClaude/CLAUDE.md  (punto de entrada unico)
    │
    ├──> setup.sh --claude  ──> CLAUDE.md (copia en raiz)
    └──> setup.sh --sync    ──> ~/.claude/skills/ (carga bajo demanda)
```

---

## Conceptos Clave

### Regla de Alcance (Scope Rule)

Antes de crear CUALQUIER archivo, el agente pregunta: "Quien va a usar esto?"

| Quien lo usa? | Donde va |
|---|---|
| 1 feature | `features/{feature}/{tipo}/{nombre}` |
| 2+ features | `features/shared/{tipo}/{nombre}` |
| Toda la app | `core/{tipo}/{nombre}` |

NUNCA se crean carpetas `utils/`, `helpers/`, `lib/` o `components/` en la raiz. Los detalles completos estan en el skill `scope-rule`.

### Spec-Driven Development (SDD)

Pipeline de 9 fases que fuerza "entender antes de construir":

```
init -> explore -> propose -> spec -> design -> tasks -> apply -> verify -> archive
```

Cada fase es un sub-agente especializado. El orquestador delega todo el trabajo pesado y solo rastrea estado y decisiones del usuario.

### Deteccion de Skills Faltantes

Antes de escribir codigo con una tecnologia, Claude verifica si existe un skill activo. Si no existe, se detiene y ofrece investigar via Context7 y crear el skill antes de continuar.

### Carga Lazy de Skills

Claude lee solo ~170 lineas al iniciar. Los skills individuales (200-500 lineas cada uno) se cargan SOLO cuando el contexto coincide. Esto ahorra tokens y mantiene las conversaciones rapidas.

### Auto-actualizacion del Ecosistema

Cuando se crean skills nuevos en un proyecto, Claude propone propagarlos de vuelta a batuta-dots para que otros proyectos se beneficien.

---

## Skills Disponibles (12)

| Skill | Descripcion |
|-------|-------------|
| `ecosystem-creator` | Crea nuevos skills, agentes, sub-agentes y workflows |
| `scope-rule` | Organiza archivos por alcance (feature / shared / core) |
| `sdd-init` a `sdd-archive` | Pipeline SDD de 9 fases |

Mas 17 skills de proyecto planificados. Ver CLAUDE.md para la hoja de ruta completa.

---

## Comandos

| Comando | Descripcion |
|---------|-------------|
| `/batuta-init [nombre]` | Importar ecosistema Batuta a un proyecto |
| `/batuta-update` | Actualizar ecosistema desde batuta-dots |
| `/sdd:init` | Inicializar contexto |
| `/sdd:explore <tema>` | Explorar idea |
| `/sdd:new <nombre>` | Propuesta de cambio |
| `/sdd:continue [nombre]` | Siguiente fase |
| `/sdd:apply [nombre]` | Implementar |
| `/sdd:verify [nombre]` | Verificar |
| `/sdd:archive [nombre]` | Archivar |
| `/create:skill <nombre>` | Crear skill |
| `/create:sub-agent <nombre>` | Crear sub-agente |
| `/create:workflow <nombre>` | Crear workflow |

---

## Contribuir

1. Ejecutar `/create:skill <nombre>` — el skill `ecosystem-creator` guia el proceso.
2. O manualmente: crear `BatutaClaude/skills/<nombre>/SKILL.md`.
3. Agregar a la tabla de skills en `BatutaClaude/CLAUDE.md`.
4. Ejecutar `./skills/setup.sh --all`.

---

## Creditos

Inspirado en [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots) de [Gentleman Programming](https://github.com/Gentleman-Programming).

---

## Licencia

[MIT](LICENSE)
