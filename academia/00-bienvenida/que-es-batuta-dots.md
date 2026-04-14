# Que es Batuta Dots

## La version corta

Batuta Dots es un ecosistema que convierte a Claude Code (un asistente de IA) en tu equipo completo de desarrollo de software. En vez de un asistente generico que responde preguntas, tienes un **gestor virtual** con 43 especialidades distribuidas en 5 agentes contratables, un proceso de trabajo profesional con 2 modos (rapido y completo), y la capacidad de construir software real desde una idea hasta un producto funcionando.

---

## La analogia del restaurante

Imagina que vas a abrir un restaurante. Podrias hacerlo tu solo — cocinar, servir, lavar, cobrar, todo al mismo tiempo. Funcionaria, pero el resultado seria caotico.

Ahora imagina que tienes:
- Un **gerente de restaurante** que no cocina sino que contrata cocineros (el main agent — gestor puro)
- **5 jefes de cocina** que se contratan segun lo que necesites (los 5 agentes: pipeline, backend, data, quality, infra)
- **Cocineros especializados** que cada jefe trae consigo (los 43 skills)
- Un **maitre** que coordina el servicio en 2 modalidades: rapida o completa (el pipeline SDD con modos SPRINT y COMPLETO)
- Un **unico inspector** que revisa el diseno antes de cocinar (el Design Approval — unico gate en modo COMPLETO)
- Un **manual de operaciones** que documenta cada receta (el PRD — un solo documento en vez de 5)

Batuta Dots funciona igual, pero para software:

| Restaurante | Batuta Dots | Que hace |
|------------|------------|---------|
| Gerente | Main agent (CLAUDE.md, 105 lineas) | Gestiona sin cocinar — solo contrata agentes |
| Jefes de cocina | 5 agentes contratables | pipeline, backend, data, quality, infra — se contratan via agent-hiring |
| Cocineros | 43 skills (13 globales + por proyecto) | Cada uno sabe hacer algo especifico muy bien |
| Maitre | Pipeline SDD (2 modos) | SPRINT (rapido, sin gates) o COMPLETO (con Design Approval) |
| Inspector | Design Approval (unico gate) | Verifica el diseno antes de construir (solo en modo COMPLETO) |
| Receta | PRD (un solo documento) | Documenta todo lo necesario para construir — reemplaza 5 artefactos separados |

---

## Que puede hacer

### Construir software completo
Desde una idea en tu cabeza hasta codigo funcionando, documentado, y probado. No importa si es una pagina web, una automatizacion, un sistema de IA, o una herramienta interna.

### Pensar antes de construir
Lo mas valioso de Batuta no es que escribe codigo — es que **te obliga a pensar**. Antes de escribir una sola linea, el sistema te hace explorar el problema, proponer soluciones, especificar requisitos, y disenar la arquitectura.

### Traer expertos cuando los necesitas
Si tu proyecto toca temas de cumplimiento legal colombiano, el sistema activa al especialista en compliance. Si necesitas disenar un pipeline de datos, activa al ingeniero de datos. Si tu proceso tiene muchas variantes, activa al analista de procesos. Todo automatico.

### Validar tu trabajo
Cada vez que construyes algo, el sistema lo verifica en 5 capas: linting, tests unitarios, tests de integracion, revision de codigo, y pruebas manuales. Las primeras 3 capas las hace la IA automaticamente.

### Documentar todo
Cada decision queda documentada. Cada cambio tiene una razon. Cuando alguien pregunte "por que se hizo asi?", la respuesta existe en un archivo que cualquier persona puede leer.

---

## Que NO es

- **No es ChatGPT con esteroides** — Es un sistema estructurado con proceso, no un chat libre
- **No es magia** — Tu tienes que entender el problema; Batuta te ayuda a resolverlo
- **No reemplaza al programador** — Es una herramienta que amplifica lo que sabes
- **No es solo para programadores** — Si puedes describir un problema, Batuta puede ayudarte a construir la solucion

---

## Las piezas del ecosistema

### Los comandos (lo que escribes)
Empiezan con `/`. Son tu forma de comunicarte con el sistema:
- `/sdd-init` — Inicializa un proyecto
- `/sdd-new mi-feature` — Empieza algo nuevo
- `/sdd-verify` — Verifica que todo esta bien

### Los skills (lo que los agentes saben hacer)
Son 43 especialidades en el hub. 13 se instalan globalmente (aplican a todo proyecto), y el resto se provisiona por proyecto segun tu tech stack (via `/batuta-init` y `/batuta-sync`):
- **sdd-explore** — Investigar y entender problemas
- **security-audit** — Revisar seguridad
- **process-analyst** — Mapear procesos complejos
- **agent-hiring** — Contratar agentes especializados
- Y muchos mas...

### Los agentes (quien ejecuta)
Son 5 agentes contratables. El main agent (el gestor) NUNCA ejecuta directamente — contrata al agente adecuado via el skill `agent-hiring`:
- **Pipeline** — Coordina el flujo SDD (research → apply → verify)
- **Backend** — APIs, bases de datos, y servicios
- **Data** — Pipelines de datos, ETL, y procesamiento
- **Quality** — Testing, validacion, y buenas practicas
- **Infra** — Infraestructura, deployment, y organizacion de archivos

Los agentes no son personal fijo — se contratan cuando se necesitan, y cada uno trae consigo los skills relevantes.

### El pipeline SDD (como se trabaja)
2 modos segun la complejidad del trabajo:

**SPRINT** (el modo por defecto — 0 gates):
1. **Research** — Investigar SIEMPRE antes de tocar codigo
2. **Apply** — Subagentes implementan con skills verificados
3. **Verify** — Verificar que funciona

**COMPLETO** (cuando el CTO lo pide via PRD — 1 gate):
1. **Research** — Investigar en paralelo con subagentes
2. **Explore** — Subagentes exploran en profundidad
3. **Design** — Disenar la arquitectura (**USER STOP** — unico gate: Design Approval)
4. **Apply** — Construir siguiendo el PRD
5. **Verify** — Verificar que funciona

### El gate (checkpoint de calidad)
Un unico punto de control en modo COMPLETO:
- **Design Approval** — Antes de construir: el diseno esta aprobado? El usuario DEBE dar su consentimiento explicito.

---

## Un ejemplo real

Imagina que un cliente te dice: "Necesito automatizar la conciliacion bancaria de mi empresa."

Con Batuta Dots en modo **COMPLETO** (tarea compleja), el flujo seria:

1. **Tu escribes**: `/sdd-new conciliacion-bancaria`
2. **Batuta investiga**: Contrata subagentes en paralelo. Investigan que es la conciliacion, que variantes existen, que sistemas usa el cliente. Buscan en Notion KB, skills relevantes, y documentacion oficial.
3. **Batuta explora**: Los subagentes mapean 4 tipos de conciliacion, 3 fuentes de datos, y 7 excepciones.
4. **Batuta diseña**: Arquitectura, modelo de datos, integraciones — todo consolidado en un PRD.
5. **Design Approval** (unico gate): "Este es el diseno. Lo apruebas?" → Tu apruebas.
6. **Batuta construye**: Agentes contratados implementan el codigo, documentado y probado.
7. **Batuta verifica**: Piramide de Validacion — linting, tests, revision.

En modo **SPRINT** (tarea mas simple), seria aun mas rapido: Research → Apply → Verify, sin gates.

**Tiempo**: Lo que antes tomaba semanas, ahora toma horas — con un PRD que documenta todas las decisiones.

---

## Siguiente paso

→ [Antes de empezar](antes-de-empezar.md) — Que necesitas instalar y configurar
