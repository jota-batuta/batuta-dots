# Diagrama de Arquitectura — Ecosistema Batuta

## Vista General del Ecosistema

```mermaid
flowchart TB
    subgraph FUENTE["PUNTO DE ENTRADA UNICO"]
        CLAUDE_SRC["BatutaClaude/CLAUDE.md<br/>Personalidad, reglas, Scope Rule,<br/>Gap Detection, routing de skills"]
    end

    subgraph AGENTS_SRC["SCOPE AGENTS"]
        AG_PIPELINE["pipeline-agent.md"]
        AG_INFRA["infra-agent.md"]
        AG_OBS["observability-agent.md"]
    end

    subgraph SETUP["SCRIPTS"]
        SETUP_SH["setup.sh<br/>--claude | --sync | --all | --verify"]
        SYNC_SH["skill-sync/sync.sh<br/>regenera routing tables"]
        REPLICATE["replicate-platform.sh<br/>--gemini | --copilot | --codex<br/>(futuro)"]
    end

    subgraph GENERADO["ARCHIVOS GENERADOS (gitignored)"]
        CLAUDE_GEN["CLAUDE.md (raiz)<br/>(copia directa)"]
    end

    subgraph SKILLS_LOCAL["~/.claude/skills/ (usuario)"]
        SK_ECO["ecosystem-creator"]
        SK_SCOPE["scope-rule"]
        SK_SDD["sdd-init...sdd-archive<br/>(9 sub-agentes)"]
        SK_PROMPT["prompt-tracker<br/>(O.R.T.A.)"]
        SK_PROJECT["skills de proyecto<br/>(creados bajo demanda)"]
    end

    subgraph COMMANDS_LOCAL["~/.claude/commands/ (usuario)"]
        CMD_INIT["/batuta-init"]
        CMD_UPDATE["/batuta-update"]
        CMD_ANALYZE["/batuta:analyze-prompts"]
    end

    CLAUDE_SRC --> SETUP_SH
    AGENTS_SRC --> SETUP_SH
    SETUP_SH -->|"--claude"| CLAUDE_GEN
    SETUP_SH -->|"--sync"| SKILLS_LOCAL
    SETUP_SH -->|"--sync"| COMMANDS_LOCAL
    SETUP_SH -->|"--all"| SYNC_SH
    SYNC_SH -->|"genera tablas"| CLAUDE_SRC
    SYNC_SH -->|"genera tablas"| AGENTS_SRC
    CLAUDE_SRC --> REPLICATE

    style FUENTE fill:#2d2d2d,stroke:#D4956A,color:#F5EDE4
    style GENERADO fill:#1a1a1a,stroke:#666,color:#999,stroke-dasharray: 5 5
    style SKILLS_LOCAL fill:#2d2d2d,stroke:#8BB87A,color:#F5EDE4
    style COMMANDS_LOCAL fill:#2d2d2d,stroke:#7AAFC4,color:#F5EDE4
```

---

## Mix-of-Experts: Routing del Agente Principal (v5)

```mermaid
flowchart TD
    USER["Usuario escribe prompt"]
    GATE["Execution Gate<br/>VALIDATE → CLASSIFY → ROUTE → LOG"]
    ROUTER["CLAUDE.md (Router)<br/>~195 lineas: personalidad,<br/>reglas, routing table"]

    subgraph AGENTS["SCOPE AGENTS"]
        PIPELINE["pipeline-agent<br/>SDD Pipeline<br/>(9 skills)"]
        INFRA["infra-agent<br/>Infraestructura<br/>(3 skills)"]
        OBS["observability-agent<br/>O.R.T.A.<br/>(1 skill)"]
    end

    subgraph SKILLS["SKILLS (carga lazy)"]
        SDD["sdd-init...sdd-archive"]
        ECO["ecosystem-creator<br/>scope-rule<br/>skill-sync"]
        PROMPT["prompt-tracker"]
    end

    RESULT["Resultado al usuario"]

    USER --> ROUTER --> GATE
    GATE -->|"scope: pipeline"| PIPELINE
    GATE -->|"scope: infra"| INFRA
    GATE -->|"scope: observability"| OBS
    PIPELINE --> SDD
    INFRA --> ECO
    OBS --> PROMPT
    SDD --> RESULT
    ECO --> RESULT
    PROMPT --> RESULT

    style ROUTER fill:#D4956A,color:#fff
    style GATE fill:#E8B84D,color:#000
    style PIPELINE fill:#7AAFC4,color:#fff
    style INFRA fill:#8BB87A,color:#fff
    style OBS fill:#9B7AB8,color:#fff
```

> El agente principal es un **router puro**. No ejecuta trabajo pesado — clasifica el scope y delega al agente experto. Solo el resultado vuelve al usuario.

---

## Skill-Sync: Redundancia Automatica (v5)

```mermaid
flowchart LR
    subgraph FUENTE["FUENTES DE VERDAD"]
        SKILLS_MD["SKILL.md frontmatters<br/>(scope, auto_invoke,<br/>allowed-tools)"]
    end

    SYNC["sync.sh<br/>(lee → agrupa → genera)"]

    subgraph GENERADO["TABLAS AUTO-GENERADAS"]
        CLAUDE_TABLE["CLAUDE.md<br/>Available Skills<br/>(Skill | Scope | Auto-invoke)"]
        AGENT_TABLE["agents/*.md<br/>Skills per scope<br/>(Skill | Auto-invoke | Tools)"]
    end

    SKILLS_MD --> SYNC
    SYNC --> CLAUDE_TABLE
    SYNC --> AGENT_TABLE

    style FUENTE fill:#2d2d2d,stroke:#8BB87A,color:#F5EDE4
    style SYNC fill:#E8B84D,color:#000
    style GENERADO fill:#1a1a1a,stroke:#666,color:#999,stroke-dasharray: 5 5
```

> Agregar un skill nuevo = crear SKILL.md con frontmatter → correr sync.sh → tablas actualizadas automaticamente. Sin edicion manual.

---

## Flujo de Trabajo SDD (Spec-Driven Development)

```mermaid
flowchart LR
    subgraph USUARIO["TU (el humano)"]
        U_DECIDE["Decides que<br/>construir"]
        U_APRUEBA["Apruebas<br/>cada fase"]
    end

    subgraph ORQUESTADOR["AGENTE PRINCIPAL (orquestador)"]
        ORC["Coordina, no ejecuta<br/>Rastrea estado<br/>Pide aprobacion"]
    end

    subgraph PIPELINE["SUB-AGENTES SDD"]
        direction LR
        INIT["sdd-init<br/>Tipo de<br/>proyecto"]
        EXPLORE["sdd-explore<br/>Investigar<br/>opciones"]
        PROPOSE["sdd-propose<br/>Propuesta<br/>formal"]
        SPEC["sdd-spec<br/>Especificaciones<br/>tecnicas"]
        DESIGN["sdd-design<br/>Arquitectura<br/>y diseno"]
        TASKS["sdd-tasks<br/>Dividir<br/>en tareas"]
        APPLY["sdd-apply<br/>Escribir<br/>codigo"]
        VERIFY["sdd-verify<br/>Verificar<br/>calidad"]
        ARCHIVE["sdd-archive<br/>Archivar y<br/>documentar"]
    end

    U_DECIDE --> ORC
    ORC --> INIT --> EXPLORE --> PROPOSE
    PROPOSE --> SPEC
    PROPOSE --> DESIGN
    SPEC --> TASKS
    DESIGN --> TASKS
    TASKS --> APPLY --> VERIFY --> ARCHIVE
    ARCHIVE --> U_APRUEBA

    ORC -.->|"delega"| PIPELINE
    U_APRUEBA -.->|"entre cada fase"| ORC

    style USUARIO fill:#2d2d2d,stroke:#E8B84D,color:#F5EDE4
    style ORQUESTADOR fill:#2d2d2d,stroke:#D4956A,color:#F5EDE4
    style PIPELINE fill:#1a1a1a,stroke:#8BB87A,color:#F5EDE4
```

### Dependencias entre fases

```mermaid
graph LR
    P[propose] --> S[spec]
    P --> D[design]
    S --> T[tasks]
    D --> T
    T --> A[apply]
    A --> V[verify]
    V --> AR[archive]

    style S fill:#7AAFC4,color:#fff
    style D fill:#7AAFC4,color:#fff
```

> **spec** y **design** pueden ejecutarse en paralelo. Ambos deben completarse antes de **tasks**.

---

## Carga Lazy de Skills (3 niveles)

```mermaid
flowchart TD
    START["Claude inicia conversacion"]
    READ["Nivel 1: Lee CLAUDE.md<br/>(~195 lineas: personalidad,<br/>reglas, scope routing table)"]
    TASK["Usuario pide tarea"]
    GATE["Execution Gate<br/>clasifica scope"]
    LOAD_AGENT["Nivel 2: Carga scope-agent<br/>(~80-120 lineas:<br/>reglas del scope)"]
    LOAD_SKILL["Nivel 3: Carga SKILL.md<br/>(~200-500 lineas:<br/>patrones especificos)"]
    WORK["Ejecuta la tarea"]
    SIMPLE{"Pregunta simple?"}
    DIRECT["Responde directo<br/>(sin routing)"]

    START --> READ --> TASK --> SIMPLE
    SIMPLE -->|"Si"| DIRECT
    SIMPLE -->|"No"| GATE --> LOAD_AGENT --> LOAD_SKILL --> WORK

    style READ fill:#D4956A,color:#fff
    style LOAD_AGENT fill:#7AAFC4,color:#fff
    style LOAD_SKILL fill:#8BB87A,color:#fff
    style GATE fill:#E8B84D,color:#000
    style DIRECT fill:#666,color:#fff
```

> Claude lee ~195 lineas al iniciar (Nivel 1). El scope agent agrega ~100 lineas (Nivel 2). El skill agrega ~200-500 lineas (Nivel 3). Solo se carga lo que se necesita.

---

## Continuidad de Sesion

```mermaid
flowchart TD
    START["Claude inicia conversacion"]
    CHECK{"Existe<br/>.batuta/session.md?"}
    READ_SESSION["Lee session.md:<br/>estado SDD, decisiones,<br/>convenciones del proyecto"]
    NO_SESSION["Procede normalmente<br/>(proyecto nuevo)"]
    WORK["Trabaja en la tarea"]
    SIGNIFICANT{"Trabajo<br/>significativo?"}
    UPDATE["Actualiza .batuta/session.md<br/>con estado actual"]
    END_SESSION["Fin de sesion"]

    START --> CHECK
    CHECK -->|"Si"| READ_SESSION --> WORK
    CHECK -->|"No"| NO_SESSION --> WORK
    WORK --> SIGNIFICANT
    SIGNIFICANT -->|"Si (fase SDD,<br/>feature, bugfix)"| UPDATE --> END_SESSION
    SIGNIFICANT -->|"No (pregunta<br/>rapida)"| END_SESSION

    style READ_SESSION fill:#8BB87A,color:#fff
    style UPDATE fill:#7AAFC4,color:#fff
    style NO_SESSION fill:#666,color:#fff
```

> Cada conversacion empieza leyendo el contexto de la anterior. Al terminar trabajo significativo, actualiza el archivo para la proxima sesion.

---

## Tracking de Satisfaccion de Prompts (O.R.T.A.)

```mermaid
flowchart TD
    PROMPT["Usuario escribe un prompt"]
    LOG_P["Log: evento 'prompt'<br/>(silencioso, automatico)"]
    GATE["Execution Gate<br/>Log: evento 'gate'<br/>(scope, validacion, routing)"]
    WORK["Claude ejecuta la tarea"]
    RESULT{"Resultado OK?"}
    CORRECTION["Usuario corrige"]
    LOG_C["Log: evento 'correction'<br/>+ tipo (missing-req,<br/>wrong-approach, etc.)"]
    SATISFIED["Usuario: 'perfecto' / 'listo'"]
    LOG_CLOSED["Log: evento 'closed'<br/>+ metricas"]
    ANALYZE["/batuta:analyze-prompts"]
    REPORT["Genera reporte:<br/>metricas + patrones +<br/>gate compliance +<br/>recomendaciones"]

    PROMPT --> LOG_P --> GATE --> WORK --> RESULT
    RESULT -->|"No"| CORRECTION --> LOG_C --> WORK
    RESULT -->|"Si"| SATISFIED --> LOG_CLOSED
    LOG_CLOSED -.->|"acumula datos"| ANALYZE
    ANALYZE --> REPORT

    style LOG_P fill:#666,color:#fff
    style GATE fill:#E8B84D,color:#000
    style LOG_C fill:#E8B84D,color:#000
    style LOG_CLOSED fill:#8BB87A,color:#fff
    style REPORT fill:#D4956A,color:#fff
```

> El tracking es SILENCIOSO — Claude nunca pide "califica mi respuesta". El Execution Gate se ejecuta ANTES de cada cambio, validando y logeando la decision de routing. Despues, `/batuta:analyze-prompts` analiza todos los eventos y genera recomendaciones.

---

## Deteccion de Skills Faltantes

```mermaid
flowchart TD
    START["Usuario pide implementar<br/>algo con tecnologia X"]
    CHECK{"Existe un skill<br/>activo para X?"}
    LOAD["Cargar skill<br/>y continuar"]
    STOP["PARAR — Informar<br/>al usuario"]
    OPTIONS{"Usuario elige"}
    OPT1["Opcion 1:<br/>Investigar Context7<br/>+ crear skill proyecto"]
    OPT2["Opcion 2:<br/>Investigar Context7<br/>+ crear skill global"]
    OPT3["Opcion 3:<br/>Continuar sin skill<br/>+ agregar TODO"]
    CREATE["ecosystem-creator<br/>auto-discovery flow"]
    CONTINUE["Implementar<br/>con skill cargado"]

    START --> CHECK
    CHECK -->|"Si"| LOAD
    CHECK -->|"No"| STOP
    LOAD --> CONTINUE
    STOP --> OPTIONS
    OPTIONS -->|"1"| OPT1
    OPTIONS -->|"2"| OPT2
    OPTIONS -->|"3"| OPT3
    OPT1 --> CREATE
    OPT2 --> CREATE
    CREATE --> CONTINUE
    OPT3 --> CONTINUE

    style STOP fill:#D47272,color:#fff
    style CREATE fill:#8BB87A,color:#fff
    style CONTINUE fill:#7AAFC4,color:#fff
```

---

## Scope Rule (Regla de Alcance)

```mermaid
flowchart TD
    START["Crear un archivo nuevo"]
    Q{"Quien lo va a usar?"}
    F1["1 feature sola"]
    F2["2+ features"]
    FALL["Toda la app"]

    PATH1["features/{feature}/{tipo}/"]
    PATH2["features/shared/{tipo}/"]
    PATH3["core/{tipo}/"]

    NEVER["NUNCA crear:<br/>utils/, helpers/, lib/,<br/>components/ en la raiz"]

    START --> Q
    Q -->|"Solo inventario"| F1
    Q -->|"Checkout + carrito"| F2
    Q -->|"Auth, DB, logging"| FALL
    F1 --> PATH1
    F2 --> PATH2
    FALL --> PATH3

    PATH1 ~~~ NEVER
    PATH2 ~~~ NEVER
    PATH3 ~~~ NEVER

    style PATH1 fill:#8BB87A,color:#fff
    style PATH2 fill:#E8B84D,color:#000
    style PATH3 fill:#D4956A,color:#fff
    style NEVER fill:#D47272,color:#fff
```

---

## Auto-Update SPO (Propagacion de Skills)

```mermaid
flowchart TD
    PROJECT["Proyecto X crea<br/>un skill nuevo"]
    Q1{"Es reutilizable<br/>en otros proyectos?"}
    STAYS["Se queda solo<br/>en Proyecto X"]
    GENERALIZE["Generalizar:<br/>quitar referencias<br/>especificas del proyecto"]
    COPY["Copiar a<br/>batuta-dots/BatutaClaude/skills/"]
    REGISTER["Registrar en<br/>CLAUDE.md"]
    SYNC["Ejecutar<br/>setup.sh --all"]
    PUSH["Commit + push<br/>a batuta-dots"]
    BENEFIT["Todos los proyectos<br/>futuros se benefician"]

    PROJECT --> Q1
    Q1 -->|"No"| STAYS
    Q1 -->|"Si"| GENERALIZE
    GENERALIZE --> COPY --> REGISTER --> SYNC --> PUSH --> BENEFIT

    style PROJECT fill:#7AAFC4,color:#fff
    style BENEFIT fill:#8BB87A,color:#fff
    style STAYS fill:#666,color:#fff
```

---

## Flujo Completo: Desde Carpeta Vacia hasta App en Internet

```mermaid
flowchart TD
    EMPTY["Carpeta vacia"]
    INIT_CMD["/batuta-init mi-app"]
    BATUTA_DIR["Crea .batuta/<br/>(session.md + prompt-log.jsonl)"]
    SDD_INIT["/sdd:init"]
    SDD_EXPLORE["/sdd:explore"]
    GAP["Deteccion de gaps<br/>(crea skills si faltan)"]
    SDD_NEW["/sdd:new"]
    SDD_CONTINUE["/sdd:continue<br/>(spec + design + tasks)"]
    SDD_APPLY["/sdd:apply<br/>(escribe codigo)"]
    SDD_VERIFY["/sdd:verify"]
    TEST["Probar en localhost"]
    DEPLOY["Configurar Coolify"]
    PUSH["Push a GitHub"]
    LIVE["App en internet"]
    SDD_ARCHIVE["/sdd:archive"]
    UPDATE{"Skills nuevos<br/>creados?"}
    PROPAGATE["Propagar a<br/>batuta-dots"]

    EMPTY --> INIT_CMD --> BATUTA_DIR --> SDD_INIT --> SDD_EXPLORE --> GAP
    GAP --> SDD_NEW --> SDD_CONTINUE --> SDD_APPLY --> SDD_VERIFY
    SDD_VERIFY --> TEST --> DEPLOY --> PUSH --> LIVE
    LIVE --> SDD_ARCHIVE --> UPDATE
    UPDATE -->|"Si"| PROPAGATE
    UPDATE -->|"No"| FIN["Proyecto completo"]

    style EMPTY fill:#666,color:#fff
    style LIVE fill:#8BB87A,color:#fff
    style GAP fill:#E8B84D,color:#000
    style PROPAGATE fill:#D4956A,color:#fff
```

---

## Como ver estos diagramas

Estos diagramas usan **Mermaid**, un formato que se renderiza automaticamente en:
- **GitHub**: Abre este archivo en github.com y los diagramas se ven como imagenes
- **VS Code**: Instala la extension "Markdown Preview Mermaid Support"
- **Mermaid Live Editor**: Copia el codigo entre ```mermaid y ``` en [mermaid.live](https://mermaid.live)
