# Hooks y automatizacion

Batuta Dots tiene 5 **hooks** — automatismos que se ejecutan sin que tu hagas nada. Son como alarmas inteligentes: se activan en el momento correcto para proteger tu trabajo.

---

## Que es un hook

Un hook es codigo que se ejecuta automaticamente cuando algo pasa. No tienes que recordar ejecutarlo — el sistema lo hace por ti.

---

## Los 5 hooks

### 1. SessionStart — Al iniciar sesion

**Cuando**: Cada vez que abres Claude Code en un proyecto.
**Que hace**: Lee `.batuta/session.md` y restaura el contexto de tu ultima sesion.

**Ejemplo**: Ayer estabas en la fase "design" del cambio "conciliacion-bancaria". Hoy abres Claude y automaticamente sabe donde quedaste.

**Sin este hook**: Tendrias que explicarle a Claude todo de nuevo cada vez.

### 2. PreToolUse (Execution Gate) — Antes de escribir

**Cuando**: Cada vez que Batuta intenta crear o modificar un archivo.
**Que hace**: Verifica que el cambio fue validado por el Execution Gate.

**Ejemplo**: Batuta quiere crear un archivo. El hook pregunta "Este cambio fue aprobado?" Si no, bloquea la escritura.

**Sin este hook**: Batuta podria escribir archivos sin que tu confirmes.

### 3. Stop — Al terminar sesion

**Cuando**: Cuando cierras Claude Code o terminas la conversacion.
**Que hace**: Dos cosas:
1. Guarda el estado de la sesion (archivos creados, fase actual)
2. Actualiza `.batuta/session.md` si hubo trabajo significativo

**Ejemplo**: Completaste 3 tareas y creaste 5 archivos. El hook guarda todo para manana.

**Sin este hook**: Perderia el contexto entre sesiones.

### 4. TeammateIdle — Cuando un teammate termina

**Cuando**: Un teammate de un Agent Team termina su tarea.
**Que hace**: Registra el evento en O.R.T.A. para tracking de calidad.

**Solo aplica** cuando usas Agent Teams (Nivel 3).

### 5. TaskCompleted — Cuando una tarea se completa

**Cuando**: Se marca una tarea como completada en un Agent Team.
**Que hace**: Quality gate — verifica que la tarea cumplio su contrato antes de marcarla como done.

**Solo aplica** cuando usas Agent Teams (Nivel 3).

---

## Donde estan configurados

Los hooks viven en `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [{ "command": "bash infra/hooks/session-start.sh" }],
    "PreToolUse": [{ "matcher": "Write|Edit", "prompt": "Execution Gate..." }],
    "Stop": [{ "command": "bash infra/hooks/session-save.sh" }],
    "TeammateIdle": [{ "command": "bash infra/hooks/orta-teammate-idle.sh" }],
    "TaskCompleted": [{ "command": "bash infra/hooks/orta-task-gate.sh" }]
  }
}
```

### Tipos de hook

| Tipo | Como funciona |
|------|--------------|
| **command** | Ejecuta un script de bash |
| **prompt** | Claude evalua una condicion y decide si continuar |

---

## Hooks a nivel de proyecto

Ademas de los hooks globales, cada proyecto puede tener sus propios hooks en `.claude/settings.local.json`. Estos se generan con `/sdd-init`.

**Ejemplo**: Un proyecto puede tener un hook adicional que verifica que todos los archivos Python tengan type hints.

---

## Lo que no necesitas hacer

Los hooks funcionan automaticamente. Tu unica interaccion es:
- **Responder al Execution Gate** cuando te pregunta "Procedo?"
- **Esperar** cuando al inicio de sesion se restaura el contexto

Todo lo demas pasa en segundo plano.

---

Ahora que dominas las herramientas intermedias, es hora del nivel avanzado:

-> [Extendiendo el ecosistema](../04-nivel-tres/extendiendo-el-ecosistema.md) — Crea tus propios skills
