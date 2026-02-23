# Team Template: AI Agent

> **Patron**: C (Investigation) — cada teammate investiga una dimension del agente.
> **Stack**: LangChain, Google ADK, framework custom, o cualquier sistema con tools + memory.
> **Nivel recomendado**: 3 (Agent Team) cuando hay prompt engineering + security review simultaneos.

---

## Cuando Usar

- Agente conversacional que necesita tools (acciones), memory (contexto persistente), y chains (flujos de razonamiento).
- El system prompt requiere iteracion seria — no es "escribir un string", es el artefacto mas critico del proyecto.
- Se necesita revision de seguridad dedicada: prompt injection, manejo de PII, control de costos.
- Frameworks soportados: LangChain, Google ADK, CrewAI, o implementacion custom sobre APIs de LLM.

### Cuando NO Usar

- Agente simple sin tools (un chatbot basico) — usa solo session.
- Solo necesitas ajustar un prompt existente — usa subagent.
- No hay requisitos de seguridad especiales — evalua si un equipo completo es necesario.

---

## Composicion

| Teammate | Scope Agent | Responsabilidad | Archivos Propios |
|----------|-------------|-----------------|------------------|
| `agent-dev` | pipeline-agent | Logica del agente, tools, chains, memory | `src/agent/**`, `src/tools/**`, `src/chains/**` |
| `prompt-engineer` | pipeline-agent | System prompts, few-shot examples, evaluacion | `prompts/**`, `evaluations/**` |
| `security-reviewer` | infra-agent | Defensa contra prompt injection, manejo de PII, control de costos | `security/**` (solo reportes, no modifica codigo) |

**Lead owns**: `main.py` / `index.ts`, archivos de configuracion, `README.md`, integracion final.

---

## Contratos

### Input Contracts

| Teammate | Recibe | Formato | De quien |
|----------|--------|---------|----------|
| `agent-dev` | Requisitos funcionales + definiciones de tools + comportamiento deseado | Markdown (spec SDD o brief) | Lead |
| `prompt-engineer` | Especificacion de comportamiento del agente + conversaciones de ejemplo | Markdown + JSONL (ejemplos) | Lead |
| `security-reviewer` | Todo el codigo + todos los prompts para revision | Acceso lectura a `src/**` + `prompts/**` | Lead (post-implementacion) |

### Output Contracts

| Teammate | Produce | Formato | Criterio de exito |
|----------|---------|---------|-------------------|
| `agent-dev` | Agente funcional con tools y memory | Codigo ejecutable en `src/` | Agente responde correctamente a 5 casos de prueba basicos |
| `prompt-engineer` | Prompts optimizados + resultados de evaluacion | Markdown en `prompts/` + metricas en `evaluations/` | Score de evaluacion >= umbral definido |
| `security-reviewer` | Reporte de auditoria de seguridad | Markdown en `security/audit-report.md` | Cero vulnerabilidades criticas; hallazgos medios documentados |

---

## File Ownership Map

```
agent-dev OWNS:
  src/agent/**
  src/tools/**
  src/chains/**

prompt-engineer OWNS:
  prompts/**
  evaluations/**

security-reviewer OWNS:
  security/**  (solo reportes — NO modifica codigo de otros teammates)

Lead OWNS:
  main.py / index.ts
  config files (pyproject.toml, package.json, .env.example)
  README.md
  docker-compose.yml (si aplica)
```

> Si `agent-dev` necesita leer prompts de `prompts/`, lo hace en modo lectura. Solo `prompt-engineer` puede modificar esos archivos.

---

## Cross-Review

| Reviewer | Revisa | Pregunta clave |
|----------|--------|----------------|
| `prompt-engineer` | Definiciones de tools de `agent-dev` | "Las descripciones de tools son claras para que el LLM las use correctamente?" |
| `security-reviewer` | TODOS los prompts y TODAS las implementaciones de tools | "Hay vectores de prompt injection? Se expone PII? Los costos estan controlados?" |
| `agent-dev` | Criterios de evaluacion de `prompt-engineer` | "Los criterios reflejan el comportamiento real esperado del agente?" |

---

## Flujo de Ejecucion

```
1. Lead define contratos y presenta plan al usuario
2. agent-dev + prompt-engineer trabajan en PARALELO
   - agent-dev: implementa tools, chains, memory
   - prompt-engineer: disenya system prompt + few-shot examples
3. Integracion: Lead conecta prompts con agente
4. security-reviewer: revisa TODO (codigo + prompts)
5. Cross-review entre los tres teammates
6. Lead consolida hallazgos y presenta resultado
```

---

## Lecciones Aprendidas

- **El system prompt es el artefacto mas critico** — hay que iterar temprano y con frecuencia. No dejarlo para el final.
- **Las descripciones de tools determinan el 80% de la calidad del agente** — si el LLM no entiende que hace un tool, no lo usara bien.
- **Siempre configurar `max_tokens` y limites de costo ANTES de probar** — un loop infinito de agente puede quemar presupuesto en minutos.
- **Probar con inputs adversariales** (intentos de prompt injection) desde el dia uno, no como afterthought.
- **Memory strategy importa** — decidir temprano entre conversation history, vector DB, o ninguno. Cambiar despues es costoso.
- **Evaluation-driven development** — definir como medir calidad ANTES de optimizar prompts. Sin metricas, es iteracion ciega.

---

## Checklist Pre-Spawn

Antes de crear el equipo, el Lead verifica:

- [ ] Framework de agente decidido (LangChain, ADK, custom)
- [ ] Tools definidos (que acciones puede ejecutar el agente?)
- [ ] Estrategia de memory decidida (conversation history, vector DB, ninguno)
- [ ] Criterios de evaluacion definidos (como medimos calidad?)
- [ ] Presupuesto de costos establecido (max tokens por request, por dia)
- [ ] Modelo de LLM seleccionado (Claude, GPT-4, Gemini — afecta diseyo de prompts)
- [ ] Casos de prueba basicos escritos (minimo 5 conversaciones esperadas)
