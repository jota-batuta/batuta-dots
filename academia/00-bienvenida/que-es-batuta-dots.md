# Que es Batuta Dots

## La version corta

Batuta Dots es un ecosistema que convierte a Claude Code (un asistente de IA) en tu equipo completo de desarrollo de software. En vez de un asistente generico que responde preguntas, tienes un **CTO virtual** con 22 especialidades, un proceso de trabajo profesional, y la capacidad de construir software real desde una idea hasta un producto funcionando.

---

## La analogia del restaurante

Imagina que vas a abrir un restaurante. Podrias hacerlo tu solo — cocinar, servir, lavar, cobrar, todo al mismo tiempo. Funcionaria, pero el resultado seria caotico.

Ahora imagina que tienes:
- Un **chef ejecutivo** que disena el menu (el CTO, que es Batuta)
- **Cocineros especializados** — uno para entradas, otro para platos fuertes, otro para postres (los 22 skills)
- Un **maitre** que coordina el servicio (el pipeline SDD)
- **Inspectores de calidad** que revisan cada plato antes de servir (los gates y la validacion)
- Un **manual de operaciones** que documenta cada receta (las especificaciones)

Batuta Dots funciona igual, pero para software:

| Restaurante | Batuta Dots | Que hace |
|------------|------------|---------|
| Chef ejecutivo | CLAUDE.md (personalidad CTO) | Define las reglas, el tono, y la filosofia |
| Cocineros | 22 skills especializados | Cada uno sabe hacer algo especifico muy bien |
| Maitre | Pipeline SDD (9 fases) | Coordina el orden: primero pensar, luego disenar, luego construir |
| Inspectores | Gates (G0.5, G1, G2) | Verifican calidad antes de avanzar |
| Recetas | Especificaciones (openspec/) | Documentan exactamente que se va a construir |
| Personal de apoyo | 3 agentes (pipeline, infra, observability) | Manejan areas especificas del trabajo |

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

### Los skills (lo que el sistema sabe hacer)
Son 22 especialidades. Algunos se activan solos cuando el sistema detecta que los necesita:
- **sdd-explore** — Investigar y entender problemas
- **security-audit** — Revisar seguridad
- **process-analyst** — Mapear procesos complejos
- Y 19 mas...

### Los agentes (quien coordina)
Son 3 coordinadores, cada uno maneja un area:
- **Pipeline** — El flujo de trabajo (explorar → disenar → construir → verificar)
- **Infra** — La organizacion de archivos y creacion de herramientas
- **Observability** — El seguimiento y la calidad

### El pipeline SDD (como se trabaja)
9 fases que van desde "tengo una idea" hasta "esta en produccion":
1. **init** — Preparar el proyecto
2. **explore** — Investigar el problema
3. **propose** — Proponer una solucion
4. **spec** — Escribir los requisitos exactos
5. **design** — Disenar la arquitectura
6. **tasks** — Dividir el trabajo en tareas
7. **apply** — Construir (escribir codigo)
8. **verify** — Verificar que funciona
9. **archive** — Archivar y documentar

### Los gates (checkpoints de calidad)
3 puntos donde el sistema se detiene y pregunta "estamos listos para continuar?":
- **G0.5** — Antes de proponer: entendemos bien el problema?
- **G1** — Antes de disenar: la solucion vale la pena?
- **G2** — Antes de archivar: esta listo para produccion?

---

## Un ejemplo real

Imagina que un cliente te dice: "Necesito automatizar la conciliacion bancaria de mi empresa."

Con Batuta Dots, el flujo seria:

1. **Tu escribes**: `/sdd-new conciliacion-bancaria`
2. **Batuta explora**: Investiga que es la conciliacion, que variantes existen, que sistemas usa el cliente
3. **Gate G0.5**: "Identificamos 4 tipos de conciliacion, 3 fuentes de datos, y 7 excepciones. Continuamos?"
4. **Batuta propone**: Presenta la solucion con costos, beneficios, y lenguaje que el cliente entiende
5. **Gate G1**: "El scope es manejable, los riesgos son bajos. Continuamos?"
6. **Batuta diseña**: Arquitectura, modelo de datos, integraciones
7. **Batuta construye**: Codigo real, documentado, probado
8. **Gate G2**: "Tests pasan, documentacion completa, rollback plan listo. Listo para produccion?"
9. **Batuta archiva**: Todo queda documentado para el futuro

**Tiempo**: Lo que antes tomaba semanas, ahora toma horas — con documentacion que antes no existia.

---

## Siguiente paso

→ [Antes de empezar](antes-de-empezar.md) — Que necesitas instalar y configurar
