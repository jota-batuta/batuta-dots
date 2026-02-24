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

```bash
# Clona el repositorio
git clone https://github.com/jota-batuta/batuta-dots.git

# Entra al directorio
cd batuta-dots

# Ejecuta el instalador
bash infra/setup.sh --all
```

El instalador hace todo por ti:
- Copia la personalidad CTO a `~/.claude/`
- Registra los 24 skills
- Configura los 3 agentes
- Instala los hooks de automatizacion
- Verifica que todo funcione

### Opcion B: Instalacion paso a paso

Si prefieres entender que se instala:

```bash
# Solo la configuracion de Claude
bash infra/setup.sh --claude

# Sincronizar skills y agentes
bash infra/setup.sh --sync

# Verificar la instalacion
bash infra/setup.sh --verify
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
  CLAUDE.md           ← La personalidad CTO
  settings.json       ← Permisos y hooks
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

### "Permission denied" al ejecutar setup.sh
En Windows, usa Git Bash (no PowerShell). En Mac/Linux, asegurate de tener permisos: `chmod +x infra/setup.sh`.

### El instalador no encuentra los archivos
Asegurate de estar dentro del directorio `batuta-dots/` antes de ejecutar el setup.

### /sdd-init no responde
Verifica tu conexion a internet — Claude Code necesita comunicarse con los servidores de Anthropic.

---

## Siguiente paso

→ [Mapa del curso](mapa-del-curso.md) — Elige tu ruta de aprendizaje
