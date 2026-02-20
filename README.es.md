# Batuta.Dots

**Ecosistema de agentes IA para una fabrica de software.**

[![Licencia: MIT](https://img.shields.io/badge/Licencia-MIT-blue.svg)](LICENSE)

---

## Que es Batuta?

Batuta es un ecosistema de agentes IA que proporciona skills unificados, workflows y una metodologia de desarrollo (Spec-Driven Development) a traves de todos los asistentes de codigo IA: Claude Code, Gemini CLI, GitHub Copilot, OpenAI Codex y OpenCode. Un solo archivo maestro (`AGENTS.md`) se sincroniza hacia el formato nativo de cada herramienta, garantizando que todas compartan las mismas reglas, convenciones y patrones.

Inspirado en [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots), pero adaptado para:

- **Fabrica de software multi-proyecto** en lugar de un solo proyecto.
- **Personalidad CTO/Mentor** que educa y documenta para personas no tecnicas.
- **Ecosystem-creator ampliado** que crea skills, agentes, sub-agentes y workflows.
- **Auto-deteccion de gaps en skills** con investigacion automatica via Context7.
- **Framework O.R.T.A.** (Observabilidad, Repetibilidad, Trazabilidad, Auto-supervision).

---

## Inicio Rapido

```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/batuta-dots.git
cd batuta-dots

# 2. Ejecutar el script de configuracion (modo interactivo)
./skills/setup.sh

# 3. O generar todos los formatos y sincronizar de una vez
./skills/setup.sh --all && ./skills/setup.sh --sync-all && ./skills/setup.sh --verify
```

### Opciones del script de configuracion

| Flag | Descripcion |
|------|-------------|
| `--claude` | Genera `CLAUDE.md` (personalidad + AGENTS.md) |
| `--gemini` | Genera `GEMINI.md` desde AGENTS.md |
| `--copilot` | Genera `.github/copilot-instructions.md` desde AGENTS.md |
| `--codex` | Genera `CODEX.md` desde AGENTS.md |
| `--all` | Genera todos los formatos anteriores |
| `--sync-claude` | Copia skills a `~/.claude/skills/` |
| `--sync-opencode` | Copia skills a la configuracion de OpenCode |
| `--sync-all` | Ejecuta `--sync-claude` y `--sync-opencode` |
| `--verify` | Verifica que los archivos generados contengan el contenido de AGENTS.md |

### Flujo de trabajo tipico

```bash
./skills/setup.sh --all          # Generar archivos de instrucciones
./skills/setup.sh --sync-all     # Sincronizar skills a configuraciones de usuario
./skills/setup.sh --verify       # Verificar que todo este correcto
```

---

## Arquitectura

```
batuta-dots/
├── AGENTS.md                           # Fuente unica de verdad para todos los asistentes IA
├── skills/
│   ├── setup.sh                        # Script de sincronizacion y generacion
│   └── setup_test.sh                   # Tests de verificacion
├── BatutaClaude/
│   ├── CLAUDE.md                       # Personalidad CTO/Mentor para Claude Code
│   ├── settings.json                   # Configuracion de Claude Code
│   ├── mcp-servers.template.json       # Plantilla de servidores MCP
│   ├── output-styles/
│   │   └── batuta.md                   # Estilo de salida personalizado
│   └── skills/                         # Skills instalables por el usuario
│       ├── ecosystem-creator/
│       │   ├── SKILL.md                # Skill bootstrap (crea todo lo demas)
│       │   └── assets/                 # Plantillas para skills, agentes, workflows
│       ├── sdd-init/SKILL.md           # Inicializar contexto SDD
│       ├── sdd-explore/SKILL.md        # Explorar codebase
│       ├── sdd-propose/SKILL.md        # Crear propuesta de cambio
│       ├── sdd-spec/SKILL.md           # Escribir especificaciones
│       ├── sdd-design/SKILL.md         # Producir diseno tecnico
│       ├── sdd-tasks/SKILL.md          # Dividir trabajo en tareas
│       ├── sdd-apply/SKILL.md          # Implementar tareas
│       ├── sdd-verify/SKILL.md         # Verificar implementacion
│       └── sdd-archive/SKILL.md        # Archivar cambio completado
├── BatutaOpenCode/
│   ├── opencode.json                   # Configuracion de agentes para OpenCode
│   └── themes/
│       └── batuta.json                 # Tema visual personalizado
│
│   Archivos generados por setup.sh:
├── CLAUDE.md                           # Auto-generado: personalidad + AGENTS.md
├── GEMINI.md                           # Auto-generado desde AGENTS.md
├── CODEX.md                            # Auto-generado desde AGENTS.md
└── .github/
    └── copilot-instructions.md         # Auto-generado desde AGENTS.md
```

---

## Como Funciona

La cadena de sincronizacion sigue un flujo de tres pasos:

```
AGENTS.md  (fuente unica de verdad)
    │
    ├──> setup.sh --claude  ──> CLAUDE.md   (personalidad BatutaClaude/CLAUDE.md + AGENTS.md)
    ├──> setup.sh --gemini  ──> GEMINI.md
    ├──> setup.sh --copilot ──> .github/copilot-instructions.md
    └──> setup.sh --codex   ──> CODEX.md
```

1. **AGENTS.md** contiene todas las reglas, skills, comandos y comportamientos. Es el archivo maestro.
2. **setup.sh** lee AGENTS.md y genera archivos en el formato nativo de cada herramienta IA. Para Claude Code, ademas prepone la personalidad definida en `BatutaClaude/CLAUDE.md`.
3. **La herramienta IA** lee su archivo de instrucciones y carga automaticamente los skills relevantes segun el contexto del trabajo.

La sincronizacion de skills funciona de forma separada:

```
BatutaClaude/skills/*
    │
    ├──> setup.sh --sync-claude   ──> ~/.claude/skills/
    └──> setup.sh --sync-opencode ──> ~/.config/opencode/skill/ + BatutaOpenCode/skill/
```

---

## Spec-Driven Development (SDD)

SDD es la metodologia de desarrollo que Batuta utiliza para coordinar el trabajo de los asistentes IA. Sigue un pipeline de 9 fases donde cada fase es un sub-agente especializado:

```
init ──> explore ──> propose ──> spec ──> design ──> tasks ──> apply ──> verify ──> archive
```

### Fases del pipeline

| Fase | Skill | Descripcion |
|------|-------|-------------|
| **init** | `sdd-init` | Inicializa el contexto del proyecto y el modo de persistencia |
| **explore** | `sdd-explore` | Explora el codebase y los enfoques posibles antes de proponer un cambio |
| **propose** | `sdd-propose` | Crea una propuesta de cambio con alcance, riesgos y criterios de exito |
| **spec** | `sdd-spec` | Escribe especificaciones delta con escenarios verificables |
| **design** | `sdd-design` | Produce el diseno tecnico y las decisiones de arquitectura |
| **tasks** | `sdd-tasks` | Divide el trabajo en fases de implementacion |
| **apply** | `sdd-apply` | Implementa los lotes de tareas siguiendo las especificaciones y el diseno |
| **verify** | `sdd-verify` | Verifica la implementacion contra las especificaciones y las tareas |
| **archive** | `sdd-archive` | Cierra el cambio y archiva los artefactos finales |

### Grafo de dependencias

```
proposal ──> [specs || design] ──> tasks ──> apply ──> verify ──> archive
```

Las especificaciones (`specs`) y el diseno (`design`) pueden ejecutarse en paralelo. Ambos deben completarse antes de pasar a la fase de tareas (`tasks`).

### Principios del orquestador

El agente principal actua como orquestador: coordina, rastrea el estado y solicita aprobacion del usuario. Nunca ejecuta trabajo pesado directamente. Todo el analisis, diseno, implementacion y verificacion se delega a sub-agentes especializados.

---

## Deteccion de Skills Faltantes

Antes de escribir codigo con una tecnologia, el asistente IA verifica si existe un skill activo para ella. Si no existe:

1. **Se detiene** antes de escribir codigo.
2. **Informa al usuario**: "No tengo un skill documentado para {tecnologia}".
3. **Propone tres opciones**:
   - **Investigar y crear (proyecto-especifico)**: Consulta Context7 para las mejores practicas actuales y crea un skill acotado a las convenciones de Batuta (multi-tenant, O.R.T.A., etc.).
   - **Investigar y crear (global)**: Misma investigacion pero con patrones genericos reutilizables en cualquier proyecto.
   - **Continuar sin skill**: Implementa con buenas practicas generales y documenta el gap con un comentario TODO.
4. Si el usuario elige crear, invoca el skill `ecosystem-creator` con el flujo de auto-descubrimiento.

### Por que importa

Sin skills documentados, el asistente IA escribe codigo generico que puede no seguir las convenciones de Batuta para multi-tenancy, observabilidad, seguridad o despliegue. Crear un skill toma aproximadamente 5 minutos y ahorra horas de refactorizacion.

### Flujo de auto-descubrimiento

```
Gap detectado: "{tecnologia}" no tiene skill activo
│
├── 1. INVESTIGAR   ── Consultar Context7 para mejores practicas actuales
├── 2. DECIDIR      ── Proyecto-especifico o global?
├── 3. CRUZAR       ── Verificar puntos de integracion con el stack Batuta
├── 4. REDACTAR     ── Generar SKILL.md con la plantilla estandar
├── 5. REVISAR      ── Presentar borrador al usuario para aprobacion
└── 6. REGISTRAR    ── Seguir la lista de verificacion de registro completa
```

---

## Skills Disponibles

### Skills de Infraestructura (incluidos de serie)

| Skill | Descripcion |
|-------|-------------|
| `ecosystem-creator` | Crea nuevos skills, agentes, sub-agentes y workflows |
| `sdd-init` | Inicializa el contexto del proyecto SDD y el modo de persistencia |
| `sdd-explore` | Explora el codebase y los enfoques antes de proponer un cambio |
| `sdd-propose` | Crea propuesta de cambio con alcance, riesgos y criterios de exito |
| `sdd-spec` | Escribe especificaciones delta con escenarios verificables |
| `sdd-design` | Produce diseno tecnico y decisiones de arquitectura |
| `sdd-tasks` | Divide el trabajo en fases de implementacion |
| `sdd-apply` | Implementa lotes de tareas siguiendo especificaciones y diseno |
| `sdd-verify` | Verifica la implementacion contra especificaciones y tareas |
| `sdd-archive` | Cierra un cambio y archiva los artefactos finales |

### Skills de Proyecto (hoja de ruta)

Los skills de proyecto se crean bajo demanda con `/create:skill <nombre>`. La hoja de ruta completa se mantiene en AGENTS.md e incluye categorias como:

- **Backend e Infraestructura**: Temporal, PostgreSQL multi-tenant, n8n, Coolify, SOPS, Redis, Webhooks.
- **IA y Agentes**: Claude SDK / LangGraph / LangChain / Google ADK, optimizacion LLM, Langfuse, Presidio PII.
- **Frontend y Portal**: Next.js 14+ App Router.
- **Cumplimiento y Dominio**: Facturacion electronica DIAN, Ley 1581/2012 Habeas Data, O.R.T.A.
- **Estandares de Desarrollo**: Convenciones Python, generador de directivas.

Cada skill de proyecto comienza con estado `planned` y pasa a `active` una vez creado.

---

## Comandos

### Comandos SDD

| Comando | Descripcion |
|---------|-------------|
| `/sdd:init` | Inicializar el contexto de orquestacion |
| `/sdd:explore <tema>` | Explorar idea y restricciones |
| `/sdd:new <nombre-cambio>` | Iniciar flujo de propuesta de cambio |
| `/sdd:continue [nombre-cambio]` | Ejecutar la siguiente fase lista segun dependencias |
| `/sdd:ff [nombre-cambio]` | Avance rapido de artefactos de planificacion |
| `/sdd:apply [nombre-cambio]` | Implementar tareas en lotes |
| `/sdd:verify [nombre-cambio]` | Validar la implementacion |
| `/sdd:archive [nombre-cambio]` | Cerrar y persistir el estado final |

### Comandos del Ecosistema

| Comando | Descripcion |
|---------|-------------|
| `/create:skill <nombre>` | Crear un nuevo skill (tecnologia, workflow o tipo de proyecto) |
| `/create:agent <nombre>` | Crear una nueva definicion de agente para OpenCode |
| `/create:sub-agent <nombre>` | Crear un nuevo sub-agente estilo SDD con contrato de envelope |
| `/create:workflow <nombre>` | Crear un nuevo comando de workflow con mapeo de skills |

### Mapeo Comando a Skill

| Comando | Skill invocado |
|---------|----------------|
| `/sdd:init` | `sdd-init` |
| `/sdd:explore` | `sdd-explore` |
| `/sdd:new` | `sdd-explore` luego `sdd-propose` |
| `/sdd:continue` | El siguiente necesario entre `sdd-spec`, `sdd-design`, `sdd-tasks` |
| `/sdd:ff` | `sdd-propose` luego `sdd-spec` luego `sdd-design` luego `sdd-tasks` |
| `/sdd:apply` | `sdd-apply` |
| `/sdd:verify` | `sdd-verify` |
| `/sdd:archive` | `sdd-archive` |
| `/create:skill` | `ecosystem-creator` (modo: skill) |
| `/create:agent` | `ecosystem-creator` (modo: agent) |
| `/create:sub-agent` | `ecosystem-creator` (modo: sub-agent) |
| `/create:workflow` | `ecosystem-creator` (modo: workflow) |

---

## Herramientas IA Soportadas

| Herramienta | Archivo de instrucciones | Formato | Notas |
|-------------|--------------------------|---------|-------|
| **Claude Code** | `CLAUDE.md` | Personalidad (`BatutaClaude/CLAUDE.md`) + AGENTS.md | Incluye skills auto-cargables en `~/.claude/skills/` |
| **Gemini CLI** | `GEMINI.md` | AGENTS.md directo | Lee GEMINI.md en la raiz del proyecto |
| **GitHub Copilot** | `.github/copilot-instructions.md` | AGENTS.md directo | Sigue la convencion de directorio `.github/` |
| **OpenAI Codex** | `CODEX.md` | AGENTS.md directo | Lee CODEX.md en la raiz del proyecto |
| **OpenCode** | `BatutaOpenCode/` | AGENTS.md + opencode.json | Soporta agentes y temas personalizados |

Todos los archivos de instrucciones se generan automaticamente desde AGENTS.md. No se deben editar directamente.

---

## Contribuir

### Agregar un Skill

1. Ejecutar `/create:skill <nombre>` -- el skill `ecosystem-creator` guia el proceso.
2. O manualmente: crear `BatutaClaude/skills/<nombre>/SKILL.md` usando la plantilla.
3. Registrar en AGENTS.md bajo la tabla de skills correspondiente.
4. Ejecutar `./skills/setup.sh --all && ./skills/setup.sh --sync-all`.

### Agregar un Agente

1. Ejecutar `/create:agent <nombre>` -- agrega la definicion a `opencode.json`.
2. Registrar en AGENTS.md si el agente referencia skills.

### Agregar un Workflow

1. Ejecutar `/create:workflow <nombre>` -- crea el comando y el mapeo de skills.
2. Agregar al mapeo "Comando a Skill" en AGENTS.md.

### Convenciones de nombres

| Tipo | Patron | Ejemplos |
|------|--------|----------|
| Skill de tecnologia | `{tecnologia}` | `python-batuta`, `typescript` |
| Skill de infraestructura | `{servicio}-{aspecto}` | `temporal-worker`, `coolify-deploy` |
| Skill de dominio | `{dominio}-{tema}` | `colombia-regulatory`, `pii-presidio` |
| Agente especialista | `{rol}` | `reviewer`, `deployer`, `documenter` |
| Sub-agente SDD | `sdd-{fase}` | `sdd-init`, `sdd-migrate` |
| Workflow SDD | `/sdd:{accion}` | `/sdd:init`, `/sdd:apply` |
| Workflow de operaciones | `/{dominio}:{accion}` | `/deploy:staging`, `/audit:security` |

---

## Creditos

Batuta.Dots esta inspirado en [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots) de [Gentleman Programming](https://github.com/Gentleman-Programming). Gentleman.Dots proporciona la base para configuraciones de agentes IA con skills y personalidad. Batuta extiende ese concepto hacia un ecosistema multi-proyecto con metodologia SDD, deteccion automatica de gaps y soporte para multiples herramientas IA.

---

## Licencia

[MIT](LICENSE)
