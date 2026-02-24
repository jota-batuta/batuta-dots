# Tu primer proyecto

Vamos a construir algo real. Sin teoria — solo tu, Claude Code, y una idea.

---

## Lo que vamos a construir

Una **lista de tareas** (to-do app) simple. El "Hola Mundo" de Batuta Dots.

---

## Paso 1: Crea la carpeta del proyecto

```bash
mkdir mi-todo-app
cd mi-todo-app
```

## Paso 2: Inicia Claude Code

```bash
claude
```

## Paso 3: Inicializa SDD

```
/sdd-init
```

Batuta analiza tu proyecto, te pregunta el tipo (responde **webapp**) y el stack (responde **Next.js**). Crea la estructura:

```
mi-todo-app/
  openspec/
    config.yaml     ← Configuracion detectada
    specs/           ← Para especificaciones
    changes/         ← Para cambios
```

## Paso 4: Empieza tu primer cambio

```
/sdd-new todo-basico
```

Batuta ejecuta 2 fases: **explore** (investiga) y **propose** (propone solucion).

**Gate G0.5**: "Entendemos bien el problema?" → Responde **si**.
**Gate G1**: "La solucion vale la pena?" → Responde **si**.

## Paso 5: Disena y planifica

```
/sdd-ff
```

Fast-forward ejecuta: spec → design → tasks. Resultado en `openspec/changes/todo-basico/`:

```
explore.md     ← Investigacion
proposal.md    ← Propuesta aprobada
spec.md        ← Requisitos exactos
design.md      ← Arquitectura
tasks.md       ← Tareas a implementar
```

## Paso 6: Construye

```
/sdd-apply
```

Batuta escribe codigo siguiendo las tareas. Antes de cada archivo, pregunta "Procedo?" — responde **si**.

## Paso 7: Verifica

```
/sdd-verify
```

La Piramide de Validacion en accion:

| Capa | Que verifica | Quien |
|------|-------------|-------|
| 1 | Linting, tipos, build | IA (automatico) |
| 2 | Tests unitarios | IA (automatico) |
| 3 | Tests integracion | IA (automatico) |
| 4 | Revision codigo | Tu (manual) |
| 5 | Pruebas manuales | Tu (manual) |

**Gate G2**: Todo pasa? Listo para produccion.

## Paso 8: Archiva

```
/sdd-archive
```

Cierra el cambio y documenta lecciones aprendidas.

---

## Lo que acabas de hacer

```
Idea → Explorar → Proponer → Especificar → Disenar →
Tareas → Implementar → Verificar → Archivar
```

El proceso profesional completo, asistido por Batuta.

---

→ [Anatomia de un comando](anatomia-de-un-comando.md) — Que pasa cuando escribes /sdd-explore
