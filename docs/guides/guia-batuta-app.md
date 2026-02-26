# Guia Paso a Paso: Crear Batuta APP con Claude Code

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
| **Scope Agent** | Un "jefe de area" especializado. Claude tiene 3: uno para el proceso de desarrollo, uno para organizacion de archivos, y uno para calidad. |
| **Execution Gate** | Un checklist que Claude ejecuta ANTES de hacer cualquier cambio de codigo. Verifica que todo este en orden. |

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

# PASO A PASO

> Sigue cada paso en orden. No saltes pasos — cada uno depende del anterior,
> como cuando aprendes a manejar.

---

## Paso 1 — Crear la carpeta del proyecto

**Que vamos a hacer**: Crear una carpeta vacia donde vivira toda nuestra aplicacion.

**Que hacer**:
1. Abre el Explorador de Archivos de Windows
2. Ve a donde quieras guardar tu proyecto (ejemplo: `E:\Proyectos\`)
3. Click derecho → Nueva Carpeta
4. Nombrala: `batuta-app`

> **IMPORTANTE**: Usa nombres SIN espacios y en minusculas (ejemplo: `batuta-app`, no `Batuta APP`).
> Los espacios y mayusculas causan problemas con las herramientas de Node.js como npm.
> Usa guiones (-) en lugar de espacios.

**Resultado**: Tienes una carpeta vacia llamada `batuta-app`.

---

## Paso 2 — Abrir Claude Code en tu proyecto

**Que vamos a hacer**: Abrir el asistente de programacion dentro de tu carpeta.

**Que hacer**:
1. Abre una terminal (busca "Terminal" o "Command Prompt" en Windows)
2. Escribe exactamente esto y presiona Enter:

```
cd "E:\Proyectos\batuta-app"
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

## Paso 3 — Instalar el ecosistema Batuta

**Que vamos a hacer**: Darle a Claude las "recetas" (skills) que necesita para trabajar al estilo Batuta. Esto incluye la configuracion del chef principal, los jefes de area (scope agents), y el sistema de calidad.

**Opcion A — Si ya tienes los commands de Batuta instalados** (recomendado):

> **IMPORTANTE**: Asegurate de estar dentro de la carpeta de tu proyecto antes de ejecutar este comando. Todo lo que Claude cree se guardara en la carpeta actual.

Simplemente escribe:

```
/batuta-init batuta-app
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

---

## Paso 4 — Iniciar el proyecto con SDD

**Que vamos a hacer**: Decirle a Claude que tipo de proyecto vamos a construir para que se prepare correctamente.

**Copia y pega este prompt**:

```
/sdd-init
```

**Que esperar**: Claude te va a hacer preguntas sobre el proyecto. Cuando te pregunte, responde asi:

| Si Claude pregunta... | Tu respondes... |
|----------------------|-----------------|
| Nombre del proyecto | `batuta-app` |
| Tipo de proyecto | `webapp` |
| Descripcion | `Dashboard para monitorear ejecuciones de n8n y consumo de tokens de Google AI, con autenticacion por email y contrasena` |
| Stack/tecnologias | `Dejalo decidir, pero sugiérele: Next.js para frontend, Python o Node para backend, PostgreSQL para base de datos` |

**Tip**: No te preocupes si no entiendes todo lo que Claude responde. Lo importante es que el "entienda" que queremos construir.

> **Detalle tecnico (opcional)**: Cuando ejecutas `/sdd-init`, Claude activa su pipeline-agent
> (el "jefe de cocina") que coordina todo el proceso de desarrollo.

---

## Paso 5 — Cuando Claude dice "no tengo un skill para eso"

**Que vamos a hacer**: Entender que pasa cuando Claude detecta que necesita aprender algo nuevo. Esto es como si un chef te dijera "no tengo la receta para ese plato, pero puedo investigarla".

**MOMENTO IMPORTANTE**: Durante el proceso de desarrollo (especialmente al ejecutar `/sdd-new`), Claude probablemente detecte que necesita skills para varias tecnologias. Te va a preguntar que hacer para cada una.

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

> **Detalle tecnico (opcional)**: El infra-agent (jefe de almacen) coordina la creacion
> de skills nuevos. Usa el ecosystem-creator para investigar y documentar la tecnologia.

**Tip**: Este paso puede tomar 10-15 minutos en total. Es normal. Claude esta "aprendiendo" para hacerlo bien a la primera.

---

## Paso 6 — Crear la propuesta

**Que vamos a hacer**: Pedirle a Claude que escriba un plan formal de lo que va a construir. Como cuando un arquitecto te muestra el boceto antes de construir.

**Copia y pega este prompt**:

```
/sdd-new batuta-app-dashboard
```

Este comando primero explora tu proyecto y luego genera una propuesta automaticamente.

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

## Paso 7 — Especificaciones, diseno y tareas

**Que vamos a hacer**: Dejar que Claude avance por las fases de planificacion. El va a crear las especificaciones tecnicas, el diseno de la arquitectura, y las tareas de implementacion.

**Copia y pega este prompt**:

```
/sdd-continue batuta-app-dashboard
```

Ejecuta `/sdd-continue` UNA vez por fase. Claude mostrara el resultado y te pedira confirmacion antes de avanzar. Repite hasta completar las fases pendientes (specs, design, tasks).

> **Alternativa rapida**: `/sdd-ff batuta-app-dashboard` ejecuta todas las fases pendientes de corrido sin pausas.

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

## Paso 8 — Construir la aplicacion

**Que vamos a hacer**: Ahora si, pedirle a Claude que ESCRIBA el codigo. Esta es la parte donde la magia pasa. Claude va a crear todos los archivos del proyecto.

**Copia y pega este prompt**:

```
/sdd-apply batuta-app-dashboard
```

**Que esperar**: Antes de empezar a escribir codigo, Claude va a ejecutar el **Execution Gate** — un checklist automatico que verifica:
- Que archivos va a crear/modificar
- Donde van a ir (siguiendo la Scope Rule)
- Que impacto tienen los cambios
- Que todo este alineado con las especificaciones

Te mostrara algo como:
```
Este cambio involucra scope pipeline + infra:
- Crear 12 archivos nuevos en features/dashboard/
- Crear 3 archivos en core/
- Procedo?
```

Despues del gate, Claude implementa en "lotes" (batches). Cada lote es un grupo de tareas relacionadas.

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

## Paso 9 — Verificar que todo funcione

**Que vamos a hacer**: Pedirle a Claude que revise su propio trabajo. Como cuando un profesor revisa un examen.

**Copia y pega este prompt**:

```
/sdd-verify batuta-app-dashboard
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
/sdd-verify batuta-app-dashboard
```

**Cuando todo este verde (sin errores)**, continua al siguiente paso.

---

## Paso 10 — Probar en tu computadora

**Que vamos a hacer**: Ver la aplicacion funcionando en tu computadora antes de subirla a internet. Como una prueba de manejo antes de salir a la carretera.

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

## Paso 11 — Configurar el despliegue a internet

**Que vamos a hacer**: Preparar todo lo necesario para que la aplicacion viva en internet. Esto incluye los archivos de configuracion que Coolify necesita.

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

## Paso 12 — Subir todo a GitHub

**Que vamos a hacer**: Guardar todo el proyecto en GitHub y activar el despliegue automatico. Es como entregar el paquete al servicio de mensajeria.

**Copia y pega este prompt**:

```
Crea un repositorio privado en GitHub llamado batuta-app bajo tu organizacion
o usuario de GitHub [TU-ORGANIZACION-O-USUARIO], sube todo el codigo, y configura el webhook de Coolify para
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

## Paso 13 — Verificar que la app esta en internet

**Que vamos a hacer**: Confirmar que la aplicacion esta viva en internet. El momento de la verdad.

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

**Si algo falla**, Claude te dira que esta mal y como arreglarlo. Los errores mas comunes son:
- Variables de entorno mal configuradas → Claude te dice cuales faltan
- Puerto incorrecto → Claude ajusta la configuracion
- Base de datos no conectada → Claude revisa la cadena de conexion

---

## Paso 14 — Archivar y celebrar

**Que vamos a hacer**: Cerrar formalmente el proyecto y guardar todo lo aprendido. Como firmar la entrega de una obra.

**Copia y pega este prompt**:

```
/sdd-archive batuta-app-dashboard
```

**Que esperar**: Claude va a:
- Verificar que todo esta completo
- Guardar las lecciones aprendidas
- Crear un resumen final del proyecto
- Actualizar `.batuta/session.md` con el estado final

**Tu app esta en internet. Felicidades!**

---

# DESPUES DE LA ENTREGA

> Estos pasos son opcionales pero recomendados para mantener tu proyecto saludable.

---

## Hacer cambios despues

Cuando quieras agregar algo nuevo o cambiar algo, NO edites el codigo directamente. Usa el mismo proceso:

```
/sdd-new nombre-del-cambio

Quiero agregar [descripcion de lo que quieres cambiar o agregar].
Por ejemplo: una nueva grafica que muestre los workflows mas usados de n8n.
```

Y sigue el mismo flujo: explore → propose → specs → design → tasks → apply → verify.

> **Importante**: Cada cambio pasa por el Execution Gate automaticamente.
> Claude valida que el cambio siga las reglas del proyecto antes de escribir codigo.

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

Ejemplo de lo que podria decirte:
> "El 40% de las correcciones fueron porque faltaba especificar el tamano de pantalla.
> Tip: cuando pidas interfaces, menciona en que dispositivos debe verse bien (celular, tablet, PC)."

---

## Actualizar el ecosistema Batuta

Cuando haya actualizaciones disponibles del ecosistema:

```
/batuta-update
```

Esto actualiza los skills y las instrucciones del chef sin tocar tu codigo ni la bitacora del proyecto.

---

## Comandos de emergencia

Si algo sale muy mal y quieres empezar de cero una fase:

| Situacion | Que escribir |
|-----------|-------------|
| Claude se trabo y no responde | Cierra la terminal, abrela de nuevo, escribe `claude` |
| Quieres deshacer el ultimo cambio | `Deshaz el ultimo cambio que hiciste` |
| No entiendes algo | `Explicame [lo que no entiendes] como si tuviera 15 anos` |
| Quieres ver el estado del proyecto | **Ver estado**: Pregunta a Claude: '¿En que fase estamos?' |

---

## Seguridad — Protege tu aplicacion

Antes de poner tu aplicacion en internet, Claude puede revisar que sea segura. Piensa en esto como poner cerraduras en las puertas de tu casa antes de irte de viaje.

**Copia y pega este prompt en cualquier momento antes del deploy**:

```
Ejecuta una auditoria de seguridad de la aplicacion. Revisa:
1. Que no haya claves o contrasenas escritas directamente en el codigo
2. Que los formularios esten protegidos contra inyeccion
3. Que las dependencias no tengan vulnerabilidades conocidas
4. Que la autenticacion este bien configurada
```

**Que esperar**: Claude va a revisar tu codigo con el checklist de seguridad AI-First (10 puntos) y te dara un reporte con lo que esta bien y lo que hay que arreglar. Los problemas criticos deben resolverse antes del deploy.

**Referencia**: Para entender mas sobre cada punto de seguridad, el skill `security-audit` tiene la guia completa.

---

## Preguntas frecuentes

**P: Claude me dice cosas que no entiendo. Que hago?**
R: Copialo y preguntale: "Explicame esto en espanol simple, sin palabras tecnicas"

**P: Cuanto tarda todo el proceso?**
R: La primera vez, entre 1 y 2 horas incluyendo la creacion de skills. La segunda vez que hagas un proyecto similar, mucho menos porque los skills ya existen.

**P: Puedo cerrar la terminal y continuar despues?**
R: Si. Abre la terminal, navega a tu carpeta (`cd "ruta/Batuta APP"`), escribe `claude`, y Claude automaticamente lee el archivo `.batuta/session.md` donde guardo en que quedo la ultima vez. No necesitas decirle nada especial — el recuerda solo.

**P: Que pasa si no tengo las API keys de n8n o Google?**
R: Dile a Claude que use valores de ejemplo. Despues tu o alguien mas puede reemplazarlos en los archivos de configuracion.

**P: Necesito internet para esto?**
R: Si, Claude Code necesita internet para funcionar. Tambien necesitas internet para que las APIs de n8n y Google respondan.

**P: Puedo usar esto para otros proyectos, no solo este?**
R: Si. El ecosistema Batuta funciona para cualquier tipo de proyecto. Solo cambia la descripcion en el paso de `/sdd-init` y `/sdd-new`.

**P: Que es el Execution Gate?**
R: Es un checklist automatico que Claude ejecuta antes de escribir codigo. Verifica donde van los archivos, que impacto tienen los cambios, y que todo siga las reglas del proyecto. No lo ves directamente, pero trabaja en segundo plano protegiendote de errores.

**P: Que son los Scope Agents?**
R: Son "jefes de area" especializados. Claude tiene 3: pipeline (proceso de desarrollo), infra (organizacion de archivos y recetas), y observability (calidad). El chef principal solo les pasa los pedidos al jefe correcto.

---

## Resumen visual del flujo completo

```
Tu (carpeta vacia)
 |
 +-- Paso 3:  Instalar ecosistema Batuta + crear .batuta/
 |
 +-- Paso 4:  /sdd-init .............. "Que tipo de proyecto es?"
 |
 |   [Claude detecta skills faltantes → Paso 5: "Opcion 1"]
 |
 +-- Paso 6:  /sdd-new ............... "Explorar + Propuesta formal"
 |     Tu: "Aprobado"
 |
 +-- Paso 7:  /sdd-continue .......... "Specs → Design → Tasks"
 |     Tu: "Continua" (3 veces)
 |
 +-- Paso 8:  /sdd-apply ............. "Construir la app"
 |     [Execution Gate valida antes de cada cambio]
 |     Tu: "Si, continua" (por cada batch)
 |
 +-- Paso 9:  /sdd-verify ........... "Revisar que todo funcione"
 |
 +-- Paso 10: Probar en tu PC ....... "localhost:3000"
 |
 +-- Paso 11: Configurar Coolify .... "Deploy automatico"
 |
 +-- Paso 12: Push a GitHub ......... "Codigo en la nube"
 |
 +-- Paso 13: Verificar deploy ...... "App en internet"
 |
 +-- Paso 14: /sdd-archive .......... "Cerrar y celebrar"
 |
 [Tu app esta en internet!]
```

---

## Nivel Avanzado: Agent Teams (Equipos de Agentes)

Cuando te sientas comodo con los pasos anteriores, puedes usar **Agent Teams** para que Claude trabaje con multiples "asistentes" en paralelo. Es como tener un equipo de programadores en lugar de uno solo.

### Cuando usar cada nivel

| Nivel | Cuando usarlo | Ejemplo en este proyecto |
|-------|--------------|------------------------|
| **Solo** (normal) | Cambios simples, 1-2 archivos | "Cambia el color del boton de login" |
| **Subagente** (automatico) | Investigar o verificar algo | Claude investiga una libreria antes de usarla |
| **Agent Team** (tu lo pides) | Trabajo grande en multiples partes | Implementar todo el dashboard de una vez |

### Como pedirle a Claude que use un equipo

```
Tu: "Necesito implementar el dashboard completo: sidebar, header, pagina de usuarios,
     y pagina de metricas. Crea un equipo para hacerlo en paralelo."
```

Claude va a:
1. Evaluar si el trabajo justifica un equipo (4 modulos = si)
2. Crear 2-3 asistentes especializados (implementador, revisor)
3. Repartir el trabajo en una lista de tareas compartida
4. Cada asistente trabaja en su parte al mismo tiempo
5. Un revisor verifica que todo encaje al final

### Ejemplos practicos para este proyecto

**Ejemplo 1 — Implementar multiples paginas en paralelo:**
```
Tu: "Tengo las specs de 4 paginas del dashboard: usuarios, metricas,
     configuracion y perfil. Implementalas todas con un equipo."
```

**Ejemplo 2 — Investigar + implementar al mismo tiempo:**
```
Tu: "Necesito agregar graficas al dashboard. Que un asistente investigue
     la mejor libreria de graficas para Next.js mientras otro prepara
     los componentes base."
```

**Ejemplo 3 — Code review en equipo:**
```
Tu: "Revisa toda la app antes del deploy. Que un asistente revise
     la seguridad, otro el rendimiento, y otro la accesibilidad."
```

### Metricas esperadas de rendimiento

Estas metricas son estimaciones para que compares cuando ejecutes los pasos. Anota tus resultados reales para mejorar el sistema.

| Escenario | Nivel | Tiempo estimado | Costo tokens | Calidad esperada | Fortaleza | Debilidad |
|-----------|-------|----------------|-------------|-----------------|-----------|-----------|
| Cambiar color de boton | Solo | 1-2 min | ~2K tokens | 95% primera vez | Rapido, sin overhead | N/A |
| Implementar 1 pagina SDD | Solo + Subagente | 15-25 min | ~50K tokens | 85% primera vez | Proceso completo, trazable | Secuencial, un paso a la vez |
| Implementar 4 paginas SDD | Agent Team | 20-35 min | ~150K tokens | 80% primera vez | Paralelo, mas rapido en total | Mas tokens, coordinacion puede fallar |
| Code review completo | Agent Team | 10-15 min | ~80K tokens | 90% cobertura | Multiples perspectivas | Hallazgos pueden solaparse |
| SDD Pipeline completo (explore→archive) | Agent Team | 30-45 min | ~200K tokens | 85% primera vez | Spec+Design en paralelo, apply paralelo | Requiere buena descripcion inicial |

> **Importante**: Estas son estimaciones iniciales. Cuando ejecutes cada paso, anota cuanto tardo
> realmente y si el resultado fue correcto a la primera. Esa informacion ayuda a mejorar el sistema
> con `/batuta-analyze-prompts`.

---

> **Recuerda**: No necesitas entender COMO funciona todo. Solo necesitas seguir los pasos
> y confiar en el proceso. Como aprender a manejar: primero sigues las instrucciones al pie
> de la letra, y con el tiempo lo haces naturalmente. Claude es tu asistente — el programa, tu decides.
