# Hooks y automatizacion

Batuta Dots tiene 5 **hooks** + 1 **bootstrap prompt** — automatismos que se ejecutan sin que tu hagas nada. Son como alarmas inteligentes: se activan en el momento correcto para proteger tu trabajo.

---

## Que es un hook

Un hook es codigo que se ejecuta automaticamente cuando algo pasa. No tienes que recordar ejecutarlo — el sistema lo hace por ti.

---

## Los 5 hooks + 1 bootstrap prompt

### 1. SessionStart — Al iniciar sesion

**Cuando**: Cada vez que abres Claude Code en un proyecto.
**Que hace**: Lee `.batuta/session.md` y restaura el contexto de tu ultima sesion.

**Ejemplo**: Ayer estabas en la fase "design" del cambio "conciliacion-bancaria". Hoy abres Claude y automaticamente sabe donde quedaste.

**Sin este hook**: Tendrias que explicarle a Claude todo de nuevo cada vez.

### 1b. Batuta Bootstrap — La Regla (v11.0)

**Cuando**: Inmediatamente despues del SessionStart, en la misma carga inicial.
**Que hace**: Establece "La Regla" — si un skill aplica a tu tarea, DEBES usarlo. Sin excepciones.

**Que contiene**:
- Lista completa de los 24 skills organizados por categoria
- 4 "racionalizaciones bandera roja" que Claude debe detectar y rechazar:
  1. "Esto es algo simple" — Las tareas simples necesitan convenciones de equipo
  2. "Ya se como hacer esto" — Los skills codifican la forma del EQUIPO, no solo conocimiento
  3. "Necesito contexto primero" — La carga del skill PRECEDE la recopilacion de contexto
  4. "El skill es overkill" — El skill define calidad minima

**Sin este bootstrap**: Claude "se olvida" de usar skills (~30% de las veces segun GAP-02/08/09). Con el bootstrap: enforcement deterministico.

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
  },
  "systemPromptFiles": ["infra/bootstrap/batuta-bootstrap.md"]
}
```

> **Nota v11.0**: El bootstrap prompt no es un hook en el sentido tecnico — es un archivo de system prompt que Claude carga al inicio. Pero funciona en conjunto con el SessionStart hook para establecer el contexto completo.

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
