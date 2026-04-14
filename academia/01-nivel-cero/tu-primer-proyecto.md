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
1. Inicializa el proyecto (crea `openspec/`, provisiona skills segun tu stack)
2. Detecta el tipo de proyecto (**webapp**) y el stack (**Next.js**)
3. Investiga (research-first, obligatorio) y te presenta lo que encontro

```
mi-todo-app/
  .claude/
    skills/          ← Skills provisionados para Next.js
  openspec/
    config.yaml     ← Configuracion detectada
    specs/           ← Para especificaciones
    changes/         ← Para cambios
```

Batuta investiga automaticamente y procede a implementar (modo SPRINT — sin gates).

## Paso 4: Batuta implementa

Como esta es una tarea simple, Batuta usa el modo **SPRINT** (el default). No necesita tu aprobacion de diseno — investigo, y ahora implementa directamente. El main agent contrata agentes especializados que escriben el codigo.

> En un proyecto complejo, Batuta usaria modo **COMPLETO**: te presentaria un PRD (documento de diseno) y esperaria tu aprobacion antes de construir. Pero para una todo app, SPRINT es suficiente.

## Paso 5: Revisa la verificacion

Batuta verifica automaticamente con la Piramide de Validacion:

| Capa | Que verifica | Quien |
|------|-------------|-------|
| 1 | Linting, tipos, build | IA (automatico) |
| 2 | Tests unitarios | IA (automatico) |
| 3 | Tests integracion | IA (automatico) |
| 4 | Revision codigo | Tu (manual) |
| 5 | Pruebas manuales | Tu (manual) |

Todo pasa? Listo. session.md queda actualizado con el estado final del proyecto.

---

## Lo que acabas de hacer

```
"Quiero una todo app" → Research → Implementacion → Verificacion
```

El proceso profesional en modo SPRINT. Tu unica accion fue describir lo que querias. Batuta investigo, implemento, y verifico automaticamente.

Para proyectos mas complejos (modo COMPLETO), el flujo agrega una pausa para que apruebes el diseno antes de construir. Pero el principio es el mismo: research-first, siempre.

> **Nota**: Si prefieres controlar cada paso manualmente, puedes usar los slash commands directamente: `/sdd-explore`, `/sdd-new`, `/sdd-apply`, `/sdd-verify`, `/sdd-continue`.

---

→ [Anatomia de un comando](anatomia-de-un-comando.md) — Como funciona internamente (para los curiosos)
