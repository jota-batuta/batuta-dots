# Diagrama de Arquitectura — Ecosistema Batuta

## Vista General del Ecosistema

```mermaid
flowchart TB
    subgraph FUENTE["FUENTE UNICA DE VERDAD"]
        AGENTS["AGENTS.md<br/>Skills, SDD, Scope Rule,<br/>Gap Detection, Auto-Update SPO"]
    end

    subgraph PERSONALIDAD["PERSONALIDAD"]
        CLAUDE_SRC["BatutaClaude/CLAUDE.md<br/>CTO/Mentor, reglas, tono,<br/>gap detection, scope rule"]
    end

    subgraph SETUP["SCRIPTS"]
        SETUP_SH["setup.sh<br/>--claude | --sync | --all | --verify"]
        REPLICATE["replicate-platform.sh<br/>--gemini | --copilot | --codex<br/>(futuro)"]
    end

    subgraph GENERADO["ARCHIVOS GENERADOS (gitignored)"]
        CLAUDE_GEN["CLAUDE.md<br/>(personalidad + AGENTS.md)"]
    end

    subgraph SKILLS_LOCAL["~/.claude/skills/ (usuario)"]
        SK_ECO["ecosystem-creator"]
        SK_SCOPE["scope-rule"]
        SK_SDD["sdd-init...sdd-archive<br/>(9 sub-agentes)"]
        SK_PROJECT["skills de proyecto<br/>(creados bajo demanda)"]
    end

    subgraph COMMANDS_LOCAL["~/.claude/commands/ (usuario)"]
        CMD_INIT["/batuta-init"]
        CMD_UPDATE["/batuta-update"]
    end

    AGENTS --> SETUP_SH
    CLAUDE_SRC --> SETUP_SH
    SETUP_SH -->|"--claude"| CLAUDE_GEN
    SETUP_SH -->|"--sync"| SKILLS_LOCAL
    SETUP_SH -->|"--sync"| COMMANDS_LOCAL
    AGENTS --> REPLICATE

    style FUENTE fill:#2d2d2d,stroke:#D4956A,color:#F5EDE4
    style PERSONALIDAD fill:#2d2d2d,stroke:#C4A882,color:#F5EDE4
    style GENERADO fill:#1a1a1a,stroke:#666,color:#999,stroke-dasharray: 5 5
    style SKILLS_LOCAL fill:#2d2d2d,stroke:#8BB87A,color:#F5EDE4
    style COMMANDS_LOCAL fill:#2d2d2d,stroke:#7AAFC4,color:#F5EDE4
```

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
    REGISTER["Registrar en<br/>AGENTS.md + CLAUDE.md"]
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

    EMPTY --> INIT_CMD --> SDD_INIT --> SDD_EXPLORE --> GAP
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
- **Mermaid Live Editor**: Copia el codigo entre \`\`\`mermaid y \`\`\` en [mermaid.live](https://mermaid.live)
