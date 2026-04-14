# Hooks y automatizacion

Batuta Dots tiene hooks — automatismos que se ejecutan sin que tu hagas nada. En v15, los hooks se simplificaron significativamente.

---

## Que es un hook

Un hook es codigo que se ejecuta automaticamente cuando algo pasa. No tienes que recordar ejecutarlo — el sistema lo hace por ti.

---

## Hooks en v15: simplificados

### SessionStart — Al iniciar sesion

**Cuando**: Cada vez que abres Claude Code en un proyecto.
**Que hace**: Inyecta dos archivos como contexto:

1. **session.md** — La unica fuente de verdad del estado del proyecto
2. **CHECKPOINT.md** — Seguro anti-compaction del estado operacional

**Ejemplo**: Ayer estabas implementando autenticacion JWT. Hoy abres Claude y automaticamente sabe donde quedaste porque session.md tiene el estado exacto.

**Sin este hook**: Tendrias que explicarle a Claude todo de nuevo cada vez.

#### Que se elimino en v15

El hook de SessionStart en v14 hacia mucho mas:
- Generaba inventarios de skills/agentes (ahora eso lo maneja `.provisions.json` al provisionar)
- Inyectaba team-history.md (ahora disponible bajo demanda, no al inicio)
- Verificaba freshness del ecosistema (ahora lo hace `/batuta-update`)
- Checkeaba drift de versiones (movido a `/batuta-update`)

**Resultado**: El inicio de sesion es mas rapido porque solo inyecta session.md + CHECKPOINT.md.

### Stop — Al terminar sesion

**Cuando**: Cuando cierras Claude Code o terminas la conversacion.
**Que hace**: Dos cosas:
1. Archiva `CHECKPOINT.md` (ultimas 10 versiones)
2. Registra la sesion en `session-log.jsonl`

### session.md: actualizado en CADA interaccion

La diferencia mas grande de v15: `session.md` ya no se actualiza "al final de la sesion". Se actualiza en **cada interaccion**. Es un documento vivo de maximo 80 lineas que responde tres preguntas:

| Pregunta | Que contiene |
|----------|-------------|
| **DONDE** | Proyecto, stack, fase SDD actual, modo (SPRINT/COMPLETO) |
| **POR QUE** | Decisiones clave con razonamiento |
| **COMO** | Siguiente paso concreto |

**Lo que NO incluye**: Inventarios de archivos, conteos de tests, detalles de implementacion. Esos viven en el codigo y en `openspec/`. Si crece mas de 80 lineas, se podan las entradas mas antiguas.

### CHECKPOINT.md: seguro anti-compaction

CHECKPOINT.md se escribe antes de 3 o mas llamadas consecutivas a herramientas y al cerrar la sesion. Captura:

```markdown
# Checkpoint — 2026-04-13T14:30:00
## Que estoy haciendo
## Estado (paso N de M, archivo, branch)
## Intentos y resultados
## Que falta
## Gotchas descubiertos (con evidencia)
```

Si Claude pierde contexto por compaction (cuando la conversacion es muy larga), CHECKPOINT.md tiene todo lo necesario para retomar.

---

## Donde estan configurados

Los hooks viven en `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [
        { "type": "command", "command": "bash ~/.claude/hooks/session-start.sh" }
      ]
    }],
    "Stop": [{
      "hooks": [
        { "type": "command", "command": "bash ~/.claude/hooks/session-save.sh" }
      ]
    }]
  }
}
```

### Tipos de hook

| Tipo | Como funciona |
|------|--------------|
| **command** | Ejecuta un script de bash |
| **prompt** | Claude evalua una condicion y decide si actuar |

---

## Notion como memoria persistente (v15)

En v15, la memoria a largo plazo vive en **Notion via MCP**, no en archivos locales. Los hooks manejan la sesion local (session.md, CHECKPOINT.md), pero los discoveries, decisiones, y gotchas que trascienden la sesion se escriben **constantemente** a Notion:

| Que | Donde |
|-----|-------|
| Estado de sesion (efimero) | session.md (local, 80 lineas max) |
| Estado operacional (anti-crash) | CHECKPOINT.md (local, archivado) |
| Discoveries y decisiones (permanente) | Notion KB via MCP |
| PRD y directivas (planificacion) | Notion, paginas hijas del proyecto |

---

## Hooks a nivel de proyecto

Ademas de los hooks globales, cada proyecto puede tener sus propios hooks en `.claude/settings.local.json`. Estos se generan con `/sdd-init` o `/batuta-init`.

---

## Lo que no necesitas hacer

Los hooks funcionan automaticamente. Tu unica interaccion es:
- **Aprobar contrataciones** cuando el agente principal propone un agente nuevo
- **Aprobar disenos** en modo COMPLETO (el unico gate formal)
- **Esperar** cuando al inicio de sesion se restaura el contexto

Todo lo demas pasa en segundo plano.

---

Ahora que dominas las herramientas intermedias, es hora del nivel avanzado:

-> [Extendiendo el ecosistema](../04-nivel-tres/extendiendo-el-ecosistema.md) — Crea tus propios skills
