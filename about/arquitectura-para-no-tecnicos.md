# Entendiendo la Arquitectura de Batuta — Sin Palabras Tecnicas

> **Para quien es esto**: Para cualquier persona que quiera entender COMO funciona
> el ecosistema Batuta sin necesitar saber programar. Si puedes entender como funciona
> un restaurante, puedes entender esto.

---

## La analogia: Batuta es un restaurante

Imagina que Batuta es un restaurante. Vamos a usar esta analogia para explicar cada parte.

---

## El Chef Principal (Claude Code)

**Claude Code** es tu chef principal. Es un cocinero con inteligencia artificial que sabe
hacer muchos platos, pero necesita recetas especificas para cocinar AL ESTILO de tu
restaurante.

Sin recetas, el chef cocina "a su manera" — y cada vez lo hace diferente. Con recetas,
siempre cocina igual, siempre bien.

---

## Las Instrucciones del Chef (CLAUDE.md)

**CLAUDE.md** es la hoja de instrucciones que el chef lee cada vez que empieza a trabajar. Contiene:

- Que personalidad tiene (CTO/Mentor: paciente, educador)
- Que reglas seguir siempre
- Donde encontrar cada receta (skill)
- Como organizar la cocina (Scope Rule)
- Que hacer cuando no tiene una receta (Skill Gap Detection)

> **Regla importante**: Solo hay UN archivo de instrucciones. Si quieres cambiar algo,
> cambias CLAUDE.md y todas las sucursales (proyectos) se actualizan.

---

## Las Recetas Individuales (Skills)

Cada **skill** es una receta especifica. Por ejemplo:

| Receta (Skill) | Que le ensena al chef |
|----------------|----------------------|
| `scope-rule` | Donde guardar cada ingrediente en la cocina (organizacion) |
| `sdd-init` | Como empezar a preparar un plato nuevo (planificacion) |
| `temporal-worker` | Como cocinar platos que llevan muchos pasos y pueden fallar |
| `nextjs-portal` | Como montar el plato para que se vea bonito (la cara que ve el cliente) |

El chef tiene **14 recetas basicas** que siempre estan disponibles, y puede **aprender
recetas nuevas** cuando las necesita.

**Detalle importante**: Las recetas NO se leen todas al empezar. El chef solo abre la
receta que necesita para el plato que esta preparando. Esto se llama "carga bajo demanda"
y hace que el chef sea mas rapido y eficiente.

---

## El Proceso de Cocina (SDD Pipeline)

Cuando un cliente pide un plato nuevo que nunca se ha hecho, el chef NO empieza a
cocinar de una. Sigue un proceso de 9 pasos:

### Los 9 pasos para crear un plato nuevo

```
1. INIT        → "Que tipo de plato es?" (entrada, principal, postre)
2. EXPLORE     → "Que ingredientes tenemos? Que tecnicas podemos usar?"
3. PROPOSE     → "Esta es mi propuesta de plato. Te parece bien?"
      ↓
   TU APRUEBAS O PIDES CAMBIOS
      ↓
4. SPEC        → "Estos son los requisitos exactos del plato"
5. DESIGN      → "Este es el diseno: que va primero, que va despues"
6. TASKS       → "Estos son los pasos que voy a seguir, en orden"
      ↓
   TU APRUEBAS
      ↓
7. APPLY       → "Ahora si, estoy cocinando" (aqui se escribe el codigo)
8. VERIFY      → "Termine. Voy a probar que todo sabe bien"
9. ARCHIVE     → "Documento la receta para que cualquiera pueda repetirla"
```

### Por que tantos pasos?

Porque es MAS RAPIDO planear bien que arreglar errores despues.

Imagina que empiezas a cocinar sin receta:
- "Ups, necesitaba harina y no compre" → parar, ir al supermercado, volver
- "Ups, tenia que precalentar el horno hace 30 minutos" → esperar 30 minutos
- "Ups, la salsa no combina con la carne" → empezar de cero

Con los 9 pasos, todos esos problemas se detectan ANTES de empezar a cocinar.

---

## La Regla de la Cocina (Scope Rule)

En un restaurante organizado, cada cosa tiene su lugar:

| Que es | Donde va | Ejemplo |
|--------|---------|---------|
| **Especias que solo usa un plato** | En la estacion de ese plato | La salsa secreta del ramen va en la estacion de ramen |
| **Especias que usan 2+ platos** | En el estante compartido | La sal y la pimienta van en el estante central |
| **Equipos de toda la cocina** | En el area principal | El horno, la nevera, el lavaplatos — hay uno solo para todos |

En codigo, esto se traduce a:

| Quien lo usa | Donde va |
|---|---|
| Solo una funcionalidad | Dentro de esa funcionalidad |
| Dos o mas funcionalidades | En una carpeta compartida |
| Toda la aplicacion | En una carpeta central |

**La regla de oro**: NUNCA tires todo en un mismo cajon. Cada cosa en su lugar segun QUIEN la usa.

---

## El Detector de Recetas Faltantes (Skill Gap Detection)

Imagina que un cliente pide "sushi" pero tu restaurante nunca ha hecho sushi.

Un chef malo diria: "Bueno, voy a intentar" y te serviria algo horrible.

El chef de Batuta dice:

> "El cliente quiere sushi, pero yo no tengo la receta de sushi.
> Sin receta, puedo hacerlo pero no va a seguir nuestros estandares.
>
> Te propongo:
> 1. Investigo como se hace sushi profesionalmente y creo la receta (~5 min)
> 2. Igual, pero hago una receta generica para cualquier restaurante
> 3. Lo intento sin receta y documentamos despues
>
> Que prefieres?"

Esto es lo que pasa AUTOMATICAMENTE cuando Claude necesita usar una tecnologia para
la que no tiene un skill documentado. Se detiene, te pregunta, y si quieres, investiga
y aprende antes de empezar.

**Por que esto importa**: Un skill de 5 minutos evita horas de arreglos despues.

---

## El Sub-Chef (Sub-Agente)

El chef principal NO hace todo el mismo. Tiene sub-chefs especializados:

| Sub-chef | Que hace |
|----------|---------|
| Sub-chef de investigacion | Explora ingredientes y tecnicas disponibles |
| Sub-chef de propuestas | Escribe la propuesta del plato nuevo |
| Sub-chef de recetas | Escribe las especificaciones exactas |
| Sub-chef de ejecucion | Cocina el plato (escribe el codigo) |
| Sub-chef de calidad | Prueba que todo este bien |

El chef principal SOLO coordina. Le dice al sub-chef: "Investiga esto" y el sub-chef
vuelve con un reporte. El chef principal nunca toca una olla.

---

## Los Jefes de Area (Scope Agents)

Pero el chef principal no le habla directamente a cada sub-chef. Tiene **jefes de area**
que coordinan grupos de sub-chefs:

| Jefe de area | Que coordina | Sub-chefs a su cargo |
|-------------|-------------|----------------------|
| **Jefe de Cocina** (pipeline) | Todo el proceso de crear platos nuevos | Los 9 sub-chefs del proceso SDD |
| **Jefe de Almacen** (infra) | Organizacion, inventario, recetas | Organizacion de ingredientes (scope-rule), creacion de recetas (ecosystem-creator), inventario automatico (skill-sync) |
| **Jefe de Calidad** (observability) | Control de calidad silencioso | Inspector de calidad (prompt-tracker) |

El chef principal SOLO decide a que jefe de area pasarle el pedido. El jefe de area
decide cuales sub-chefs necesita y los coordina.

**Por que es mejor asi?** Porque el chef principal no necesita recordar los 14 recetarios.
Solo necesita saber 3 numeros de telefono: el del jefe de cocina, el del jefe de almacen,
y el del jefe de calidad. Cada jefe de area conoce en detalle las recetas de su area.

---

## El Checklist Antes de Cocinar (Execution Gate)

Imagina que antes de empezar CUALQUIER plato, el chef revisa un checklist:

```
Antes de cocinar:
 ✓ Tengo todos los ingredientes? (skill check)
 ✓ Se donde va a ir este plato en el menu? (scope/location)
 ✓ Cuantos platos diferentes voy a afectar? (impacto)
 ✓ Hay una receta aprobada para esto? (SDD check)
 → Si todo esta bien: "Voy a preparar {plato} en {estacion}. Procedo?"
```

Este checklist es el **Execution Gate**. Se ejecuta ANTES de cada cambio de codigo.
No se puede saltar. Tiene dos modos:

| Modo | Cuando | Ejemplo |
|------|--------|---------|
| **Rapido** | Un solo cambio simple | "Modifico el archivo X. Procedo?" |
| **Completo** | Multiples cambios o algo nuevo | Lista de archivos + impacto + donde van |

**Por que esto importa**: Es la diferencia entre un chef que verifica la receta antes
de cocinar y uno que improvisa. El checklist previene errores ANTES de que ocurran.

---

## El Inventario Automatico (Skill-Sync)

Imagina que cada vez que un chef agrega una receta nueva al libro, el sistema
automaticamente actualiza:
1. El menu del restaurante (para los clientes)
2. La lista de recetas de cada jefe de area (para los sub-chefs)

Nadie tiene que recordar hacerlo. Es automatico.

Eso es lo que hace **skill-sync**: cuando se crea o modifica una receta (SKILL.md),
un script lee todas las recetas y regenera las tablas de referencia automaticamente.

```
Chef crea nueva receta de sushi
   ↓
sync.sh lee TODAS las recetas
   ↓
Actualiza el menu general (CLAUDE.md)
   ↓
Actualiza la lista del jefe de cocina (pipeline-agent)
   ↓
Listo — todos saben que ahora hay sushi disponible
```

**Por que esto importa**: Sin inventario automatico, alguien tendria que recordar
actualizar el menu cada vez que se agrega una receta. Con skill-sync, es imposible
que una receta quede "invisible" — siempre aparece en el inventario.

---

## La Actualizacion de Recetas (Auto-Update SPO)

Imagina que en una sucursal del restaurante, un chef inventa una receta nueva increible
para "tacos de cochinita". Esa receta deberia llegar a TODAS las sucursales.

Eso es lo que hace el Auto-Update SPO:

```
Sucursal A inventa receta → Se evalua → Se generaliza → Se copia al libro maestro
→ Todas las sucursales la tienen
```

Al final de cada proyecto, Claude te pregunta:

> "Durante este proyecto creamos estas recetas nuevas:
> - Receta de sushi (Temporal.io)
> - Receta de tempura (n8n workflows)
>
> Quieres que las mande al libro maestro para que otros proyectos las tengan?"

---

## El Cuaderno del Turno (Continuidad de Sesion)

Imagina que en el restaurante hay tres turnos de chefs. Si el chef del turno de la mañana
preparo una salsa especial y dejo notas de como le quedo, el chef de la tarde puede
continuar sin empezar de cero.

Eso es lo que hace `.batuta/session.md` — es el **cuaderno del turno**. Cada vez que
Claude termina un trabajo importante, anota:

- Que estaba haciendo
- Que decisiones tomo
- Que le falta por hacer
- Que convenciones descubrio del proyecto

La proxima vez que abras Claude, el lee el cuaderno del turno y sabe exactamente
donde quedaste. Ya no necesitas repetirle "estabamos haciendo X con Y".

---

## El Inspector de Calidad (Prompt Tracker)

Todo buen restaurante tiene un sistema para mejorar. Cuando un cliente dice "esta
sopa le falta sal", eso no se olvida — se registra en una bitacora.

El **prompt-tracker** es la bitacora del restaurante:

- Cada vez que le pides algo a Claude, se registra silenciosamente
- Si tienes que corregir algo ("no, queria con menos sal"), se registra el tipo de error
- Cuando dices "perfecto" o "listo", se cierra la anotacion

**Importante**: Claude NUNCA te pregunta "¿calificame del 1 al 10?". La bitacora es
silenciosa y automatica.

Despues de varias interacciones, puedes pedirle a Claude que analice la bitacora con
`/batuta:analyze-prompts`. El te dira cosas como:

> "El 60% de las correcciones son porque falta especificar el tamano de pantalla.
> Recomendacion: cuando pidas interfaces, menciona en que pantallas debe verse bien."

Esto te ayuda a TI a darle mejores instrucciones, y a Claude a mejorar sus reglas.

---

## Los Comandos (Como le hablas al chef)

No necesitas saber programar. Solo necesitas saber estos "comandos" que son como
pedidos en el restaurante:

| Que quieres | Que escribes |
|-------------|-------------|
| Instalar Batuta en un proyecto nuevo | `/batuta-init nombre-del-proyecto` |
| Empezar a planear algo nuevo | `/sdd:init` |
| Investigar como hacer algo | `/sdd:explore tema` |
| Crear una propuesta formal | `/sdd:new nombre` |
| Continuar al siguiente paso | `/sdd:continue` |
| Construir lo que se planeo | `/sdd:apply` |
| Verificar que todo funcione | `/sdd:verify` |
| Cerrar y documentar | `/sdd:archive` |
| Crear una receta nueva | `/create:skill nombre` |
| Analizar como mejorar la comunicacion | `/batuta:analyze-prompts` |
| Actualizar inventario de recetas | `/batuta:sync-skills` |

---

## Los Roles en el Restaurante

| Rol | Quien es | Que hace |
|-----|---------|---------|
| **Dueno del restaurante** | Tu (JNMZ) | Decides que platos ofrecer, apruebas propuestas |
| **Chef principal (router)** | Claude Code + CLAUDE.md | Recibe pedidos y los pasa al jefe de area correcto. Nunca cocina. |
| **Jefes de area** | Scope Agents (pipeline, infra, observability) | Coordinan a los sub-chefs de su area |
| **Sub-chefs** | Sub-agentes SDD | Hacen el trabajo pesado: investigar, disenar, cocinar, verificar |
| **Recetas** | Skills (SKILL.md) | Instrucciones detalladas para cada plato/tecnologia |
| **Organizacion de cocina** | Scope Rule | Donde va cada cosa |
| **Checklist pre-cocina** | Execution Gate | Verifica antes de cocinar: ingredientes, ubicacion, impacto |
| **Control de calidad** | sdd-verify + O.R.T.A. | Verifican que todo salga bien |
| **Bitacora del turno** | .batuta/session.md | El cuaderno donde el chef anota en que quedo para el proximo turno |
| **Inspector de calidad** | prompt-tracker | Registra silenciosamente cada pedido y correccion para mejorar |
| **Inventario automatico** | skill-sync | Actualiza el menu y listas de recetas automaticamente |
| **Aprendiz que investiga** | ecosystem-creator | Cuando falta una receta, investiga y la crea |

---

## Diagrama simple del flujo

```
TU IDEA
   ↓
"Quiero una app que haga X"
   ↓
/batuta-init → Instala el ecosistema + crea .batuta/
   ↓
/sdd:init → Define el tipo de proyecto
   ↓
/sdd:explore → Claude investiga como hacerlo
   ↓
(Si falta un skill → lo crea automaticamente)
   ↓
/sdd:new → Claude te muestra el plan
   ↓
TU APRUEBAS
   ↓
/sdd:continue → Specs + Diseno + Tareas
   ↓
Execution Gate → Verifica antes de construir
   ↓
/sdd:apply → Claude construye la app
   ↓
/sdd:verify → Claude verifica que funcione
   ↓
Pruebas en tu computadora
   ↓
Deploy a internet (Coolify)
   ↓
/sdd:archive → Documenta y cierra
   ↓
APP LISTA EN INTERNET
```

---

## Preguntas frecuentes

**P: Necesito saber programar para usar esto?**
R: No. Solo necesitas saber copiar y pegar los comandos de las guias. Claude programa por ti.

**P: Que pasa si Claude hace algo mal?**
R: El paso de `/sdd:verify` revisa todo automaticamente. Si encuentra errores, te dice cuales son y los corrige.

**P: Puedo usar esto para cualquier tipo de proyecto?**
R: Si. El sistema funciona para aplicaciones web, automatizaciones, agentes de IA, infraestructura, y mas. Solo cambia la descripcion en `/sdd:init`.

**P: Cuanto cuesta?**
R: Claude Code tiene un costo de suscripcion. Las APIs de Google (Gmail, Gemini) son practicamente gratis para uso normal. Coolify puede correr en tu propio servidor.

**P: Que es O.R.T.A.?**
R: Son cuatro cosas que toda aplicacion de Batuta debe tener:
- **O**bservabilidad: Puedes ver que esta pasando en la app (logs, metricas). El **prompt-tracker** implementa esto para el propio ecosistema — registra cada interaccion y correccion.
- **R**epetibilidad: Si algo funciona hoy, funciona manana igual
- **T**razabilidad: Puedes seguir el rastro de cada decision y cambio. El **session.md** implementa esto — guarda el contexto de cada sesion.
- **A**uto-supervision: La app se vigila a si misma y te avisa si algo sale mal. Incluye el **Execution Gate** (preventivo: verifica ANTES de actuar) y el **prompt-tracker** (reactivo: registra DESPUES para mejorar)

**P: Si cierro la terminal, Claude se olvida de todo?**
R: No. Gracias al cuaderno del turno (`.batuta/session.md`), Claude lee donde quedo la ultima vez y continua sin que tengas que repetirle todo. Es automatico.

**P: Por que el chef principal nunca cocina directamente?**
R: Porque un CTO (director tecnico) no escribe codigo el mismo. Coordina al equipo, toma decisiones, y se asegura de que todo siga el plan. Si el CTO se pone a cocinar, nadie esta viendo el panorama completo.

---

> **Recuerda**: No necesitas entender como funciona un motor para manejar un carro.
> Solo necesitas saber los pedales y el volante. Los comandos son tus pedales,
> las guias son tu manual, y Claude es el motor.
