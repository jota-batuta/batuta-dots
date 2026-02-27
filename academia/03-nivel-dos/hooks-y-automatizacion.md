# Hooks y automatizacion

Batuta Dots tiene 2 **hook types** (SessionStart, Stop) + 1 **bootstrap prompt** — automatismos que se ejecutan sin que tu hagas nada. Son como alarmas inteligentes: se activan en el momento correcto para proteger tu trabajo.

---

## Que es un hook

Un hook es codigo que se ejecuta automaticamente cuando algo pasa. No tienes que recordar ejecutarlo — el sistema lo hace por ti.

---

## Los 2 hook types (SessionStart, Stop)

### 1. SessionStart — Al iniciar sesion

**Cuando**: Cada vez que abres Claude Code en un proyecto.
**Que hace**: Lee `.batuta/session.md` y restaura el contexto de tu ultima sesion.

**Ejemplo**: Ayer estabas en la fase "design" del cambio "conciliacion-bancaria". Hoy abres Claude y automaticamente sabe donde quedaste.

**Sin este hook**: Tendrias que explicarle a Claude todo de nuevo cada vez.

### 1b. Batuta Bootstrap — La Regla (v11.1)

**Cuando**: Inmediatamente despues del SessionStart, en la misma carga inicial.
**Que hace**: Establece "La Regla" — si un skill aplica a tu tarea, DEBES usarlo. Sin excepciones.

**Que contiene**:
- Lista completa de los 23 skills organizados por categoria
- 4 "racionalizaciones bandera roja" que Claude debe detectar y rechazar:
  1. "Esto es algo simple" — Las tareas simples necesitan convenciones de equipo
  2. "Ya se como hacer esto" — Los skills codifican la forma del EQUIPO, no solo conocimiento
  3. "Necesito contexto primero" — La carga del skill PRECEDE la recopilacion de contexto
  4. "El skill es overkill" — El skill define calidad minima

**Sin este bootstrap**: Claude "se olvida" de usar skills (~30% de las veces segun GAP-02/08/09). Con el bootstrap: enforcement deterministico.

### 2. Stop — Al terminar sesion

**Cuando**: Cuando cierras Claude Code o terminas la conversacion.
**Que hace**: Dos cosas:
1. Guarda el estado de la sesion (archivos creados, fase actual)
2. Actualiza `.batuta/session.md` si hubo trabajo significativo

**Session Budget (80 lineas max)**: El archivo `session.md` es un documento de briefing para un nuevo agente que retoma el trabajo. Responde tres preguntas: DONDE estamos (proyecto, stack, fase), POR QUE llegamos ahi (decisiones con razonamiento), y COMO continuar (siguiente paso). Nunca incluye inventarios de archivos, conteos de tests, ni detalles de implementacion — esos viven en el codigo y en `openspec/`. Si crece mas de 80 lineas, se podan las entradas mas antiguas.

**Ejemplo**: Completaste 3 tareas y creaste 5 archivos. El hook guarda todo para manana.

**Sin este hook**: Perderia el contexto entre sesiones.

---

## Donde estan configurados

Los hooks viven en `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [
        { "type": "command", "command": "bash ~/.claude/hooks/session-start.sh" },
        { "type": "prompt", "prompt": "BATUTA BOOTSTRAP — THE RULE: If a skill applies..." }
      ]
    }],
    "Stop": [{
      "hooks": [
        { "type": "command", "command": "bash ~/.claude/hooks/session-save.sh" },
        { "type": "prompt", "prompt": "Before stopping, check if .batuta/session.md exists..." }
      ]
    }]
  }
}
```

> **Nota v12.1**: El bootstrap ("La Regla") esta embebido como prompt hook inline dentro del SessionStart array, no como archivo separado. El hook `command` ejecuta el script de descubrimiento de skills y el hook `prompt` inyecta La Regla directamente. Ambos se ejecutan en secuencia al iniciar sesion.

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
