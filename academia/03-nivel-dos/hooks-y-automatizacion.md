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
- Lista completa de los 22 skills organizados por categoria
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

**Ejemplo**: Completaste 3 tareas y creaste 5 archivos. El hook guarda todo para manana.

**Sin este hook**: Perderia el contexto entre sesiones.

---

## Donde estan configurados

Los hooks viven en `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [{ "command": "bash infra/hooks/session-start.sh" }],
    "Stop": [{ "command": "bash infra/hooks/session-save.sh" }]
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

## Comportamientos autonomos complementarios (v12)

Ademas de los hooks, Batuta tiene comportamientos autonomos que complementan la automatizacion:

| Comportamiento | Que hace | Se parece a un hook? |
|----------------|---------|---------------------|
| **Self-heal** | Cuando reportas una violacion de reglas, el agente identifica el problema en CLAUDE.md, propone un fix, y lo aplica con tu autorizacion | No es un hook — es una reaccion a tu feedback |
| **Provisioning continuo** | Si a mitad de una tarea el agente necesita un skill que no tiene localmente, lo copia de la libreria global automaticamente | Similar al SessionStart pero ocurre en cualquier momento |
| **Clasificacion post-creacion** | Despues de crear un skill, evalua si es generico o especifico del proyecto | Se dispara automaticamente despues de ecosystem-creator |

Estos comportamientos refuerzan "La Regla" del bootstrap: no solo se asegura de que los skills se usen, sino que se auto-corrige cuando algo sale mal.

---

## Lo que no necesitas hacer

Los hooks y comportamientos autonomos funcionan automaticamente. Tu unica interaccion es:
- **Responder al Execution Gate** cuando te pregunta "Procedo?"
- **Esperar** cuando al inicio de sesion se restaura el contexto
- **Aprobar** cuando el agente propone cambios a CLAUDE.md (self-heal)

Todo lo demas pasa en segundo plano.

---

Ahora que dominas las herramientas intermedias, es hora del nivel avanzado:

-> [Extendiendo el ecosistema](../04-nivel-tres/extendiendo-el-ecosistema.md) — Crea tus propios skills
