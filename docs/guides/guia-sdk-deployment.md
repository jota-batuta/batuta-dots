# Guia: Desplegar Agentes Batuta con el Claude Agent SDK

> **Para quien es esta guia**: Para desarrolladores que ya usan Claude Code con
> batuta-dots y quieren ejecutar agentes en pipelines CI/CD, workers en background,
> o asistentes embebidos en productos. Se asume familiaridad con Python o TypeScript
> y con la estructura de batuta-dots.
>
> **Formato**: Cada seccion es independiente. Puedes saltar a la que necesites,
> pero si es tu primera vez, lee las secciones 1-3 en orden.

---

## Glosario

| Palabra | Que significa |
|---------|---------------|
| **Agent SDK** | Libreria oficial de Anthropic para ejecutar agentes Claude desde codigo (Python o TypeScript). A diferencia del CLI de Claude Code (interactivo), el SDK permite ejecucion headless: sin terminal, sin usuario presente. |
| **setting_sources** | Parametro del SDK que indica de donde cargar la configuracion. Con `["project"]`, el SDK carga `.claude/skills/`, `CLAUDE.md`, y `.claude/commands/` -- las mismas fuentes que Claude Code usa en una sesion interactiva. |
| **defer_loading** | Modo de carga diferida de herramientas. En vez de cargar todas las herramientas (MCP servers) al inicio, el agente las descubre bajo demanda con Tool Search. Reduce el uso de tokens en ~85%. |
| **Headless** | Ejecucion sin interfaz visual ni usuario interactivo. El agente corre solo en un servidor, contenedor Docker, o GitHub Actions. |
| **Frontmatter** | Metadata YAML al inicio de un archivo Markdown, entre delimitadores `---`. Los agentes batuta lo usan para definir modelo, herramientas, y configuracion SDK. |
| **Bloque sdk:** | Seccion en el frontmatter de los archivos de agentes (`BatutaClaude/agents/*.md`) que define parametros especificos para despliegue via Agent SDK. |
| **allowed_tools** | Lista de herramientas que el agente puede usar. Principio de minimo privilegio: cada agente recibe solo lo que necesita. |

---

## 1. Que es el Agent SDK y cuando usarlo

El **Claude Agent SDK** es la libreria oficial de Anthropic para ejecutar agentes Claude
desde aplicaciones, scripts, y pipelines -- fuera de la terminal interactiva de Claude Code.

### Cuando usar cada herramienta

| Escenario | Herramienta | Por que |
|-----------|-------------|---------|
| Sesion interactiva de desarrollo | Claude Code CLI | Integracion con IDE, hooks nativos, retroalimentacion en tiempo real |
| Review automatico de PRs en CI/CD | Agent SDK | Headless, repetible, corre en GitHub Actions |
| Procesamiento de datos en background | Agent SDK | Larga duracion, sin interaccion de usuario |
| Asistente embebido en un producto | Agent SDK | UX personalizada, acceso via API |
| Tarea simple de una sola vez | Claude Code CLI | Mas simple, sin setup adicional |
| Script sin uso de herramientas | Anthropic Client SDK (Messages API) | El Agent SDK agrega overhead; para completions simples usa la API directa |

**Regla clave**: Si tu agente necesita usar herramientas (leer archivos, ejecutar comandos, buscar
en codigo), usa el Agent SDK. Si solo necesitas generar texto, usa la Messages API directamente.

---

## 2. Instalacion

### Python

```bash
pip install claude-agent-sdk
```

Requisitos: Python 3.10+. La libreria es async-native, asi que usaras `asyncio`.

### TypeScript

```bash
npm install @anthropic-ai/claude-agent-sdk
```

Requisitos: Node.js 18+. La libreria expone un `AsyncIterable` para consumir respuestas.

### Variable de entorno

Ambas librerias requieren `ANTHROPIC_API_KEY`:

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

En CI/CD, configura esto como un secret (por ejemplo, `${{ secrets.ANTHROPIC_API_KEY }}`
en GitHub Actions).

---

## 3. Configuracion del proyecto

Para que un agente SDK se comporte igual que en Claude Code, el proyecto necesita
la misma estructura de configuracion que batuta-dots provisiona.

### Archivos que el SDK lee con `setting_sources=["project"]`

```
mi-proyecto/
├── .claude/
│   ├── skills/           # Skills provisionados por /sdd-init
│   │   ├── security-audit/SKILL.md
│   │   ├── api-design/SKILL.md
│   │   └── ...
│   ├── commands/         # Comandos slash personalizados (opcional)
│   └── CLAUDE.md         # Overrides de proyecto (capa 2)
├── CLAUDE.md             # Reglas del hub batuta-dots (capa 1)
├── .mcp.json             # Servidores MCP del proyecto
└── ...
```

### Como preparar un proyecto existente

Si el proyecto ya tiene batuta-dots configurado (tiene `.batuta/` y `.claude/`),
el SDK lo detecta automaticamente con `setting_sources=["project"]`. No necesitas
hacer nada mas.

Si el proyecto es nuevo:

1. Ejecuta `/sdd-init` en Claude Code para provisionar skills y crear la estructura
2. Verifica que `.claude/skills/` tiene los skills necesarios
3. Verifica que `CLAUDE.md` existe en la raiz del proyecto

### Archivos de agentes con bloque sdk:

Los agentes en `BatutaClaude/agents/` tienen un bloque `sdk:` en su frontmatter
que define como ejecutarlos via SDK:

```yaml
---
name: pipeline-agent
description: SDD Pipeline specialist...
sdk:
  model: claude-sonnet-4-6
  max_tokens: 16384
  allowed_tools: [Read, Edit, Write, Bash, Glob, Grep, Task, Skill, WebFetch, WebSearch]
  setting_sources: [project]
  defer_loading: true
---
```

Este bloque se parsea en el SDK para crear la configuracion automaticamente.
Ver Patron 3 del skill `claude-agent-sdk` para el parser.

---

## 4. Ejemplo: CI/CD pipeline con quality-agent (Python)

Este ejemplo automatiza la revision de PRs usando un agente batuta en GitHub Actions.

### Paso 1: Crear el script del agente

Crea `scripts/review_pr.py` en tu proyecto:

```python
#!/usr/bin/env python3
"""CI/CD PR Review Agent -- revisa PRs automaticamente via Agent SDK.

Contexto de negocio: Automatiza la revision de codigo en pull requests usando
skills de batuta-dots. Corre en GitHub Actions y publica comentarios via gh CLI.
"""
import asyncio
import os
import sys
from claude_agent_sdk import query, ClaudeAgentOptions

# BUSINESS RULE: setting_sources=["project"] carga CLAUDE.md + skills.
# El agente sigue las mismas reglas que un desarrollador en Claude Code.
OPTIONS = ClaudeAgentOptions(
    model="claude-sonnet-4-6",
    setting_sources=["project"],
    allowed_tools=["Read", "Glob", "Grep", "Bash"],
    max_tokens=16384,
    defer_loading=True,
)


async def review_pr(pr_number: str) -> str:
    """Ejecuta el agente de revision para un PR.

    Args:
        pr_number: Numero del PR en GitHub.

    Returns:
        Revision en formato markdown.
    """
    prompt = f"""Review PR #{pr_number}:
1. Calidad de codigo y adherencia a convenciones del proyecto
2. Problemas de seguridad (usa patrones del skill security-audit)
3. Tests o documentacion faltante
4. Cambios que rompen compatibilidad

Usa `gh pr diff {pr_number}` para ver los cambios.
Usa `gh pr view {pr_number}` para descripcion y metadata.
Produce una revision estructurada con secciones para cada categoria."""

    parts = []
    async for msg in query(prompt=prompt, options=OPTIONS):
        if msg.type == "text":
            parts.append(msg.content)
    return "".join(parts)


async def main():
    """Punto de entrada para ejecucion en CI/CD."""
    pr_number = os.environ.get("PR_NUMBER")
    if not pr_number:
        print("ERROR: Variable PR_NUMBER no definida", file=sys.stderr)
        sys.exit(1)

    review = await review_pr(pr_number)
    print(review)

    # WORKAROUND: Publica la revision como comentario del PR usando gh CLI.
    with open("/tmp/review.md", "w") as f:
        f.write(review)
    os.system(f"gh pr comment {pr_number} --body-file /tmp/review.md")


if __name__ == "__main__":
    asyncio.run(main())
```

### Paso 2: Crear el workflow de GitHub Actions

Crea `.github/workflows/agent-review.yml`:

```yaml
# BUSINESS RULE: Corre en apertura/actualizacion de PR.
# Usa Agent SDK para revision automatizada.
name: Agent PR Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    name: AI Code Review
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install claude-agent-sdk
      - name: Run Agent Review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          PR_NUMBER: ${{ github.event.pull_request.number }}
        run: python scripts/review_pr.py
```

### Paso 3: Configurar el secret

En GitHub: Settings > Secrets and variables > Actions > New repository secret >
`ANTHROPIC_API_KEY` con tu clave de API de Anthropic.

---

## 5. Ejemplo: Embedded assistant con backend-agent (TypeScript)

Este ejemplo expone un agente batuta como endpoint API para integrarlo en un producto.

### Paso 1: Crear el servidor

```typescript
/**
 * Asistente embebido -- expone un agente batuta via Express.
 *
 * Contexto de negocio: Provee un endpoint /api/assistant para features del
 * producto que necesitan capacidades de analisis de codigo o documentacion.
 */
import express, { Request, Response } from "express";
import { query, ClaudeAgentOptions } from "@anthropic-ai/claude-agent-sdk";

const app = express();
app.use(express.json());

// SECURITY: Solo herramientas de lectura para asistentes embebidos.
// Nunca dar acceso de escritura a agentes que sirven a usuarios finales.
const ASSISTANT_OPTIONS: ClaudeAgentOptions = {
  model: "claude-sonnet-4-6",
  settingSources: ["project"],
  allowedTools: ["Read", "Glob", "Grep"],
  maxTokens: 8192,
  deferLoading: true,
};

app.post("/api/assistant", async (req: Request, res: Response) => {
  const { prompt } = req.body;
  if (!prompt || typeof prompt !== "string") {
    return res.status(400).json({ error: "Se requiere un prompt" });
  }

  try {
    const parts: string[] = [];
    for await (const msg of query({ prompt, options: ASSISTANT_OPTIONS })) {
      if (msg.type === "text") {
        parts.push(msg.content);
      }
    }
    return res.json({ response: parts.join("") });
  } catch (err) {
    console.error("Error del agente:", err);
    return res.status(500).json({ error: "Ejecucion del agente fallo" });
  }
});

const PORT = process.env.PORT ?? 3001;
app.listen(PORT, () => console.log(`Assistant API en puerto ${PORT}`));
```

### Paso 2: Dockerizar

```dockerfile
# Dockerfile para asistente embebido
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
# SECURITY: Usuario no-root
RUN addgroup --system --gid 1001 appuser && \
    adduser --system --uid 1001 appuser
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.claude ./.claude
COPY --from=builder /app/CLAUDE.md ./CLAUDE.md
# BUSINESS RULE: Copiar .claude/ y CLAUDE.md para que setting_sources funcione
USER appuser
EXPOSE 3001
CMD ["node", "dist/server.js"]
```

**Importante**: El `Dockerfile` debe copiar `.claude/` y `CLAUDE.md` al contenedor
para que `setting_sources=["project"]` funcione. Sin estos archivos, el agente
pierde todas las reglas y skills de batuta.

---

## 6. Tool Search y defer_loading

### El problema

Cada MCP server registrado agrega definiciones de herramientas al contexto del agente.
Con 10+ servidores, esto puede sumar 20,000+ tokens antes de que el agente haga nada util.
Mas tokens de contexto = mayor costo, menor precision.

### La solucion: defer_loading

```python
options = ClaudeAgentOptions(
    setting_sources=["project"],
    # BUSINESS RULE: defer_loading reduce overhead de tokens en ~85%.
    # Las herramientas se descubren bajo demanda con Tool Search.
    defer_loading=True,
)
```

### Cuando activarlo

| Cantidad de MCPs | defer_loading | Por que |
|-----------------|---------------|---------|
| 0-2 servidores | `false` | Overhead bajo; carga directa es mas rapida |
| 3-4 servidores | Opcional | Beneficio marginal; prueba ambas opciones |
| 5+ servidores | `true` (recomendado) | Ahorro significativo de tokens |
| 10+ servidores | `true` (obligatorio) | Sin esto, el contexto se llena de definiciones |

### Como funciona internamente

1. Con `defer_loading=false`: Todas las herramientas de todos los MCPs se cargan al
   inicio de la sesion. El agente las ve en su contexto desde el primer turno.
2. Con `defer_loading=true`: Solo se carga un meta-tool llamado "Tool Search". Cuando
   el agente necesita una herramienta, usa Tool Search para descubrir cuales estan
   disponibles, y solo carga las que necesita.

---

## 7. Hooks: mapeo entre Claude Code y SDK

Los hooks de Claude Code (scripts que corren antes/despues de acciones) se traducen
directamente a handlers en el SDK.

### Tabla de mapeo

| Hook en Claude Code | Equivalente en SDK | Cuando se ejecuta |
|--------------------|--------------------|--------------------|
| `SessionStart` | `hooks.SessionStart` | Al iniciar la sesion del agente |
| `Stop` | `hooks.SessionEnd` | Al finalizar la sesion |
| `PreToolUse` | `hooks.PreToolUse` + `HookMatcher` | Antes de ejecutar una herramienta |
| `PostToolUse` | `hooks.PostToolUse` + `HookMatcher` | Despues de ejecutar una herramienta |

### Ejemplo: Bloquear comandos peligrosos (Python)

```python
from claude_agent_sdk import query, ClaudeAgentOptions, Hooks, HookMatcher

def validate_bash_command(tool_input: dict) -> bool:
    """Valida que un comando Bash no sea destructivo.

    Args:
        tool_input: Diccionario con el input de la herramienta Bash.

    Returns:
        True si el comando es seguro, False si debe bloquearse.
    """
    command = tool_input.get("command", "")
    # SECURITY: Bloquear operaciones destructivas de git.
    dangerous = ["--force", "reset --hard", "push -f", "rm -rf"]
    for pattern in dangerous:
        if pattern in command:
            return False
    return True

hooks = Hooks(
    pre_tool_use=[
        {
            "matcher": HookMatcher(tool_name="Bash"),
            "handler": validate_bash_command,
        }
    ],
)

# El agente no podra ejecutar 'git push --force' ni 'rm -rf'
async for msg in query(
    prompt="Limpia el repositorio",
    options=ClaudeAgentOptions(
        setting_sources=["project"],
        hooks=hooks,
    ),
):
    print(msg)
```

---

## 8. Troubleshooting

### Problemas comunes y soluciones

| Sintoma | Causa probable | Solucion |
|---------|---------------|----------|
| El agente ignora reglas de CLAUDE.md | `setting_sources` no configurado | Agregar `setting_sources=["project"]` |
| El agente no encuentra skills | `.claude/skills/` no provisionado | Ejecutar `/sdd-init` en Claude Code primero |
| Uso excesivo de tokens con MCPs | `defer_loading` no activado | Configurar `defer_loading=True` para 5+ MCPs |
| El agente se queda sin contexto | `max_tokens` muy bajo o tarea muy amplia | Aumentar `max_tokens` o reducir el alcance del prompt |
| Herramientas no disponibles | Faltan entradas en `allowed_tools` | Agregar las herramientas necesarias a la lista |
| MCPs no se descubren | `.mcp.json` faltante o malformado | Verificar que `.mcp.json` existe y es JSON valido |
| Agente produce output vacio | No se recogen mensajes tipo `text` | Verificar `msg.type == "text"` en el loop async |
| Comportamiento diferente al CLI | Hooks no mapeados al SDK | Mapear hooks usando la tabla de la seccion 7 |
| Error de autenticacion | `ANTHROPIC_API_KEY` no definida | Configurar la variable de entorno o el secret en CI/CD |
| Agente en Docker no carga skills | `.claude/` no copiado en Dockerfile | Agregar `COPY .claude ./.claude` y `COPY CLAUDE.md ./` |

### Verificacion rapida antes de desplegar

```bash
# 1. Verificar que las skills estan provisionadas
ls .claude/skills/

# 2. Verificar que CLAUDE.md existe
cat CLAUDE.md | head -5

# 3. Probar ejecucion headless con Claude Code CLI
claude --print "Lista los skills cargados en este proyecto"

# 4. Verificar la API key
echo $ANTHROPIC_API_KEY | head -c 10
# Debe mostrar "sk-ant-api" (los primeros 10 caracteres)
```

---

## Que Significa Todo Esto (Resumen)

> **En terminos simples**: Claude Code es como un chef trabajando en tu cocina mientras
> tu le das instrucciones directamente. El Agent SDK es darle a ese mismo chef su libro
> de recetas (skills) y ponerlo a trabajar en la cocina de un restaurante donde los
> pedidos llegan automaticamente -- sin que tu estes presente. El chef sigue las mismas
> recetas y las mismas reglas de la casa (CLAUDE.md), pero ahora trabaja de forma
> autonoma.
>
> Esta guia te ensena como montar esa "cocina de restaurante": ya sea para revisar
> codigo automaticamente cuando alguien propone cambios (CI/CD), para procesar datos
> en el background (workers), o para agregar un asistente inteligente a tu producto
> (embedded assistant). Lo importante es que el agente se comporta igual sin importar
> donde corra -- en tu terminal o en un servidor.
