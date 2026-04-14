# Diagrama de Arquitectura — Ecosistema Batuta (v15)

## Vista General del Ecosistema

```mermaid
flowchart TB
    subgraph FUENTE["CLAUDE.md — 105 LINEAS, ORQUESTADOR PURO"]
        CLAUDE_SRC["BatutaClaude/CLAUDE.md<br/>Rules, Delegation, State,<br/>Notion, SDD modes, Commands"]
    end

    subgraph AGENTS_SRC["5 AGENTS (contract templates)"]
        AG_PIPELINE["pipeline-agent"]
        AG_BACKEND["backend-agent"]
        AG_DATA["data-agent"]
        AG_QUALITY["quality-agent"]
        AG_INFRA["infra-agent"]
    end

    subgraph SKILLS_SRC["43 SKILLS EN HUB"]
        SK_GLOBAL["13 globales<br/>(~/.claude/skills/)"]
        SK_PROJECT["30 per-project<br/>(.claude/skills/)"]
    end

    subgraph SETUP["SCRIPTS"]
        SETUP_SH["setup.sh<br/>--claude | --sync | --all | --hooks | --verify"]
        SYNC_BI["sync.sh / batuta-sync"]
    end

    subgraph GENERADO["ARCHIVOS GENERADOS (gitignored)"]
        CLAUDE_GEN["CLAUDE.md (raiz)<br/>(copia directa)"]
    end

    CLAUDE_SRC --> SETUP_SH
    AGENTS_SRC --> SETUP_SH
    SKILLS_SRC --> SETUP_SH
    SETUP_SH -->|"--claude"| CLAUDE_GEN
    SETUP_SH -->|"--sync"| SK_GLOBAL

    style FUENTE fill:#2d2d2d,stroke:#D4956A,color:#F5EDE4
    style GENERADO fill:#1a1a1a,stroke:#666,color:#999,stroke-dasharray: 5 5
    style SKILLS_SRC fill:#2d2d2d,stroke:#8BB87A,color:#F5EDE4
    style AGENTS_SRC fill:#2d2d2d,stroke:#9B7AB8,color:#F5EDE4
```

---

## Modelo de Delegacion: Main Agent = Gestor (v15)

El main agent NUNCA ejecuta. Para toda tarea, contrata un agente especializado via el skill `agent-hiring`.

```mermaid
flowchart TD
    USER["Usuario escribe prompt"]

    subgraph MAIN["MAIN AGENT (CLAUDE.md — 105 lineas)"]
        RULES["Research-First<br/>Self-Awareness<br/>Delegation por Contrato"]
        DETECT["Detecta necesidad:<br/>que expertise necesito?"]
    end

    CHECK{"Agente existe en<br/>.claude/agents/ o<br/>~/.claude/agents/?"}

    subgraph HIRE["AGENT-HIRING PROTOCOL"]
        PROPOSE["Propuesta de contratacion<br/>(USER STOP obligatorio)"]
        CREATE_AGENT["Crea archivo .md<br/>en .claude/agents/"]
    end

    subgraph AGENTS["5 AGENTS (contract templates)"]
        PIPELINE["pipeline-agent<br/>(SDD lifecycle)"]
        BACKEND["backend-agent<br/>(API, auth, DB)"]
        DATA["data-agent<br/>(ETL, RAG, LLM)"]
        QUALITY["quality-agent<br/>(tests, debug, security)"]
        INFRA["infra-agent<br/>(deploy, CI/CD, monitoring)"]
    end

    REPORT["Agente reporta:<br/>FINDINGS / FAILURES /<br/>DECISIONS / GOTCHAS"]

    USER --> MAIN --> DETECT --> CHECK
    CHECK -->|"Si"| AGENTS
    CHECK -->|"No"| HIRE --> PROPOSE -->|"aprobado"| CREATE_AGENT --> AGENTS
    AGENTS --> REPORT

    style MAIN fill:#D4956A,color:#fff
    style HIRE fill:#2d2d2d,stroke:#E8B84D,color:#F5EDE4
    style AGENTS fill:#2d2d2d,stroke:#9B7AB8,color:#F5EDE4
    style REPORT fill:#8BB87A,color:#fff
    style PROPOSE fill:#D47272,color:#fff
```

> El main agent no tiene skills cargados. Solo sabe a quien contratar. Skills pertenecen a los AGENTES. Los agentes reportan con formato estandar: FINDINGS, FAILURES, DECISIONS, GOTCHAS. Los agentes pueden correr en paralelo — 5 agentes investigando = minutos, no horas.

---

## SDD Pipeline: 2 Modos (v15)

```mermaid
flowchart LR
    subgraph SPRINT["SPRINT (default — 0 gates formales)"]
        direction LR
        S_RESEARCH["Research<br/>(obligatorio)"]
        S_APPLY["Apply<br/>(subagentes implementan)"]
        S_VERIFY["Verify"]
    end

    subgraph COMPLETO["COMPLETO (CTO lo pide via PRD — 1 gate)"]
        direction LR
        C_RESEARCH["Research<br/>(obligatorio)"]
        C_EXPLORE["Explore<br/>(subagentes en paralelo)"]
        C_DESIGN["Design"]
        C_GATE{{"USER STOP<br/>Design Approval"}}
        C_APPLY["Apply"]
        C_VERIFY["Verify"]
    end

    S_RESEARCH --> S_APPLY --> S_VERIFY
    C_RESEARCH --> C_EXPLORE --> C_DESIGN --> C_GATE --> C_APPLY --> C_VERIFY

    style SPRINT fill:#2d2d2d,stroke:#8BB87A,color:#F5EDE4
    style COMPLETO fill:#2d2d2d,stroke:#7AAFC4,color:#F5EDE4
    style C_GATE fill:#D47272,color:#fff
    style S_RESEARCH fill:#E8B84D,color:#000
    style C_RESEARCH fill:#E8B84D,color:#000
```

> **Research-First es NO NEGOCIABLE en ambos modos**. SPRINT no tiene gates formales — research → apply → verify. COMPLETO tiene 1 gate en Design Approval. PRD es el artefacto unico de planificacion — el CTO lo escribe en Notion, Claude Code lo lee via MCP.

### PRD como Artefacto Unico

```mermaid
flowchart TD
    subgraph CTO["CAPA CTO — Notion"]
        PRD["PRD<br/>(Product Requirements Doc)<br/>unico artefacto de planificacion"]
    end

    subgraph BRIDGE["PUENTE"]
        MCP["Notion MCP<br/>(busqueda semantica<br/>por nombre, nunca IDs)"]
    end

    subgraph CODE["CAPA CODE — Claude Code"]
        READ_PRD["Lee PRD via MCP"]
        EXECUTE["Ejecuta segun modo:<br/>SPRINT o COMPLETO"]
    end

    PRD -->|"escrito en Notion"| MCP
    MCP -->|"leido via MCP"| READ_PRD --> EXECUTE

    style CTO fill:#2d2d2d,stroke:#D4956A,color:#F5EDE4
    style BRIDGE fill:#E8B84D,color:#000
    style CODE fill:#2d2d2d,stroke:#7AAFC4,color:#F5EDE4
    style PRD fill:#D4956A,color:#fff
```

> El PRD reemplaza la cadena de 5 artefactos (explore → propose → spec → design → tasks). Un solo documento con todo lo necesario para ejecutar.

---

## Skills: Pertenecen a los Agentes, No al Main Agent (v15)

```mermaid
flowchart TD
    subgraph HUB["batuta-dots HUB (43 skills)"]
        ALL_SKILLS["43 skills totales"]
    end

    subgraph GLOBAL["~/.claude/skills/ (13 globales)"]
        G_SCOPE["scope-rule"]
        G_ECO["ecosystem-creator<br/>ecosystem-lifecycle"]
        G_HIRING["agent-hiring"]
        G_SDD["sdd-init, sdd-explore<br/>sdd-apply, sdd-verify<br/>sdd-design"]
        G_OTHER["team-orchestrator<br/>security-audit<br/>skill-eval, prd-generator"]
    end

    subgraph PROJECT[".claude/skills/ (per-project, provisionados)"]
        P_TECH["Skills segun tech stack<br/>(fastapi-crud, react-nextjs,<br/>sqlalchemy-models, etc.)"]
    end

    subgraph AGENTS["AGENTES CARGAN SUS SKILLS"]
        A_PIPELINE["pipeline-agent<br/>→ sdd-*, prd-generator"]
        A_BACKEND["backend-agent<br/>→ fastapi-crud, jwt-auth"]
        A_DATA["data-agent<br/>→ data-pipeline, llm-pipeline"]
        A_QUALITY["quality-agent<br/>→ tdd-workflow, e2e-testing"]
        A_INFRA["infra-agent<br/>→ coolify-deploy, ci-cd"]
    end

    HUB -->|"setup.sh --sync"| GLOBAL
    HUB -->|"/batuta-init<br/>(tech detection)"| PROJECT
    GLOBAL --> AGENTS
    PROJECT --> AGENTS

    style HUB fill:#2d2d2d,stroke:#D4956A,color:#F5EDE4
    style GLOBAL fill:#2d2d2d,stroke:#8BB87A,color:#F5EDE4
    style PROJECT fill:#2d2d2d,stroke:#7AAFC4,color:#F5EDE4
    style AGENTS fill:#2d2d2d,stroke:#9B7AB8,color:#F5EDE4
```

> El main agent NO carga skills. Claude Code carga solo descripciones de 1 linea (~450 tokens) al inicio. El contenido completo carga solo cuando un agente contratado lo necesita. Skills del hub: 13 globales + 30 per-project = 43 total.

---

## State: session.md como Fuente Unica de Verdad (v15)

```mermaid
flowchart TD
    START["Claude inicia sesion<br/>(SessionStart hook)"]
    CHECK_SESSION{"Existe<br/>.batuta/session.md?"}
    CHECK_CP{"Existe<br/>.batuta/CHECKPOINT.md?"}
    READ_SESSION["Lee session.md:<br/>WHERE / WHY / HOW<br/>80 lineas max"]
    READ_CP["Inyecta CHECKPOINT.md:<br/>paso N de M, intentos,<br/>gotchas con evidencia"]
    NOTION["Notion MCP:<br/>busca proyecto por nombre<br/>→ inyecta contexto"]
    NO_SESSION["Proyecto nuevo"]

    subgraph WORK["DURANTE LA SESION"]
        UPDATE["session.md se actualiza<br/>en CADA INTERACCION"]
        MUST["MUST: CHECKPOINT.md<br/>antes de 3+ tool calls"]
    end

    subgraph STOP["STOP HOOK"]
        S1["CHECKPOINT.md<br/>(archiva ultimas 10)"]
        S2["session-log.jsonl<br/>(append)"]
        S3["Notion KB<br/>(gotchas, decisions)"]
    end

    START --> CHECK_SESSION
    CHECK_SESSION -->|"Si"| READ_SESSION --> CHECK_CP
    CHECK_SESSION -->|"No"| NOTION --> NO_SESSION
    CHECK_CP -->|"Si"| READ_CP --> WORK
    CHECK_CP -->|"No"| WORK
    WORK --> STOP
    S1 --> S2 --> S3

    style READ_SESSION fill:#8BB87A,color:#fff
    style READ_CP fill:#9B7AB8,color:#fff
    style UPDATE fill:#7AAFC4,color:#fff
    style MUST fill:#D47272,color:#fff
    style NOTION fill:#E8B84D,color:#000
    style NO_SESSION fill:#666,color:#fff
```

**Capas de persistencia (v15)**:

| Capa | Archivo | Proposito | Escrito | Leido |
|------|---------|-----------|---------|-------|
| Global | `MEMORY.md` | Preferencias usuario | Usuario/agente | Todos los proyectos |
| Sesion | `.batuta/session.md` | Fuente unica de verdad (WHERE/WHY/HOW) | Cada interaccion | SessionStart, CTO |
| Anti-compaction | `.batuta/CHECKPOINT.md` | Estado operacional (paso N de M) | MUST rule + Stop | SessionStart (auto) |
| Largo plazo | Notion KB | Gotchas, decisions, discoveries | Stop (auto, si MCP) | Research-First chain |

> session.md se actualiza en CADA interaccion, no solo al cerrar. Es la fuente unica de verdad. CHECKPOINT.md es el seguro anti-compaction — captura lo que session.md no puede (intentos fallidos, evidencia de decisiones).

---

## Research-First Chain (v15)

```mermaid
flowchart LR
    TASK["Tarea nueva"]
    R1["1. Notion KB via MCP<br/>(ya resolvimos esto?)"]
    R2["2. Skill relevante<br/>(leerlo, verificar vigencia)"]
    R3["3. WebFetch docs oficiales<br/>(framework changes)"]
    R4["4. WebSearch<br/>(como otros lo resolvieron)"]
    EXECUTE["Implementar con<br/>conocimiento verificado"]

    TASK --> R1 --> R2 --> R3 --> R4 --> EXECUTE

    style R1 fill:#7AAFC4,color:#fff
    style R2 fill:#8BB87A,color:#fff
    style R3 fill:#E8B84D,color:#000
    style R4 fill:#D4956A,color:#fff
    style EXECUTE fill:#8BB87A,color:#fff
```

> Research se hace con subagentes en paralelo. 5 subagentes investigando = minutos. Training data puede estar desactualizado — verificar SIEMPRE. Si no hay skill → buscar en web → considerar crear skill si el patron es reutilizable.

---

## Notion MCP: Puente CTO ↔ Code (v15)

```mermaid
flowchart TD
    subgraph CTO_DESKTOP["CTO DESKTOP (Notion)"]
        PROJ["Proyectos DB"]
        KB["Knowledge Base"]
        PRD_N["PRDs / Directivas"]
    end

    subgraph MCP_BRIDGE["NOTION MCP (busqueda semantica)"]
        SEARCH["Busca por NOMBRE<br/>(nunca hardcodear IDs)"]
    end

    subgraph CODE_LAYER["CLAUDE CODE"]
        INTERACTION0["Interaction 0:<br/>busca proyecto por nombre<br/>del directorio de trabajo"]
        READ_PRD_N["Lee PRD/directiva activa<br/>en paginas hijas"]
        WRITE_KB["Escribe gotchas,<br/>decisions a KB"]
    end

    PROJ --> SEARCH
    KB --> SEARCH
    PRD_N --> SEARCH
    SEARCH --> INTERACTION0
    SEARCH --> READ_PRD_N
    CODE_LAYER -->|"Stop hook"| WRITE_KB --> KB

    style CTO_DESKTOP fill:#2d2d2d,stroke:#D4956A,color:#F5EDE4
    style MCP_BRIDGE fill:#E8B84D,color:#000
    style CODE_LAYER fill:#2d2d2d,stroke:#7AAFC4,color:#F5EDE4
    style SEARCH fill:#E8B84D,color:#000
```

> NUNCA hardcodear database IDs, page IDs, o data_source_ids. Los IDs cambian — los nombres persisten. Si Notion MCP no disponible, continuar sin bloquear.

---

## Flujo Completo: Desde Prompt hasta Resultado (v15)

```mermaid
flowchart TD
    USER["Usuario describe tarea"]

    subgraph MAIN["MAIN AGENT (gestor)"]
        RESEARCH["Research-First chain<br/>(Notion → skill → web)"]
        CLASSIFY{"Modo SDD?"}
    end

    subgraph SPRINT_FLOW["SPRINT (default)"]
        S_HIRE["Contrata agente(s)<br/>via agent-hiring"]
        S_APPLY_F["Agentes implementan<br/>con skills verificados"]
        S_VERIFY_F["Agente quality verifica"]
    end

    subgraph COMPLETO_FLOW["COMPLETO (CTO via PRD)"]
        C_PRD["Lee PRD de Notion"]
        C_EXPLORE_F["Agentes exploran<br/>en paralelo"]
        C_DESIGN_F["Agente pipeline<br/>produce Design"]
        C_GATE_F{{"USER STOP"}}
        C_APPLY_F["Agentes implementan"]
        C_VERIFY_F["Verificacion"]
    end

    RESULT["Resultado + session.md<br/>actualizado"]

    USER --> MAIN --> RESEARCH --> CLASSIFY
    CLASSIFY -->|"sin PRD"| SPRINT_FLOW --> RESULT
    CLASSIFY -->|"con PRD"| COMPLETO_FLOW --> RESULT

    S_HIRE --> S_APPLY_F --> S_VERIFY_F
    C_PRD --> C_EXPLORE_F --> C_DESIGN_F --> C_GATE_F --> C_APPLY_F --> C_VERIFY_F

    style MAIN fill:#D4956A,color:#fff
    style SPRINT_FLOW fill:#2d2d2d,stroke:#8BB87A,color:#F5EDE4
    style COMPLETO_FLOW fill:#2d2d2d,stroke:#7AAFC4,color:#F5EDE4
    style C_GATE_F fill:#D47272,color:#fff
    style RESEARCH fill:#E8B84D,color:#000
```

---

## Hooks: Enforcement Deterministico (v15)

```mermaid
flowchart TD
    subgraph HOOKS["CLAUDE CODE HOOKS"]
        SS["SessionStart<br/>(command)"]
        STOP_H["Stop<br/>(prompt)"]
        SUB_STOP["SubagentStop<br/>(prompt)"]
    end

    subgraph SS_ACTIONS["SessionStart — lee + inyecta"]
        READ_SKILLS["Inventario de skills<br/>(descripciones 1 linea)"]
        READ_SESSION_H["session.md<br/>(WHERE/WHY/HOW)"]
        READ_CP_H["CHECKPOINT.md<br/>(si existe)"]
    end

    subgraph STOP_ACTIONS["Stop — archiva + persiste"]
        STEP1["CHECKPOINT.md<br/>(archiva last 10)"]
        STEP2["session-log.jsonl<br/>(append)"]
        STEP3["Notion KB<br/>(gotchas si MCP)"]
    end

    subgraph SUB_ACTIONS["SubagentStop — reporta"]
        TEAM_HIST["team-history.md<br/>(append sub-agent report)"]
    end

    SS --> SS_ACTIONS
    STOP_H --> STOP_ACTIONS
    SUB_STOP --> SUB_ACTIONS

    style HOOKS fill:#2d2d2d,stroke:#E8B84D,color:#F5EDE4
    style SS fill:#8BB87A,color:#fff
    style STOP_H fill:#D47272,color:#fff
    style SUB_STOP fill:#9B7AB8,color:#fff
    style STEP1 fill:#9B7AB8,color:#fff
    style STEP2 fill:#7AAFC4,color:#fff
```

> Hooks ejecutan deterministicamente — no dependen de que Claude "recuerde". SessionStart inyecta contexto. Stop archiva y persiste. SubagentStop captura reportes de agentes contratados en team-history.md.

---

## Scope Rule

```mermaid
flowchart TD
    START["Crear archivo nuevo"]
    Q{"Quien lo usa?"}
    F1["1 feature"]
    F2["2+ features"]
    FALL["Toda la app"]

    PATH1["features/{feature}/{tipo}/"]
    PATH2["features/shared/{tipo}/"]
    PATH3["core/{tipo}/"]

    NEVER["NUNCA crear:<br/>utils/, helpers/, lib/,<br/>components/ en la raiz"]

    START --> Q
    Q -->|"Solo una"| F1
    Q -->|"Varias"| F2
    Q -->|"Todo"| FALL
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

## Skill Sync: Hub → Proyectos (v15)

```mermaid
flowchart TD
    subgraph HUB_SYNC["batuta-dots HUB (43 skills, 5 agents)"]
        BC["BatutaClaude/<br/>skills/ + agents/"]
    end

    subgraph GLOBAL_SYNC["~/.claude/skills/ (13 globales)"]
        G_SK["Skills universales"]
    end

    subgraph PROJECT_SYNC["Proyecto (.claude/)"]
        P_SKILLS[".claude/skills/<br/>(provisionados por tech)"]
        P_AGENTS[".claude/agents/<br/>(contratados bajo demanda)"]
        P_SESSION[".batuta/session.md"]
    end

    BC -->|"setup.sh --sync"| G_SK
    BC -->|"/batuta-init"| P_SKILLS
    BC -->|"agent-hiring"| P_AGENTS

    P_SKILLS -->|"/batuta-sync<br/>opcion 2: subir al hub"| BC

    style HUB_SYNC fill:#2d2d2d,stroke:#D4956A,color:#F5EDE4
    style GLOBAL_SYNC fill:#2d2d2d,stroke:#8BB87A,color:#F5EDE4
    style PROJECT_SYNC fill:#2d2d2d,stroke:#7AAFC4,color:#F5EDE4
```

> `/batuta-sync` maneja el flujo bidireccional: opcion 2 = subir al hub, opcion 3 = traer del hub. Skills se provisionan con `/batuta-init` (tech detection). Agents se crean bajo demanda via `agent-hiring`.

---

## AI Validation Pyramid

```mermaid
flowchart BT
    subgraph PYRAMID["PIRAMIDE DE VALIDACION"]
        direction BT
        L1["Layer 1: Lint / Type Check<br/>(automatico, agente)"]
        L2["Layer 2: Unit Tests<br/>(automatico, agente)"]
        L3["Layer 3: E2E / Integration<br/>(automatico, agente)"]
        L4["Layer 4: Code Review<br/>(humano o agente senior)"]
        L5["Layer 5: Manual Testing<br/>(humano obligatorio)"]
    end

    L1 --> L2 --> L3 --> L4 --> L5

    style L1 fill:#8BB87A,color:#fff
    style L2 fill:#8BB87A,color:#fff
    style L3 fill:#7AAFC4,color:#fff
    style L4 fill:#E8B84D,color:#000
    style L5 fill:#D4956A,color:#fff
```

> Layers 1-3: agente (automatico). Layers 4-5: humano (obligatorio). No existe validacion 100% automatica.

---

## Folder Structure (v15)

```mermaid
flowchart TD
    subgraph ROOT["batuta-dots/"]
        CLAUDE_DIR["BatutaClaude/<br/>CLAUDE.md (105 lineas), VERSION,<br/>settings.json, agents/ (5), skills/ (43),<br/>commands/ (12)"]
        INFRA_DIR["infra/<br/>setup.sh, sync.sh, hooks/"]
        DOCS["docs/<br/>architecture/, guides/, qa/"]
        TEAMS["teams/<br/>templates/, playbook.md"]
    end

    subgraph CLAUDE_DETAIL["BatutaClaude/ detalle"]
        CLAUDE_MD_D["CLAUDE.md<br/>(orquestador puro, 105 lineas)"]
        AGENTS_D["agents/ (5):<br/>pipeline, backend, data,<br/>quality, infra"]
        SKILLS_D["skills/ (43):<br/>13 globales + 30 per-project"]
        COMMANDS_D["commands/ (12):<br/>sdd-*, batuta-*, create, skill-eval"]
    end

    CLAUDE_DIR --> CLAUDE_DETAIL

    style ROOT fill:#2d2d2d,stroke:#D4956A,color:#F5EDE4
    style CLAUDE_DETAIL fill:#2d2d2d,stroke:#7AAFC4,color:#F5EDE4
    style TEAMS fill:#E8B84D,color:#000
```

---

## Modelo de Agentes (v15)

| Agente | Rol | Skills que carga | Cuando se activa |
|--------|-----|-----------------|-----------------|
| `pipeline-agent` | SDD lifecycle | sdd-*, prd-generator | Build / Continue |
| `backend-agent` | API, auth, DB | fastapi-crud, jwt-auth, sqlalchemy-models | Senales: API, auth, ORM |
| `data-agent` | ETL, RAG, LLM | data-pipeline, llm-pipeline, vector-db-rag | Senales: datos, ETL, AI |
| `quality-agent` | Tests, debug, security | tdd-workflow, e2e-testing, security-audit | Siempre disponible |
| `infra-agent` | Deploy, CI/CD, monitoring | coolify-deploy, ci-cd-pipeline, observability | Senales: deploy, infra |

> 5 agentes como contract templates. El main agent los contrata via `agent-hiring`. Cada agente es un archivo `.md` — contrato permanente que persiste entre proyectos. Los agentes pueden correr en paralelo.

---

## Resumen de Cambios v14 → v15

| Aspecto | v14 | v15 |
|---------|-----|-----|
| CLAUDE.md | ~331 lineas (personalidad, filosofia, routing) | 105 lineas (orquestador puro: rules, delegation, state) |
| SDD Pipeline | 9 fases, 8 gates | 2 modos: SPRINT (0 gates) y COMPLETO (1 gate en Design) |
| Artefactos de planificacion | 5 (explore, propose, spec, design, tasks) | 1 (PRD) |
| Main agent | Router MoE que ejecuta via routing | Gestor que NUNCA ejecuta — contrata agentes |
| Skills | Pertenecen al main agent | Pertenecen a los AGENTES |
| Agents | 6 (3 scope + 3 domain) | 5 contract templates (pipeline, backend, data, quality, infra) |
| session.md | Escrito al cerrar sesion | Actualizado en CADA interaccion |
| Notion | IDs hardcodeados | Busqueda semantica por nombre, nunca IDs |
| Research | Gate opcional en explore | NO NEGOCIABLE en todos los modos |
| Hub skills | 38 | 43 (13 globales + 30 per-project) |

---

## Como ver estos diagramas

Estos diagramas usan **Mermaid**, un formato que se renderiza automaticamente en:
- **GitHub**: Abre este archivo en github.com y los diagramas se ven como imagenes
- **VS Code**: Instala la extension "Markdown Preview Mermaid Support"
- **Mermaid Live Editor**: Copia el codigo entre ```mermaid y ``` en [mermaid.live](https://mermaid.live)
