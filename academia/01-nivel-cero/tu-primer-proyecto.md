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

## Paso 3: Describe lo que quieres

```
Quiero construir una lista de tareas simple con Next.js.
El usuario puede crear, completar y eliminar tareas.
```

Batuta detecta que es un proyecto nuevo y necesita SDD. Automaticamente:
1. Inicializa el proyecto (crea `openspec/`)
2. Te pregunta el tipo de proyecto (responde **webapp**) y el stack (responde **Next.js**)
3. Explora el problema y te presenta una propuesta

```
mi-todo-app/
  openspec/
    config.yaml     ← Configuracion detectada
    specs/           ← Para especificaciones
    changes/         ← Para cambios
```

**Gate G0.5**: "Entendemos bien el problema?" → Responde **si**.
Batuta presenta su propuesta.
**Gate G1**: "La solucion vale la pena?" → Responde **si**.

## Paso 4: Aprueba la propuesta

Batuta te muestra un resumen de lo que propone construir. Revisalo y responde:

```
Dale, me parece bien.
```

Batuta automaticamente avanza por las fases de planificacion: spec → design → tasks. Resultado en `openspec/changes/todo-basico/`:

```
explore.md     ← Investigacion
proposal.md    ← Propuesta aprobada
spec.md        ← Requisitos exactos
design.md      ← Arquitectura
tasks.md       ← Tareas a implementar
```

## Paso 5: Aprueba el plan de tareas

Batuta te presenta las tareas organizadas en fases. Revisalas y responde:

```
Arranca.
```

Batuta escribe codigo siguiendo las tareas. Antes de cada archivo, pregunta "Procedo?" — responde **si**.

## Paso 6: Revisa la verificacion

Batuta verifica automaticamente con la Piramide de Validacion:

| Capa | Que verifica | Quien |
|------|-------------|-------|
| 1 | Linting, tipos, build | IA (automatico) |
| 2 | Tests unitarios | IA (automatico) |
| 3 | Tests integracion | IA (automatico) |
| 4 | Revision codigo | Tu (manual) |
| 5 | Pruebas manuales | Tu (manual) |

**Gate G2**: Todo pasa? Listo para produccion.

## Paso 7: Archiva

Batuta cierra el cambio y documenta lecciones aprendidas.

---

## Lo que acabas de hacer

```
"Quiero una todo app" → Propuesta → Aprobacion → Plan → Implementacion → Verificacion → Archivado
```

El proceso profesional completo. Tus unicas acciones fueron: describir lo que querias, aprobar la propuesta, y aprobar el plan de tareas. Batuta hizo el resto.

> **Nota**: Si prefieres controlar cada paso manualmente, puedes usar los slash commands directamente: `/sdd-init`, `/sdd-new`, `/sdd-ff`, `/sdd-apply`, `/sdd-verify`, `/sdd-archive`.

---

→ [Anatomia de un comando](anatomia-de-un-comando.md) — Como funciona internamente (para los curiosos)
