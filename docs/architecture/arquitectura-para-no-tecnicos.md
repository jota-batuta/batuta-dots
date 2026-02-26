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

El chef tiene **24 recetas basicas** que siempre estan disponibles (incluyendo 6 recetas de estrategia CTO agregadas en v10.0), y puede **aprender recetas nuevas** cuando las necesita.

**Detalle importante**: Las recetas NO se leen todas al empezar. El chef solo abre la
receta que necesita para el plato que esta preparando. Esto se llama "carga bajo demanda"
y hace que el chef sea mas rapido y eficiente.

---

## El Proceso de Cocina (SDD Pipeline)

Cuando un cliente pide un plato nuevo que nunca se ha hecho, el chef NO empieza a
cocinar de una. Sigue un proceso de 9 pasos:

### Los 9 pasos para crear un plato nuevo

Lo mejor: no necesitas memorizar estos pasos. Le dices al chef "quiero un plato de pollo al horno para 20 personas" y el automaticamente sigue el proceso. Tu solo apruebas en los puntos clave.

```
Tu dices: "Quiero un plato de pollo al horno para 20 personas"
      ↓
   EL CHEF AUTOMATICAMENTE:
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

### Que pasa si descubres un problema a mitad de camino?

En un restaurante real, a veces descubres que falta un ingrediente cuando ya estas cocinando. El chef de Batuta no empieza de cero — **retrocede** a la receta, la corrige, y continua desde ahi.

| El chef esta... | Descubre que... | Entonces... |
|----------------|-----------------|-------------|
| Cocinando (APPLY) | Falta un ingrediente en la receta | Vuelve a la receta (SPEC), la corrige, y sigue cocinando |
| Cocinando (APPLY) | La tecnica no funciona | Vuelve al plan de cocina (DESIGN), lo ajusta, y replanifica |
| Probando (VERIFY) | El plato no sabe como esperaba | Vuelve a cocinar (APPLY) si es un ajuste, o al plan (DESIGN) si hay que repensar |

Cada retroceso queda anotado en una bitacora para que no se pierda el aprendizaje.

### Por que tantos pasos?

Porque es MAS RAPIDO planear bien que arreglar errores despues.

Imagina que empiezas a cocinar sin receta:
- "Ups, necesitaba harina y no compre" → parar, ir al supermercado, volver
- "Ups, tenia que precalentar el horno hace 30 minutos" → esperar 30 minutos
- "Ups, la salsa no combina con la carne" → empezar de cero

Con los 9 pasos, la mayoria de esos problemas se detectan ANTES de empezar a cocinar. Y si aparece uno nuevo durante la coccion, hay un proceso claro para manejarlo sin empezar de cero.

---

## La Capa CTO (CTO Strategy Layer) — v10.0

Imagina que antes tu restaurante tenia DOS manuales: uno para el equipo de cocina (como preparar los platos) y otro para el director del restaurante (como evaluar si un plato nuevo vale la pena ofrecerlo). El director leia su manual aparte y luego le daba instrucciones verbales al chef.

**El problema**: A veces las instrucciones se perdian en la traduccion.

**La solucion (v10.0)**: Ahora hay UN solo manual que integra ambas perspectivas. El chef no solo sabe COMO cocinar, sino tambien sabe hacer las preguntas estrategicas del director.

### Los 3 puntos de control (Gates)

Antes de ciertos pasos, el chef debe pasar un "control de calidad estrategico":

| Control | Cuando | Que verifica |
|---------|--------|-------------|
| **G0.5 — Entiendo el problema?** | Antes de proponer una solucion | Que todas las variantes del plato estan identificadas, que los ingredientes especiales estan mapeados, que se sabe quien lo va a comer |
| **G1 — Vale la pena?** | Antes de empezar a planear | Que el costo de hacer el plato no supera lo que van a pagar por el, que hay suficientes clientes que lo pedirian |
| **G2 — Listo para servir?** | Antes de cerrar | Que todos los controles de calidad pasaron, que la receta esta documentada, que si algo sale mal se puede corregir |

### Los consultores especializados (6 skills nuevos)

El chef ahora puede llamar a **consultores** cuando necesita ayuda especializada:

| Consultor | Cuando lo llama | Que hace |
|-----------|---------------|---------|
| **Analista de procesos** | Cuando el plato tiene muchas variantes | Mapea TODOS los casos: el plato normal, el vegetariano, el sin gluten, el para ninos... |
| **Diseñador de aprendizaje** | Cuando los proveedores cambian sus productos | Diseña como el chef aprende nuevos ingredientes sin romper recetas existentes |
| **Ingeniero de datos** | Cuando hay que conectar con el sistema del proveedor | Diseña como llegan los pedidos y como se transforman |
| **Especialista LLM** | Cuando se usa inteligencia artificial | Diseña como la IA evalua, con que confianza, y como detectar cuando se equivoca |
| **Ingeniero de infraestructura** | Cuando hay que montar una nueva cocina | Diseña los contenedores, el despliegue, el monitoreo |
| **Oficial de cumplimiento** | Cuando hay datos personales o financieros | Verifica que se cumplan las normas colombianas de proteccion de datos |

> **La clave**: Estos consultores NO se llaman siempre — solo cuando el plato lo requiere. Un plato simple no necesita al consultor de IA. Pero un plato que usa ingredientes de otro pais SI necesita al oficial de cumplimiento.

---

## Las Dos Cocinas (Multi-Plataforma) — v10.2

Imagina que tu restaurante crece y ahora tienes DOS cocinas:

| Cocina | Que es | Cuando se usa |
|--------|--------|--------------|
| **Cocina principal** (Claude Code) | La cocina completa del restaurante, con todo el equipamiento: hornos industriales, alarmas automaticas, equipo completo de chefs, inventario inteligente | Platos elaborados, banquetes, menus nuevos, todo lo que requiere planificacion seria |
| **Cocina rapida** (Antigravity) | Una cocina satellite con el mismo recetario pero menos equipamiento: sin alarmas automaticas pero con un ayudante que le recuerda al chef los pasos | Sandwiches, ensaladas, pedidos simples, preparaciones rapidas |

**Lo importante**: Ambas cocinas usan las MISMAS recetas (skills). Si un chef inventa una receta nueva en la cocina rapida, se copia al libro maestro y automaticamente esta disponible en la cocina principal. Y viceversa.

```
Cocina principal (Claude Code)  ←→  Libro maestro (batuta-dots)  ←→  Cocina rapida (Antigravity)
```

**Por que dos cocinas?** Porque la cocina principal es mas poderosa pero tiene costo ($200/mes), mientras que la cocina rapida es GRATIS. Usas la principal para lo importante y la rapida para lo mecanico. Ambas trabajan en paralelo — como tener dos turnos trabajando al mismo tiempo.

**Diferencias tecnicas simplificadas**:
- La cocina principal tiene alarmas automaticas (hooks) que le recuerdan al chef hacer el checklist. La cocina rapida tiene un letrero en la pared que dice "No olvides el checklist" (rules).
- La cocina principal puede armar equipos temporales especiales (Agent Teams). La cocina rapida tiene un coordinador que maneja varios chefs al mismo tiempo (Manager View).
- Ambas tienen las mismas 22 recetas. Solo 2 recetas son exclusivas de la cocina principal porque necesitan las alarmas automaticas.

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
| **Jefe de Almacen** (infra) | Organizacion, inventario, seguridad, recetas | Organizacion de ingredientes (scope-rule), creacion de recetas (ecosystem-creator), inventario automatico (skill-sync), coordinador de equipo (team-orchestrator), protocolo de higiene (security-audit) |
| **Jefe de Calidad** (observability) | Control de calidad silencioso | Inspector de calidad (prompt-tracker) |

El chef principal SOLO decide a que jefe de area pasarle el pedido. El jefe de area
decide cuales sub-chefs necesita y los coordina.

**Por que es mejor asi?** Porque el chef principal no necesita recordar los 15 recetarios.
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

Ademas, `setup.sh --all` tambien instala las **alarmas automaticas** (hooks) que
hacen que el checklist y la bitacora funcionen automaticamente.

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

## El Equipo Temporal (Agent Teams) — v7

Hasta ahora, el chef principal trabaja con sus sub-chefs uno a la vez: le pide algo a uno, espera la respuesta, y luego le pide algo al siguiente. Funciona bien para el dia a dia.

Pero imagina que llega un pedido ENORME: un banquete para 200 personas, con 5 platos diferentes, postre, y decoracion especial. Un solo chef coordinando sub-chefs uno por uno NO da abasto.

**La solucion**: El chef principal puede armar un **equipo temporal** — como contratar cocineros extra para el banquete.

### Los 3 niveles de trabajo

| Nivel | Analogia | Cuando se usa |
|-------|----------|---------------|
| **Solo** | El chef cocina un plato el mismo | Arreglar un error, responder una pregunta, editar algo simple |
| **Sub-chef** | El chef le pide ayuda puntual a un colega | "Investiga esto y dime que encuentras" — el resultado vuelve al chef |
| **Equipo temporal** | El chef arma un squad con cocina propia | Cada cocinero tiene su propia estacion, su propio espacio, y se comunican entre ellos |

### Como funciona el equipo temporal

```
1. PLANEAR    → El chef evalua: "Esto es grande, necesito equipo"
2. ARMAR      → Elige cocineros segun el menu (uno para carnes, otro para postres)
3. ASIGNAR    → Reparte las tareas: "Tu haces el pollo, tu el pastel"
4. COCINAR    → Cada cocinero trabaja EN PARALELO en su estacion
5. VERIFICAR  → Un inspector revisa cada plato antes de servirlo
6. CONSOLIDAR → El chef junta todo y presenta el banquete completo
```

### Las reglas del equipo

- **Cada cocinero tiene su propia cocina**: No se estorban entre ellos
- **Se comunican por notas**: "Ya termine la salsa, la dejo en el refrigerador"
- **Hay un inspector automatico**: Cuando alguien termina un plato, el inspector verifica que siga la receta y que los ingredientes esten en su lugar
- **Solo el chef principal anota en la bitacora**: Para evitar que todos escriban al mismo tiempo y hagan un desorden
- **El chef puede pedirle al cocinero que PLANEE antes de cocinar**: Como un Execution Gate para cada miembro del equipo

### Ejemplo practico

Imagina que quieres construir una app con tres partes: la pantalla que ve el usuario, los calculos internos, y la conexion con otra app.

**Sin equipo temporal**: El chef hace las tres cosas UNA POR UNA. Primero la pantalla, luego los calculos, luego la conexion. Toma 3x tiempo.

**Con equipo temporal**: El chef arma tres cocineros, cada uno hace una parte AL MISMO TIEMPO. El chef coordina y al final junta todo. Toma ~1x tiempo (con un poco extra de coordinacion).

### Los jefes de area se convierten en "manuales de entrenamiento"

Los jefes de area (pipeline, infra, calidad) ahora tienen un doble rol:

- **Cuando trabaja solo el chef**: Funcionan como siempre — guias de referencia
- **Cuando hay equipo temporal**: Se convierten en el "manual de entrenamiento" para cada cocinero nuevo. El chef le da el manual al cocinero y este sabe exactamente que hacer

> **Importante**: El equipo temporal es como contratar extras para un banquete — se arma para la tarea grande y cuando termina, cada quien se va. No es permanente. Para tareas normales, el chef sigue trabajando solo o con sus sub-chefs de siempre.

---

## Las Alarmas Automaticas (Native Hooks) — v8

Imagina que el restaurante tiene un sistema de alarmas automaticas que funcionan sin que nadie las active:

| Alarma | Cuando suena | Que hace |
|--------|-------------|---------|
| **Alarma de apertura** (SessionStart) | Cuando el chef empieza su turno | Lee el cuaderno del turno anterior y las instrucciones del restaurante |
| **Alarma de cocina** (PreToolUse) | Cuando el chef va a tocar un plato | Ejecuta el checklist automaticamente — si no pasa, no puede cocinar |
| **Alarma de cierre** (Stop) | Cuando el chef termina su turno | Guarda notas en el cuaderno para el siguiente turno |

**Por que importa**: Antes, el chef tenia que "acordarse" de leer el cuaderno y hacer el checklist. Ahora las alarmas lo obligan — es imposible saltarselo. Es como tener un sistema contra incendios que funciona solo, sin depender de que alguien recuerde activarlo.

---

## El Control de Calidad por Capas (AI Validation Pyramid) — v8

Imagina que antes de servir un plato, pasa por 5 controles de calidad, como una linea de inspeccion en una fabrica:

```
Nivel 5: TU pruebas el plato (obligatorio — el humano tiene la ultima palabra)
Nivel 4: Un critico gastronomico lo evalua (humano experto o chef senior)
Nivel 3: Se prueba que el plato completo funcione junto (integracion)
Nivel 2: Se prueba cada ingrediente por separado (sabor, frescura)
Nivel 1: Se verifica que los ingredientes basicos sean correctos (no estan vencidos)
```

**La regla clave**: Los niveles 1-3 los hace el chef automaticamente (rapido). Los niveles 4-5 SIEMPRE requieren un humano. No existe la calidad 100% automatica — tu siempre tienes la ultima palabra antes de servir.

---

## La Comanda Precisa (Contract-First Protocol) — v9

En un restaurante con equipo temporal, el error mas comun es que el chef le dice al cocinero "haz el pollo" y el cocinero hace algo completamente diferente a lo esperado. La solucion? **Comandas precisas**.

Antes de que el cocinero empiece, el chef le entrega una comanda que dice:

```
COMANDA PARA COCINERO A
- Recibiras: la receta del pollo al horno, los ingredientes ya pesados
- Debes producir: el pollo listo, en bandeja #3, con salsa aparte
- Tu estacion: solo usas el horno #2 y la mesa 4 (no toques nada mas)
```

Esto evita tres problemas clasicos:
1. **Producto diferente al esperado**: La comanda dice exactamente que se espera
2. **Cocineros estorbandose**: Cada uno tiene su estacion asignada — no se cruzan
3. **Platos incompletos**: Antes de servir, el chef compara el plato con la comanda. Si falta la salsa, se devuelve

> **Tip**: Piensa en las comandas como los contratos de un proyecto — si todo esta escrito desde el principio, nadie puede decir "yo entendi otra cosa".

---

## Los Menus Especializados (Team Templates) — v9

Imagina que el restaurante tiene menus pre-armados para diferentes tipos de eventos:

| Evento | Menu | Cocineros |
|--------|------|-----------|
| **Boda elegante** (App web SaaS) | Menu de 5 tiempos con decoracion | Chef de carnes, pastelero, decorador |
| **Catering de oficina** (Microservicio API) | Sandwiches + ensaladas + bebidas | Chef rapido, ayudante de calidad, empacador |
| **Food truck** (Automatizacion n8n) | Tacos + aguas frescas | Taquero, ayudante |
| **Curso de cocina** (Agente IA) | Clase practica paso a paso | Instructor, ayudante de seguridad, critico |
| **Banquete industrial** (Pipeline de datos) | Comida para 500+ personas | Chef de linea, inspector de calidad, logistica |
| **Renovar el menu** (Refactoring) | Modernizar platos clasicos sin perder sabor | Analista de recetas, dos cocineros, critico |

Estos menus se guardan en `teams/templates/` y el chef solo tiene que elegir el que mas se parece a lo que necesitas.

---

## El Manual del Mesero Experimentado (Playbook) — v9

El **playbook** (`teams/playbook.md`) es como el manual que le das a un mesero nuevo para que sepa como funciona todo sin tener que preguntarle a alguien cada 5 minutos:

- **Cuando pedir equipo extra**: Solo para eventos grandes. Para un sandwich, no necesitas 3 cocineros
- **Errores que todos cometen**: No armar equipo para tareas simples, no dar comandas claras, dejar que dos cocineros usen la misma olla
- **Como elegir el menu correcto**: Segun el tipo de evento y cuantos invitados hay
- **Como crear un menu nuevo**: Si ningun menu existente sirve para tu evento

---

## El Protocolo de Higiene (Security-Audit) — v9

Todo restaurante serio tiene un protocolo de higiene. En la cocina digital, la "higiene" es la **seguridad**:

| Inspeccion | Que revisa | Ejemplo |
|-----------|-----------|---------|
| **Ingredientes contaminados** | Codigo con vulnerabilidades comunes (OWASP) | Verificar que no hay inyecciones de codigo o datos sin validar |
| **Llaves de la cocina expuestas** | Secretos visibles en el codigo | Contraseñas, tokens de API, credenciales de base de datos |
| **Proveedores dudosos** | Dependencias con problemas conocidos | Librerias desactualizadas o con vulnerabilidades |
| **Plan contra robos** | Modelo de amenazas | Quien podria atacar, como, y que protegemos |
| **Higiene del chef AI** | Proteccion especifica para apps con IA | Que nadie pueda manipular al agente o abusar del servicio |

El protocolo de higiene se revisa en DOS momentos:
1. **Al disenar el plato** (sdd-design): Se planea la proteccion ANTES de cocinar
2. **Al verificar el plato** (sdd-verify): Se inspecciona DESPUES de cocinar

> **Regla de oro**: La seguridad no se agrega al final — se planea desde el principio. Es como lavarse las manos ANTES de cocinar, no despues de servir.

---

## Como le hablas al chef

No necesitas saber programar NI memorizar comandos. Simplemente describe lo que necesitas:

| Que quieres | Que le dices a Batuta |
|-------------|----------------------|
| Construir algo nuevo | "Necesito una app que haga X" |
| Investigar algo | "Como funciona el sistema de pagos?" |
| Continuar donde quedaste | "Donde quedamos?" o "sigue con lo de ayer" |
| Corregir un problema descubierto | "Esto no funciona, falta manejar el caso X" |
| Arreglar un bug puntual | "El boton de login no funciona" |

Batuta detecta que necesitas y ejecuta el proceso automaticamente. Tu solo apruebas en los momentos clave (la propuesta y el plan de tareas).

### Comandos manuales (para los que quieren control total)

Si prefieres controlar cada paso directamente, tambien puedes usar comandos:

| Que quieres | Que escribes |
|-------------|-------------|
| Instalar Batuta en un proyecto nuevo | `/batuta-init nombre-del-proyecto` |
| Empezar a planear algo nuevo | `/sdd-init` |
| Investigar como hacer algo | `/sdd-explore tema` |
| Crear una propuesta formal | `/sdd-new nombre` |
| Continuar al siguiente paso | `/sdd-continue` |
| Construir lo que se planeo | `/sdd-apply` |
| Verificar que todo funcione | `/sdd-verify` |
| Cerrar y documentar | `/sdd-archive` |
| Crear una receta nueva | `/create-skill nombre` |
| Analizar como mejorar la comunicacion | `/batuta:analyze-prompts` |
| Actualizar inventario de recetas | `/batuta:sync-skills` |

---

## Los Roles en el Restaurante

| Rol | Quien es | Que hace |
|-----|---------|---------|
| **Dueno del restaurante** | Tu (el usuario) | Decides que platos ofrecer, apruebas propuestas |
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
| **Equipo temporal** | Agent Teams (v7) | Cocineros extra para banquetes grandes — trabajan en paralelo, cada uno con su estacion |
| **Coordinador de equipo** | team-orchestrator (v7) | Decide cuando armar equipo temporal y como repartir las tareas |
| **Alarmas automaticas** | Native Hooks (v8) | Alarmas que obligan al chef a seguir el proceso sin que pueda saltarselo |
| **Control de calidad por capas** | AI Validation Pyramid (v8) | 5 niveles de inspeccion — los primeros 3 automaticos, los ultimos 2 humanos |
| **Comandas precisas** | Contract-First Protocol (v9) | Contratos escritos que definen que recibe y que produce cada cocinero |
| **Menus especializados** | Team Templates (v9) | Configuraciones pre-armadas de equipo para diferentes tipos de proyecto |
| **Manual del mesero** | Playbook (v9) | Guia de cuando y como usar equipos temporales, errores comunes |
| **Protocolo de higiene** | Security-Audit (v9) | Revision de seguridad: al disenar y al verificar |
| **Controles estrategicos** | Gates G0.5/G1/G2 (v10) | Entiendo? Vale la pena? Listo? |
| **Consultores especializados** | 6 skills CTO (v10) | Procesos, IA, datos, infra, compliance |
| **Cocina rapida** | Antigravity IDE (v10.2) | Segunda cocina con el mismo recetario, para pedidos rapidos y mecanicos |
| **Libro maestro compartido** | batuta-dots hub (v10.2) | Todas las recetas en un solo lugar, sincronizadas entre ambas cocinas |

---

## Diagrama simple del flujo

```
TU IDEA
   ↓
"Quiero una app que haga X"
   ↓
Batuta detecta: proyecto nuevo, necesita SDD
   ↓
Automaticamente: instala ecosistema + investiga el problema
   ↓
(Si falta un skill → lo crea automaticamente)
   ↓
Claude te presenta la propuesta
   ↓
TU APRUEBAS
   ↓
Claude automaticamente: Specs + Diseno + Tareas
   ↓
Claude te presenta el plan
   ↓
TU APRUEBAS
   ↓
Claude construye la app (Execution Gate verifica cada archivo)
   ↓
(Si descubre un problema → retrocede, corrige, y sigue)
   ↓
Claude verifica que funcione
   ↓
Pruebas en tu computadora
   ↓
Deploy a internet (Coolify)
   ↓
Claude documenta y cierra
   ↓
APP LISTA EN INTERNET
```

---

## Preguntas frecuentes

**P: Necesito saber programar para usar esto?**
R: No. Solo necesitas describir lo que quieres en lenguaje natural. Claude programa por ti. Los comandos existen como opcion para control directo, pero no son necesarios.

**P: Que pasa si Claude hace algo mal?**
R: El paso de `/sdd-verify` revisa todo automaticamente. Si encuentra errores, te dice cuales son y los corrige.

**P: Puedo usar esto para cualquier tipo de proyecto?**
R: Si. El sistema funciona para aplicaciones web, automatizaciones, agentes de IA, infraestructura, y mas. Solo cambia la descripcion en `/sdd-init`.

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

**P: Cuando se usa el equipo temporal (Agent Teams)?**
R: Solo para tareas grandes que tienen muchas partes independientes. Piensa en la diferencia entre cocinar un sandwich (solo) y preparar un banquete (equipo). Para el dia a dia, el chef trabaja solo o con ayuda puntual. El equipo temporal se arma solo cuando vale la pena la coordinacion extra.

**P: El equipo temporal cuesta mas?**
R: Si. Cada cocinero temporal es como tener otro chef completo trabajando. Si armas un equipo de 3, es como pagar 3 chefs. Por eso solo se usa cuando la tarea es lo suficientemente grande para justificarlo.

**P: Por que el chef principal nunca cocina directamente?**
R: Porque un CTO (director tecnico) no escribe codigo el mismo. Coordina al equipo, toma decisiones, y se asegura de que todo siga el plan. Si el CTO se pone a cocinar, nadie esta viendo el panorama completo.

---

## La Regla y el MCP Discovery (v11.0)

### La Regla — Como un reglamento de seguridad en una fabrica

En una fabrica, hay procedimientos obligatorios: casco, gafas de seguridad, protocolo de emergencia. No importa si eres el mas experimentado — SIEMPRE los sigues. "La Regla" en Batuta es igual: si existe un procedimiento (skill) para lo que estas haciendo, lo sigues. No hay excepciones, no hay atajos.

Antes de v11.0, era como tener carteles de seguridad pegados en la pared — dependias de que la gente los leyera. Ahora es como un torniquete automatico: no entras a la planta sin tu casco.

### MCP Discovery — Como verificar herramientas antes de construir

Antes de empezar a construir una pared, un albanil revisa: "Tengo las herramientas correctas? Hay una mejor que la que tengo?". MCP Discovery hace exactamente eso — antes de escribir codigo, verifica que herramientas (servidores MCP) estan disponibles y cuales convendria instalar.

Es como la diferencia entre un albanil que trabaja con lo que tiene en el bolsillo vs uno que primero revisa la bodega completa de la ferreteria.

### Review en 2 etapas — Como una revision de planos

Un arquitecto diseña los planos, pero antes de construir: un ingeniero estructural verifica que cumple con las normas (revision de spec), y un inspector de calidad verifica que los materiales son correctos (revision de calidad). Solo cuando ambos aprueban, se construye. En Batuta v11.0, las tareas complejas pasan por esta misma doble revision automatica.

---

> **Recuerda**: No necesitas entender como funciona un motor para manejar un carro.
> Solo necesitas saber los pedales y el volante. Los comandos son tus pedales,
> las guias son tu manual, y Claude es el motor.
