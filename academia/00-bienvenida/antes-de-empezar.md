# Antes de empezar

Todo lo que necesitas instalar y configurar para usar Batuta Dots.

---

## Requisitos del sistema

| Requisito | Minimo | Recomendado |
|-----------|--------|-------------|
| Sistema operativo | Windows 10, macOS 12, Ubuntu 20 | Windows 11, macOS 14, Ubuntu 22 |
| RAM | 8 GB | 16 GB |
| Disco | 2 GB libres | 10 GB libres |
| Internet | Conexion estable | Conexion rapida (las consultas a Claude son en la nube) |

---

## Paso 1: Instalar Claude Code

Claude Code es la herramienta base. Es un asistente de IA que se ejecuta en tu terminal (la ventana negra donde escribes comandos).

### En Windows

1. Abre PowerShell como administrador
2. Instala Node.js si no lo tienes:
```
winget install OpenJS.NodeJS
```
3. Instala Claude Code:
```
npm install -g @anthropic-ai/claude-code
```
4. Verifica la instalacion:
```
claude --version
```

### En macOS

1. Abre Terminal
2. Instala con npm:
```
npm install -g @anthropic-ai/claude-code
```
3. Verifica:
```
claude --version
```

### En Linux

1. Abre tu terminal
2. Instala con npm:
```
npm install -g @anthropic-ai/claude-code
```
3. Verifica:
```
claude --version
```

> **Nota**: Si no tienes Node.js, instalalo primero desde [nodejs.org](https://nodejs.org).

---

## Paso 2: Configurar tu cuenta

La primera vez que ejecutes `claude` en tu terminal, te pedira autenticarte con tu cuenta de Anthropic. Sigue las instrucciones en pantalla.

---

## Paso 3: Instalar Batuta Dots

Batuta Dots se instala encima de Claude Code. Es como instalar plugins en tu navegador — le dan superpoderes.

### Opcion A: Instalacion automatica (recomendada)

Ejecuta un solo comando desde la carpeta de tu proyecto:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/jota-batuta/batuta-dots/main/infra/install.sh)
```

El instalador:
1. Descarga el ecosistema en un directorio temporal
2. Te pregunta que plataforma instalar (Claude Code o Antigravity)
3. Instala los 24 skills, 3 agentes, hooks y configuracion en `~/.claude/`
4. Configura tu directorio actual como proyecto Batuta
5. Limpia todo automaticamente — no queda ninguna copia del repositorio

**En Windows (Git Bash):**

```bash
curl -fsSL https://raw.githubusercontent.com/jota-batuta/batuta-dots/main/infra/install.sh -o /tmp/batuta-install.sh && bash /tmp/batuta-install.sh
```

### Opcion B: Instalacion sin interaccion

Si ya sabes que plataforma quieres:

```bash
# Solo Claude Code
bash <(curl -fsSL https://raw.githubusercontent.com/jota-batuta/batuta-dots/main/infra/install.sh) --claude

# Solo Antigravity (Gemini CLI)
bash <(curl -fsSL https://raw.githubusercontent.com/jota-batuta/batuta-dots/main/infra/install.sh) --antigravity

# Ambas plataformas
bash <(curl -fsSL https://raw.githubusercontent.com/jota-batuta/batuta-dots/main/infra/install.sh) --both
```

---

## Paso 4: Verificar que todo funciona

Abre una terminal nueva y ejecuta:

```bash
# Crea una carpeta de prueba
mkdir mi-primer-proyecto
cd mi-primer-proyecto

# Inicia Claude Code
claude

# Dentro de Claude, escribe:
/sdd-init
```

Si ves algo como esto, todo esta funcionando:

```
SDD Initialized

Project: mi-primer-proyecto
Type: webapp (detected)
Stack: ...
Location: openspec/
```

---

## Estructura despues de instalar

Despues de la instalacion, tu carpeta personal de Claude tendra esta estructura:

```
~/.claude/
  settings.json       ← Permisos y hooks
  output-styles/
    batuta.md         ← Estilo de salida personalizado
  agents/
    pipeline-agent.md ← Coordinador del flujo SDD
    infra-agent.md    ← Coordinador de infraestructura
    observability-agent.md ← Coordinador de calidad
  skills/
    sdd-explore/      ← Skill para investigar
    sdd-propose/      ← Skill para proponer
    security-audit/   ← Skill para seguridad
    ... (24 skills en total)
```

---

## Problemas comunes

### "claude: command not found"
Node.js no esta instalado o npm no esta en el PATH. Reinstala Node.js y reinicia tu terminal.

### "Permission denied" al ejecutar el instalador
En Windows, usa Git Bash (no PowerShell ni CMD). En Mac/Linux, verifica que `curl` esta instalado: `curl --version`.

### El instalador falla al descargar
Verifica tu conexion a internet. El instalador necesita acceso a GitHub para descargar el ecosistema.

### /sdd-init no responde
Verifica tu conexion a internet — Claude Code necesita comunicarse con los servidores de Anthropic.

---

## Siguiente paso

→ [Mapa del curso](mapa-del-curso.md) — Elige tu ruta de aprendizaje
