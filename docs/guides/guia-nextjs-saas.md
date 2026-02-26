# Guia Paso a Paso: App SaaS con Next.js y Claude Code

> **Para quien es esta guia**: Para cualquier persona, sin importar si nunca ha programado.
> Solo necesitas saber copiar y pegar texto. Claude Code hace el resto.
>
> **Formato**: Sigue los pasos en orden, como cuando aprendes a manejar un carro:
> primero el cinturon, luego el espejo, luego el freno, luego arrancar.
> Cada paso depende del anterior.

---

## Glosario — Palabras que vas a ver

Antes de empezar, aqui tienes un mini-diccionario. No necesitas memorizarlo, vuelve aqui si ves una palabra que no entiendes.

| Palabra | Que significa (sin tecnicismos) |
|---------|-------------------------------|
| **SaaS** | Software as a Service. Una aplicacion en internet que varios clientes usan al mismo tiempo, cada uno con su propia cuenta. Piensa en Netflix: todos usamos la misma app, pero cada uno tiene su perfil y sus peliculas guardadas. |
| **Multi-tenant** | Que multiples clientes ("inquilinos") comparten la misma aplicacion pero sus datos estan separados. Como un edificio de apartamentos: todos viven en el mismo edificio, pero cada quien tiene su llave y su espacio privado. |
| **Next.js** | Una herramienta para construir paginas web modernas. Piensa en ella como una fabrica de sitios web que viene con todo lo necesario incluido: la estructura, el motor, y las herramientas. |
| **App Router** | La forma en que Next.js organiza las paginas de tu sitio. Cada carpeta es una pagina. Si creas una carpeta llamada "dashboard", automaticamente tienes una pagina en `tuapp.com/dashboard`. |
| **Prisma** | Un traductor entre tu aplicacion y la base de datos. En vez de hablar el idioma de la base de datos (SQL), le hablas en un idioma mas simple y Prisma traduce. |
| **PostgreSQL** | Una base de datos. Es como un archivero gigante y muy organizado donde se guardan todos los datos de tu aplicacion: usuarios, suscripciones, configuraciones. |
| **NextAuth** | Una libreria que se encarga del login de usuarios. Maneja todo: el formulario de entrada, la contrasena encriptada, la sesion del usuario, el "Olvide mi contrasena". |
| **Dashboard** | Un panel de control. La pantalla principal que ves despues de iniciar sesion, con graficas, numeros, y accesos rapidos. Como el tablero de un carro. |
| **Suscripcion** | El plan que un cliente paga para usar tu aplicacion. Como los planes de Netflix: basico, estandar, premium. Cada uno tiene distintas funciones. |
| **Panel de administracion** | Una seccion especial solo para los duenos de la aplicacion. Desde ahi puedes ver todos los clientes, sus suscripciones, y manejar la configuracion general. |
| **Migracion** | Un cambio organizado en la estructura de la base de datos. Como remodelar una habitacion: tienes un plano de como era antes, que cambias, y como queda despues. Si algo sale mal, puedes "regresar" al estado anterior. |
| **API** | Un "mesero" que lleva pedidos entre sistemas. Cuando la pantalla necesita datos, le pide al API, y el API va a la base de datos y trae la respuesta. |
| **Middleware** | Un "guardia de seguridad" que revisa cada peticion antes de dejarla pasar. Verifica que el usuario tenga permiso de ver lo que pide. |
| **CSRF** | Cross-Site Request Forgery. Un tipo de ataque donde alguien intenta hacer acciones en tu app haciendose pasar por ti. Como si alguien falsificara tu firma para hacer un tramite. |
| **XSS** | Cross-Site Scripting. Un tipo de ataque donde alguien intenta inyectar codigo malicioso en tu pagina. Como si alguien metiera una carta trampa en tu buzon. |
| **Variable de entorno** | Un dato secreto que tu aplicacion necesita pero que NO debe estar en el codigo. Como la combinacion de una caja fuerte: la app la necesita para funcionar, pero nunca la escribes en un papel visible. |
| **Deploy** | Poner tu aplicacion en internet para que otros la vean. Como subir una foto a Instagram, pero con toda una aplicacion. |
| **Docker** | Una herramienta que empaqueta tu aplicacion con TODO lo que necesita para funcionar. Como enviar un paquete con el regalo, las pilas, y las instrucciones incluidas. |
| **Vercel** | Una plataforma para poner aplicaciones Next.js en internet. Es como un hosting especializado que sabe exactamente como manejar Next.js. |
| **Prompt** | El mensaje que le escribes a Claude. Como enviarle un WhatsApp con instrucciones. |
| **Claude Code** | Un asistente de programacion que vive en tu terminal. Tu le dices que quieres y el lo construye. |
| **Terminal** | La pantalla negra donde escribes comandos. Piensa en ella como un chat con tu computadora. |
| **Skill** | Un documento que le dice a Claude COMO hacer algo especifico. Como una receta de cocina. |
| **SDD** | Spec-Driven Development. Un proceso paso a paso para construir software: primero planeas, luego construyes. Como un arquitecto que primero dibuja el plano y luego construye la casa. |
| **Repositorio (repo)** | Una carpeta especial que guarda todo tu codigo y recuerda cada cambio que haces. |
| **Scope Agent** | Un "jefe de area" especializado. Claude tiene 3: uno para el proceso de desarrollo, uno para organizacion de archivos, y uno para calidad. |
| **Execution Gate** | Un checklist que Claude ejecuta ANTES de hacer cualquier cambio de codigo. Verifica que todo este en orden. |

---

## Que vamos a construir

**Mi SaaS App** — Una aplicacion web completa tipo SaaS (Software as a Service) donde:

1. **Registro y login de usuarios**: Las personas se registran con su email y contrasena, verifican su cuenta, y pueden recuperar su contrasena si la olvidan
2. **Dashboard con graficas**: Despues de iniciar sesion, cada usuario ve un panel de control con graficas y numeros relevantes sobre su uso de la aplicacion
3. **Gestion de suscripciones**: Los usuarios pueden elegir un plan (gratis, basico, premium), actualizar su plan, o cancelar su suscripcion
4. **Panel de administracion**: Los duenos de la aplicacion pueden ver todos los usuarios registrados, sus planes, metricas de uso, y administrar la configuracion general
5. **Multi-tenant**: Cada cliente ve SOLO sus datos. Los datos de un cliente nunca se mezclan con los de otro

### Tecnologias que Claude va a usar

No necesitas instalar ni entender estas tecnologias. Claude se encarga de todo. Solo es informativo.

| Tecnologia | Para que la usamos | Analogia |
|------------|-------------------|----------|
| **Next.js 14+ (App Router)** | Construir todas las paginas y la logica del servidor | La estructura y el motor del edificio |
| **Prisma** | Comunicarse con la base de datos | El traductor que habla con el archivero |
| **PostgreSQL** | Guardar todos los datos | El archivero organizado |
| **NextAuth** | Manejar el login y registro | El portero del edificio |
| **Tailwind CSS** | Hacer que la app se vea bonita | El decorador de interiores |
| **Recharts o Chart.js** | Las graficas del dashboard | El dibujante de graficas |

---

## Antes de empezar — Lo que necesitas tener instalado

Pide ayuda a alguien para instalar estas cosas si no las tienes:

| Herramienta | Para que sirve | Como instalar |
|-------------|---------------|---------------|
| **Node.js** | Hace que JavaScript funcione en tu computadora | Descarga de [nodejs.org](https://nodejs.org) la version LTS |
| **Git** | Guarda el historial de tu proyecto | Descarga de [git-scm.com](https://git-scm.com) |
| **Claude Code** | El asistente que va a programar por ti | En la terminal escribe: `npm install -g @anthropic-ai/claude-code` |
| **PostgreSQL** | La base de datos donde se guardan los datos | Descarga de [postgresql.org](https://www.postgresql.org/download/) o usa Docker (ver abajo) |

### Opcion alternativa para PostgreSQL: Docker

Si no quieres instalar PostgreSQL directamente en tu computadora, puedes usar Docker. Docker es como una "caja" que contiene PostgreSQL listo para usar sin ensuciar tu sistema.

| Herramienta | Para que sirve | Como instalar |
|-------------|---------------|---------------|
| **Docker Desktop** | Correr PostgreSQL en un contenedor aislado | Descarga de [docker.com](https://www.docker.com/products/docker-desktop/) |

### Verificar que todo esta instalado

Abre una terminal y escribe estos comandos uno por uno:

```
node --version
git --version
claude --version
```

Si los tres muestran un numero (como `v20.11.0`), estas lista.

Para PostgreSQL, verifica con:
```
psql --version
```

O si usas Docker:
```
docker --version
```

Si alguno NO muestra un numero, instala esa herramienta antes de continuar.

---

# PASO A PASO

> Sigue cada paso en orden. No saltes pasos — cada uno depende del anterior,
> como cuando aprendes a manejar.

---

## Paso 1 — Crear la carpeta del proyecto

**Que vamos a hacer**: Crear una carpeta vacia donde vivira toda nuestra aplicacion SaaS.

**Que hacer**:
1. Abre el Explorador de Archivos de Windows
2. Ve a donde quieras guardar tu proyecto (ejemplo: `E:\Proyectos\`)
3. Click derecho → Nueva Carpeta
4. Nombrala: `mi-saas-app`

> **Nota**: Si la carpeta ya tiene archivos de un intento anterior, borra su contenido primero o usa otra carpeta vacia.

> **IMPORTANTE**: Usa nombres SIN espacios y en minusculas (ejemplo: `mi-saas-app`, no `Mi SaaS App`).
> Los espacios y mayusculas causan problemas con las herramientas de Node.js como npm.
> Usa guiones (-) en lugar de espacios.

**Resultado**: Tienes una carpeta vacia llamada `mi-saas-app`.

---

## Paso 2 — Abrir Claude Code e instalar el ecosistema Batuta

**Que vamos a hacer**: Abrir el asistente de programacion dentro de tu carpeta y darle las "recetas" (skills) que necesita para trabajar al estilo Batuta.

**Que hacer**:
1. Abre una terminal (busca "Terminal" o "Command Prompt" en Windows)
2. Escribe exactamente esto y presiona Enter:

```
cd "E:\Proyectos\mi-saas-app"
```

> Cambia la ruta si tu carpeta esta en otro lugar.

3. Ahora escribe:

```
claude
```

Se abre Claude Code. Vas a ver algo como:
```
Claude Code v1.x.x
>
```
Ese `>` es donde le escribes tus instrucciones.

4. Ahora instala el ecosistema Batuta.

**Opcion A — Si ya tienes los commands de Batuta instalados** (recomendado):

> **IMPORTANTE**: Asegurate de estar dentro de la carpeta de tu proyecto antes de ejecutar este comando. Todo lo que Claude cree se guardara en la carpeta actual.

```
/batuta-init mi-saas-app
```

Y listo. Claude configura todo automaticamente.

**Opcion B — Si es la primera vez y no tienes los commands:**

Copia y pega este prompt:

```
Necesito configurar este proyecto con el ecosistema Batuta.

Haz lo siguiente:
1. Clona el repositorio github.com/jota-batuta/batuta-dots en una carpeta temporal
2. Ejecuta: bash <ruta-a-batuta-dots>/infra/setup.sh --project .
3. Inicializa git en esta carpeta si no existe
4. Confirma cuando todo este listo
```

Esto crea CLAUDE.md, la carpeta .batuta/, sincroniza skills, e instala hooks en tu proyecto.

> Despues de esta primera vez, los commands `/batuta-init` y `/batuta-update` quedan
> instalados y ya no necesitas copiar el prompt largo nunca mas.

**Que esperar**: Claude va a descargar el ecosistema y configurar todo. Puede tomar 1-2 minutos. Cuando termine, te dira que archivos creo, incluyendo:
- `CLAUDE.md` — Las instrucciones del chef (router principal + scope agents + execution gate)
- `.batuta/session.md` — El cuaderno donde Claude anota en que quedo (para continuar despues)

**Tip**: Si Claude te pide permiso para ejecutar comandos, di "yes" o "si".

**Resultado**: Tu carpeta ahora tiene el ecosistema Batuta instalado.

---

## Paso 3 — Inicializar el proyecto SDD

**Que vamos a hacer**: Decirle a Claude que tipo de proyecto vamos a construir para que se prepare correctamente. Como cuando un arquitecto registra el tipo de obra antes de empezar.

**Copia y pega este prompt:**

```
/sdd-init
```

Cuando Claude pregunte:

| Si Claude pregunta... | Tu respondes... |
|----------------------|-----------------|
| Nombre del proyecto | `mi-saas-app` |
| Tipo de proyecto | `webapp` |
| Descripcion | `Aplicacion SaaS multi-tenant con registro de usuarios, dashboard con graficas, gestion de suscripciones, y panel de administracion. Usando Next.js, Prisma, PostgreSQL y NextAuth.` |

**Que esperar**: Claude te va a hacer preguntas. Cuando termine, va a guardar la configuracion base del proyecto.

---

## Paso 4 — Cuando Claude dice "no tengo un skill para eso"

**Que vamos a hacer**: Entender que pasa cuando Claude detecta que necesita aprender algo nuevo. Esto es como si un chef te dijera "no tengo la receta para ese plato, pero puedo investigarla".

**MOMENTO IMPORTANTE**: Durante el proceso de desarrollo (especialmente al ejecutar `/sdd-new`), Claude probablemente detecte que necesita skills para varias tecnologias. Te va a preguntar que hacer para cada una.

**Cuando Claude diga algo como:**
> "No tengo un skill documentado para Next.js App Router... Te propongo:
> 1. Investigar y crear el skill (proyecto)
> 2. Investigar y crear el skill (global)
> 3. Continuar sin skill"

**Tu respuesta siempre debe ser:**

```
Opcion 1 — Investiga y crea el skill acotado a nuestro proyecto
```

**Esto puede pasar varias veces para:**
- Next.js App Router (como construir las paginas)
- Prisma (como comunicarse con la base de datos)
- NextAuth (como manejar el login)
- PostgreSQL (configuracion de la base de datos)
- Multi-tenancy (como separar datos entre clientes)
- Graficas (como mostrar los datos visualmente)

**Cada vez que te pregunte, responde "Opcion 1"**.

Claude va a investigar usando Context7 (su base de conocimiento actualizada) y crear las recetas que necesita. Esto toma unos minutos por skill, pero solo pasa una vez.

> **Detalle tecnico (opcional)**: El infra-agent (jefe de organizacion) coordina la creacion
> de skills nuevos. Usa el ecosystem-creator para investigar y documentar la tecnologia.

**Tip**: Este paso puede tomar 15-20 minutos en total. Es normal. Claude esta "aprendiendo" para hacerlo bien a la primera. Puedes ir por un cafe mientras tanto.

---

## Paso 5 — Crear la propuesta

**Que vamos a hacer**: Pedirle a Claude que escriba un plan formal de lo que va a construir. Como cuando un arquitecto te muestra el boceto antes de construir.

**Copia y pega este prompt:**

```
/sdd-new mi-saas-app
```

Este comando primero explora tu proyecto y luego genera una propuesta automaticamente.

**Que esperar**: Claude va a crear un documento llamado "proposal" que incluye:
- Que se va a construir (en lenguaje simple)
- Que riesgos hay
- Criterios de exito (como sabemos que funciona)

Claude te va a mostrar un **resumen** y te preguntara si esta bien.

**Lee el resumen con calma**. Si algo no te suena bien, dile. Por ejemplo:

```
Me parece bien pero quiero que el dashboard tambien muestre una tabla con
los ultimos miembros que se unieron a la organizacion.
```

**Cuando estes conforme, di:**

```
Aprobado, continua con el siguiente paso
```

---

## Paso 6 — Especificaciones y diseno

**Que vamos a hacer**: Dejar que Claude defina los detalles tecnicos: exactamente que tablas crear en la base de datos, como se conectan las paginas, y que hace cada parte de la aplicacion.

**Copia y pega este prompt:**

```
/sdd-continue mi-saas-app
```

Ejecuta `/sdd-continue` UNA vez por fase. Claude mostrara el resultado y te pedira confirmacion antes de avanzar. Repite hasta completar las fases pendientes (specs, design, tasks).

> **Alternativa rapida**: `/sdd-ff mi-saas-app` ejecuta todas las fases pendientes de corrido sin pausas.

**Que esperar**: Claude va a ejecutar las siguientes fases una por una:

| Fase | Que hace | Cuanto toma |
|------|---------|-------------|
| **Specs** | Define EXACTAMENTE que debe hacer cada pagina, cada boton, cada tabla de la base de datos | 3-5 min |
| **Design** | Decide la arquitectura: como se organizan los archivos, como fluye la informacion entre las partes | 5-8 min |
| **Tasks** | Divide todo el trabajo en tareas pequenas y ordenadas, agrupadas en "lotes" (batches) | 3-5 min |

**Entre cada fase**, Claude te va a mostrar un resumen y preguntar si continua.

**Tu respuesta cada vez:**

```
Se ve bien, continua
```

**Si algo no entiendes**, pregunta sin miedo:

```
No entendi la parte de "middleware de autenticacion". Explicame que significa
eso en terminos simples.
```

Claude esta configurado para explicarte las cosas de forma que cualquier persona las entienda.

**Tip**: Este paso puede tomar 10-20 minutos. Puedes ir por un cafe mientras Claude trabaja entre fases.

---

## Paso 7 — Construir el esquema de base de datos

**Que vamos a hacer**: Crear la estructura de la base de datos. Es como dibujar las estanterias y los cajones del archivero ANTES de empezar a guardar documentos. Este es el primer lote de implementacion.

**Copia y pega este prompt:**

```
/sdd-apply mi-saas-app

Empieza por el Batch 1: estructura del proyecto y base de datos.
Incluye:
- Inicializar el proyecto Next.js con App Router
- Configurar Prisma con PostgreSQL
- Crear el esquema de base de datos con todas las tablas:
  usuarios, organizaciones, membresias, suscripciones, planes, actividad
- Ejecutar la primera migracion
- Configurar las variables de entorno con valores de desarrollo
```

**Que esperar**: Antes de empezar a escribir codigo, Claude va a ejecutar el **Execution Gate** — un checklist automatico que verifica:
- Que archivos va a crear/modificar
- Donde van a ir (siguiendo la Scope Rule)
- Que impacto tienen los cambios
- Que todo este alineado con las especificaciones

Te mostrara algo como:
```
Este cambio involucra scope pipeline + infra:
- Inicializar proyecto Next.js
- Crear 8 archivos de esquema en core/
- Ejecutar migracion de Prisma
- Procedo?
```

Di "si" y Claude creara todo.

**MOMENTO IMPORTANTE — Conexion a PostgreSQL:**

Claude necesita saber donde esta tu base de datos. Cuando pregunte:

**Si instalaste PostgreSQL directamente:**

```
La base de datos esta en mi computadora.
Usa estos datos:
- Host: localhost
- Puerto: 5432
- Usuario: postgres
- Contrasena: [tu contrasena de PostgreSQL]
- Nombre de la base de datos: mi_saas_dev
```

**Si prefieres usar Docker:**

```
Usa Docker para la base de datos. Crea un docker-compose.yml que levante
PostgreSQL con estos datos:
- Usuario: saas_user
- Contrasena: saas_dev_password
- Nombre de la base de datos: mi_saas_dev
- Puerto: 5432
```

> **IMPORTANTE**: Estas contrasenas son solo para desarrollo en tu computadora.
> Cuando la app vaya a internet, usaras contrasenas seguras diferentes.

**Resultado**: La estructura del proyecto esta creada con la base de datos configurada.

---

## Paso 8 — Implementar autenticacion

**Que vamos a hacer**: Construir todo el sistema de login, registro, y manejo de sesiones. Es como instalar las cerraduras y las llaves del edificio.

**Copia y pega este prompt:**

```
Continua con el siguiente batch: autenticacion.

Implementa:
1. NextAuth configurado con credenciales (email + contrasena)
2. Pagina de registro: formulario con nombre, email, contrasena, nombre de la organizacion
3. Pagina de login: formulario con email y contrasena
4. Pagina de "Olvide mi contrasena": formulario que envia un email con un link para resetear
5. Middleware que protege todas las paginas del dashboard (solo usuarios logueados pueden entrar)
6. Al registrarse, se crea automaticamente una organizacion nueva para el usuario
7. Roles: el que crea la organizacion es "admin", los que se unen son "miembro"

Para el envio de emails de verificacion y reseteo, usa una configuracion
basica que funcione en desarrollo (puede ser console.log del link por ahora).
```

**Que esperar**: Claude ejecutara el Execution Gate y luego implementara:
- Las paginas de login, registro, y recuperacion de contrasena
- La logica del servidor para verificar credenciales
- El middleware de proteccion de rutas
- La configuracion de NextAuth

Di "Si, continua" cuando te pida aprobacion para cada grupo de archivos.

**Tip**: Si Claude pide instalar dependencias (librerias), di "yes".

**Resultado**: Tu app ya tiene login y registro funcionando.

---

## Paso 9 — Implementar el dashboard

**Que vamos a hacer**: Construir la pantalla principal que los usuarios ven despues de iniciar sesion: graficas, numeros, y actividad reciente. Es como construir la sala principal del edificio.

**Copia y pega este prompt:**

```
Continua con el siguiente batch: dashboard y navegacion.

Implementa:
1. Layout principal del dashboard con:
   - Sidebar (barra lateral) con navegacion: Dashboard, Miembros, Suscripcion, Configuracion
   - Header (barra superior) con el nombre del usuario y boton de cerrar sesion
   - Area principal donde se muestra el contenido de cada pagina

2. Pagina de Dashboard (la principal):
   - 4 tarjetas de resumen: Total de miembros, Plan actual, Proyectos activos, Actividad del mes
   - Grafica de barras: actividad diaria de los ultimos 30 dias
   - Grafica circular: distribucion por categoria (configurable)
   - Lista de las ultimas 10 actividades con fecha, descripcion y quien la hizo

3. Que todos los datos vengan de la base de datos filtrados por la organizacion del usuario logueado
4. Que las graficas usen colores profesionales y se vean bien en pantallas grandes y medianas
5. Que la pagina sea responsiva (se adapte a diferentes tamanos de pantalla)
```

**Que esperar**: Claude creara las paginas del dashboard con graficas funcionales. Puede que necesite instalar una libreria de graficas (como Recharts o Chart.js). Di "yes" si pide permiso.

**NOTA**: Los datos de las graficas van a estar vacios o con datos de ejemplo al principio. Eso es normal — se llenan a medida que los usuarios usen la aplicacion.

**Resultado**: Tu app tiene un dashboard con graficas y navegacion.

---

## Paso 10 — Implementar graficas y visualizacion de datos

**Que vamos a hacer**: Conectar las graficas del dashboard con datos reales de la base de datos y asegurarnos de que se vean bien. Es como conectar los indicadores del tablero del carro al motor.

**Copia y pega este prompt:**

```
Continua con el siguiente batch: graficas y visualizacion.

Implementa:
1. API endpoints que devuelvan datos para las graficas:
   - /api/dashboard/activity — actividad diaria de los ultimos 30 dias
   - /api/dashboard/distribution — distribucion por categoria
   - /api/dashboard/summary — numeros de las tarjetas de resumen
   - /api/dashboard/recent — ultimas 10 actividades

2. Todos los endpoints deben filtrar por la organizacion del usuario logueado
   (multi-tenant: nadie ve datos de otra organizacion)

3. Datos de ejemplo (seed):
   - Crea un script que genere datos de ejemplo para poder ver las graficas funcionando
   - Incluye: 5 usuarios de ejemplo, actividad de los ultimos 30 dias, varias categorias

4. Conecta las graficas del dashboard a los API endpoints reales

5. Agrega estados de carga (loading) mientras se obtienen los datos
```

**Que esperar**: Claude creara los endpoints del servidor que devuelven datos y los conectara con las graficas. Tambien creara datos de ejemplo para que puedas ver las graficas funcionando sin esperar a que haya usuarios reales.

**Resultado**: Las graficas del dashboard muestran datos reales (de ejemplo por ahora).

---

## Paso 11 — Implementar gestion de suscripciones

**Que vamos a hacer**: Construir la parte donde los usuarios pueden ver su plan, comparar opciones, y cambiar de plan. Es como instalar la oficina de atencion al cliente del edificio.

**Copia y pega este prompt:**

```
Continua con el siguiente batch: gestion de suscripciones.

Implementa:
1. Pagina de "Suscripcion" accesible desde el sidebar del dashboard

2. Seccion de plan actual:
   - Nombre del plan (Gratis, Pro, Enterprise)
   - Fecha desde cuando esta activo
   - Limites del plan: miembros permitidos, proyectos, almacenamiento
   - Cuanto ha usado de cada limite (barra de progreso)

3. Tabla comparativa de planes:
   - 3 columnas: Gratis, Pro, Enterprise
   - Filas: cada funcionalidad con un check si esta incluida
   - Boton "Plan actual" en el plan que tienen, "Mejorar" en los demas
   - El boton de "Mejorar" muestra un mensaje: "Para cambiar de plan, contacta al administrador"
     (la integracion de pagos se agrega despues)

4. Pagina de miembros de la organizacion:
   - Lista de todos los miembros con nombre, email, rol, fecha de ingreso
   - Indicador de cuantos miembros quedan disponibles segun el plan
   - Boton de "Invitar miembro" (genera un codigo de invitacion)

5. Los limites por plan estan en la base de datos:
   | Plan | Miembros | Proyectos | Almacenamiento |
   |------|----------|-----------|----------------|
   | Gratis | 3 | 1 | 100 MB |
   | Pro | 20 | 10 | 5 GB |
   | Enterprise | Ilimitado | Ilimitado | 50 GB |
```

**Que esperar**: Claude creara las paginas de suscripcion y miembros con toda la logica de limites. La parte de pagos reales (Stripe) se puede agregar despues — por ahora el cambio de plan es manual.

**Resultado**: Los usuarios pueden ver su plan, sus limites, y gestionar miembros.

---

## Paso 12 — Implementar el panel de administracion

**Que vamos a hacer**: Construir la seccion especial donde los duenos de la aplicacion (tu) pueden ver y manejar a todos los clientes. Es como la oficina del gerente del edificio.

**Copia y pega este prompt:**

```
Continua con el siguiente batch: panel de administracion.

Implementa:
1. Ruta protegida /admin que SOLO pueden ver usuarios con rol "superadmin"
   (diferente del "admin" de una organizacion — "superadmin" es el dueno de toda la app)

2. Dashboard de administracion:
   - Tarjetas de resumen: total de organizaciones, total de usuarios, distribucion de planes
   - Grafica: organizaciones nuevas por mes
   - Grafica: distribucion de planes (Gratis vs Pro vs Enterprise)

3. Pagina de organizaciones:
   - Tabla con todas las organizaciones: nombre, plan, miembros, fecha de creacion, estado
   - Filtros: por plan, por estado (activa/inactiva)
   - Busqueda por nombre
   - Click en una organizacion abre sus detalles

4. Detalle de organizacion:
   - Informacion general: nombre, email del creador, fecha, plan
   - Lista de miembros
   - Boton para cambiar el plan manualmente
   - Boton para desactivar/activar la organizacion (desactivar bloquea el acceso)

5. Middleware de admin:
   - Verificar que el usuario sea superadmin antes de mostrar cualquier pagina de /admin
   - Si un usuario normal intenta acceder a /admin, redirigirlo al dashboard normal

6. Crea un superadmin por defecto con los datos de seed
```

**Que esperar**: Claude creara todo el panel de administracion con las protecciones de seguridad necesarias. Este panel es completamente separado del dashboard de usuarios normales.

**Resultado**: Tienes un panel de administracion completo para manejar tu SaaS.

---

## Paso 13 — Verificar que todo funcione

**Que vamos a hacer**: Pedirle a Claude que revise su propio trabajo. Como cuando un profesor revisa un examen antes de entregarlo.

**Copia y pega este prompt:**

```
/sdd-verify mi-saas-app
```

**Que esperar**: Claude va a verificar:
- Que el codigo hace lo que las especificaciones dicen
- Que los tests pasan (si los creo)
- Que la seguridad multi-tenant esta correcta (datos separados por organizacion)
- Que el middleware de autenticacion protege todas las rutas
- Que el panel de admin solo es accesible por superadmins
- Que las migraciones de Prisma estan actualizadas
- Que no hay errores de compilacion

Si encuentra problemas, los va a listar y te va a preguntar si quieres que los corrija.

**Tu respuesta:**

```
Si, corrige todos los problemas que encontraste
```

Despues de las correcciones, ejecuta verify otra vez:

```
/sdd-verify mi-saas-app
```

**Cuando todo este verde (sin errores)**, continua al siguiente paso.

---

## Paso 14 — Probar en tu computadora

**Que vamos a hacer**: Ver la aplicacion funcionando en tu computadora antes de subirla a internet. Como una prueba de manejo antes de salir a la carretera.

**Copia y pega este prompt:**

```
Levanta la aplicacion en modo desarrollo para que pueda verla en mi navegador.
Incluye los datos de ejemplo (seed).
Dame las instrucciones paso a paso de como acceder.
```

**Que esperar**: Claude va a ejecutar los comandos necesarios y te dira algo como:

```
La aplicacion esta corriendo en: http://localhost:3000

Usuarios de ejemplo:
- Superadmin: admin@example.com / password123
- Usuario Pro: user@acme.com / password123
- Usuario Gratis: free@startup.com / password123
```

**Que hacer**:
1. Abre tu navegador (Chrome, Firefox, etc.)
2. Escribe en la barra de direcciones: `http://localhost:3000`
3. Deberias ver la pantalla de login

**Prueba estas cosas:**

| Prueba | Que hacer | Que esperar |
|--------|----------|-------------|
| Login normal | Inicia sesion con `user@acme.com` | Ver el dashboard con graficas |
| Registro nuevo | Click en "Registrarse", crea una cuenta nueva | Ver dashboard vacio de tu nueva organizacion |
| Suscripcion | Click en "Suscripcion" en el sidebar | Ver el plan actual y la tabla comparativa |
| Miembros | Click en "Miembros" | Ver la lista de miembros de tu organizacion |
| Panel admin | Inicia sesion con `admin@example.com`, ve a `/admin` | Ver el panel de administracion con todas las organizaciones |
| Seguridad | Con un usuario normal, intenta ir a `/admin` | Debe redirigirte al dashboard normal (NO debe dejarte entrar) |

**Si algo no funciona**, dile a Claude exactamente que ves:

```
Cuando hago click en "Suscripcion" me sale un error 500 y la pagina se queda en blanco.
```

Claude va a investigar y corregir el problema.

---

## Paso 15 — Preparar para despliegue

**Que vamos a hacer**: Configurar todo para que la aplicacion pueda vivir en internet. Tienes dos opciones: Vercel (mas facil, gratis para empezar) o Docker/Coolify (mas control, tu propio servidor).

### Opcion A — Vercel (recomendado para empezar)

```
Necesito preparar la app para desplegar en Vercel.

Configura:
1. Un archivo vercel.json si es necesario
2. Las variables de entorno que necesito configurar en Vercel
3. La base de datos PostgreSQL en un servicio como Neon o Supabase (gratis)
4. Las instrucciones paso a paso para el primer deploy

Dame la lista EXACTA de variables de entorno que debo configurar en Vercel,
con una descripcion de que es cada una y donde obtener el valor.
```

### Opcion B — Docker/Coolify (si tienes tu propio servidor)

```
Necesito configurar el despliegue en Coolify con Docker.

Tenemos:
- Coolify corriendo en: [TU URL DE COOLIFY]
- El dominio para la app sera: [TU DOMINIO, ejemplo: app.miempresa.com]

Configura:
1. Un Dockerfile optimizado para produccion
2. Un docker-compose.yml con la app + PostgreSQL
3. Variables de entorno para produccion
4. Health checks
5. Despliegue automatico cuando hagamos push a la rama main
6. Instrucciones paso a paso para Coolify
```

**Que esperar**: Claude va a crear todos los archivos de configuracion necesarios y darte una lista de pasos a seguir.

**Despues del deploy, copia y pega:**

```
Crea un repositorio privado en GitHub llamado mi-saas-app bajo mi cuenta,
sube todo el codigo, y haz el commit inicial.

Verifica que .gitignore incluya:
- .env
- .env.local
- node_modules/
- Cualquier archivo con secretos
```

---

# SEGURIDAD — Lo que debes saber

> Esta seccion explica las protecciones de seguridad que Claude implementa automaticamente
> en tu aplicacion. No necesitas hacer nada extra, pero es bueno que entiendas que esta pasando.

---

## Proteccion contra CSRF (falsificacion de solicitudes)

**Que es**: Imagina que alguien te envia un link malicioso y al hacer click, sin que te des cuenta, se ejecuta una accion en tu app (como cambiar tu contrasena o eliminar tu cuenta).

**Como te protege Claude**: Next.js y NextAuth incluyen proteccion CSRF automatica. Cada formulario tiene un "sello secreto" (token) que verifica que la accion viene de tu app y no de un sitio externo.

**Que significa para ti**: No necesitas hacer nada. La proteccion ya esta activa.

---

## Proteccion contra XSS (inyeccion de codigo)

**Que es**: Imagina que un usuario malintencionado escribe codigo malicioso en un campo de texto (como su nombre de organizacion) y ese codigo se ejecuta cuando otros ven la pagina.

**Como te protege Claude**: React (que es la base de Next.js) automaticamente "desinfecta" todo el texto que se muestra en pantalla. Si alguien escribe codigo malicioso, se muestra como texto plano en vez de ejecutarse.

**Que significa para ti**: No necesitas hacer nada. Pero NUNCA uses `dangerouslySetInnerHTML` si alguien te lo sugiere (el nombre ya te dice que es peligroso).

---

## Middleware de autenticacion

**Que es**: Un guardia de seguridad invisible que revisa cada vez que alguien intenta acceder a una pagina. Si no has iniciado sesion, te manda al login. Si no eres admin, no te deja entrar al panel de administracion.

**Como te protege Claude**: NextAuth crea un middleware que se ejecuta ANTES de cada pagina. Verifica:
1. Que tengas una sesion activa (que hayas iniciado sesion)
2. Que tu sesion no haya expirado
3. Que tengas el rol necesario para esa pagina (usuario normal vs superadmin)

**Que significa para ti**: Todas las paginas del dashboard estan protegidas automaticamente.

---

## Variables de entorno (secretos)

**Que es**: Datos sensibles que tu aplicacion necesita (como la contrasena de la base de datos o la clave secreta para las sesiones) pero que NUNCA deben estar escritos directamente en el codigo.

**Como te protege Claude**: Todos los secretos van en un archivo `.env` que:
- NUNCA se sube a GitHub (esta en `.gitignore`)
- Es diferente para desarrollo (tu computadora) y produccion (internet)
- Se configura como "variables de entorno" en Vercel o Coolify

**Que significa para ti**: Nunca compartas tu archivo `.env` con nadie. Si alguien necesita acceder al proyecto, debe crear su propio `.env` con sus propios valores.

**Datos que van en el archivo `.env`:**

| Variable | Que es | Ejemplo |
|----------|--------|---------|
| `DATABASE_URL` | La direccion de tu base de datos | `postgresql://user:pass@localhost:5432/mi_saas_dev` |
| `NEXTAUTH_SECRET` | La clave para encriptar las sesiones | Una cadena larga de caracteres aleatorios |
| `NEXTAUTH_URL` | La URL de tu aplicacion | `http://localhost:3000` (desarrollo) o `https://app.miempresa.com` (produccion) |

---

## Separacion multi-tenant

**Que es**: La garantia de que los datos de una organizacion NUNCA son visibles para otra. Cada organizacion es como un apartamento con su propia cerradura.

**Como te protege Claude**: Cada consulta a la base de datos incluye automaticamente un filtro por la organizacion del usuario logueado. No existe forma de pedir datos de otra organizacion desde la interfaz.

**Que significa para ti**: Tus clientes pueden confiar en que sus datos estan seguros y privados.

---

# Usando Agent Teams (Equipos de Agentes)

> **Referencia tecnica**: Si quieres ver la plantilla completa del equipo pre-configurado
> para proyectos SaaS con Next.js, revisa `teams/templates/nextjs-saas.md` en batuta-dots.
> No necesitas leerla — Claude la carga automaticamente cuando le pides un equipo.

Cuando te sientas comodo con los pasos anteriores, puedes usar **Agent Teams** para que Claude trabaje con multiples "asistentes" en paralelo. Es como tener un equipo de programadores en lugar de uno solo.

---

## Cuando usar cada nivel

| Nivel | Cuando usarlo | Ejemplo en este proyecto |
|-------|--------------|------------------------|
| **Solo** (normal) | Cambios simples, 1-2 archivos | "Cambia el color del boton de login" |
| **Subagente** (automatico) | Investigar o verificar algo | Claude investiga la mejor libreria de graficas antes de usarla |
| **Agent Team** (tu lo pides) | Trabajo grande en multiples partes | Implementar 4 paginas del dashboard al mismo tiempo |

---

## Patron recomendado para este proyecto: Cross-Layer (Patron D)

Un SaaS tiene muchas "capas" que necesitan trabajar juntas: base de datos, logica del servidor, y la interfaz visual. El Patron Cross-Layer asigna un asistente especializado a cada capa.

### Como funciona

Claude crea un equipo de 3 asistentes:

| Asistente | Especialidad | Que hace en este proyecto |
|-----------|-------------|--------------------------|
| **DB Specialist** | Base de datos y Prisma | Crea las tablas, relaciones, migraciones, y consultas optimizadas |
| **API Architect** | Logica del servidor y API | Crea los endpoints, el middleware, la autenticacion, y la logica de negocio |
| **UI Builder** | Interfaz y componentes | Crea las paginas, los formularios, las graficas, y el diseno visual |

Un cuarto asistente, el **Integrator**, verifica al final que todo encaje: que la interfaz llame a los endpoints correctos, que los endpoints usen las tablas correctas, y que no haya inconsistencias.

### Como pedirlo

```
Necesito implementar el modulo de suscripciones completo: tablas de base de datos,
endpoints de API, y paginas de interfaz. Crea un equipo Cross-Layer con 3 especialistas
(DB, API, UI) para hacerlo en paralelo.
```

Claude va a:
1. Evaluar si el trabajo justifica un equipo (modulo completo con 3 capas = si)
2. Crear los 3 asistentes especializados
3. Repartir el trabajo: DB crea las tablas, API crea los endpoints, UI crea las paginas
4. Cada asistente trabaja en su parte al mismo tiempo
5. El Integrator verifica que todo funcione junto al final

---

## Ejemplos practicos para este proyecto

**Ejemplo 1 — Implementar multiples paginas en paralelo:**
```
Necesito implementar 4 paginas del dashboard: miembros, suscripcion,
configuracion y perfil. Crea un equipo para hacerlo en paralelo.
```

**Ejemplo 2 — Agregar sistema de pagos:**
```
Quiero integrar Stripe para pagos reales. Que un asistente prepare
la base de datos y los webhooks, otro cree la logica de checkout,
y otro actualice la interfaz de suscripciones.
```

**Ejemplo 3 — Code review antes del deploy:**
```
Revisa toda la app antes del deploy. Que un asistente revise
la seguridad (CSRF, XSS, SQL injection), otro el rendimiento
(queries lentas, carga de paginas), y otro la accesibilidad
(que personas con discapacidades puedan usarla).
```

---

## Metricas esperadas de rendimiento

Estas metricas son estimaciones para que compares cuando ejecutes los pasos. Anota tus resultados reales para mejorar el sistema.

| Escenario | Nivel | Tiempo estimado | Costo tokens | Calidad esperada | Fortaleza | Debilidad |
|-----------|-------|----------------|-------------|-----------------|-----------|-----------|
| Cambiar color de boton | Solo | 1-2 min | ~2K tokens | 95% primera vez | Rapido, sin overhead | N/A |
| Implementar 1 pagina SDD | Solo + Subagente | 15-25 min | ~50K tokens | 85% primera vez | Proceso completo, trazable | Secuencial, un paso a la vez |
| Implementar 4 paginas SDD | Agent Team | 20-35 min | ~150K tokens | 80% primera vez | Paralelo, mas rapido en total | Mas tokens, coordinacion puede fallar |
| Modulo completo Cross-Layer | Agent Team | 25-40 min | ~180K tokens | 80% primera vez | 3 capas simultaneas, especialistas | Integracion manual al final |
| Code review completo | Agent Team | 10-15 min | ~80K tokens | 90% cobertura | Multiples perspectivas | Hallazgos pueden solaparse |
| SDD Pipeline completo | Agent Team | 30-45 min | ~200K tokens | 85% primera vez | Spec+Design paralelo | Requiere buena descripcion inicial |

> **Importante**: Estas son estimaciones iniciales. Cuando ejecutes cada paso, anota cuanto tardo
> realmente y si el resultado fue correcto a la primera. Esa informacion ayuda a mejorar el sistema.

---

# TROUBLESHOOTING — Problemas comunes y como resolverlos

> Aqui tienes los problemas mas comunes que pueden pasar y como resolverlos.
> Si tu problema no esta aqui, dile a Claude exactamente que ves y el lo investiga.

---

## Errores de Prisma y migraciones

### "La migracion fallo" o "Migration failed"

**Que paso**: Prisma intento cambiar la estructura de la base de datos y algo salio mal. Es como si el remodelador encontrara una pared que no esperaba.

**Que hacer**: Copia y pega esto:

```
La migracion de Prisma fallo con este error: [pega el error aqui].
Diagnostica el problema y sugiere como resolverlo.
Si es necesario, resetea la base de datos de desarrollo.
```

**Errores comunes:**
- "Unique constraint failed" — Hay datos duplicados que no deberian existir
- "Foreign key constraint failed" — Una tabla depende de otra que no existe todavia
- "Column does not exist" — El codigo espera una columna que la base de datos no tiene

### "No puedo conectar a la base de datos"

**Que hacer**:

```
No puedo conectar a PostgreSQL. Verifica:
1. Que PostgreSQL esta corriendo
2. Que los datos de conexion en .env son correctos
3. Que la base de datos existe
Dame las instrucciones para diagnosticar paso a paso.
```

### Resetear la base de datos (solo en desarrollo)

Si algo esta muy enredado y quieres empezar de cero con la base de datos:

```
Resetea la base de datos de desarrollo completamente.
Borra todo, ejecuta las migraciones desde cero, y vuelve a cargar los datos de ejemplo.
```

> **CUIDADO**: Esto borra TODOS los datos. Solo hazlo en tu computadora de desarrollo, NUNCA en produccion.

---

## Errores de autenticacion y sesiones

### "Me saca de la sesion cada vez que recargo la pagina"

**Que hacer**:

```
La sesion se pierde al recargar la pagina. Verifica:
1. Que NEXTAUTH_SECRET esta configurado en .env
2. Que NEXTAUTH_URL apunta a http://localhost:3000
3. Que las cookies de sesion se estan guardando correctamente
```

### "No me deja iniciar sesion aunque la contrasena es correcta"

**Que hacer**:

```
El login no funciona aunque uso las credenciales correctas.
Revisa los logs del servidor para ver que error esta dando NextAuth.
Verifica que la encriptacion de contrasenas funciona correctamente.
```

### "Un usuario normal puede acceder al panel de admin"

**Que hacer**:

```
URGENTE: Un usuario sin rol superadmin puede acceder a /admin.
Revisa el middleware de proteccion de rutas de admin y corrigelo.
Verifica que el rol se esta verificando ANTES de renderizar la pagina.
```

---

## Errores de build (compilacion)

### "npm run build falla"

**Que hacer**:

```
El build falla con este error: [pega el error aqui].
Diagnostica y corrige todos los errores de compilacion.
Ejecuta el build de nuevo despues de corregir.
```

**Errores comunes:**
- "Module not found" — Falta instalar una libreria. Claude la instalara automaticamente.
- "Type error" — Un dato esta llegando en formato incorrecto. Claude lo corrige.
- "ESLint error" — Una regla de estilo de codigo no se cumple. Claude lo ajusta.

### "La pagina se ve en blanco despues del build"

**Que hacer**:

```
Despues del build, la pagina se muestra en blanco.
Abre las herramientas de desarrollo del navegador (F12) y ve a la pestana Console.
Copia cualquier error rojo que aparezca y pegalo aqui.
```

---

## Problemas de despliegue

### "El deploy en Vercel falla"

**Que hacer**:

```
El deploy en Vercel fallo con este error: [pega el error de Vercel].
Diagnostica el problema. Verifica:
1. Que todas las variables de entorno estan configuradas en Vercel
2. Que la URL de la base de datos es accesible desde Vercel
3. Que el build funciona localmente
```

### "La app funciona en mi computadora pero no en produccion"

**Que hacer**:

```
La app funciona bien en localhost pero en produccion da este error: [pega el error].
Las diferencias mas comunes entre desarrollo y produccion son:
- Variables de entorno diferentes
- URL de la base de datos
- NEXTAUTH_URL apuntando a la URL de produccion
Diagnostica y corrige.
```

---

## Comandos de emergencia

Si algo sale muy mal y quieres recuperarte rapido:

| Situacion | Que escribir |
|-----------|-------------|
| Claude se trabo y no responde | Cierra la terminal, abrela de nuevo, escribe `claude` |
| Quieres deshacer el ultimo cambio | `Deshaz el ultimo cambio que hiciste` |
| No entiendes algo | `Explicame [lo que no entiendes] como si tuviera 15 anos` |
| Quieres ver el estado del proyecto | **Ver estado**: Pregunta a Claude: '¿En que fase estamos?' |
| La base de datos esta enredada | `Resetea la base de datos de desarrollo y ejecuta el seed de nuevo` |
| El build falla y no sabes por que | `Ejecuta npm run build y analiza cada error. Corrigelos todos.` |

---

# DESPUES DE LA ENTREGA

> Estos pasos son opcionales pero recomendados para mantener tu proyecto saludable.

---

## Hacer cambios despues

Cuando quieras agregar algo nuevo o cambiar algo, NO edites el codigo directamente. Usa el mismo proceso:

```
/sdd-new nombre-del-cambio

Quiero agregar [descripcion de lo que quieres cambiar o agregar].
Por ejemplo: integracion con Stripe para cobrar suscripciones reales.
```

Y sigue el mismo flujo: explore → propose → specs → design → tasks → apply → verify.

> **Importante**: Cada cambio pasa por el Execution Gate automaticamente.
> Claude valida que el cambio siga las reglas del proyecto antes de escribir codigo.

---

## Mejorar tus instrucciones

Despues de trabajar un rato con Claude (10+ interacciones), pidele feedback directo:

```
Como ha ido la comunicacion en este proyecto? Que tipo de errores has cometido y como puedo mejorar mis instrucciones?
```

Claude revisa el contexto del proyecto y te dice:
- Que tipo de errores comete mas seguido
- Tasa de compliance del Execution Gate
- **Recomendaciones concretas** para que tus proximos pedidos sean mas claros

---

## Actualizar el ecosistema Batuta

Cuando haya actualizaciones disponibles del ecosistema:

```
/batuta-update
```

Esto actualiza los skills y las instrucciones del chef sin tocar tu codigo ni la bitacora del proyecto.

---

## Proximos pasos sugeridos

Una vez que tu SaaS basico esta funcionando, estas son las funcionalidades que puedes agregar:

| Funcionalidad | Que decirle a Claude | Complejidad |
|---------------|---------------------|-------------|
| Pagos con Stripe | `/sdd-new stripe-integration` — Integrar Stripe Checkout para cobrar suscripciones reales | Alta (Agent Team recomendado) |
| Invitaciones por email | `/sdd-new email-invitations` — Enviar invitaciones por email real con SendGrid o Resend | Media |
| Notificaciones in-app | `/sdd-new notifications` — Sistema de notificaciones dentro de la app | Media |
| Modo oscuro | `/sdd-new dark-mode` — Agregar toggle de modo oscuro/claro | Baja |
| Exportar datos | `/sdd-new export-data` — Exportar datos del dashboard a CSV o PDF | Media |
| API publica | `/sdd-new public-api` — API para que los clientes se integren con tu SaaS | Alta (Agent Team recomendado) |
| Multi-idioma | `/sdd-new i18n` — Soporte para espanol e ingles | Media |

---

## Estructura esperada del proyecto

```
mi-saas-app/
├── core/                                  # Singletons de toda la app
│   ├── config/
│   │   └── plans.ts                      # Definicion de planes (Gratis, Pro, Enterprise)
│   ├── database/
│   │   └── prisma.ts                     # Cliente Prisma (conexion a la base de datos)
│   └── auth/
│       └── auth-options.ts               # Configuracion de NextAuth
├── features/
│   ├── auth/                             # Feature: autenticacion
│   │   ├── components/
│   │   │   ├── login-form.tsx
│   │   │   ├── register-form.tsx
│   │   │   └── forgot-password-form.tsx
│   │   └── services/
│   │       └── auth-service.ts
│   ├── dashboard/                        # Feature: dashboard principal
│   │   ├── components/
│   │   │   ├── summary-cards.tsx
│   │   │   ├── activity-chart.tsx
│   │   │   ├── distribution-chart.tsx
│   │   │   └── recent-activity.tsx
│   │   └── services/
│   │       └── dashboard-service.ts
│   ├── subscriptions/                    # Feature: gestion de suscripciones
│   │   ├── components/
│   │   │   ├── plan-comparison.tsx
│   │   │   ├── current-plan.tsx
│   │   │   └── usage-progress.tsx
│   │   └── services/
│   │       └── subscription-service.ts
│   ├── members/                          # Feature: gestion de miembros
│   │   ├── components/
│   │   │   ├── members-list.tsx
│   │   │   └── invite-dialog.tsx
│   │   └── services/
│   │       └── member-service.ts
│   ├── admin/                            # Feature: panel de administracion
│   │   ├── components/
│   │   │   ├── admin-dashboard.tsx
│   │   │   ├── organizations-table.tsx
│   │   │   └── org-detail.tsx
│   │   └── services/
│   │       └── admin-service.ts
│   └── shared/                           # Shared entre 2+ features
│       ├── components/
│       │   ├── sidebar.tsx
│       │   ├── header.tsx
│       │   └── loading-spinner.tsx
│       └── hooks/
│           └── use-current-org.ts
├── app/                                   # App Router de Next.js (paginas)
│   ├── (auth)/                           # Grupo de paginas de autenticacion
│   │   ├── login/page.tsx
│   │   ├── register/page.tsx
│   │   └── forgot-password/page.tsx
│   ├── (dashboard)/                      # Grupo de paginas del dashboard
│   │   ├── layout.tsx                    # Layout con sidebar y header
│   │   ├── page.tsx                      # Dashboard principal
│   │   ├── members/page.tsx
│   │   ├── subscription/page.tsx
│   │   └── settings/page.tsx
│   ├── admin/                            # Panel de administracion
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── organizations/
│   │       ├── page.tsx
│   │       └── [id]/page.tsx
│   └── api/                              # API endpoints
│       ├── auth/[...nextauth]/route.ts
│       └── dashboard/
│           ├── activity/route.ts
│           ├── distribution/route.ts
│           ├── summary/route.ts
│           └── recent/route.ts
├── prisma/
│   ├── schema.prisma                     # Esquema de la base de datos
│   ├── migrations/                       # Historial de migraciones
│   └── seed.ts                           # Datos de ejemplo
├── middleware.ts                          # Middleware de autenticacion
├── .env                                  # Variables de entorno (NO va a git)
├── .env.example                          # Ejemplo de variables (SI va a git)
├── docker-compose.yml                    # PostgreSQL en Docker (desarrollo)
├── Dockerfile                            # Para produccion
├── package.json
└── .gitignore
```

> Nota como sigue la **Scope Rule**: cada feature tiene su carpeta, shared solo tiene lo que usan
> 2+ features, y core tiene los singletons.

---

## Preguntas frecuentes

**P: Claude me dice cosas que no entiendo. Que hago?**
R: Copialo y preguntale: "Explicame esto en espanol simple, sin palabras tecnicas"

**P: Cuanto tarda todo el proceso?**
R: La primera vez, entre 2 y 3 horas incluyendo la creacion de skills. La segunda vez que hagas un proyecto similar, mucho menos porque los skills ya existen.

**P: Puedo cerrar la terminal y continuar despues?**
R: Si. Abre la terminal, navega a tu carpeta (`cd "ruta/mi-saas-app"`), escribe `claude`, y Claude automaticamente lee el archivo `.batuta/session.md` donde guardo en que quedo. No necesitas decirle nada especial — el recuerda solo.

**P: Necesito saber programar para modificar la app despues?**
R: No. Siempre puedes pedirle a Claude que haga los cambios por ti. Solo describe lo que quieres en lenguaje natural (como si le enviaras un mensaje a un programador amigo).

**P: Cuanto cuesta mantener una app SaaS?**
R: Depende de cuantos usuarios tengas. Para empezar: Vercel (gratis), base de datos en Neon (gratis hasta 500MB), y dominio (10-15 dolares al ano). Cuando crezcas, los costos suben gradualmente.

**P: Y si quiero cobrar a mis clientes?**
R: La integracion con Stripe se puede agregar despues siguiendo el mismo proceso SDD. Le dices a Claude que quieres agregar pagos y el te guia.

**P: Que es el Execution Gate?**
R: Es un checklist automatico que Claude ejecuta antes de escribir codigo. Verifica donde van los archivos, que impacto tienen los cambios, y que todo siga las reglas del proyecto. No lo ves directamente, pero trabaja en segundo plano protegiendote de errores.

**P: Que son los Scope Agents?**
R: Son "jefes de area" especializados. Claude tiene 3: pipeline (proceso de desarrollo), infra (organizacion de archivos y recetas), y observability (calidad). El chef principal solo les pasa los pedidos al jefe correcto.

**P: Que pasa si mi base de datos se llena?**
R: PostgreSQL maneja bien grandes cantidades de datos. Cuando llegues a millones de filas, Claude puede ayudarte a optimizar las consultas y agregar indices. Pero eso probablemente no pase por un buen rato.

---

## Resumen visual del flujo completo

```
Tu (carpeta vacia)
 |
 +-- Paso 1-2:  Crear carpeta + Instalar Batuta + crear .batuta/
 |
 +-- Paso 3:    /sdd-init ................... "Configurar proyecto SDD"
 |
 |   [Claude detecta skills faltantes → Paso 4: "Opcion 1"]
 |
 +-- Paso 5:    /sdd-new .................... "Explorar + Propuesta formal"
 |     Tu: "Aprobado"
 |
 +-- Paso 6:    /sdd-continue ............... "Specs → Design → Tasks"
 |     Tu: "Continua" (3 veces)
 |
 +-- Paso 7:    /sdd-apply (Batch 1) ........ "Base de datos + Prisma"
 |     [Execution Gate valida antes de cada cambio]
 |
 +-- Paso 8:    Batch 2 ..................... "Autenticacion (login/registro)"
 |
 +-- Paso 9:    Batch 3 ..................... "Dashboard + navegacion"
 |
 +-- Paso 10:   Batch 4 ..................... "Graficas y datos"
 |
 +-- Paso 11:   Batch 5 ..................... "Suscripciones + miembros"
 |
 +-- Paso 12:   Batch 6 ..................... "Panel de administracion"
 |
 +-- Paso 13:   /sdd-verify ................ "Revisar que todo funcione"
 |
 +-- Paso 14:   Probar en tu PC ............ "localhost:3000"
 |
 +-- Paso 15:   Deploy ..................... "App en internet"
 |
 [Tu SaaS esta en internet!]
```

---

> **Recuerda**: No necesitas entender COMO funciona todo. Solo necesitas seguir los pasos
> y confiar en el proceso. Como aprender a manejar: primero sigues las instrucciones al pie
> de la letra, y con el tiempo lo haces naturalmente. Claude es tu asistente — el programa, tu decides.
