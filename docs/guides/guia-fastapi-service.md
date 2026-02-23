# Guia Paso a Paso: Microservicio API con FastAPI y Claude Code

> **Para quien es esta guia**: Para cualquier persona que sepa copiar y pegar texto.
> Claude Code hace la programacion, tu solo le das las instrucciones.
>
> **Formato**: Sigue los pasos en orden, como cuando aprendes a manejar.
> Cada paso depende del anterior. No saltes pasos.

---

## Glosario — Palabras que vas a ver

Antes de empezar, aqui tienes un mini-diccionario. No necesitas memorizarlo, vuelve aqui si ves una palabra que no entiendes.

| Palabra | Que significa (sin tecnicismos) |
|---------|-------------------------------|
| **Prompt** | El mensaje que le escribes a Claude. Como enviarle un WhatsApp con instrucciones. |
| **Claude Code** | Un asistente de programacion que vive en tu terminal. Tu le dices que quieres y el lo construye. |
| **Terminal** | La pantalla negra donde escribes comandos. Piensa en ella como un chat con tu computadora. |
| **Microservicio** | Una aplicacion pequena y especializada que hace UNA cosa bien. Como un puesto del mercado: uno vende frutas, otro verduras, otro carnes. Cada uno es independiente pero juntos forman el mercado completo. |
| **FastAPI** | Una herramienta de Python para crear microservicios rapidos. Es como un kit de construccion que ya viene con las piezas principales armadas — tu solo agregas lo que necesitas. |
| **API** | Un "mesero" que lleva pedidos entre sistemas. Tu aplicacion de celular le pide "dame mis tareas" a la API, y la API va a la base de datos, busca las tareas, y te las devuelve. |
| **REST API** | Un estilo de organizar la API. Como las reglas de un restaurante: para pedir usas el menu (GET), para ordenar llenas la comanda (POST), para cambiar tu pedido le dices al mesero (PUT), para cancelar dices "ya no quiero eso" (DELETE). |
| **Endpoint** | La direccion exacta donde un servicio recibe pedidos. Como el numero de ventanilla en un banco: "para crear una tarea, ve a la ventanilla /tareas". |
| **CRUD** | Las 4 operaciones basicas con datos: Crear, Leer, Actualizar, Borrar (Create, Read, Update, Delete). Como en una libreta: escribes notas nuevas, lees las que ya tienes, tachas y reescribes, o arrancas la pagina. |
| **JWT** | JSON Web Token. Un "pase de seguridad" digital. Cuando te logueas, el sistema te da un pase (JWT) que usas para demostrar quien eres en cada peticion. Como la pulsera que te dan en un evento — con ella puedes entrar y salir sin mostrar tu boleto cada vez. |
| **Autenticacion** | El proceso de verificar quien eres. Cuando escribes tu email y contrasena, la aplicacion verifica que seas tu de verdad. Como mostrar tu credencial al guardia de un edificio. |
| **Base de datos** | El lugar donde se guardan todos los datos. Piensa en una bodega organizada con estantes etiquetados: cada estante tiene un tipo de dato (usuarios en uno, tareas en otro). |
| **PostgreSQL** | Un tipo de base de datos muy popular y confiable. Es como una bodega profesional con inventario digital — sabe exactamente que tiene, donde esta, y te deja buscar de muchas formas. |
| **SQLAlchemy** | Una herramienta que le permite a Python hablar con la base de datos. Como un traductor: tu le dices a Python "dame las tareas del usuario Juan" y SQLAlchemy lo traduce al idioma que entiende PostgreSQL. |
| **Alembic** | Una herramienta que maneja los cambios en la estructura de la base de datos. Como un arquitecto que modifica los planos de un edificio: agrega pisos nuevos sin derrumbar los existentes. Cuando necesitas agregar una columna nueva a una tabla, Alembic lo hace de forma segura. |
| **Migracion** | Un cambio controlado en la estructura de la base de datos. Cuando agregas un campo nuevo (como "telefono" a la tabla de usuarios), eso es una migracion. Alembic las ejecuta en orden y puede deshacerlas si algo sale mal. |
| **Hash** | Una forma de convertir tu contrasena en un codigo ilegible. Si tu contrasena es "gatito123", el hash la convierte en algo como "a8b2c9d4e5f6". Nadie puede descifrar el hash para saber tu contrasena original, pero el sistema puede verificar que "gatito123" produce el mismo hash. |
| **Token** | Ver JWT arriba. Es un codigo temporal que demuestra que ya te autenticaste. |
| **Deploy** | Poner tu aplicacion en internet para que otros la usen. Como abrir las puertas de tu tienda al publico. |
| **Docker** | Una herramienta que empaqueta aplicaciones para que funcionen en cualquier computadora igual. Como una caja de mudanza estandarizada. |
| **Coolify** | Una plataforma para poner aplicaciones en internet. Como un hosting inteligente. |
| **SDD** | Spec-Driven Development. Un proceso paso a paso: primero planeas, luego construyes. Como un arquitecto que primero dibuja el plano. |
| **Skill** | Un documento que le dice a Claude COMO hacer algo especifico. Como una receta de cocina. |
| **Scope Agent** | Un "jefe de area" especializado. Claude tiene 3: uno para desarrollo (SDD pipeline), uno para infraestructura y seguridad, y uno para observabilidad y continuidad de sesion. |
| **Execution Gate** | Un checklist que Claude ejecuta ANTES de hacer cualquier cambio de codigo. Verifica que todo este en orden. |
| **pytest** | Una herramienta para ejecutar pruebas automaticas en Python. Como un inspector de calidad que revisa cada pieza antes de empaquetarla. |
| **OWASP** | Una organizacion que publica las mejores practicas de seguridad para aplicaciones web. Como un manual de seguridad industrial — te dice que peligros existen y como prevenirlos. |
| **SQL Injection** | Un ataque donde alguien intenta hackear tu base de datos escribiendo codigo malicioso en los campos de texto (como el campo de login). Es como si alguien escribiera una "orden de liberacion falsa" en el espacio de "nombre" de un formulario. Nuestro sistema esta protegido contra esto. |
| **Variable de entorno** | Un dato secreto que la aplicacion necesita pero que no se guarda en el codigo. Como la combinacion de una caja fuerte — la sabes de memoria, no la escribes en un papel pegado a la caja. |
| **Schema** | La forma o estructura que deben tener los datos. Como un formulario: tiene campos obligatorios (nombre, email) y campos opcionales (telefono). Si envias datos que no cumplen el schema, la API los rechaza. |

---

## Que vamos a construir

**Batuta Task Manager API** — Un microservicio completo que:

1. **Maneja usuarios**: Registro, login, y perfiles de usuario con contrasenas seguras
2. **Maneja tareas**: Crear, leer, actualizar y borrar tareas (como un Todoist o Trello basico)
3. **Autenticacion con JWT**: Cada usuario necesita loguearse para acceder a sus tareas
4. **Base de datos PostgreSQL**: Todos los datos se guardan de forma segura y permanente
5. **Tests automaticos**: Pruebas que verifican que todo funciona antes de cada despliegue
6. **Documentacion automatica**: FastAPI genera automaticamente una pagina donde puedes probar la API

### Ejemplo concreto

1. Te registras: `POST /auth/register` con tu email y contrasena
2. Te logueas: `POST /auth/login` y recibes un token JWT (tu "pulsera")
3. Creas una tarea: `POST /tasks` con titulo "Comprar leche" y el token en el header
4. Ves tus tareas: `GET /tasks` y recibes la lista de tus tareas
5. Marcas como completada: `PUT /tasks/1` cambiando el estado a "completada"
6. Borras una tarea: `DELETE /tasks/1`

Todo protegido — solo tu puedes ver y modificar TUS tareas.

---

## Antes de empezar — Lo que necesitas tener instalado

Pide ayuda a alguien para instalar estas herramientas si no las tienes:

| Herramienta | Para que sirve | Como instalar |
|-------------|---------------|---------------|
| **Python 3.11+** | El lenguaje de programacion del microservicio | Descarga de [python.org](https://python.org). En la instalacion, marca la casilla "Add Python to PATH" |
| **Node.js** | Necesario para Claude Code | Descarga de [nodejs.org](https://nodejs.org) la version LTS |
| **Git** | Guarda el historial de tu proyecto | Descarga de [git-scm.com](https://git-scm.com) |
| **Claude Code** | El asistente que va a programar por ti | En la terminal escribe: `npm install -g @anthropic-ai/claude-code` |
| **Docker** (opcional) | Para correr PostgreSQL y desplegar a produccion | Descarga de [docker.com](https://docker.com) |

### Como instalar PostgreSQL

Tienes dos opciones:

**Opcion A — Con Docker (recomendado, mas limpio)**:
```
docker run --name postgres-batuta -e POSTGRES_USER=batuta -e POSTGRES_PASSWORD=batuta_dev -e POSTGRES_DB=batuta_tasks -p 5432:5432 -d postgres:16
```
Esto crea una base de datos PostgreSQL lista para usar en tu computadora.

**Opcion B — Instalacion directa**:
1. Descarga de [postgresql.org](https://www.postgresql.org/download/)
2. Instala con las opciones por defecto
3. Recuerda el usuario y contrasena que elegiste

Para verificar que todo esta instalado, abre una terminal y escribe:
```
python --version
node --version
git --version
claude --version
```
Si todos muestran un numero (como `Python 3.11.5`), estas lista.

---

# PASO A PASO

> Sigue cada paso en orden. No saltes pasos — cada uno depende del anterior,
> como cuando aprendes a manejar.

---

## Paso 1 — Crear la carpeta del proyecto

**Que vamos a hacer**: Crear una carpeta vacia donde vivira todo nuestro microservicio. Es como preparar un escritorio limpio antes de empezar a trabajar.

**Que hacer**:
1. Abre el Explorador de Archivos de Windows
2. Ve a donde quieras guardar tu proyecto (ejemplo: `E:\Proyectos\`)
3. Click derecho, Nueva Carpeta
4. Nombrala: `batuta-task-api`

> **IMPORTANTE**: Usa nombres SIN espacios y en minusculas.
> Los espacios causan problemas con las herramientas de programacion.
> Usa guiones (-) en lugar de espacios.

5. Abre una terminal (busca "Terminal" o "Command Prompt" en Windows)
6. Escribe exactamente esto y presiona Enter:

```
cd "E:\Proyectos\batuta-task-api"
```

> Cambia la ruta si tu carpeta esta en otro lugar.

7. Ahora escribe:

```
claude
```

**Resultado**: Se abre Claude Code. Vas a ver algo como:
```
Claude Code v1.x.x
>
```
Ese `>` es donde le escribes tus instrucciones.

---

## Paso 2 — Instalar el ecosistema Batuta

**Que vamos a hacer**: Darle a Claude las "recetas" (skills) que necesita para trabajar al estilo Batuta. Esto incluye la configuracion del chef principal, los jefes de area (scope agents), y el sistema de calidad.

> **IMPORTANTE**: Asegurate de estar dentro de la carpeta de tu proyecto antes de ejecutar este comando. Todo lo que Claude cree se guardara en la carpeta actual.

**Opcion A — Si ya tienes los commands de Batuta instalados** (recomendado):

Simplemente escribe:

```
/batuta-init batuta-task-api
```

Y listo. Claude configura todo automaticamente.

**Opcion B — Si es la primera vez y no tienes los commands:**

Copia y pega este prompt:

```
Necesito configurar este proyecto con el ecosistema Batuta.

Haz lo siguiente:
1. Clona el repositorio github.com/jota-batuta/batuta-dots en una carpeta temporal
2. Ejecuta el script: bash <ruta-a-batuta-dots>/skills/setup.sh --project .
3. Inicializa git en esta carpeta si no existe
4. Confirma cuando todo este listo
```

Esto crea CLAUDE.md, la carpeta .batuta/, sincroniza skills, e instala hooks en tu proyecto.

> Despues de esta primera vez, los commands `/batuta-init` y `/batuta-update` quedan
> instalados y ya no necesitas copiar el prompt largo nunca mas.

**Que esperar**: Claude va a descargar el ecosistema y configurar todo. Puede tomar 1-2 minutos. Cuando termine, te dira que archivos creo, incluyendo:
- `CLAUDE.md` — Las instrucciones del chef (router principal + scope agents + execution gate)
- `.batuta/session.md` — El cuaderno donde Claude anota en que quedo (para continuar despues)
- `.batuta/prompt-log.jsonl` — La bitacora de calidad (se llena automaticamente)

**Tip**: Si Claude te pide permiso para ejecutar comandos, di "yes" o "si".

---

## Paso 3 — Iniciar el proyecto con SDD

**Que vamos a hacer**: Decirle a Claude que tipo de proyecto vamos a construir para que se prepare correctamente. SDD es el proceso de "primero planear, luego construir".

**Copia y pega este prompt**:

```
/sdd:init
```

**Que esperar**: Claude te va a hacer preguntas sobre el proyecto. Cuando te pregunte, responde asi:

| Si Claude pregunta... | Tu respondes... |
|----------------------|-----------------|
| Nombre del proyecto | `batuta-task-api` |
| Tipo de proyecto | `api` |
| Descripcion | `Microservicio REST API con FastAPI para manejar tareas (task manager). Incluye autenticacion con JWT, operaciones CRUD para tareas, base de datos PostgreSQL con Alembic para migraciones, y tests automaticos con pytest.` |
| Stack/tecnologias | `Python con FastAPI, PostgreSQL, SQLAlchemy, Alembic, JWT, pytest` |

**Tip**: No te preocupes si no entiendes las tecnologias. Claude las conoce y sabe como usarlas. Tu solo le estas diciendo "quiero esto".

> **Detalle tecnico (opcional)**: Cuando ejecutas `/sdd:init`, Claude activa su pipeline-agent
> (el "jefe de proceso") que coordina todo el desarrollo paso a paso.

---

## Paso 4 — Cuando Claude dice "no tengo un skill para eso"

**Que vamos a hacer**: Dejar que Claude investigue y documente las tecnologias que necesita. Es como si un chef dijera "no conozco esta tecnica, dejame investigarla primero".

**MOMENTO IMPORTANTE**: Durante el proceso, Claude probablemente detecte que necesita skills para:
- **FastAPI** (el framework del microservicio)
- **SQLAlchemy** (hablar con la base de datos)
- **Alembic** (migraciones de base de datos)
- **JWT/Autenticacion** (sistema de login)
- **pytest** (tests automaticos)

**Cuando Claude diga algo como:**
> "No tengo un skill documentado para FastAPI... Te propongo:
> 1. Investigar y crear el skill (proyecto)
> 2. Investigar y crear el skill (global)
> 3. Continuar sin skill"

**Tu respuesta siempre debe ser**:

```
Opcion 1 — Investiga y crea el skill acotado a nuestro proyecto
```

**Cada vez que te pregunte, responde "Opcion 1"**.

> Opcion 1 crea el skill solo para este proyecto. Opcion 2 lo hace disponible para todos tus proyectos.

Claude va a investigar usando Context7 (su base de conocimiento actualizada) y crear las recetas que necesita. Esto toma unos minutos por skill, pero solo pasa una vez.

> **Detalle tecnico (opcional)**: El infra-agent (jefe de organizacion) coordina la creacion
> de skills nuevos. Usa el ecosystem-creator para investigar y documentar la tecnologia.

**Tip**: Este paso puede tomar 10-15 minutos en total. Es una inversion que se paga sola — Claude va a escribir mejor codigo porque tiene las recetas correctas.

---

## Paso 5 — Crear la propuesta

**Que vamos a hacer**: Pedirle a Claude que escriba un plan formal de lo que va a construir. Como cuando un arquitecto te muestra el boceto antes de construir — puedes decir "cambia esto" ANTES de que empiece.

**Copia y pega este prompt**:

```
/sdd:new batuta-task-manager
```

Este comando primero explora tu proyecto y luego genera una propuesta automaticamente.

**Que esperar**: Claude va a crear un documento de propuesta que incluye:
- Que se va a construir (en lenguaje simple)
- Que riesgos hay (y como los vamos a manejar)
- Criterios de exito (como sabemos que funciona)

Claude te va a mostrar un **resumen** y te preguntara si esta bien.

**Lee el resumen con calma**. Si algo no te suena bien, dile. Por ejemplo:

```
Me parece bien pero agrega que las tareas tambien deben tener
una lista de "etiquetas" (tags) para organizarlas mejor.
Por ejemplo: "trabajo", "personal", "urgente".
```

**Cuando estes conforme, di:**

```
Aprobado, continua con el siguiente paso
```

---

## Paso 6 — Especificaciones y diseno

**Que vamos a hacer**: Dejar que Claude avance por las fases de planificacion. El va a crear las especificaciones tecnicas (que exactamente debe hacer cada endpoint), el diseno de la arquitectura (como se organizan las piezas), y la lista de tareas (en que orden se construye).

**Copia y pega este prompt**:

```
/sdd:continue batuta-task-manager
```

Ejecuta `/sdd:continue` UNA vez por fase. Claude mostrara el resultado y te pedira confirmacion antes de avanzar. Repite hasta completar las fases pendientes (specs, design, tasks).

> **Alternativa rapida**: `/sdd:ff <nombre>` ejecuta todas las fases pendientes de corrido sin pausas.

**Que esperar**: Claude va a ejecutar las siguientes fases una por una:

| Fase | Que hace | Cuanto toma |
|------|---------|-------------|
| **Specs** | Define EXACTAMENTE que debe hacer cada endpoint: que recibe, que devuelve, que errores puede dar. Como escribir los requisitos de un examen. | 3-5 min |
| **Design** | Decide las decisiones tecnicas importantes: como se estructura la base de datos, como funciona el JWT, como se organizan los archivos. | 3-5 min |
| **Tasks** | Divide todo el trabajo en tareas ordenadas: "primero la base de datos, luego la autenticacion, luego las tareas, luego los tests". | 2-3 min |

**Entre cada fase**, Claude te va a mostrar un resumen y preguntar si continua.

**Tu respuesta cada vez**:

```
Se ve bien, continua
```

**Si algo no entiendes**, pregunta sin miedo:

```
No entendi la parte de "Alembic migrations con revision autogenerate".
Explicame que significa eso en terminos simples.
```

Claude esta configurado para explicarte las cosas como si tuvieras 15 anos.

**Tip**: Este paso puede tomar 10-15 minutos. Puedes ir por un cafe mientras Claude trabaja.

---

## Paso 7 — Construir los modelos de base de datos

**Que vamos a hacer**: Crear las "tablas" de la base de datos. Las tablas son como hojas de calculo: una para usuarios (con columnas de nombre, email, contrasena) y otra para tareas (con columnas de titulo, descripcion, estado). Este es el cimiento de toda la aplicacion.

**Copia y pega este prompt**:

```
/sdd:apply batuta-task-manager

Empieza por los modelos de base de datos y las migraciones con Alembic.

Implementa:
1. Modelo de Usuario: id, email (unico), nombre, contrasena (hasheada), fecha_creacion
2. Modelo de Tarea: id, titulo, descripcion, estado, prioridad, fecha_creacion,
   fecha_vencimiento, usuario_id (referencia al usuario que la creo)
3. Configuracion de SQLAlchemy (la conexion a PostgreSQL)
4. Configuracion de Alembic (para manejar cambios en la base de datos)
5. Migracion inicial que crea las tablas
6. Archivo de configuracion con los datos de conexion a la base de datos

Usa estos datos de conexion para desarrollo:
- Host: localhost
- Puerto: 5432
- Usuario: batuta
- Contrasena: batuta_dev
- Base de datos: batuta_tasks
```

**Que esperar**: Antes de escribir codigo, Claude va a ejecutar el **Execution Gate** — un checklist automatico que verifica:
- Que archivos va a crear o modificar
- Donde van a ir (siguiendo la Scope Rule)
- Que impacto tienen los cambios
- Que todo este alineado con las especificaciones

Te mostrara algo como:
```
Este cambio involucra scope pipeline + infra:
- Crear 5 archivos nuevos en core/ y features/
- Configurar SQLAlchemy y Alembic
- Procedo?
```

**Tu respuesta**:

```
Si, procede
```

**Cuando Claude pida permisos** para instalar dependencias (librerias de Python), di "yes". Va a instalar FastAPI, SQLAlchemy, Alembic, y otras herramientas necesarias.

**Resultado**: Al terminar, tendras la estructura de la base de datos lista.

---

## Paso 8 — Construir la autenticacion

**Que vamos a hacer**: Construir el sistema de login. Esto incluye: registrarse, iniciar sesion, y recibir un token JWT (la "pulsera" que demuestra que eres tu). Sin esto, cualquiera podria ver las tareas de cualquiera.

**Copia y pega este prompt**:

```
Continua con la implementacion. Ahora construye el sistema de autenticacion:

1. Endpoint POST /auth/register:
   - Recibe: email, contrasena, nombre
   - Valida que el email no exista ya
   - Guarda la contrasena como hash (NUNCA en texto plano)
   - Devuelve: datos del usuario creado (sin la contrasena)

2. Endpoint POST /auth/login:
   - Recibe: email, contrasena
   - Verifica que el email existe
   - Verifica que la contrasena es correcta comparando hashes
   - Si todo esta bien, genera un token JWT con fecha de expiracion (24 horas)
   - Devuelve: el token JWT

3. Endpoint GET /auth/me:
   - Requiere token JWT en el header Authorization
   - Verifica que el token sea valido y no haya expirado
   - Devuelve: datos del usuario actual

4. Endpoint PUT /auth/me:
   - Requiere token JWT
   - Permite actualizar nombre (no email ni contrasena por ahora)
   - Devuelve: datos actualizados

5. Middleware de autenticacion:
   - Una funcion que verifica el token JWT en cada request protegido
   - Si el token es invalido o expiro, devuelve error 401 (No autorizado)
   - Si el token es valido, pasa los datos del usuario al endpoint

Usa bcrypt para hashear contrasenas y python-jose para los tokens JWT.
El secreto del JWT debe estar en una variable de entorno, no en el codigo.
```

**Que esperar**: Claude ejecutara el Execution Gate y luego implementara todo el sistema de autenticacion. Te mostrara los archivos que va a crear y pedira confirmacion.

**Tu respuesta**: "Si, continua".

**Resultado**: Al terminar, puedes registrar usuarios y loguearte para recibir un token.

---

## Paso 9 — Construir las operaciones de tareas (CRUD)

**Que vamos a hacer**: Construir los endpoints para crear, ver, actualizar y borrar tareas. Esta es la funcionalidad principal de nuestra aplicacion — todo lo que el usuario hace con sus tareas.

**Copia y pega este prompt**:

```
Continua con la implementacion. Ahora construye los endpoints CRUD de tareas:

1. POST /tasks — Crear tarea:
   - Requiere token JWT
   - Recibe: titulo (obligatorio), descripcion (opcional), prioridad (baja/media/alta),
     fecha_vencimiento (opcional)
   - El estado inicial siempre es "pendiente"
   - El usuario_id se toma automaticamente del token JWT
   - Devuelve: la tarea creada con su id

2. GET /tasks — Listar mis tareas:
   - Requiere token JWT
   - SOLO devuelve las tareas del usuario logueado (NUNCA las de otros)
   - Soporta filtros opcionales:
     - ?status=pendiente (filtrar por estado)
     - ?priority=alta (filtrar por prioridad)
     - ?page=1&limit=10 (paginacion — no devolver 10000 tareas de golpe)
   - Ordena por fecha de creacion (las mas recientes primero)

3. GET /tasks/{id} — Ver una tarea:
   - Requiere token JWT
   - Solo devuelve la tarea si es del usuario logueado
   - Si la tarea no existe o es de otro usuario, devuelve error 404

4. PUT /tasks/{id} — Actualizar tarea:
   - Requiere token JWT
   - Solo permite actualizar si la tarea es del usuario logueado
   - Puede actualizar: titulo, descripcion, estado, prioridad, fecha_vencimiento
   - Devuelve: la tarea actualizada

5. DELETE /tasks/{id} — Borrar tarea:
   - Requiere token JWT
   - Solo permite borrar si la tarea es del usuario logueado
   - Devuelve: confirmacion de que se borro

IMPORTANTE — Seguridad:
- Cada endpoint DEBE verificar que la tarea pertenece al usuario del token
- Un usuario NUNCA puede ver, editar, o borrar tareas de otro usuario
- Esto se llama "aislamiento de datos" y es fundamental para la seguridad
```

**Que esperar**: Claude creara todos los endpoints siguiendo las especificaciones. Cada endpoint estara protegido por el middleware de autenticacion del paso anterior.

**Tu respuesta en cada confirmacion**: "Si, continua".

**Resultado**: Al terminar, tienes una API funcional completa con registro, login, y gestion de tareas.

---

## Paso 10 — Escribir tests automaticos

**Que vamos a hacer**: Crear pruebas automaticas que verifican que TODO funciona correctamente. Es como un inspector de calidad que revisa cada pieza antes de empaquetarla. Si alguien cambia algo en el futuro y rompe algo, los tests lo detectan inmediatamente.

**Copia y pega este prompt**:

```
Ahora escribe los tests automaticos con pytest:

TESTS DE AUTENTICACION:
1. Registrar un usuario nuevo → debe funcionar y devolver los datos
2. Registrar con un email que ya existe → debe dar error
3. Login con credenciales correctas → debe devolver un token JWT
4. Login con contrasena incorrecta → debe dar error 401
5. Login con email que no existe → debe dar error 401
6. Acceder a /auth/me con token valido → debe devolver mis datos
7. Acceder a /auth/me sin token → debe dar error 401
8. Acceder a /auth/me con token expirado → debe dar error 401

TESTS DE TAREAS:
9. Crear una tarea con datos validos → debe funcionar
10. Crear una tarea sin titulo → debe dar error 422 (datos invalidos)
11. Listar mis tareas → debe devolver solo las mias
12. Listar tareas filtradas por estado → debe devolver solo las de ese estado
13. Ver una tarea mia → debe funcionar
14. Ver una tarea de otro usuario → debe dar error 404
15. Actualizar una tarea mia → debe funcionar
16. Actualizar una tarea de otro usuario → debe dar error 404
17. Borrar una tarea mia → debe funcionar
18. Borrar una tarea de otro usuario → debe dar error 404

TESTS DE SEGURIDAD:
19. Enviar SQL injection en el campo de email → debe rechazarlo
20. Enviar un token JWT manipulado → debe dar error 401
21. Paginacion con valores negativos → debe dar error 422

Usa una base de datos de prueba separada (no la de desarrollo) para que
los tests no afecten tus datos reales. Despues de cada test, limpia
los datos de prueba.

Apunta a una cobertura minima del 80%.
```

**Que esperar**: Claude va a crear los archivos de tests y la configuracion necesaria para ejecutarlos.

Cuando termine, ejecuta los tests:

```
Ejecuta todos los tests y muestrame los resultados.
Si algun test falla, corrigelo.
```

**Que esperar**: Claude ejecutara `pytest` y te mostrara algo como:

```
================================ test session starts ================================
tests/test_auth.py ........ [8 passed]
tests/test_tasks.py .......... [10 passed]
tests/test_security.py ... [3 passed]
================================ 21 passed in 4.52s ================================

Cobertura: 87%
```

**Si algunos tests fallan**, Claude los corrige automaticamente. Solo dile:

```
Corrige los tests que fallaron y ejecutalos de nuevo.
```

Repite hasta que todos pasen.

---

## Paso 11 — Verificar con la Piramide de Validacion

**Que vamos a hacer**: Pedirle a Claude que haga una revision completa de todo el proyecto. La Piramide de Validacion revisa desde lo mas basico (errores de escritura en el codigo) hasta lo mas avanzado (seguridad y documentacion).

**Copia y pega este prompt**:

```
/sdd:verify batuta-task-manager
```

**Que esperar**: Claude va a verificar 5 capas, de abajo hacia arriba:

| Capa | Que verifica | Quien |
|------|-------------|-------|
| 1 | Tipos, linting, build | Claude |
| 2 | Tests unitarios | Claude |
| 3 | Tests de integracion/E2E | Claude |
| 4 | Code review | TU (humano) |
| 5 | Testing manual | TU (humano) |

Ademas, Claude verifica seguridad y documentacion automaticamente como pasos transversales.

Si encuentra problemas, los va a listar y te va a preguntar si quieres que los corrija.

**Tu respuesta**:

```
Si, corrige todos los problemas que encontraste
```

Despues de las correcciones, ejecuta verify otra vez:

```
/sdd:verify batuta-task-manager
```

**Cuando todo este verde (sin errores)**, continua al siguiente paso.

---

## Paso 12 — Probar en tu computadora

**Que vamos a hacer**: Levantar la aplicacion completa en tu computadora y probarla antes de subirla a internet. FastAPI genera automaticamente una pagina interactiva donde puedes probar cada endpoint sin necesidad de herramientas extra.

**Copia y pega este prompt**:

```
Levanta la aplicacion en modo desarrollo para que pueda probarla.
Asegurate de que la base de datos este corriendo y las migraciones
esten aplicadas. Dame las instrucciones paso a paso.
```

**Que esperar**: Claude va a:
1. Verificar que PostgreSQL esta corriendo
2. Ejecutar las migraciones de Alembic (crear las tablas)
3. Levantar FastAPI

Te dira algo como:
```
La aplicacion esta corriendo:
- API: http://localhost:8000
- Documentacion interactiva: http://localhost:8000/docs
- Documentacion alternativa: http://localhost:8000/redoc
```

**Que hacer**:
1. Abre tu navegador
2. Ve a `http://localhost:8000/docs`
3. Vas a ver una pagina bonita con todos los endpoints listados

**Prueba estas cosas en la pagina de /docs:**

1. **Registrate**: Click en `POST /auth/register` → "Try it out" → llena los campos → "Execute"
2. **Loguea**: Click en `POST /auth/login` → usa tu email y contrasena → copia el token que te devuelve
3. **Autoriza**: Click en el boton "Authorize" arriba a la derecha → pega el token → "Authorize"
4. **Crea una tarea**: Click en `POST /tasks` → "Try it out" → llena titulo y descripcion → "Execute"
5. **Lista tus tareas**: Click en `GET /tasks` → "Try it out" → "Execute" → veras tu tarea

**Si algo no funciona**, dile a Claude exactamente que ves:

```
Cuando intento hacer login con el endpoint POST /auth/login
me da un error 500. El mensaje dice: [pega el error aqui]
```

Claude va a investigar y corregir el problema.

---

## Paso 13 — Desplegar a produccion

**Que vamos a hacer**: Poner la aplicacion en internet para que funcione las 24 horas. Esto incluye crear los archivos que Docker necesita para empaquetar la aplicacion y configurar Coolify para que la mantenga corriendo.

**Copia y pega este prompt**:

```
Necesito desplegar el microservicio a produccion.

Tenemos:
- Coolify corriendo en: [TU URL DE COOLIFY, ejemplo: https://coolify.tudominio.com]
- El dominio para la API sera: [TU DOMINIO, ejemplo: api.tudominio.com]

Configura:
1. Un Dockerfile para el microservicio FastAPI
2. Docker Compose para desarrollo local (API + PostgreSQL juntos)
3. Configuracion de Coolify:
   - Servicio para la API
   - Base de datos PostgreSQL como servicio en Coolify
4. Variables de entorno para produccion:
   - DATABASE_URL (conexion a PostgreSQL)
   - JWT_SECRET (secreto para firmar tokens — debe ser largo y aleatorio)
   - CORS_ORIGINS (dominios permitidos para hacer requests)
5. Health check que verifique que la API esta respondiendo
6. Despliegue automatico cuando hagamos push a la rama main
7. HTTPS habilitado (Coolify lo maneja automaticamente)

IMPORTANTE:
- La contrasena de PostgreSQL en produccion debe ser diferente a la de desarrollo
- El JWT_SECRET en produccion debe ser diferente al de desarrollo
- Nunca usar los valores por defecto en produccion

Dame los archivos necesarios y las instrucciones paso a paso.
```

**Que esperar**: Claude va a crear:
- `Dockerfile` (como empaquetar la API)
- `docker-compose.yml` (para desarrollo local)
- Instrucciones detalladas para configurar Coolify

**Para la parte de Coolify**, probablemente necesites acceso al panel de Coolify. Si no lo tienes, pide ayuda a quien maneja la infraestructura.

---

## Paso 14 — Subir a GitHub y activar

**Que vamos a hacer**: Guardar todo en GitHub y activar el despliegue automatico. Cada vez que hagas un cambio y lo subas, la API se actualiza sola en internet.

**Copia y pega este prompt**:

```
Crea un repositorio privado en GitHub llamado batuta-task-api
bajo tu organizacion o usuario de GitHub [TU-ORGANIZACION-O-USUARIO], sube todo el codigo, y configura
el webhook de Coolify para despliegue automatico.

IMPORTANTE: Verifica que .gitignore incluya:
- .env (variables secretas)
- Cualquier archivo con contrasenas, API keys o tokens
- __pycache__/ (archivos temporales de Python)
- .pytest_cache/ (archivos temporales de tests)

Haz el commit inicial con todo lo que hemos construido.
```

**Si Claude pide permisos de git** (commit, push), di "yes".

---

## Paso 15 — Verificar, archivar, y celebrar

**Que vamos a hacer**: Confirmar que todo funciona en internet y cerrar formalmente el proyecto.

**Verifica primero**:

```
Verifica que el despliegue en Coolify esta funcionando correctamente.
Revisa los logs y confirma que:
1. La API esta respondiendo en la URL de produccion
2. La base de datos PostgreSQL esta conectada
3. Las migraciones se ejecutaron correctamente
4. El endpoint /docs esta accesible
5. El health check esta pasando
6. HTTPS esta funcionando
```

**Si todo esta bien**, abre tu navegador y ve a `https://api.tudominio.com/docs`. Deberias ver la pagina de documentacion interactiva, igual que cuando probaste en tu computadora.

**Si algo falla**, los errores mas comunes son:
- Base de datos no conecta: verificar DATABASE_URL en las variables de entorno de Coolify
- Error de migracion: Claude te ayuda a ejecutar las migraciones manualmente
- CORS bloqueado: verificar que CORS_ORIGINS incluya los dominios correctos
- Health check falla: verificar que el puerto esta bien configurado

**Cuando todo funcione**, archiva el proyecto:

```
/sdd:archive batuta-task-manager
```

Claude cierra el proyecto formalmente: verifica que todo esta completo, guarda las lecciones aprendidas, y actualiza `.batuta/session.md`.

**Tu microservicio esta en produccion. Felicidades!**

---

# SECCION DE SEGURIDAD

> Esta seccion es MUY IMPORTANTE. Un microservicio con autenticacion maneja datos sensibles
> (contrasenas, emails, datos personales). La seguridad no es opcional.

---

## Checklist OWASP para nuestra API

OWASP es la organizacion mas respetada en seguridad de aplicaciones web. Aqui estan las protecciones que nuestro microservicio implementa:

| Vulnerabilidad OWASP | Que es | Como nos protegemos |
|-----------------------|--------|---------------------|
| **Inyeccion SQL** | Alguien escribe codigo malicioso en el campo de login para hackear la base de datos | SQLAlchemy usa "consultas parametrizadas" que impiden esto automaticamente. Nunca concatenamos texto del usuario directamente en una consulta SQL. |
| **Autenticacion rota** | Alguien roba o adivina tu token | Los tokens JWT expiran cada 24 horas. Las contrasenas se guardan como hash (ilegibles). El secreto JWT es largo y aleatorio. |
| **Exposicion de datos** | La API devuelve datos que no deberia (como contrasenas) | Los schemas de respuesta NUNCA incluyen la contrasena. Solo devolvemos lo necesario. |
| **Control de acceso roto** | Un usuario accede a las tareas de otro | Cada endpoint verifica que la tarea pertenezca al usuario del token. Si no es tuya, error 404 (como si no existiera). |
| **Configuracion insegura** | Usar contrasenas por defecto en produccion | Variables de entorno diferentes para desarrollo y produccion. Nunca valores por defecto en produccion. |
| **Componentes vulnerables** | Usar librerias con errores de seguridad conocidos | Claude actualiza las dependencias a versiones seguras. |

### Como verificar la seguridad

Pidele a Claude despues de cualquier cambio:

```
Ejecuta una revision de seguridad OWASP Top 10 en la API.
Verifica que no haya vulnerabilidades nuevas y que todas las
protecciones siguen activas.
```

---

## Prevencion de SQL Injection

La inyeccion SQL es uno de los ataques mas comunes y peligrosos. Funciona asi:

Imagina que el campo de login dice "Escribe tu email". Un atacante escribe:
```
' OR 1=1; DROP TABLE usuarios; --
```

Si el sistema pone eso directamente en la consulta a la base de datos, podria borrar toda la tabla de usuarios. Es como escribir "abrir todas las celdas" en el campo de "nombre del preso".

**Nuestra proteccion**: SQLAlchemy NUNCA pone texto del usuario directamente en consultas. Siempre usa "parametros seguros" que tratan el texto como DATOS, no como comandos. El texto malicioso se guarda literalmente como texto, sin ejecutarse.

---

## Mejores practicas de JWT

| Practica | Que hacemos | Por que |
|----------|-------------|---------|
| **Secreto largo** | Minimo 32 caracteres aleatorios | Un secreto corto se puede adivinar por fuerza bruta |
| **Expiracion** | Tokens expiran en 24 horas | Si alguien roba un token, deja de funcionar al dia siguiente |
| **No guardar datos sensibles en el token** | Solo guardamos el user_id y la fecha de expiracion | Los tokens pueden ser decodificados por cualquiera (la firma evita que se modifiquen, pero el contenido es visible) |
| **Secretos diferentes por entorno** | Desarrollo y produccion usan secretos distintos | Si alguien obtiene el secreto de desarrollo, no puede usarlo en produccion |
| **HTTPS obligatorio** | La API en produccion solo acepta HTTPS | Sin HTTPS, alguien podria interceptar el token en transito (como leer una carta abierta) |

Para rotar el secreto JWT (cambiar la "llave") sin desconectar a todos los usuarios:

```
Necesito rotar el JWT_SECRET en produccion.
Implementa un sistema de doble secreto que acepte tokens firmados
con el secreto viejo durante 24 horas mientras todos migran al nuevo.
```

---

# DESPUES DE LA ENTREGA

> Estos pasos son opcionales pero recomendados para mantener tu API saludable.

---

## Hacer cambios despues

Cuando quieras agregar algo nuevo o cambiar algo, NO edites el codigo directamente. Usa el mismo proceso:

```
/sdd:new nombre-del-cambio

Quiero agregar [descripcion].
Por ejemplo: un campo de "etiquetas" a las tareas para poder
organizarlas por temas (trabajo, personal, etc.)
```

Y sigue el mismo flujo: propose, specs, design, tasks, apply, verify (el explore se ejecuta automaticamente dentro de `/sdd:new`).

> **Importante**: Cada cambio pasa por el Execution Gate automaticamente.
> Claude valida que el cambio siga las reglas del proyecto antes de escribir codigo.

---

## Agregar nuevas funcionalidades

Ejemplos de cosas que puedes agregar despues:

```
/sdd:new task-tags

Quiero agregar etiquetas (tags) a las tareas:
- Cada tarea puede tener multiples tags
- Los tags son strings simples: "trabajo", "personal", "urgente"
- Poder filtrar tareas por tag: GET /tasks?tag=trabajo
- Poder listar todos los tags: GET /tags
```

```
/sdd:new task-subtasks

Quiero agregar subtareas:
- Cada tarea puede tener una lista de subtareas (checklist)
- Cada subtarea tiene: titulo y estado (completada/pendiente)
- Cuando todas las subtareas estan completadas, sugerir completar la tarea principal
```

---

## Mejorar tus instrucciones

Despues de trabajar un rato con Claude (10+ interacciones):

```
/batuta-analyze-prompts
```

Claude revisa la bitacora de calidad y te da recomendaciones concretas.

---

## Actualizar el ecosistema Batuta

```
/batuta-update
```

Actualiza los skills sin tocar tu codigo.

---

## Estructura esperada del proyecto

```
batuta-task-api/
├── core/                                    # Configuracion central
│   ├── config.py                            # Variables de entorno y configuracion
│   ├── database.py                          # Conexion a PostgreSQL con SQLAlchemy
│   └── security.py                          # Funciones de hash y JWT
├── features/
│   ├── auth/                                # Feature: autenticacion
│   │   ├── routes/
│   │   │   └── auth_router.py               # Endpoints: register, login, me
│   │   ├── services/
│   │   │   └── auth_service.py              # Logica de negocio de autenticacion
│   │   ├── models/
│   │   │   └── user.py                      # Modelo de usuario (tabla en la BD)
│   │   ├── schemas/
│   │   │   └── user_schema.py               # Estructura de datos de entrada/salida
│   │   └── tests/
│   │       └── test_auth.py                 # Tests de autenticacion
│   ├── tasks/                               # Feature: gestion de tareas
│   │   ├── routes/
│   │   │   └── task_router.py               # Endpoints: CRUD de tareas
│   │   ├── services/
│   │   │   └── task_service.py              # Logica de negocio de tareas
│   │   ├── models/
│   │   │   └── task.py                      # Modelo de tarea (tabla en la BD)
│   │   ├── schemas/
│   │   │   └── task_schema.py               # Estructura de datos de entrada/salida
│   │   └── tests/
│   │       └── test_tasks.py                # Tests de tareas
│   └── shared/                              # Compartido entre features
│       └── middleware/
│           └── auth_middleware.py            # Verificacion de token JWT
├── alembic/                                 # Migraciones de base de datos
│   ├── versions/                            # Cada migracion es un archivo aqui
│   └── env.py                               # Configuracion de Alembic
├── alembic.ini                              # Configuracion de Alembic
├── main.py                                  # Punto de entrada de la aplicacion
├── Dockerfile                               # Para produccion
├── docker-compose.yml                       # Para desarrollo local
├── .env.example                             # Ejemplo de variables (SIN secretos)
├── .env                                     # Variables secretas (NO va a git)
├── .gitignore                               # Archivos excluidos de git
├── requirements.txt                         # Dependencias de Python
├── pytest.ini                               # Configuracion de tests
└── conftest.py                              # Configuracion compartida de tests
```

> Nota como sigue la **Scope Rule**: cada feature (auth, tasks) tiene su carpeta, shared tiene lo que usan ambas features (el middleware de autenticacion), y core tiene la configuracion central.

---

## Comandos de emergencia

Si algo sale muy mal y necesitas actuar rapido:

| Situacion | Que escribir |
|-----------|-------------|
| Claude se trabo y no responde | Cierra la terminal, abrela de nuevo, escribe `claude` |
| Quieres deshacer el ultimo cambio | `Deshaz el ultimo cambio que hiciste` |
| La base de datos se corrompio | `Borra la base de datos de desarrollo y recreala con las migraciones` |
| Los tests no pasan | `Ejecuta los tests y corrige todos los que fallen` |
| No entiendes algo | `Explicame [lo que no entiendes] como si tuviera 15 anos` |
| Quieres ver el estado del proyecto | `/sdd:continue batuta-task-manager` |

---

## Preguntas frecuentes

**P: Puedo usar esta API desde una app de celular o un frontend?**
R: Si. Cualquier aplicacion puede conectarse a esta API: una app web (React, Next.js), una app de celular (Flutter, React Native), o incluso otra API. Solo necesita saber la URL y enviar los headers correctos.

**P: Cuanto cuesta correr esto?**
R: FastAPI y PostgreSQL son gratuitos. El unico costo es el servidor donde lo despliegas. En Coolify con un servidor basico, el costo es de unos $5-10 USD al mes.

**P: Cuantos usuarios puede manejar?**
R: FastAPI es muy rapido. Un servidor basico puede manejar miles de peticiones por segundo. Para una app con cientos de usuarios, es mas que suficiente.

**P: Puedo cerrar la terminal y continuar despues?**
R: Si. Abre la terminal, navega a tu carpeta, escribe `claude`, y Claude lee `.batuta/session.md` automaticamente. Recuerda donde quedo sin que le digas nada.

**P: Que pasa si olvido mi contrasena de la base de datos?**
R: Para desarrollo, la contrasena esta en el archivo `.env`. Para produccion, esta en las variables de entorno de Coolify. Puedes cambiarla, pero necesitas actualizar la configuracion.

**P: Puedo conectar esta API a un frontend que ya tengo?**
R: Si. Solo necesitas configurar CORS (los dominios que pueden hacer peticiones) para incluir el dominio de tu frontend. Pidele a Claude: "Agrega mi frontend https://mi-app.com a los origenes CORS permitidos".

**P: Necesito internet para desarrollar?**
R: Para Claude Code si. Pero la API y PostgreSQL pueden correr localmente sin internet. Solo necesitas internet para desplegar y para que Claude te ayude.

**P: Cuanto tarda todo el proceso?**
R: La primera vez, entre 1.5 y 2.5 horas incluyendo la creacion de skills. La segunda vez, mucho menos porque los skills ya existen.

---

## Resumen visual del flujo completo

```
Tu (carpeta vacia)
 |
 +-- Paso 2:  Instalar ecosistema Batuta + crear .batuta/
 |
 +-- Paso 3:  /sdd:init .............. "Que tipo de proyecto es?"
 |
 |   [Claude detecta skills faltantes → Paso 4: "Opcion 1"]
 |
 +-- Paso 5:  /sdd:new ............... "Explora + Propuesta formal"
 |     Tu: "Aprobado"
 |
 +-- Paso 6:  /sdd:continue .......... "Specs → Design → Tasks"
 |     Tu: "Continua" (3 veces)
 |
 +-- Paso 7:  /sdd:apply ............. "Modelos de base de datos"
 |     [Execution Gate valida antes de cada cambio]
 |
 +-- Paso 8:  Autenticacion .......... "Register, login, JWT"
 |
 +-- Paso 9:  CRUD de tareas ......... "Crear, leer, actualizar, borrar"
 |
 +-- Paso 10: Tests con pytest ....... "21 tests automaticos"
 |
 +-- Paso 11: /sdd:verify ............ "Piramide de Validacion"
 |
 +-- Paso 12: Probar en tu PC ........ "localhost:8000/docs"
 |
 +-- Paso 13: Deploy a Coolify ....... "Poner en internet"
 |
 +-- Paso 14: Push a GitHub .......... "Codigo en la nube"
 |
 +-- Paso 15: Verificar + archivar ... "Confirmar y celebrar"
 |
 [Tu API esta en produccion!]
```

---

## Nivel Avanzado: Agent Teams (Equipos de Agentes)

Cuando te sientas comodo con los pasos anteriores, puedes usar **Agent Teams** para que Claude trabaje con multiples "asistentes" en paralelo. Es como tener un equipo de programadores en lugar de uno solo.

### Cuando usar cada nivel

| Nivel | Cuando usarlo | Ejemplo en este proyecto |
|-------|--------------|------------------------|
| **Solo** (normal) | Cambios simples, 1-2 archivos | "Agrega un campo de telefono al modelo de usuario" |
| **Subagente** (automatico) | Investigar o verificar algo | Claude investiga la mejor forma de implementar paginacion |
| **Agent Team** (tu lo pides) | Trabajo grande en multiples partes | Agregar tags + subtareas + notificaciones al mismo tiempo |

### Como pedirle a Claude que use un equipo

```
Tu: "Necesito agregar 3 funcionalidades nuevas a la API: etiquetas (tags),
     subtareas (checklist), y notificaciones por email cuando una tarea
     vence. Crea un equipo para implementar todo en paralelo."
```

Claude va a:
1. Evaluar si el trabajo justifica un equipo (3 features = si)
2. Crear 2-3 asistentes especializados
3. Repartir el trabajo: uno hace tags, otro subtareas, otro notificaciones
4. Cada asistente trabaja en su parte al mismo tiempo
5. Un revisor verifica que todo encaje al final

### Ejemplos practicos para este proyecto

**Ejemplo 1 — Agregar multiples features en paralelo:**
```
Tu: "Necesito agregar a la API: etiquetas para tareas, subtareas con checklist,
     y un endpoint de estadisticas que muestre cuantas tareas tengo por estado.
     Crea un equipo para implementar todo."
```

**Ejemplo 2 — Refactorizar y agregar tests al mismo tiempo:**
```
Tu: "Quiero mejorar la seguridad (agregar rate limiting, validacion de passwords
     fuertes, logs de auditoria) mientras otro asistente agrega tests
     de rendimiento. Crea un equipo."
```

**Ejemplo 3 — Documentacion y optimizacion:**
```
Tu: "Necesito que un asistente escriba la documentacion completa de la API
     para desarrolladores externos, mientras otro optimiza las consultas
     a la base de datos para que sean mas rapidas."
```

### Metricas esperadas de rendimiento

Estas metricas son estimaciones para que compares cuando ejecutes los pasos. Anota tus resultados reales para mejorar el sistema.

| Escenario | Nivel | Tiempo estimado | Costo tokens | Calidad esperada | Fortaleza | Debilidad |
|-----------|-------|----------------|-------------|-----------------|-----------|-----------|
| Agregar un campo a un modelo | Solo | 3-5 min | ~5K tokens | 95% primera vez | Rapido, incluye migracion | N/A |
| Agregar 1 feature SDD completa | Solo + Subagente | 20-30 min | ~60K tokens | 85% primera vez | Proceso completo, trazable | Secuencial |
| Agregar 3 features paralelo | Agent Team | 25-40 min | ~180K tokens | 80% primera vez | 3 features al mismo tiempo | Migraciones pueden chocar |
| Revision seguridad + tests | Agent Team | 15-25 min | ~120K tokens | 90% cobertura | Dos perspectivas simultaneas | Pueden sugerir cambios contradictorios |
| Documentacion completa | Agent Team | 15-20 min | ~80K tokens | 85% primera vez | Cada seccion se escribe en paralelo | Tono puede variar entre secciones |

> **Importante**: Para migraciones de base de datos (Alembic), el modo Solo es mas seguro
> porque las migraciones deben ejecutarse en orden estricto. Los Agent Teams son mejores
> para features que no comparten tablas de base de datos.

---

## Troubleshooting — Problemas comunes y como resolverlos

### Problemas con la base de datos

| Problema | Que ves | Como resolverlo |
|----------|---------|-----------------|
| No conecta a PostgreSQL | Error "connection refused" al iniciar la API | Verifica que PostgreSQL este corriendo. Si usas Docker: `docker ps` para ver si el contenedor esta activo. Si no aparece: `docker start postgres-batuta`. |
| Error de migracion | Error "Table already exists" o "relation does not exist" | Las migraciones estan desincronizadas. Pidele a Claude: "Resincroniza las migraciones de Alembic y aplica todas las pendientes." |
| Base de datos llena | Error "disk full" o respuestas muy lentas | Si es desarrollo, puedes borrar y recrear: `docker rm postgres-batuta` y volver a crearlo. En produccion, necesitas mas espacio — contacta a quien maneja la infraestructura. |
| Datos corruptos en desarrollo | Datos inconsistentes despues de muchos cambios | Borra la base de datos de desarrollo y recreala: pidele a Claude que lo haga. Nunca hagas esto en produccion. |

Pidele a Claude:
```
Tengo este error con la base de datos: [pega el error].
Diagnostica el problema y dame la solucion paso a paso.
```

### Problemas con la autenticacion

| Problema | Que ves | Como resolverlo |
|----------|---------|-----------------|
| Token expirado | Error 401 con mensaje "Token expired" | Es normal despues de 24 horas. Haz login de nuevo para obtener un token nuevo. |
| "Invalid token" despues de reiniciar | Error 401 con mensaje "Invalid token" | Si cambiaste el JWT_SECRET, los tokens viejos dejan de funcionar. Los usuarios necesitan hacer login de nuevo. |
| "User not found" en /auth/me | Error 404 despues de hacer login exitoso | La base de datos puede haber sido limpiada despues del login. Registrate de nuevo. |
| Contrasena rechazada | Error 422 al registrarse | Verifica que la contrasena cumple los requisitos minimos (si los hay). Pidele a Claude que te muestre los requisitos. |

### Problemas con los tests

| Problema | Que ves | Como resolverlo |
|----------|---------|-----------------|
| Tests fallan por base de datos | Error "database does not exist" en pytest | Los tests necesitan una base de datos de prueba separada. Pidele a Claude: "Crea la base de datos de tests y configura pytest para usarla." |
| Tests pasan local pero fallan en CI | Tests verdes en tu PC pero rojos en GitHub Actions | Las configuraciones de conexion pueden ser diferentes. Pidele a Claude que unifique las configuraciones. |
| Tests intermitentes | A veces pasan, a veces fallan sin cambiar nada | Puede ser un problema de orden de ejecucion o limpieza de datos. Pidele a Claude: "Arregla los tests intermitentes, probablemente hay un problema de limpieza entre tests." |

### Problemas con Docker y Coolify

| Problema | Que ves | Como resolverlo |
|----------|---------|-----------------|
| Docker build falla | Error al construir la imagen de Docker | Copia el error exacto y pasaselo a Claude. Los mas comunes son dependencias que faltan o versiones incompatibles. |
| La API no arranca en Coolify | El servicio se reinicia constantemente | Revisa los logs en Coolify. Los errores mas comunes: variables de entorno faltantes, base de datos no accesible, o puerto incorrecto. |
| CORS bloqueado | Error "CORS policy" en el navegador cuando tu frontend intenta conectarse | Agrega el dominio de tu frontend a CORS_ORIGINS en las variables de entorno. Pidele a Claude que lo configure. |
| Migraciones no se ejecutan en produccion | Tablas no existen en la base de datos de produccion | Las migraciones necesitan ejecutarse manualmente la primera vez. Pidele a Claude las instrucciones para tu configuracion especifica. |

Para cualquier problema no listado aqui:

```
Tengo este error al [describir que estabas haciendo]:
[pega el error completo aqui]

Ayudame a diagnosticarlo y resolverlo.
```

---

> **Recuerda**: No necesitas entender COMO funciona todo por dentro. Solo necesitas seguir los pasos
> y confiar en el proceso. Como aprender a manejar: primero sigues las instrucciones al pie
> de la letra, y con el tiempo lo haces naturalmente. Claude es tu asistente — el programa, tu decides.
