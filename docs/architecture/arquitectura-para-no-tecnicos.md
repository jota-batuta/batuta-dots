# Entendiendo la Arquitectura de Batuta — Sin Palabras Tecnicas (v15)

> **Para quien es esto**: Para cualquier persona que quiera entender COMO funciona
> el ecosistema Batuta sin necesitar saber programar. Si puedes entender como funciona
> un restaurante, puedes entender esto.

---

## La analogia: Batuta es un restaurante

Imagina que Batuta es un restaurante. Vamos a usar esta analogia para explicar cada parte.

---

## El Gerente del Restaurante (Main Agent)

En v15, el agente principal ya NO es un chef. Es un **gerente** — un manager que coordina
pero nunca toca una olla.

El gerente recibe tu pedido, identifica que tipo de especialista necesita, y lo **contrata**.
No cocina, no investiga directamente, no escribe codigo. Solo decide a quien llamar.

> **Cambio clave vs versiones anteriores**: Antes, el agente principal era un "chef que delegaba". Ahora es un gerente puro — su unica funcion es contratar al especialista correcto para cada tarea.

---

## Las Instrucciones del Gerente (CLAUDE.md)

**CLAUDE.md** es la hoja de instrucciones del gerente. Son solo **105 lineas** — corta y directa. Contiene:

- Que reglas seguir siempre (investigar antes de actuar, nunca asumir)
- Como contratar especialistas (protocolo de contratacion)
- Como mantener el estado del proyecto (una sola fuente de verdad)
- Como conectar con el director (Notion)
- Los dos modos de trabajo (rapido y completo)

> **Regla importante**: El gerente no tiene recetas (skills) propias. Solo sabe a QUIEN llamar. Las recetas las tienen los especialistas.

---

## El Protocolo de Contratacion (Agent Hiring)

Cuando llega un pedido, el gerente sigue este proceso:

```
Tu dices: "Necesito un endpoint de login"
   |
Gerente piensa: "Necesito un especialista en APIs"
   |
Gerente revisa: "Tengo un especialista en APIs contratado?"
   |
SI → Lo llama directamente
NO → Te propone contratar uno nuevo:
     "Necesito contratar un backend-specialist.
      Va a usar estas recetas: jwt-auth, fastapi-crud.
      Te parece bien?"
   |
TU APRUEBAS → Se crea el contrato → El especialista trabaja
```

**Lo importante**: El gerente NUNCA improvisa. Si no tiene un especialista para la tarea, te pide permiso antes de contratar uno nuevo. Cada contrato queda escrito en un archivo — no se pierde.

---

## Los 5 Especialistas del Restaurante (Agents)

El restaurante tiene 5 especialistas de planta, cada uno experto en su area:

| Especialista | Que hace | Cuando lo llaman |
|-------------|---------|-----------------|
| **Jefe de produccion** (pipeline) | Coordina el proceso completo de crear platos nuevos | Cuando hay que construir algo nuevo |
| **Chef de linea** (backend) | Sabe de APIs, autenticacion, bases de datos | Cuando mencionas "API", "login", "base de datos" |
| **Sous chef de datos** (data) | Experto en datos, transformaciones, inteligencia artificial | Cuando mencionas "datos", "ETL", "IA" |
| **Inspector de calidad** (quality) | Revisa que cada plato cumpla estandares | Siempre disponible — la calidad no es opcional |
| **Jefe de instalaciones** (infra) | Maneja despliegue, servidores, monitoreo | Cuando mencionas "deploy", "servidor", "monitoreo" |

Cada especialista tiene sus propias recetas (skills). El gerente no necesita saber las recetas — solo necesita saber a quien llamar.

**Los especialistas trabajan en paralelo**. Si necesitas investigar 3 cosas a la vez, el gerente contrata 3 especialistas y todos trabajan al mismo tiempo. 5 especialistas investigando = minutos, no horas.

---

## Las Recetas (Skills)

Cada **skill** es una receta especifica. Hay **43 recetas** en el libro maestro:

- **13 recetas universales** que todos los restaurantes (proyectos) necesitan
- **30 recetas especializadas** que se asignan segun el tipo de cocina del restaurante

| Receta (Skill) | Que le ensena al especialista |
|----------------|------------------------------|
| `scope-rule` | Donde guardar cada ingrediente en la cocina (organizacion) |
| `fastapi-crud` | Como preparar APIs rapidas |
| `jwt-auth` | Como verificar la identidad de los clientes |
| `tdd-workflow` | Como probar cada plato antes de servirlo |
| `agent-hiring` | Como contratar especialistas nuevos |

**Detalle clave**: Las recetas NO pertenecen al gerente — pertenecen a los **especialistas**. El gerente no lee recetas. Los especialistas si.

Las recetas no se leen todas al empezar. Solo se abre la que el especialista necesita para el plato que esta preparando.

---

## Los Dos Modos de Trabajo (SDD Pipeline)

En v15, hay DOS modos de trabajo. Piensa en ellos como dos tipos de pedido:

### SPRINT — El pedido rapido (default)

Como pedir un sandwich en un cafe. No necesitas planificacion elaborada.

```
Tu dices: "Necesito arreglar el boton de login"
   |
Gerente: INVESTIGA primero (obligatorio, siempre)
   → Revisa el archivo del restaurante (Notion KB)
   → Lee la receta relevante (skill)
   → Verifica en internet que la receta este al dia
   |
Gerente contrata al especialista correcto
   |
El especialista COCINA (implementa)
   |
El inspector VERIFICA que todo funcione
   |
LISTO
```

**Sin gates formales.** No hay pausas para aprobacion. Pero la investigacion es OBLIGATORIA — nunca se salta.

### COMPLETO — El menu degustacion (cuando el director lo pide)

Como planear un banquete. El director (CTO) escribe un documento de planificacion (PRD) con todo lo que necesita.

```
El director escribe el PRD en Notion:
   "Necesito un sistema de pagos con estas caracteristicas..."
   |
Gerente lee el PRD via Notion
   |
INVESTIGA (obligatorio)
   |
Especialistas EXPLORAN opciones (en paralelo)
   |
Especialista de pipeline produce el DISENO
   |
*** PAUSA: El gerente te muestra el diseno ***
*** TU APRUEBAS o pides cambios ***
   |
Especialistas IMPLEMENTAN
   |
Inspector VERIFICA
   |
LISTO
```

**Un solo gate**: la aprobacion del diseno. No mas cadenas de 8 aprobaciones.

### El ticket de pedido (PRD)

El **PRD** (Product Requirements Doc) es como el ticket de pedido en un restaurante.
Antes habia 5 documentos separados (investigacion, propuesta, especificaciones, diseno, tareas).
Ahora hay UNO SOLO: el PRD. Todo lo que el especialista necesita saber esta ahi.

El director lo escribe en Notion. El gerente lo lee automaticamente. Asi de simple.

---

## La Investigacion Antes de Todo (Research-First)

Esta es la regla mas importante de v15: **SIEMPRE investigar antes de actuar**.

No importa si es un pedido rapido (SPRINT) o un banquete (COMPLETO). Antes de que cualquier especialista empiece a cocinar, el gerente investiga:

```
1. Revisar el archivo del restaurante (Notion KB)
   → "Alguien ya resolvio algo similar?"

2. Leer la receta relevante (skill)
   → "Tenemos un procedimiento para esto?"
   → "La receta esta al dia o el ingrediente cambio?"

3. Consultar el manual oficial del proveedor (docs)
   → "El proveedor cambio algo recientemente?"

4. Buscar en internet
   → "Como lo resolvieron otros restaurantes?"
```

Esta cadena de investigacion se hace con **subagentes en paralelo**. 5 investigadores al mismo tiempo = rapido.

> **Regla de oro**: No existe tarea tan trivial que justifique saltar la investigacion. Asumir sin verificar es el error mas caro del restaurante.

---

## El Cuaderno del Turno (session.md)

Imagina que hay un cuaderno en la cocina donde el turno actual anota TODO lo que esta pasando. No solo al final del turno — **en cada momento**.

Eso es `.batuta/session.md`. Es la **unica fuente de verdad** del estado del proyecto. Responde tres preguntas:

- **DONDE**: En que parte del proyecto estamos
- **POR QUE**: Que estamos haciendo y por que
- **COMO**: Que decisiones tomamos y que convenciones descubrimos

**Diferencia con versiones anteriores**: Antes, el cuaderno se escribia solo al final del turno. Ahora se actualiza en CADA interaccion. Si el gerente toma una decision a las 3pm, queda anotada a las 3pm — no al cerrar.

---

## La Ficha de Estado (CHECKPOINT.md)

Ademas del cuaderno, hay una **ficha de estado** pegada en la estacion de trabajo.

```
FICHA DE ESTADO
---
Que estoy haciendo: integrar pagos
Paso actual: 3 de 7
Lo que intente y fallo: endpoint /pay → error 401
Lo que decidi: usar SDK en vez de llamada directa
Lo que falta: configurar retry, probar con tarjeta test
Descubrimiento: proveedor requiere IP fija para webhooks
```

Esta ficha existe porque a veces el contexto se satura (como un chef que pierde el hilo
en un turno largo). La ficha le permite retomar exactamente donde estaba.

Se escribe automaticamente antes de tareas largas y al cerrar el turno. Se inyecta automaticamente al abrir el siguiente turno. Nadie tiene que recordar hacerlo.

---

## El Director y su Oficina (Notion + CTO)

El restaurante tiene un **director** (CTO) que planifica desde su oficina (Notion).
El gerente (Claude Code) esta en la cocina. Se comunican por un sistema de mensajes (Notion MCP).

El flujo:

1. **El director escribe** el plan del nuevo plato (PRD) en su oficina (Notion)
2. **El gerente lee** el plan automaticamente via el sistema de mensajes
3. **El gerente contrata** a los especialistas y ejecuta
4. **Los especialistas reportan** resultados
5. **El gerente escribe** los descubrimientos de vuelta al archivo del director

**Regla importante**: El gerente busca todo por NOMBRE, nunca por codigo. Si el proyecto se llama "batuta-portal", busca "batuta-portal" — no un numero de serie. Los numeros cambian; los nombres persisten.

Si el sistema de mensajes no esta disponible, el gerente continua sin bloquear. El trabajo no se detiene porque la oficina este cerrada.

---

## Las Alarmas Automaticas (Hooks)

El restaurante tiene alarmas automaticas que funcionan sin que nadie las active:

| Alarma | Cuando suena | Que hace |
|--------|-------------|---------|
| **Alarma de apertura** (SessionStart) | Al empezar el turno | Lee el cuaderno del turno anterior + la ficha de estado + el inventario de recetas |
| **Alarma de cierre** (Stop) | Al terminar el turno | Escribe la ficha de estado + actualiza el log + envia descubrimientos al archivo del director |
| **Alarma de sub-agente** (SubagentStop) | Cuando un especialista contratado termina | Guarda su reporte en el historial del equipo |

Las alarmas son deterministicas — funcionan solas, sin que nadie recuerde activarlas.

---

## La Regla de la Cocina (Scope Rule)

En un restaurante organizado, cada cosa tiene su lugar:

| Que es | Donde va | Ejemplo |
|--------|---------|---------|
| Especias que solo usa un plato | En la estacion de ese plato | La salsa secreta del ramen |
| Especias que usan 2+ platos | En el estante compartido | Sal y pimienta |
| Equipos de toda la cocina | En el area principal | Horno, nevera, lavaplatos |

**La regla**: NUNCA tires todo en un mismo cajon. Cada cosa en su lugar segun QUIEN la usa.

---

## El Inventario de Recetas (Sync)

Cuando un especialista inventa una receta nueva en un proyecto, puede compartirla:

```
Especialista crea receta nueva de sushi
   |
/batuta-sync → opcion 2: "subir al hub"
   |
La receta llega al libro maestro (batuta-dots)
   |
Todos los proyectos futuros pueden usarla
```

Y al reves — si una receta del libro maestro no esta en tu proyecto:

```
/batuta-sync → opcion 3: "traer del hub"
   |
Seleccionas la receta que necesitas
   |
Se copia a tu proyecto
```

---

## El Control de Calidad por Capas (Validation Pyramid)

Antes de servir un plato, pasa por 5 controles:

```
Nivel 5: TU pruebas el plato (humano obligatorio)
Nivel 4: Un critico lo evalua (humano experto)
Nivel 3: Se prueba el plato completo junto
Nivel 2: Se prueba cada ingrediente por separado
Nivel 1: Se verifica que los ingredientes basicos sean correctos
```

Los niveles 1-3 los hace el inspector automaticamente. Los niveles 4-5 SIEMPRE requieren un humano. Tu tienes la ultima palabra antes de servir.

---

## El Glosario: Restaurante → Batuta

| En el restaurante | En Batuta | Que hace |
|-------------------|-----------|---------|
| **Gerente** | Main Agent + CLAUDE.md (105 lineas) | Recibe pedidos, contrata especialistas. NUNCA cocina |
| **Contrato de especialista** | Archivo .md en .claude/agents/ | Documento permanente que define que sabe hacer el especialista |
| **Protocolo de contratacion** | agent-hiring skill | Como el gerente decide a quien contratar |
| **Especialistas** (5) | Agents (pipeline, backend, data, quality, infra) | Expertos que hacen el trabajo. Cada uno con sus recetas |
| **Recetas** (43) | Skills (SKILL.md) | Instrucciones especificas. Pertenecen a los especialistas |
| **Ticket de pedido** | PRD (Product Requirements Doc) | El unico documento de planificacion |
| **Pedido rapido** | SPRINT mode (default) | Research → Apply → Verify. Sin gates |
| **Menu degustacion** | COMPLETO mode | Research → Explore → Design (aprobacion) → Apply → Verify |
| **Investigar antes de cocinar** | Research-First chain | Notion → skill → docs → web. OBLIGATORIO siempre |
| **Cuaderno del turno** | session.md | Fuente unica de verdad. Se actualiza en cada interaccion |
| **Ficha de estado** | CHECKPOINT.md | Seguro anti-confusion. Paso actual, intentos, gotchas |
| **Oficina del director** | Notion via MCP | Donde el CTO planifica. Busqueda por nombre, nunca IDs |
| **Alarmas automaticas** | Hooks (SessionStart, Stop, SubagentStop) | Acciones obligatorias que nadie puede saltarse |
| **Organizacion de cocina** | Scope Rule | Donde va cada cosa segun quien la usa |
| **Control de calidad** | AI Validation Pyramid | 5 niveles. Los primeros 3 automaticos, los ultimos 2 humanos |

---

## Como le hablas al gerente

No necesitas saber programar NI memorizar comandos. Simplemente describe lo que necesitas:

| Que quieres | Que le dices |
|-------------|-------------|
| Construir algo nuevo | "Necesito una app que haga X" |
| Arreglar algo | "El boton de login no funciona" |
| Investigar algo | "Como funciona el sistema de pagos?" |
| Continuar donde quedaste | "Donde quedamos?" |

Batuta detecta que necesitas y contrata al especialista correcto automaticamente. Tu solo apruebas cuando el gerente te lo pide (y en SPRINT, ni siquiera eso).

### Comandos manuales (opcionales)

| Que quieres | Que escribes |
|-------------|-------------|
| Instalar Batuta en un proyecto | `/batuta-init` |
| Explorar un tema | `/sdd-explore tema` |
| Empezar algo nuevo | `/sdd-new nombre` |
| Implementar desde PRD | `/sdd-apply` |
| Verificar que funcione | `/sdd-verify` |
| Sincronizar recetas | `/batuta-sync` |
| Crear una receta nueva | `/create skill nombre` |

---

## Diagrama simple del flujo

```
TU IDEA
   |
"Quiero una app que haga X"
   |
Gerente INVESTIGA (obligatorio, siempre):
   → Notion KB → skill → docs → web
   |
Gerente contrata al especialista correcto
   |
Especialista trabaja (con sus recetas)
   |
Inspector verifica la calidad
   |
Session.md actualizado
   |
RESULTADO LISTO
```

---

## Preguntas frecuentes

**P: Necesito saber programar para usar esto?**
R: No. Solo describes lo que quieres. El gerente contrata al especialista correcto.

**P: Que pasa si algo sale mal?**
R: El inspector de calidad (quality-agent) revisa automaticamente. Si encuentra errores, te dice cuales son y los corrige.

**P: Por que el gerente nunca cocina directamente?**
R: Porque si el gerente se pone a cocinar, nadie esta coordinando. Ademas, si cargara TODAS las recetas de TODOS los especialistas, se le llenaria la memoria y seria mas lento.

**P: Que es la diferencia entre SPRINT y COMPLETO?**
R: SPRINT es para tareas del dia a dia — rapido, sin pausas. COMPLETO es para proyectos grandes donde el director escribe un plan formal (PRD) y hay una pausa para aprobar el diseno.

**P: Que es el PRD?**
R: El ticket de pedido. Un solo documento con todo lo que el especialista necesita saber. Reemplaza los 5 documentos que habia antes.

**P: Si cierro la terminal, el gerente se olvida de todo?**
R: No. Gracias al cuaderno del turno (session.md), el gerente lee donde quedo y continua sin que repitas nada.

**P: Cuantas recetas tiene el sistema?**
R: 43 en el libro maestro. 13 universales que todos los proyectos usan. 30 especializadas que se asignan segun el tipo de proyecto.

**P: Batuta tiene demasiadas reglas?**
R: Batuta tiene pocas reglas OBLIGATORIAS (investigar siempre, aprobar contrataciones nuevas, 1 gate en modo COMPLETO). El resto son guias que ayudan a los especialistas a cocinar mejor.

---

> **Recuerda**: No necesitas entender como funciona un motor para manejar un carro.
> Solo necesitas saber los pedales y el volante. Los comandos son tus pedales,
> las guias son tu manual, y el gerente es quien coordina todo bajo el capo.
