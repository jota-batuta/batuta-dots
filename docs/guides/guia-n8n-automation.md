# Guia Paso a Paso: Automatizacion de Procesos con n8n y Claude Code

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
| **n8n** | Una herramienta de automatizacion visual. Imagina una fabrica donde conectas maquinas con tubos: cada maquina hace algo (leer email, clasificar, responder) y el tubo pasa el resultado a la siguiente. n8n es esa fabrica digital. |
| **Workflow** | Una cadena de pasos automaticos en n8n. Como una receta de cocina: paso 1, paso 2, paso 3. Cada paso recibe algo del anterior y pasa algo al siguiente. |
| **Webhook** | Una "puerta de entrada" que recibe informacion de afuera. Cuando llega un email, el webhook le avisa a n8n "oye, llego algo nuevo". Como un timbre que suena cuando alguien toca la puerta. |
| **API** | Un "mesero" que lleva pedidos entre sistemas. Cuando n8n le pide a la IA que clasifique un email, lo hace a traves de una API. |
| **API Key** | Una contrasena especial que identifica a tu aplicacion. Como tu credencial de empleado — sin ella, no te dejan entrar al edificio. |
| **Clasificacion** | Cuando la IA lee un email y decide en que categoria cae: urgente, normal, o spam. Como un cartero que separa las cartas por destino. |
| **Deploy** | Poner tu aplicacion en internet para que funcione sola, sin tu computadora encendida. Como subir una foto a Instagram — ya queda ahi aunque apagues tu celular. |
| **Docker** | Una herramienta que empaqueta aplicaciones para que funcionen en cualquier computadora igual. Como una caja de mudanza estandarizada — da igual donde la lleves, todo llega igual. |
| **Docker Compose** | Un archivo que le dice a Docker "levanta estos 3 servicios juntos". Como una orden de pedido que dice "traeme la pizza, la bebida y el postre al mismo tiempo". |
| **Coolify** | Una plataforma para poner aplicaciones en internet. Como un hosting inteligente que se encarga de que todo siga corriendo. |
| **SDD** | Spec-Driven Development. Un proceso paso a paso para construir software: primero planeas, luego construyes. Como un arquitecto que primero dibuja el plano y luego construye la casa. |
| **Skill** | Un documento que le dice a Claude COMO hacer algo especifico. Como una receta de cocina. |
| **Scope Agent** | Un "jefe de area" especializado. Claude tiene 3: uno para desarrollo (SDD pipeline), uno para infraestructura y seguridad, y uno para observabilidad y continuidad de sesion. |
| **Execution Gate** | Un checklist que Claude ejecuta ANTES de hacer cualquier cambio de codigo. Verifica que todo este en orden antes de tocar algo. |
| **Rate Limiting** | Un limite de velocidad. Controla cuantas peticiones puede recibir tu sistema por minuto. Como un portero de discoteca que solo deja entrar a 10 personas por minuto para que no se llene de golpe. |
| **JSON** | Un formato para organizar datos. Piensa en el como una ficha con campos: nombre, edad, direccion. Las computadoras lo leen facilmente. |
| **Variable de entorno** | Un dato secreto que la aplicacion necesita pero que no se guarda en el codigo. Como la combinacion de una caja fuerte — la sabes de memoria, no la escribes en un papel pegado a la caja. |
| **Spam** | Correo basura. Publicidad no deseada, estafas, o mensajes que no pediste. |
| **Endpoint** | La direccion exacta donde un servicio recibe pedidos. Como el numero de ventanilla en un banco: "para depositos, vaya a la ventanilla 3". |

---

## Que vamos a construir

**Batuta Email Automator** — Un sistema de automatizacion que:

1. **Recibe emails automaticamente**: Cuando llega un email a tu casilla, el sistema se entera al instante
2. **Clasifica con inteligencia artificial**: La IA lee cada email y decide si es urgente, normal, o spam
3. **Responde automaticamente**: Los emails urgentes reciben una respuesta inmediata de "recibido, lo atendemos pronto"
4. **Organiza todo en n8n**: Puedes ver en un panel visual que paso con cada email, cuales se procesaron, cuales fallaron
5. **Funciona solo**: Una vez configurado, trabaja las 24 horas sin que tu hagas nada

### Ejemplo concreto

Llega un email con asunto "URGENTE: El servidor esta caido" -->
El webhook le avisa a n8n que llego algo -->
n8n pasa el email a la IA para clasificarlo -->
La IA dice "esto es urgente" -->
n8n envia una respuesta automatica: "Recibimos tu mensaje urgente. Lo estamos atendiendo." -->
n8n guarda un registro de lo que hizo.

Todo esto en menos de 10 segundos, sin que tu muevas un dedo.

---

## Antes de empezar — Lo que necesitas tener instalado

Pide ayuda a alguien para instalar estas herramientas si no las tienes:

| Herramienta | Para que sirve | Como instalar |
|-------------|---------------|---------------|
| **Node.js** | Hace que JavaScript funcione en tu computadora | Descarga de [nodejs.org](https://nodejs.org) la version LTS |
| **Git** | Guarda el historial de tu proyecto (como un "control de cambios") | Descarga de [git-scm.com](https://git-scm.com) |
| **Claude Code** | El asistente que va a programar por ti | En la terminal escribe: `npm install -g @anthropic-ai/claude-code` |
| **n8n** | La herramienta de automatizacion donde viviriran los workflows | Ver opciones abajo |
| **Docker** (opcional) | Para correr n8n y desplegar a produccion | Descarga de [docker.com](https://docker.com) |

### Como instalar n8n

Tienes dos opciones. Elige la que te quede mas comoda:

**Opcion A — n8n Cloud (la mas facil, sin instalar nada)**:
1. Ve a [n8n.io](https://n8n.io) y crea una cuenta gratuita
2. Te dan una URL como `https://tu-nombre.app.n8n.cloud`
3. Listo — n8n ya esta corriendo en internet

**Opcion B — n8n en tu computadora con Docker (gratis pero necesitas Docker)**:
1. Asegurate de tener Docker instalado
2. En la terminal escribe:
```
docker run -it --rm --name n8n -p 5678:5678 -v n8n_data:/home/node/.n8n docker.n8n.io/n8nio/n8n
```
3. Abre tu navegador y ve a `http://localhost:5678`
4. Crea tu cuenta de administrador

Para verificar que todo lo demas esta instalado, abre una terminal y escribe:
```
node --version
git --version
claude --version
```
Si los tres muestran un numero (como `v20.11.0`), estas lista.

---

# PASO A PASO

> Sigue cada paso en orden. No saltes pasos — cada uno depende del anterior,
> como cuando aprendes a manejar.

---

## Paso 1 — Crear la carpeta del proyecto

**Que vamos a hacer**: Crear una carpeta vacia donde vivira toda nuestra automatizacion. Es como preparar un escritorio limpio antes de empezar a trabajar.

**Que hacer**:
1. Abre el Explorador de Archivos de Windows
2. Ve a donde quieras guardar tu proyecto (ejemplo: `E:\Proyectos\`)
3. Click derecho, Nueva Carpeta
4. Nombrala: `batuta-n8n-automation`

> **IMPORTANTE**: Usa nombres SIN espacios y en minusculas.
> Los espacios causan problemas con las herramientas de programacion.
> Usa guiones (-) en lugar de espacios.

5. Abre una terminal (busca "Terminal" o "Command Prompt" en Windows)
6. Escribe exactamente esto y presiona Enter:

```
cd "E:\Proyectos\batuta-n8n-automation"
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
/batuta-init batuta-n8n-automation
```

Y listo. Claude configura todo automaticamente.

**Opcion B — Si es la primera vez y no tienes los commands:**

Ejecuta en la terminal (fuera de Claude Code):

```
bash <ruta-a-batuta-dots>/infra/setup.sh --project .
```

Esto crea CLAUDE.md, la carpeta .batuta/, sincroniza skills, e instala hooks en tu proyecto.

> Despues de esta primera vez, los commands `/batuta-init` y `/batuta-update` quedan
> instalados y ya no necesitas copiar el prompt largo nunca mas.

**Que esperar**: Claude va a descargar el ecosistema y configurar todo. Puede tomar 1-2 minutos. Cuando termine, te dira que archivos creo, incluyendo:
- `CLAUDE.md` — Las instrucciones del chef (router principal + scope agents + execution gate)
- `.batuta/session.md` — El cuaderno donde Claude anota en que quedo (para continuar despues)

**Tip**: Si Claude te pide permiso para ejecutar comandos, di "yes" o "si".

---

## Paso 3 — Iniciar el proyecto con SDD

**Que vamos a hacer**: Decirle a Claude que tipo de proyecto vamos a construir para que se prepare correctamente. SDD es el proceso de "primero planear, luego construir" — como un arquitecto que dibuja el plano antes de poner ladrillos.

**Copia y pega este prompt**:

```
/sdd-init
```

**Que esperar**: Claude te va a hacer preguntas sobre el proyecto. Cuando te pregunte, responde asi:

| Si Claude pregunta... | Tu respondes... |
|----------------------|-----------------|
| Nombre del proyecto | `batuta-n8n-automation` |
| Tipo de proyecto | `automation` |
| Descripcion | `Sistema de automatizacion con n8n que recibe emails, los clasifica con IA (urgente, normal, spam), y responde automaticamente. Usa webhooks para recibir notificaciones y workflows de n8n para orquestar todo el proceso.` |
| Stack/tecnologias | `Dejalo decidir, pero sugiérele: Node.js o Python para la logica de clasificacion, n8n para los workflows, Docker para despliegue` |

**Tip**: No te preocupes si no entiendes todo lo que Claude responde. Lo importante es que el "entienda" que queremos construir.

> **Detalle tecnico (opcional)**: Cuando ejecutas `/sdd-init`, Claude activa su pipeline-agent
> (el "jefe de proceso") que coordina todo el desarrollo paso a paso.

---

## Paso 4 — Cuando Claude dice "no tengo un skill para eso"

**Que vamos a hacer**: Entender que pasa cuando Claude detecta que necesita aprender algo nuevo. Esto es como si un chef te dijera "no tengo la receta para ese plato, pero puedo investigarla y documentarla para hacerlo bien".

**MOMENTO IMPORTANTE**: Despues del explore, Claude probablemente detecte que necesita skills para varias tecnologias. Te va a preguntar que hacer para cada una.

**Cuando Claude diga algo como:**
> "No tengo un skill documentado para n8n Workflows... Te propongo:
> 1. Investigar y crear el skill (proyecto)
> 2. Investigar y crear el skill (global)
> 3. Continuar sin skill"

Opcion 1 crea el skill solo para este proyecto. Opcion 2 lo hace disponible para todos tus proyectos.

**Tu respuesta siempre debe ser**:

```
Opcion 1 — Investiga y crea el skill acotado a nuestro proyecto
```

**Esto puede pasar varias veces para**:
- n8n Workflows (como crear y conectar los nodos de automatizacion)
- Webhooks (como recibir notificaciones de email)
- Clasificacion con IA (como conectar con Gemini Flash o Claude)
- Docker (como empaquetar la aplicacion)
- Coolify (como desplegar a produccion)

**Cada vez que te pregunte, responde "Opcion 1"**.

Claude va a investigar usando Context7 (su base de conocimiento actualizada) y crear las recetas que necesita. Esto toma unos minutos por skill, pero solo pasa una vez.

> **Detalle tecnico (opcional)**: El infra-agent (jefe de organizacion) coordina la creacion
> de skills nuevos. Usa el ecosystem-creator para investigar y documentar la tecnologia.

**Tip**: Este paso puede tomar 10-15 minutos en total. Es normal. Claude esta "aprendiendo" para hacerlo bien a la primera. Es una inversion que se paga sola.

---

## Paso 5 — Crear la propuesta

**Que vamos a hacer**: Pedirle a Claude que escriba un plan formal de lo que va a construir. Como cuando un arquitecto te muestra el boceto antes de construir — puedes decir "esto no me gusta" o "agrega esto" ANTES de que empiece a construir.

**Copia y pega este prompt**:

```
/sdd-new batuta-email-automator
```

Este comando primero explora tu proyecto y luego genera una propuesta automaticamente.

**Que esperar**: Claude va a crear un documento llamado "proposal" que incluye:
- Que se va a construir (en lenguaje simple)
- Que riesgos hay
- Criterios de exito (como sabemos que funciona)

Claude te va a mostrar un **resumen** y te preguntara si esta bien.

**Lee el resumen con calma**. Si algo no te suena bien, dile. Por ejemplo:

```
Me parece bien pero agrega que cuando un email se clasifica como urgente,
ademas de responder automaticamente, debe enviar una notificacion a un
canal de Slack o un numero de WhatsApp.
```

**Cuando estes conforme, di:**

```
Aprobado, continua con el siguiente paso
```

---

## Paso 6 — Especificaciones, diseno y tareas

**Que vamos a hacer**: Dejar que Claude avance por las fases de planificacion. El va a crear las especificaciones tecnicas (que exactamente debe hacer cada parte), el diseno de la arquitectura (como se conectan las piezas), y la lista de tareas (en que orden se construye).

**Copia y pega este prompt**:

```
/sdd-continue batuta-email-automator
```

Ejecuta `/sdd-continue` UNA vez por fase. Claude mostrara el resultado y te pedira confirmacion antes de avanzar. Repite hasta completar las fases pendientes (specs, design, tasks).

> **Alternativa rapida**: `/sdd-ff batuta-email-automator` ejecuta todas las fases pendientes de corrido sin pausas.

**Que esperar**: Claude va a ejecutar las siguientes fases una por una:

| Fase | Que hace | Cuanto toma |
|------|---------|-------------|
| **Specs** | Define EXACTAMENTE que debe hacer cada parte: el webhook, el clasificador, el workflow de n8n, las respuestas automaticas | 2-5 min |
| **Design** | Decide la estructura del workflow de n8n: cuantos nodos, como se conectan, que tecnologias usa el servicio de clasificacion | 3-5 min |
| **Tasks** | Divide todo el trabajo en tareas pequenas y ordenadas: "primero el webhook, luego el clasificador, luego el workflow" | 2-3 min |

**Entre cada fase**, Claude te va a mostrar un resumen y preguntar si continua.

**Tu respuesta cada vez**:

```
Se ve bien, continua
```

**Si algo no entiendes**, pregunta sin miedo:

```
No entendi la parte de "webhook authentication con HMAC".
Explicame que significa eso en terminos simples.
```

Claude esta configurado para explicarte las cosas de forma que cualquier persona las entienda.

**Tip**: Este paso puede tomar 10-15 minutos. Puedes ir por un cafe mientras Claude trabaja entre fases.

---

## Paso 7 — Construir el servicio de clasificacion

**Que vamos a hacer**: Pedirle a Claude que construya el "cerebro" de nuestra automatizacion — el servicio que recibe texto de un email y responde con la clasificacion (urgente, normal, o spam). Esta es la primera parte del codigo real.

**Copia y pega este prompt**:

```
/sdd-apply batuta-email-automator

Empieza por el servicio de clasificacion (el cerebro de la IA).
Implementa primero este componente porque el workflow de n8n
va a depender de el.
```

**Que esperar**: Antes de empezar a escribir codigo, Claude va a ejecutar el **Execution Gate** — un checklist automatico que verifica:
- Que archivos va a crear o modificar
- Donde van a ir (siguiendo la Scope Rule — la regla de organizacion de archivos)
- Que impacto tienen los cambios
- Que todo este alineado con las especificaciones

Te mostrara algo como:
```
Este cambio involucra scope pipeline + infra:
- Crear 6 archivos nuevos en features/classifier/
- Crear 2 archivos en core/
- Procedo?
```

**Tu respuesta**:

```
Si, procede
```

Claude va a crear:
- El servicio de clasificacion con el endpoint HTTP
- La conexion con el modelo de IA (Gemini Flash o el que se haya elegido)
- La configuracion de variables de entorno
- Tests basicos para verificar que clasifica correctamente

**Cuando Claude pida las credenciales del modelo de IA:**

```
Para la API key del modelo de IA:
- Si usas Gemini Flash: GOOGLE_API_KEY=tu_api_key_aqui
- Si usas Claude: ANTHROPIC_API_KEY=tu_api_key_aqui

Crea un archivo .env con las credenciales.
```

> **IMPORTANTE**: Si no tienes una API key a la mano, dile a Claude:
> ```
> No tengo el API key ahora. Usa valores de ejemplo (placeholders)
> y despues los cambio manualmente.
> ```

**Tip**: Si Claude pide permiso para instalar dependencias (librerias), di "yes".

---

## Paso 8 — Construir la logica del webhook

**Que vamos a hacer**: Crear la "puerta de entrada" que recibe los emails. El webhook es como un buzon inteligente — recibe el email, verifica que venga de una fuente autorizada, y se lo pasa al clasificador.

**Copia y pega este prompt**:

```
Continua con la implementacion. Ahora construye el webhook receiver:

1. Un endpoint HTTP que recibe notificaciones de emails nuevos via POST
2. Validacion de autenticacion: el request debe traer un token secreto
   en el header "Authorization" para verificar que no es alguien random
3. Validacion del formato: verificar que el JSON trae los campos
   obligatorios (from, subject, body)
4. Si todo esta bien, pasar los datos al clasificador que ya construimos
5. Devolver la respuesta con la clasificacion al que llamo al webhook
6. Si algo falla, devolver un error claro explicando que salio mal
7. Rate limiting: maximo 100 requests por minuto

Asegurate de que el webhook y el clasificador esten conectados correctamente.
```

**Que esperar**: Claude ejecutara el Execution Gate de nuevo (ya es automatico) y luego implementara el webhook. Te mostrara los archivos que va a crear y pedira confirmacion.

**Tu respuesta**: "Si, continua".

Al terminar, tendras dos componentes funcionando:
1. El webhook (la puerta de entrada)
2. El clasificador (el cerebro)

---

## Paso 9 — Crear el workflow de n8n

**Que vamos a hacer**: Crear el workflow visual en n8n que conecta todo: recibe el email, llama al clasificador, y ejecuta la accion correcta segun la clasificacion. Este es el paso donde la "fabrica" se arma completa.

**Copia y pega este prompt**:

```
Ahora crea el workflow de n8n como un archivo JSON exportable.

El workflow debe tener estos nodos:

NODO 1 — Webhook Trigger:
- Recibe POST con los datos del email
- URL: /webhook/email-classifier

NODO 2 — HTTP Request al clasificador:
- Llama a nuestro servicio de clasificacion
- Le pasa el asunto y cuerpo del email
- Recibe la clasificacion (urgente/normal/spam)

NODO 3 — Switch (decision):
- Si la clasificacion es "urgente" → va al nodo 4a
- Si la clasificacion es "normal" → va al nodo 4b
- Si la clasificacion es "spam" → va al nodo 4c

NODO 4a — Respuesta urgente:
- Envia una respuesta automatica al remitente
- Texto: "Hemos recibido tu mensaje urgente. Nuestro equipo lo esta atendiendo."
- Opcionalmente: notifica a un canal (Slack, email interno, etc.)

NODO 4b — Email normal:
- Registra el email como procesado
- No hace nada mas (el email se queda en la bandeja normal)

NODO 4c — Spam:
- Registra el email como spam
- Opcionalmente: mueve el email a la carpeta de spam

NODO 5 — Registro final:
- Guarda un log de lo que paso: fecha, remitente, asunto, clasificacion, accion tomada
- Esto puede ser en un archivo JSON, una base de datos, o un Google Sheet

Genera el archivo JSON del workflow para que yo pueda importarlo
directamente en n8n (Workflows → Import from File).

Tambien dame instrucciones paso a paso de como importarlo en n8n
y como configurar las credenciales dentro de n8n.
```

**Que esperar**: Claude va a crear un archivo JSON con el workflow completo de n8n. Tambien te dara instrucciones de como importarlo.

**Como importar el workflow en n8n:**
1. Abre n8n en tu navegador
2. Ve a "Workflows" en el menu lateral
3. Click en "Add Workflow" o el boton de "+"
4. Click en los tres puntos (menu) → "Import from File"
5. Selecciona el archivo JSON que Claude creo
6. El workflow aparece con todos los nodos conectados

> **IMPORTANTE**: Despues de importar, necesitas configurar las credenciales dentro de n8n
> (la URL de tu servicio de clasificacion, tokens de autenticacion, etc.).
> Claude te dara las instrucciones exactas para esto.

---

## Paso 10 — Probar la automatizacion completa

**Que vamos a hacer**: Verificar que todo funciona de principio a fin. Vamos a simular que llega un email y ver si el sistema lo clasifica y responde correctamente. Como una prueba de manejo antes de salir a la carretera.

**Copia y pega este prompt**:

```
Necesito probar toda la automatizacion de principio a fin.

Crea un script de prueba que:

1. Envie 3 emails de prueba al webhook:
   - Email 1: Asunto "URGENTE: El servidor de produccion esta caido"
     (debe clasificarse como urgente)
   - Email 2: Asunto "Reunion de equipo el viernes"
     (debe clasificarse como normal)
   - Email 3: Asunto "Gana $10000 en 5 minutos! Click aqui!"
     (debe clasificarse como spam)

2. Muestre el resultado de cada clasificacion
3. Verifique que las acciones correctas se ejecutaron:
   - Email urgente: se envio respuesta automatica
   - Email normal: se registro como procesado
   - Email spam: se marco como spam

4. Muestre un resumen final: "3 de 3 emails procesados correctamente"
   o "1 de 3 fallo: [detalle del error]"

Primero levanta el servicio de clasificacion y despues ejecuta las pruebas.
Dame las instrucciones paso a paso.
```

**Que esperar**: Claude va a:
1. Levantar el servicio de clasificacion en tu computadora
2. Ejecutar los emails de prueba
3. Mostrarte los resultados

**Si todo funciona**, veras algo como:
```
Email 1 (urgente): OK — Clasificado como "urgente", respuesta enviada
Email 2 (normal): OK — Clasificado como "normal", registrado
Email 3 (spam): OK — Clasificado como "spam", marcado

Resultado: 3/3 pruebas pasaron
```

**Si algo falla**, dile a Claude exactamente que ves:

```
El email 1 se clasifico como "normal" en lugar de "urgente".
El error dice: [pega el error aqui]
```

Claude va a investigar y corregir el problema.

---

## Paso 11 — Verificar con SDD

**Que vamos a hacer**: Pedirle a Claude que revise su propio trabajo completo. Como cuando un profesor revisa un examen — busca errores, cosas incompletas, o problemas de seguridad.

**Copia y pega este prompt**:

```
/sdd-verify batuta-email-automator
```

**Que esperar**: Claude va a verificar usando la Piramide de Validacion:
- **Capa 1**: Que el codigo no tenga errores de sintaxis (como faltas de ortografia en programacion)
- **Capa 2**: Que los tests pasen (las pruebas automaticas)
- **Capa 3**: Que todo funcione junto (prueba de principio a fin)
- **Capa 4**: Revision de seguridad (que las API keys no esten expuestas, que el webhook este protegido)
- **Capa 5**: Que la documentacion este completa

Si encuentra problemas, los va a listar y te va a preguntar si quieres que los corrija.

**Tu respuesta**:

```
Si, corrige todos los problemas que encontraste
```

Despues de las correcciones, ejecuta verify otra vez:

```
/sdd-verify batuta-email-automator
```

**Cuando todo este verde (sin errores)**, continua al siguiente paso.

---

## Paso 12 — Desplegar a produccion

**Que vamos a hacer**: Poner todo en internet para que funcione solo, las 24 horas, sin tu computadora encendida. Es como instalar una maquina en una fabrica — una vez encendida, trabaja sola.

**Copia y pega este prompt**:

```
Necesito desplegar toda la automatizacion a produccion.

Tenemos:
- Coolify corriendo en: [TU URL DE COOLIFY, ejemplo: https://coolify.tudominio.com]
- n8n ya esta corriendo en: [URL DE N8N, ejemplo: https://n8n.tudominio.com]
- El dominio para el servicio de clasificacion: [TU DOMINIO, ejemplo: classifier.tudominio.com]

Configura:
1. Un Dockerfile para el servicio de clasificacion
2. Docker Compose para desarrollo local (que pueda levantar todo con un comando)
3. Configuracion de Coolify para el servicio de clasificacion
4. Variables de entorno para produccion:
   - API key del modelo de IA
   - Token de autenticacion del webhook
   - URL del servicio de clasificacion (para que n8n sepa donde llamar)
5. Health check que verifique que el servicio esta vivo
6. Despliegue automatico cuando hagamos push a la rama main

Para n8n:
- Actualiza el workflow de n8n con la URL de produccion del clasificador
- Exporta el workflow actualizado como JSON

Dame los archivos necesarios y las instrucciones paso a paso.
```

**Que esperar**: Claude va a crear:
- Un archivo `Dockerfile` (le dice a Docker como empaquetar la aplicacion)
- Un archivo `docker-compose.yml` (para desarrollo local)
- Instrucciones de como configurar Coolify
- El workflow de n8n actualizado con URLs de produccion

**Para la parte de Coolify**, probablemente necesites acceso al panel de Coolify. Si no lo tienes, pide ayuda a quien maneja la infraestructura.

---

## Paso 13 — Subir a GitHub y activar

**Que vamos a hacer**: Guardar todo el proyecto en GitHub (como una copia de seguridad inteligente) y activar el despliegue automatico. Cada vez que hagas un cambio y lo subas a GitHub, la app se actualiza sola en internet.

**Copia y pega este prompt**:

```
Crea un repositorio privado en GitHub llamado batuta-n8n-automation
bajo la organizacion [TU-ORGANIZACION-O-USUARIO], sube todo el codigo, y configura
el webhook de Coolify para despliegue automatico.

IMPORTANTE: Verifica que .gitignore incluya:
- .env (variables secretas)
- Cualquier archivo con API keys o tokens
- node_modules/ (dependencias que se reinstalan automaticamente)

Haz el commit inicial con todo lo que hemos construido.
```

**Si Claude pide permisos de git** (commit, push), di "yes".

**Que esperar**: Claude va a:
1. Crear el repositorio en GitHub
2. Verificar que los archivos secretos estan excluidos
3. Hacer commit de todos los archivos
4. Hacer push
5. Darte el link del repositorio

---

## Paso 14 — Verificar y archivar

**Que vamos a hacer**: Confirmar que todo esta funcionando en internet y cerrar formalmente el proyecto.

**Verifica primero**:

```
Verifica que el despliegue en Coolify esta funcionando correctamente.
Revisa los logs de los servicios y confirma que:
1. El servicio de clasificacion esta respondiendo en la URL de produccion
2. El webhook esta activo y acepta requests
3. El workflow de n8n esta activado y conectado al webhook correcto
4. Las variables de entorno estan configuradas (API keys, tokens)
5. El health check esta pasando
```

**Si todo esta bien**, abre n8n y activa el workflow. Luego, enviate un email de prueba a ti mismo y verifica que el sistema lo clasifica y responde.

**Si algo falla**, los errores mas comunes son:
- Variables de entorno mal configuradas: Claude te dice cuales faltan
- URL del clasificador incorrecta en n8n: Claude ajusta el workflow
- Webhook no accesible: verificar que el puerto esta abierto en Coolify
- API key invalida: verificar que se copio correctamente

**Cuando todo funcione**, archiva el proyecto:

```
/sdd-archive batuta-email-automator
```

Claude cierra el proyecto formalmente: verifica que todo esta completo, guarda las lecciones aprendidas, y actualiza `.batuta/session.md`.

**Tu automatizacion de emails esta en produccion. Felicidades!**

---

# SECCION DE SEGURIDAD

> Esta seccion es MUY IMPORTANTE. La seguridad protege tu sistema de accesos no autorizados,
> uso indebido, y problemas de costos inesperados.

---

## Proteccion de API Keys

Las API keys son como las llaves de tu casa. Si alguien las consigue, puede entrar y hacer lo que quiera. Sigue estas reglas:

| Regla | Por que | Como |
|-------|---------|------|
| **Nunca pongas API keys en el codigo** | Si el codigo se sube a internet (GitHub), cualquiera las ve | Usa archivos `.env` que estan excluidos de git |
| **Rota las API keys cada 3 meses** | Si alguien consiguio una key vieja, deja de funcionar | Ve al panel del proveedor (Google, Anthropic) y genera una nueva |
| **Usa keys diferentes para desarrollo y produccion** | Si hackean tu computadora de pruebas, la produccion sigue segura | Crea 2 keys: una para tu PC, otra para Coolify |
| **Monitorea el consumo** | Si ves un gasto inusual, alguien puede estar usando tu key | Revisa el dashboard del proveedor de IA semanalmente |

### Como verificar que tus keys estan seguras

Pidele a Claude:

```
Verifica que ninguna API key, token, o secreto este expuesto en el codigo
o en archivos que se suben a git. Lista todos los archivos que contienen
secretos y confirma que estan en .gitignore.
```

---

## Autenticacion del Webhook

El webhook es una puerta publica. Sin proteccion, cualquiera puede enviar datos falsos. Como protegerlo:

| Proteccion | Que hace | Nivel |
|-----------|---------|-------|
| **Token en el header** | Solo acepta requests que traigan un token secreto | Basico (minimo necesario) |
| **Validacion de IP** | Solo acepta requests de IPs conocidas (tu servidor de email) | Intermedio |
| **HMAC signature** | Verifica que el contenido no fue alterado en el camino | Avanzado |

Nuestro sistema usa **token en el header** como minimo. Para configurarlo:

1. El token se guarda como variable de entorno: `WEBHOOK_SECRET=un-token-largo-y-aleatorio`
2. Quien envie emails al webhook debe incluir el header: `Authorization: Bearer un-token-largo-y-aleatorio`
3. El webhook verifica que el token sea correcto antes de procesar el email

Si quieres agregar mas seguridad despues, pidele a Claude:

```
Agrega validacion HMAC al webhook para verificar que los datos
no fueron alterados en transito.
```

---

## Rate Limiting

El rate limiting es como un portero de discoteca: controla cuantas personas entran por minuto. Sin el, alguien podria enviar 10,000 emails falsos en un segundo y:
- Gastar todo tu credito de IA
- Tumbar tu servicio
- Generar costos inesperados

Nuestro sistema tiene un limite de **100 requests por minuto**. Si alguien excede ese limite, recibe un error y tiene que esperar.

Para ajustar el limite:

```
Cambia el rate limit del webhook a 50 requests por minuto
(en lugar de 100) porque nuestro volumen de emails es bajo.
```

---

# DESPUES DE LA ENTREGA

> Estos pasos son opcionales pero recomendados para mantener tu automatizacion saludable.

---

## Hacer cambios despues

Cuando quieras modificar algo, NO edites el codigo directamente. Usa el mismo proceso:

```
/sdd-new nombre-del-cambio

Quiero agregar [descripcion del cambio].
Por ejemplo: una nueva categoria de clasificacion llamada "factura"
que detecte emails con facturas adjuntas.
```

Y sigue el mismo flujo: explore, propose, specs, design, tasks, apply, verify.

> **Importante**: Cada cambio pasa por el Execution Gate automaticamente.
> Claude valida que el cambio siga las reglas del proyecto antes de escribir codigo.

---

## Agregar nuevas categorias de clasificacion

Para que la IA reconozca mas tipos de email:

```
/sdd-new email-classifier-new-categories

Quiero agregar estas categorias al clasificador:
- "factura" — emails que contienen facturas o cobros
- "reunion" — invitaciones a reuniones o eventos
- "soporte" — tickets de soporte tecnico o ayuda

Actualiza el prompt de la IA y ajusta el workflow de n8n
para manejar las nuevas categorias.
```

---

## Mejorar tus instrucciones

Despues de trabajar un rato con Claude (10+ interacciones), puedes pedirle que analice como le ha ido entendiendo tus pedidos:

```
/batuta-analyze-prompts
```

Claude va a revisar la bitacora de calidad y te dira:
- Cuantas veces tuvo que corregir algo
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

## Estructura esperada del proyecto

```
batuta-n8n-automation/
├── core/                                  # Configuracion central
│   ├── config.js                          # Variables de entorno y configuracion
│   └── logger.js                          # Sistema de registro (logs)
├── features/
│   ├── classifier/                        # Feature: clasificacion de emails
│   │   ├── services/
│   │   │   ├── ai-classifier.js           # Logica de clasificacion con IA
│   │   │   └── prompt-templates.js        # Plantillas de instrucciones para la IA
│   │   ├── models/
│   │   │   └── classification.js          # Estructura de datos de clasificacion
│   │   └── tests/
│   │       └── classifier.test.js         # Tests del clasificador
│   ├── webhook/                           # Feature: recepcion de emails
│   │   ├── routes/
│   │   │   └── webhook-handler.js         # Endpoint del webhook
│   │   ├── middleware/
│   │   │   ├── auth.js                    # Verificacion de token
│   │   │   └── rate-limiter.js            # Limite de peticiones
│   │   └── tests/
│   │       └── webhook.test.js            # Tests del webhook
│   ├── responder/                         # Feature: respuestas automaticas
│   │   ├── services/
│   │   │   └── auto-responder.js          # Logica de respuesta
│   │   └── templates/
│   │       └── urgent-reply.js            # Plantilla de respuesta urgente
│   └── shared/                            # Compartido entre features
│       └── email-parser/
│           └── parser.js                  # Extraccion de datos del email
├── n8n/
│   └── workflows/
│       └── email-classifier-workflow.json # Workflow exportable de n8n
├── scripts/
│   └── test-automation.js                 # Script de prueba manual
├── Dockerfile                             # Para produccion
├── docker-compose.yml                     # Para desarrollo local
├── .env.example                           # Ejemplo de variables (SIN secretos)
├── .env                                   # Variables secretas (NO va a git)
├── .gitignore                             # Archivos excluidos de git
├── package.json                           # Dependencias del proyecto
└── README.md                              # Documentacion
```

> Nota como sigue la **Scope Rule**: cada feature tiene su carpeta, shared solo tiene lo que usan 2+ features, y core tiene la configuracion central.

---

## Comandos de emergencia

Si algo sale muy mal y necesitas actuar rapido:

| Situacion | Que escribir |
|-----------|-------------|
| Claude se trabo y no responde | Cierra la terminal, abrela de nuevo, escribe `claude` |
| Quieres deshacer el ultimo cambio | `Deshaz el ultimo cambio que hiciste` |
| El webhook esta recibiendo ataques | Desactiva el workflow en n8n (Workflows → click en el toggle para desactivar) |
| Gastaste mucho en la API de IA | Revisa el dashboard del proveedor y pausa la key temporalmente |
| No entiendes algo | `Explicame [lo que no entiendes] como si tuviera 15 anos` |
| Quieres ver el estado del proyecto | `/sdd-continue batuta-email-automator` (te muestra donde quedamos) |

---

## Preguntas frecuentes

**P: Puedo usar esto con Gmail, Outlook, o cualquier email?**
R: Si. El webhook recibe datos en un formato estandar. Solo necesitas configurar una regla en tu proveedor de email que reenvie los datos al webhook. Claude te ayuda a configurar eso para Gmail (con Apps Script), Outlook (con Power Automate), o cualquier otro.

**P: Cuanto cuesta usar la IA para clasificar?**
R: Muy poco. Gemini Flash cobra aproximadamente $0.075 por cada millon de palabras procesadas. Si recibes 100 emails al dia, el costo mensual es menor a $0.50 USD. Practicamente gratis.

**P: Que pasa si la IA se equivoca en la clasificacion?**
R: Es raro con emails claros, pero puede pasar. Puedes mejorar la precision ajustando el prompt de clasificacion. Pidele a Claude: "El clasificador se equivoca con los emails de [tipo]. Mejora el prompt para distinguirlos mejor."

**P: Puedo cerrar la terminal y continuar despues?**
R: Si. Abre la terminal, navega a tu carpeta, escribe `claude`, y Claude automaticamente lee `.batuta/session.md` donde guardo en que quedo. No necesitas decirle nada especial — el recuerda solo.

**P: Cuanto tarda todo el proceso?**
R: La primera vez, entre 1.5 y 2.5 horas incluyendo la creacion de skills. La segunda vez que hagas un proyecto similar, mucho menos porque los skills ya existen.

**P: Puedo agregar mas acciones ademas de responder emails urgentes?**
R: Si. Puedes agregar cualquier accion que n8n soporte: enviar mensajes de Slack, crear tareas en Notion, actualizar un Google Sheet, enviar un SMS, y cientos de cosas mas. Solo describele a Claude que quieres y el configura el workflow.

**P: Necesito internet para que la automatizacion funcione?**
R: Si. n8n y el servicio de clasificacion necesitan estar conectados a internet para recibir emails y llamar a la API de IA. Si tu internet se cae, los emails se acumulan y se procesan cuando vuelve.

---

## Resumen visual del flujo completo

```
Tu (carpeta vacia)
 |
 +-- Paso 2:  Instalar ecosistema Batuta + crear .batuta/
 |
 +-- Paso 3:  /sdd-init .............. "Que tipo de proyecto es?"
 |
 |   [Claude detecta skills faltantes → Paso 4: "Opcion 1"]
 |
 +-- Paso 5:  /sdd-new ............... "Explora + Propuesta formal"
 |     Tu: "Aprobado"
 |
 +-- Paso 6:  /sdd-continue .......... "Specs → Design → Tasks"
 |     Tu: "Continua" (3 veces)
 |
 +-- Paso 7:  /sdd-apply ............. "Construir el clasificador"
 |     [Execution Gate valida antes de cada cambio]
 |
 +-- Paso 8:  Construir webhook ...... "La puerta de entrada"
 |
 +-- Paso 9:  Crear workflow n8n ..... "Conectar todo visualmente"
 |
 +-- Paso 10: Probar todo ............ "Emails de prueba"
 |
 +-- Paso 11: /sdd-verify ............ "Revisar que todo funcione"
 |
 +-- Paso 12: Deploy a Coolify ....... "Poner en internet"
 |
 +-- Paso 13: Push a GitHub .......... "Codigo en la nube"
 |
 +-- Paso 14: Verificar + archivar ... "Confirmar y celebrar"
 |
 [Tu automatizacion esta en produccion!]
```

---

## Nivel Avanzado: Agent Teams (Equipos de Agentes)

Cuando te sientas comodo con los pasos anteriores, puedes usar **Agent Teams** para que Claude trabaje con multiples "asistentes" en paralelo. Es como tener un equipo de programadores en lugar de uno solo.

### Cuando usar cada nivel

| Nivel | Cuando usarlo | Ejemplo en este proyecto |
|-------|--------------|------------------------|
| **Solo** (normal) | Cambios simples, 1-2 archivos | "Cambia la plantilla de respuesta automatica para urgentes" |
| **Subagente** (automatico) | Investigar o verificar algo | Claude investiga como conectar n8n con Slack |
| **Agent Team** (tu lo pides) | Trabajo grande en multiples partes | Agregar 3 nuevas categorias de clasificacion + 3 nuevas acciones automaticas al mismo tiempo |

### Como pedirle a Claude que use un equipo

```
Tu: "Necesito agregar clasificacion de facturas, soporte, y reuniones al
     mismo tiempo, cada una con su propia accion automatica en n8n.
     Crea un equipo para hacerlo en paralelo."
```

Claude va a:
1. Evaluar si el trabajo justifica un equipo (3 categorias + 3 acciones = si)
2. Crear 2-3 asistentes especializados
3. Repartir el trabajo en una lista de tareas compartida
4. Cada asistente trabaja en su parte al mismo tiempo
5. Un revisor verifica que todo encaje al final

### Ejemplos practicos para este proyecto

**Ejemplo 1 — Agregar multiples categorias en paralelo:**
```
Tu: "Necesito que el clasificador tambien detecte: facturas, reuniones,
     soporte tecnico, y newsletters. Cada una necesita su propia logica
     en el workflow de n8n. Crea un equipo para implementar todo."
```

**Ejemplo 2 — Conectar multiples canales de notificacion:**
```
Tu: "Cuando un email es urgente, quiero que ademas de responder por email,
     notifique por Slack, cree un ticket en Jira, y envie un SMS.
     Que el equipo implemente las 3 integraciones en paralelo."
```

**Ejemplo 3 — Optimizar rendimiento y seguridad al mismo tiempo:**
```
Tu: "Necesito que un asistente optimice el rendimiento del clasificador
     (cache de respuestas, procesamiento en lote) mientras otro refuerza
     la seguridad (HMAC, logs de auditoria, alertas de abuso)."
```

### Metricas esperadas de rendimiento

Estas metricas son estimaciones para que compares cuando ejecutes los pasos. Anota tus resultados reales para mejorar el sistema.

| Escenario | Nivel | Tiempo estimado | Costo tokens | Calidad esperada | Fortaleza | Debilidad |
|-----------|-------|----------------|-------------|-----------------|-----------|-----------|
| Cambiar plantilla de respuesta | Solo | 2-3 min | ~3K tokens | 95% primera vez | Rapido, sin overhead | N/A |
| Agregar 1 categoria SDD | Solo + Subagente | 15-25 min | ~50K tokens | 85% primera vez | Proceso trazable | Secuencial |
| Agregar 3 categorias paralelo | Agent Team | 20-35 min | ~150K tokens | 80% primera vez | 3 categorias al mismo tiempo | Workflow de n8n puede necesitar ajuste manual |
| Conectar 3 canales de notificacion | Agent Team | 25-40 min | ~180K tokens | 80% primera vez | Cada integracion es independiente | APIs externas pueden fallar |
| Optimizacion rendimiento + seguridad | Agent Team | 20-30 min | ~120K tokens | 85% cobertura | Dos perspectivas simultaneas | Pueden tocar los mismos archivos |

> **Importante**: Estas son estimaciones iniciales. Cuando ejecutes cada paso, anota cuanto tardo
> realmente y si el resultado fue correcto a la primera. Esa informacion ayuda a mejorar el sistema
> con `/batuta-analyze-prompts`.

---

## Troubleshooting — Problemas comunes y como resolverlos

### Problemas con n8n

| Problema | Que ves | Como resolverlo |
|----------|---------|-----------------|
| El workflow no se activa | El workflow esta en gris (desactivado) en n8n | Click en el toggle para activar el workflow. Debe quedar en verde. |
| El webhook no recibe datos | Al enviar un request al webhook, recibes error 404 | Verifica la URL del webhook en n8n. Asegurate de que incluya `/webhook/` al inicio. En n8n Cloud la URL es diferente a la local. |
| Error "No credentials" en n8n | n8n dice que no tiene credenciales configuradas | Ve a Settings → Credentials en n8n y configura las credenciales del servicio de clasificacion. |
| El workflow se ejecuta pero no hace nada | Los nodos se ejecutan "exitosamente" pero no pasan datos | Revisa las conexiones entre nodos. Click en cada nodo y verifica que la salida del anterior llega como entrada. |
| Timeout en el HTTP Request | n8n dice "Request timed out" al llamar al clasificador | Tu servicio de clasificacion esta tardando mucho o no esta corriendo. Verificalo con Claude. |

Pidele a Claude:
```
El workflow de n8n tiene el error "[pega el error exacto]".
Ayudame a diagnosticar y resolver el problema.
```

### Problemas con el webhook

| Problema | Que ves | Como resolverlo |
|----------|---------|-----------------|
| Error 401 Unauthorized | El webhook rechaza los requests | Verifica que el token en el header `Authorization` sea correcto. Debe coincidir con la variable de entorno `WEBHOOK_SECRET`. |
| Error 400 Bad Request | El webhook dice "formato invalido" | Verifica que el JSON que envias tenga los campos obligatorios: `from`, `subject`, `body`. |
| Error 429 Too Many Requests | El webhook dice "rate limit exceeded" | Estas enviando demasiados emails por minuto. Espera un minuto e intenta de nuevo, o pide a Claude que aumente el limite. |
| El webhook no es accesible desde internet | Funciona en `localhost` pero no desde afuera | Si estas en desarrollo local, necesitas exponer el puerto (Claude te ayuda). En produccion, verifica que Coolify tenga el puerto configurado. |

### Problemas con la clasificacion

| Problema | Que ves | Como resolverlo |
|----------|---------|-----------------|
| Todo se clasifica como "normal" | La IA siempre responde "normal" sin importar el email | El prompt de clasificacion necesita mejores ejemplos. Pidele a Claude que lo ajuste. |
| Error de API key invalida | Error "Invalid API key" o "Unauthorized" | Verifica que la API key en el archivo `.env` sea correcta y no tenga espacios extra. |
| Respuestas lentas (mas de 5 segundos) | La clasificacion tarda mucho | Puede ser el modelo de IA. Si usas un modelo lento, pide a Claude que cambie a Gemini Flash (es mas rapido). |
| La IA responde con texto largo en lugar de una categoria | En lugar de "urgente", responde "Este email parece ser urgente porque..." | El prompt de clasificacion necesita ser mas estricto. Pidele a Claude que lo ajuste. |

### Problemas con Docker y Coolify

| Problema | Que ves | Como resolverlo |
|----------|---------|-----------------|
| Docker no encuentra la imagen | Error "Image not found" | Ejecuta `docker build` de nuevo. Claude te da el comando exacto. |
| El servicio se reinicia constantemente | En Coolify, el servicio aparece reiniciandose cada 30 segundos | Revisa los logs en Coolify para ver que error esta causando el reinicio. Pidele a Claude que diagnostique. |
| Variables de entorno no llegan | El servicio dice "API_KEY is undefined" | Verifica que las variables estan configuradas en Coolify. Ve a tu servicio → Environment → verifica que las variables existen. |
| Puerto ya en uso | Error "Port 3000 already in use" | Otro programa esta usando ese puerto. Cambia el puerto en la configuracion o cierra el otro programa. |

Para cualquier problema no listado aqui, la mejor estrategia es copiar el error exacto y pasarselo a Claude:

```
Tengo este error al [describir que estabas haciendo]:
[pega el error completo aqui]

Ayudame a diagnosticarlo y resolverlo.
```

---

> **Recuerda**: No necesitas entender COMO funciona todo por dentro. Solo necesitas seguir los pasos
> y confiar en el proceso. Como aprender a manejar: primero sigues las instrucciones al pie
> de la letra, y con el tiempo lo haces naturalmente. Claude es tu asistente — el programa, tu decides.
