# Guia Paso a Paso: Crear Batuta APP con Claude Code

> **Para quien es esta guia**: Para cualquier persona, sin importar si nunca ha programado.
> Solo necesitas saber copiar y pegar texto. Claude Code hace el resto.

---

## Glosario — Palabras que vas a ver

Antes de empezar, aqui tienes un mini-diccionario. No necesitas memorizarlo, vuelve aqui si ves una palabra que no entiendes.

| Palabra | Que significa (sin tecnicismos) |
|---------|-------------------------------|
| **Prompt** | El mensaje que le escribes a Claude. Como enviarle un WhatsApp con instrucciones. |
| **Claude Code** | Un asistente de programacion que vive en tu terminal. Tu le dices que quieres y el lo construye. |
| **Terminal** | La pantalla negra donde escribes comandos. Piensa en ella como un chat con tu computadora. |
| **Frontend** | Lo que el usuario ve: botones, graficas, colores. La "cara" de la aplicacion. |
| **Backend** | Lo que pasa detras de escena: donde se guardan datos, donde se procesan cosas. La "cocina" del restaurante. |
| **API** | Un "mesero" que lleva pedidos entre sistemas. Cuando decimos "API de n8n", es la forma de pedirle datos a n8n. |
| **Deploy** | Poner tu aplicacion en internet para que otros la vean. Como subir una foto a Instagram. |
| **Skill** | Un documento que le dice a Claude COMO hacer algo especifico. Como una receta de cocina. |
| **SDD** | Spec-Driven Development. Un proceso paso a paso para construir software: primero planeas, luego construyes. Como un arquitecto que primero dibuja el plano y luego construye la casa. |
| **Repositorio (repo)** | Una carpeta especial que guarda todo tu codigo y recuerda cada cambio que haces. |
| **n8n** | Una herramienta de automatizacion. Ejecuta tareas automaticas (como enviar emails, procesar datos). |
| **Coolify** | Una plataforma para poner aplicaciones en internet. Como un hosting inteligente. |

---

## Que vamos a construir

**Batuta APP** — Un panel de control (dashboard) donde puedes ver:

1. **Ejecuciones de n8n**: Cuantas automatizaciones se ejecutaron, cuales fallaron, cuales salieron bien
2. **Consumo de tokens de Google AI**: Cuanto estamos gastando en inteligencia artificial
3. **Login sencillo**: Entras con tu email y una contrasena que tu mismo manejas
4. **Todo automatico**: Cuando se hacen cambios, la aplicacion se actualiza sola en internet

---

## Antes de empezar — Lo que necesitas tener instalado

Pide ayuda a alguien para instalar estas 3 cosas si no las tienes:

| Herramienta | Para que sirve | Como instalar |
|-------------|---------------|---------------|
| **Node.js** | Hace que JavaScript funcione en tu computadora | Descarga de [nodejs.org](https://nodejs.org) la version LTS |
| **Git** | Guarda el historial de tu proyecto | Descarga de [git-scm.com](https://git-scm.com) |
| **Claude Code** | El asistente que va a programar por ti | En la terminal escribe: `npm install -g @anthropic-ai/claude-code` |

Para verificar que todo esta instalado, abre una terminal y escribe:
```
node --version
git --version
claude --version
```
Si los tres muestran un numero (como `v20.11.0`), estas lista.

---

# LAS SLIDES

---

## Slide 1 — Crear la carpeta del proyecto

**Que vamos a hacer**: Crear una carpeta vacia donde vivira toda nuestra aplicacion.

**Que hacer**:
1. Abre el Explorador de Archivos de Windows
2. Ve a donde quieras guardar tu proyecto (ejemplo: `E:\Proyectos\`)
3. Click derecho → Nueva Carpeta
4. Nombrala: `Batuta APP`

**Resultado**: Tienes una carpeta vacia llamada `Batuta APP`.

---

## Slide 2 — Abrir Claude Code en tu proyecto

**Que vamos a hacer**: Abrir el asistente de programacion dentro de tu carpeta.

**Que hacer**:
1. Abre una terminal (busca "Terminal" o "Command Prompt" en Windows)
2. Escribe exactamente esto y presiona Enter:

```
cd "E:\Proyectos\Batuta APP"
```

> Cambia la ruta si tu carpeta esta en otro lugar.

3. Ahora escribe:

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

## Slide 3 — Instalar el ecosistema Batuta

**Que vamos a hacer**: Darle a Claude las "recetas" (skills) que necesita para trabajar al estilo Batuta.

**Copia y pega este prompt**:

```
Necesito configurar este proyecto con el ecosistema Batuta.

Haz lo siguiente:
1. Clona el repositorio github.com/jota-batuta/batuta-dots en una carpeta temporal
2. Ejecuta el script skills/setup.sh --all para generar CLAUDE.md y sincronizar skills
3. Copia el archivo BatutaClaude/CLAUDE.md a la raiz de este proyecto como CLAUDE.md
4. Copia el archivo AGENTS.md a la raiz de este proyecto
5. Inicializa git en esta carpeta si no existe
6. Confirma cuando todo este listo
```

**Que esperar**: Claude va a descargar el ecosistema y configurar todo. Puede tomar 1-2 minutos. Cuando termine, te dira que archivos creo.

**Tip**: Si Claude te pide permiso para ejecutar comandos, di "yes" o "si".

---

## Slide 4 — Iniciar el proyecto con SDD

**Que vamos a hacer**: Decirle a Claude que tipo de proyecto vamos a construir para que se prepare correctamente.

**Copia y pega este prompt**:

```
/sdd:init
```

**Que esperar**: Claude te va a hacer preguntas sobre el proyecto. Cuando te pregunte, responde asi:

| Si Claude pregunta... | Tu respondes... |
|----------------------|-----------------|
| Nombre del proyecto | `batuta-app` |
| Tipo de proyecto | `webapp` |
| Descripcion | `Dashboard para monitorear ejecuciones de n8n y consumo de tokens de Google AI, con autenticacion por email y contrasena` |
| Stack/tecnologias | `Dejalo decidir, pero sugiérele: Next.js para frontend, Python o Node para backend, PostgreSQL para base de datos` |

**Tip**: No te preocupes si no entiendes todo lo que Claude responde. Lo importante es que el "entienda" que queremos construir.

---

## Slide 5 — Explorar la idea

**Que vamos a hacer**: Pedirle a Claude que investigue COMO construir lo que necesitamos antes de empezar a programar. Como cuando un arquitecto estudia el terreno antes de dibujar planos.

**Copia y pega este prompt**:

```
/sdd:explore batuta-app-dashboard

Necesito explorar como construir un dashboard con estas caracteristicas:

PANTALLA PRINCIPAL:
- Grafica de barras mostrando ejecuciones de n8n por dia (exitosas vs fallidas)
- Numero total de ejecuciones este mes
- Porcentaje de exito
- Lista de las ultimas 10 ejecuciones con su estado (exito/fallo) y nombre del workflow

PANTALLA DE TOKENS:
- Consumo de tokens de Google AI del proyecto actual
- Grafica de consumo por dia
- Costo estimado en dolares

AUTENTICACION:
- Login con email y contrasena
- Registro de usuarios nuevos
- Recuperar contrasena por email
- No necesitamos Google login ni nada complicado

DATOS:
- Los datos de n8n vienen de la API REST de n8n (ya tenemos n8n corriendo)
- Los datos de Google vienen de la API de Google Cloud (billing o AI platform)
- La app debe actualizarse cada 5 minutos automaticamente

DEPLOY:
- Se despliega en Coolify
- Cuando hacemos push a git, se despliega automaticamente
- Frontend y backend se despliegan juntos pero como servicios separados
```

**Que esperar**: Claude va a investigar el codebase (que esta vacio) y las tecnologias. Probablemente te diga algo como:

> "Para implementar esto necesitamos trabajar con **Next.js**, pero no tengo un skill documentado..."

Esto es **NORMAL y BUENO**. Significa que el sistema de deteccion de skills esta funcionando.

---

## Slide 6 — Cuando Claude dice "no tengo un skill para eso"

**Que vamos a hacer**: Entender que pasa cuando Claude detecta que necesita aprender algo nuevo. Esto es como si un chef te dijera "no tengo la receta para ese plato, pero puedo investigarla".

**MOMENTO IMPORTANTE**: Despues del explore, Claude probablemente detecte que necesita skills para varias tecnologias. Te va a preguntar que hacer para cada una.

**Cuando Claude diga algo como:**
> "No tengo un skill documentado para Next.js... Te propongo:
> 1. Investigar y crear el skill (proyecto)
> 2. Investigar y crear el skill (global)
> 3. Continuar sin skill"

**Tu respuesta siempre debe ser**:

```
Opcion 1 — Investiga y crea el skill acotado a nuestro proyecto
```

**Esto puede pasar varias veces para**:
- Next.js (frontend)
- n8n API (conectar con n8n)
- Google Cloud API (consumo de tokens)
- PostgreSQL (base de datos)
- Autenticacion (login)
- Coolify (deploy)

**Cada vez que te pregunte, responde "Opcion 1"**.

Claude va a investigar usando Context7 (su base de conocimiento actualizada) y crear las recetas que necesita. Esto toma unos minutos por skill, pero solo pasa una vez.

**Tip**: Este paso puede tomar 10-15 minutos en total. Es normal. Claude esta "aprendiendo" para hacerlo bien a la primera.

---

## Slide 7 — Crear la propuesta

**Que vamos a hacer**: Pedirle a Claude que escriba un plan formal de lo que va a construir. Como cuando un arquitecto te muestra el boceto antes de construir.

**Copia y pega este prompt**:

```
/sdd:new batuta-app-dashboard
```

**Que esperar**: Claude va a crear un documento llamado "proposal" que incluye:
- Que se va a construir (en lenguaje simple)
- Que riesgos hay
- Criterios de exito (como sabemos que funciona)

Claude te va a mostrar un **resumen** y te preguntara si esta bien.

**Lee el resumen con calma**. Si algo no te suena bien, dile. Por ejemplo:

```
Me parece bien pero agrega que tambien queremos ver el nombre del workflow
de n8n en la lista de ejecuciones, no solo el estado.
```

**Cuando estes conforme, di:**

```
Aprobado, continua con el siguiente paso
```

---

## Slide 8 — Continuar el pipeline automaticamente

**Que vamos a hacer**: Dejar que Claude avance por las fases de planificacion. El va a crear las especificaciones tecnicas, el diseno de la arquitectura, y las tareas de implementacion.

**Copia y pega este prompt**:

```
/sdd:continue batuta-app-dashboard
```

**Que esperar**: Claude va a ejecutar las siguientes fases una por una:

| Fase | Que hace | Cuanto toma |
|------|---------|-------------|
| **Specs** | Define EXACTAMENTE que debe hacer cada parte (como una lista de requisitos) | 2-5 min |
| **Design** | Decide la arquitectura: que tecnologias, como se conectan, donde vive cada cosa | 3-5 min |
| **Tasks** | Divide todo el trabajo en tareas pequenas y ordenadas | 2-3 min |

**Entre cada fase**, Claude te va a mostrar un resumen y preguntar si continua.

**Tu respuesta cada vez**:

```
Se ve bien, continua
```

**Si algo no entiendes**, pregunta sin miedo:

```
No entendi la parte de "RLS policies". Explicame que significa eso
en terminos simples.
```

Claude esta configurado para explicarte las cosas de forma que cualquier persona las entienda.

**Tip**: Este paso puede tomar 10-15 minutos. Puedes ir por un cafe mientras Claude trabaja entre fases.

---

## Slide 9 — Implementar (construir la aplicacion)

**Que vamos a hacer**: Ahora si, pedirle a Claude que ESCRIBA el codigo. Esta es la parte donde la magia pasa. Claude va a crear todos los archivos del proyecto.

**Copia y pega este prompt**:

```
/sdd:apply batuta-app-dashboard
```

**Que esperar**: Claude va a implementar el proyecto en "lotes" (batches). Cada lote es un grupo de tareas relacionadas.

Ejemplo de lo que vas a ver:
```
Implementando Batch 1 de 5: Estructura del proyecto y base de datos
- Creando estructura de carpetas...
- Configurando PostgreSQL...
- Creando modelos de datos...

Batch 1 completado. Continuo con Batch 2?
```

**Tu respuesta cada vez**:

```
Si, continua con el siguiente batch
```

**MOMENTOS IMPORTANTES durante la implementacion:**

### Cuando Claude pida las API keys:

Claude va a necesitar datos reales para conectar con n8n y Google. Te va a preguntar algo como:

> "Necesito la URL de tu instancia de n8n y un API key para conectarme"

**Responde con tus datos reales**:

```
La URL de n8n es: https://n8n.tudominio.com
El API key de n8n es: [pega aqui tu API key de n8n]

Para Google Cloud:
- Project ID: [tu project id]
- Las credenciales estan en: [ruta al archivo JSON de credenciales]
```

> **IMPORTANTE**: Si no tienes estos datos a la mano, dile a Claude:
> ```
> No tengo los API keys ahora. Usa valores de ejemplo (placeholders)
> y despues los cambio manualmente.
> ```

### Cuando Claude pida permisos para ejecutar comandos:

Va a pedir instalar dependencias (librerias que el proyecto necesita). Di "yes".

**Tip**: La implementacion puede tomar 15-30 minutos dependiendo de la complejidad. Claude trabaja solo, tu solo le das "si" cuando pide continuar.

---

## Slide 10 — Verificar que todo funcione

**Que vamos a hacer**: Pedirle a Claude que revise su propio trabajo. Como cuando un profesor revisa un examen.

**Copia y pega este prompt**:

```
/sdd:verify batuta-app-dashboard
```

**Que esperar**: Claude va a verificar:
- Que el codigo hace lo que las especificaciones dicen
- Que los tests pasan
- Que la documentacion esta completa
- Que la aplicacion esta lista para desplegarse

Si encuentra problemas, los va a listar y te va a preguntar si quieres que los corrija.

**Tu respuesta**:

```
Si, corrige todos los problemas que encontraste
```

Despues de las correcciones, ejecuta verify otra vez:

```
/sdd:verify batuta-app-dashboard
```

**Cuando todo este verde (sin errores)**, continua al siguiente slide.

---

## Slide 11 — Probar la aplicacion en tu computadora

**Que vamos a hacer**: Ver la aplicacion funcionando en tu computadora antes de subirla a internet.

**Copia y pega este prompt**:

```
Levanta la aplicacion en modo desarrollo para que pueda verla en mi navegador.
Dame las instrucciones paso a paso de como acceder.
```

**Que esperar**: Claude va a ejecutar los comandos necesarios y te dira algo como:

```
La aplicacion esta corriendo:
- Frontend: http://localhost:3000
- Backend: http://localhost:8000

Abre tu navegador y ve a http://localhost:3000
```

**Que hacer**:
1. Abre tu navegador (Chrome, Firefox, etc.)
2. Escribe en la barra de direcciones: `http://localhost:3000`
3. Deberias ver la pantalla de login de Batuta APP

**Prueba estas cosas**:
- Registrate con un email y contrasena
- Inicia sesion
- Mira el dashboard de n8n (si pusiste API keys reales, veras datos reales)
- Mira la pantalla de tokens de Google

**Si algo no funciona**, dile a Claude exactamente que ves:

```
Cuando hago click en "Registrarse" me sale una pantalla blanca y no pasa nada.
```

Claude va a investigar y corregir el problema.

---

## Slide 12 — Configurar el despliegue automatico

**Que vamos a hacer**: Configurar Coolify para que la aplicacion se suba a internet automaticamente cada vez que hagamos cambios.

**Copia y pega este prompt**:

```
Necesito configurar el despliegue automatico en Coolify.

Tenemos:
- Coolify corriendo en: [TU URL DE COOLIFY, ejemplo: https://coolify.tudominio.com]
- El dominio para la app sera: [TU DOMINIO, ejemplo: app.batutaai.com]

Configura:
1. Un servicio para el backend
2. Un servicio para el frontend
3. Que ambos se desplieguen automaticamente cuando hagamos push a la rama main
4. Variables de entorno para las API keys (n8n y Google)
5. La base de datos PostgreSQL como servicio en Coolify

Dame los archivos necesarios (docker-compose, Dockerfile, etc.) y las
instrucciones para configurar Coolify.
```

**Que esperar**: Claude va a crear:
- Un archivo `docker-compose.yml` (le dice a Coolify como levantar la app)
- Un `Dockerfile` para el frontend
- Un `Dockerfile` para el backend
- Instrucciones paso a paso para configurar Coolify

**Tip**: Para esta parte, probablemente necesites acceso a tu panel de Coolify. Si no lo tienes, pide ayuda a quien maneja la infraestructura.

---

## Slide 13 — Subir todo a GitHub

**Que vamos a hacer**: Guardar todo el proyecto en GitHub y activar el despliegue automatico.

**Copia y pega este prompt**:

```
Crea un repositorio privado en GitHub llamado batuta-app bajo la organizacion
jota-batuta, sube todo el codigo, y configura el webhook de Coolify para
despliegue automatico.

Haz el commit inicial con todo lo que hemos construido.
```

**Que esperar**: Claude va a:
1. Crear el repo en GitHub
2. Hacer commit de todos los archivos
3. Hacer push
4. Darte el link del repositorio

**Si Claude pide permisos de git** (commit, push), di "yes".

---

## Slide 14 — Verificar el despliegue

**Que vamos a hacer**: Confirmar que la aplicacion esta viva en internet.

**Copia y pega este prompt**:

```
Verifica que el despliegue en Coolify esta funcionando correctamente.
Revisa los logs de los servicios y confirma que:
1. El backend esta respondiendo
2. El frontend esta cargando
3. La base de datos esta conectada
4. Las APIs de n8n y Google estan respondiendo
```

**Que esperar**: Claude revisara los logs y te dara un reporte de estado.

**Si todo esta bien**, abre tu navegador y ve a tu dominio (ejemplo: `https://app.batutaai.com`).

**Si algo falla**, Claude te dira que esta mal y como arreglarlo.

---

## Slide 15 — Archivar y celebrar

**Que vamos a hacer**: Cerrar formalmente el proyecto y guardar todo lo aprendido.

**Copia y pega este prompt**:

```
/sdd:archive batuta-app-dashboard
```

**Que esperar**: Claude va a:
- Verificar que todo esta completo
- Guardar las lecciones aprendidas
- Crear un resumen final del proyecto

---

# EXTRAS

---

## Extra A — Si quieres hacer cambios despues

Cuando quieras agregar algo nuevo o cambiar algo, NO edites el codigo directamente. Usa el mismo proceso:

```
/sdd:new nombre-del-cambio

Quiero agregar [descripcion de lo que quieres cambiar o agregar].
Por ejemplo: una nueva grafica que muestre los workflows mas usados de n8n.
```

Y sigue el mismo flujo: explore → propose → specs → design → tasks → apply → verify.

---

## Extra B — Comandos de emergencia

Si algo sale muy mal y quieres empezar de cero una fase:

| Situacion | Que escribir |
|-----------|-------------|
| Claude se trabo y no responde | Cierra la terminal, abrela de nuevo, escribe `claude` |
| Quieres deshacer el ultimo cambio | `Deshaz el ultimo cambio que hiciste` |
| No entiendes algo | `Explicame [lo que no entiendes] como si tuviera 15 anos` |
| Quieres ver el estado del proyecto | `/sdd:continue batuta-app-dashboard` (te muestra donde quedamos) |

---

## Extra C — Preguntas frecuentes

**P: Claude me dice cosas que no entiendo. Que hago?**
R: Copialo y preguntale: "Explicame esto en espanol simple, sin palabras tecnicas"

**P: Cuanto tarda todo el proceso?**
R: La primera vez, entre 1 y 2 horas incluyendo la creacion de skills. La segunda vez que hagas un proyecto similar, mucho menos porque los skills ya existen.

**P: Puedo cerrar la terminal y continuar despues?**
R: Si. Abre la terminal, navega a tu carpeta (`cd "ruta/Batuta APP"`), escribe `claude`, y dile: "Continuemos donde quedamos con el proyecto batuta-app-dashboard"

**P: Que pasa si no tengo las API keys de n8n o Google?**
R: Dile a Claude que use valores de ejemplo. Despues tu o alguien mas puede reemplazarlos en los archivos de configuracion.

**P: Necesito internet para esto?**
R: Si, Claude Code necesita internet para funcionar. Tambien necesitas internet para que las APIs de n8n y Google respondan.

**P: Puedo usar esto para otros proyectos, no solo este?**
R: Si. El ecosistema Batuta funciona para cualquier tipo de proyecto. Solo cambia la descripcion en el paso de `/sdd:init` y `/sdd:explore`.

---

## Resumen visual del flujo completo

```
Tu (carpeta vacia)
 |
 +-- Slide 3: Instalar ecosistema Batuta
 |
 +-- Slide 4: /sdd:init .............. "Que tipo de proyecto es?"
 |
 +-- Slide 5: /sdd:explore ........... "Investigar como hacerlo"
 |
 |   [Claude detecta skills faltantes → Slide 6: "Opcion 1"]
 |
 +-- Slide 7: /sdd:new ............... "Propuesta formal"
 |     Tu: "Aprobado"
 |
 +-- Slide 8: /sdd:continue .......... "Specs → Design → Tasks"
 |     Tu: "Continua" (3 veces)
 |
 +-- Slide 9: /sdd:apply ............. "Construir la app"
 |     Tu: "Si, continua" (por cada batch)
 |
 +-- Slide 10: /sdd:verify ........... "Revisar que todo funcione"
 |
 +-- Slide 11: Probar en tu PC ....... "localhost:3000"
 |
 +-- Slide 12: Configurar Coolify .... "Deploy automatico"
 |
 +-- Slide 13: Push a GitHub ......... "Codigo en la nube"
 |
 +-- Slide 14: Verificar deploy ...... "App en internet"
 |
 +-- Slide 15: /sdd:archive .......... "Cerrar y celebrar"
 |
 [Tu app esta en internet!]
```

---

> **Recuerda**: No necesitas entender COMO funciona todo. Solo necesitas seguir los pasos y confiar en el proceso. Claude es tu asistente — el programa, tu decides.
