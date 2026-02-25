# Troubleshooting

Problemas comunes al usar Batuta Dots y como resolverlos.

---

## Instalacion y setup

### "claude: command not found"
**Causa**: Node.js no esta instalado o npm no esta en el PATH.
**Solucion**: Instala Node.js desde nodejs.org, reinicia tu terminal, ejecuta `npm install -g @anthropic-ai/claude-code`.

### "A parameter cannot be found that matches parameter name 'fsSL'" (Windows)
**Causa**: Estas usando PowerShell. Su `curl` es un alias de `Invoke-WebRequest`, no el curl real.
**Solucion**: Usa WSL o Git Bash en lugar de PowerShell. Si tienes WSL, haz click en la pestaña "wsl" de tu terminal.

### "Permission denied" al ejecutar el instalador
**Causa**: Problemas de permisos en la terminal.
**Solucion**:
- Windows: Usa WSL o Git Bash (no PowerShell ni CMD)
- Mac/Linux: Verifica que `curl` esta instalado: `curl --version`

### El instalador falla al descargar
**Causa**: Sin conexion a internet o GitHub no accesible.
**Solucion**: Verifica tu conexion. El instalador necesita acceso a GitHub para descargar el ecosistema.

### Reinstalar desde cero
**Solucion**: Ejecuta el instalador de nuevo — es idempotente:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/jota-batuta/batuta-dots/master/infra/install.sh)
```

### Reinstalar hooks solamente (desarrolladores)
**Solucion**: Requiere un clon local de batuta-dots: `bash infra/setup.sh --hooks`

---

## Comandos SDD

### /sdd-init no responde
**Causa**: Sin conexion a internet o problema de autenticacion.
**Solucion**: Verifica tu conexion. Ejecuta `claude` sin argumentos para re-autenticar.

### /sdd-new dice "openspec/ not found"
**Causa**: No ejecutaste /sdd-init primero.
**Solucion**: Ejecuta `/sdd-init` antes de `/sdd-new`.

### /sdd-continue no detecta la fase actual
**Causa**: Los artefactos del cambio estan incompletos o corruptos.
**Solucion**: Revisa `openspec/changes/{nombre}/` y verifica que los archivos existen. Si faltan, ejecuta la fase manualmente (ej: `/sdd-ff`).

### /sdd-ff se detiene a mitad
**Causa**: Un gate no paso (G0.5 o G1).
**Solucion**: Revisa el checklist del gate. Completa los items faltantes y ejecuta `/sdd-continue`.

---

## Execution Gate

### "Execution Gate: este cambio no fue validado"
**Causa**: Intentas escribir un archivo sin pasar por el gate.
**Solucion**: Describe lo que quieres hacer para que el gate valide. Responde "si" cuando pregunte "Procedo?"

### El gate bloquea cambios que deberian pasar
**Causa**: El hook PreToolUse es conservador.
**Solucion**: Re-intenta con una descripcion mas clara del cambio. Si persiste, verifica que estas dentro de una fase SDD activa.

### El gate no aparece
**Causa**: Los hooks no estan instalados.
**Solucion**: Ejecuta `bash infra/setup.sh --hooks` para reinstalar hooks.

---

## Skills y agentes

### Un skill no se activa automaticamente
**Causa**: El skill no esta registrado en las tablas de ruteo.
**Solucion**: Ejecuta `/batuta-sync-skills` para regenerar tablas.

### "Skill not found" al crear skill
**Causa**: ecosystem-creator no encuentra el directorio de skills.
**Solucion**: Verifica que `~/.claude/skills/` existe.

### Skill gap detection no ofrece crear skill
**Causa**: La tecnologia ya tiene un skill registrado (posiblemente con otro nombre).
**Solucion**: Ejecuta `/batuta-sync-skills` y revisa la lista de skills activos.

---

## Agent Teams

### El equipo no se crea
**Causa**: La variable CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS no esta activa.
**Solucion**: Verifica en `~/.claude/settings.json` que `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` es "1".

### Teammates se solapan en archivos
**Causa**: Los contratos no definieron file ownership correctamente.
**Solucion**: Revisa los contratos antes de crear el equipo. Cada archivo debe pertenecer a exactamente 1 teammate.

### Team en Windows no usa split panes
**Causa**: Windows solo soporta modo in-process.
**Solucion**: Es el comportamiento esperado. Los teammates corren en el mismo proceso. Para split panes, usa macOS con tmux/iTerm2.

---

## Sesion y continuidad

### Claude no recuerda lo de ayer
**Causa**: session.md no se actualizo o no existe.
**Solucion**: Verifica que `.batuta/session.md` existe en tu proyecto. El hook Stop deberia actualizarlo automaticamente.

### "Han pasado N dias desde la ultima actualizacion"
**Causa**: El ecosistema no se ha actualizado recientemente.
**Solucion**: Ejecuta `/batuta-update` para obtener la ultima version.

---

## Rendimiento

### Claude tarda mucho en responder
**Causa**: Contexto muy grande o demasiados archivos abiertos.
**Solucion**: Cierra sesion y abre una nueva. Los hooks restauraran el contexto relevante.

### Los tokens se consumen rapido con Agent Teams
**Causa**: Agent Teams usan 3-5x mas tokens que solo.
**Solucion**: Evalua si realmente necesitas Nivel 3. Para tareas de 2-3 archivos, Nivel 2 es suficiente.

---

## Si nada funciona

1. Reinstala con el instalador: `bash <(curl -fsSL https://raw.githubusercontent.com/jota-batuta/batuta-dots/master/infra/install.sh) --claude`
2. Revisa la documentacion en `docs/guides/`
3. Abre un issue en el repositorio
