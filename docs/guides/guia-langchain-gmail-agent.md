# Guia Paso a Paso: Agente LangChain + Gmail con Claude Code

> **Para quien es esta guia**: Para cualquier persona que sepa copiar y pegar texto.
> Claude Code hace la programacion, tu solo le das las instrucciones.
>
> **Formato**: Sigue los pasos en orden, como cuando aprendes a manejar.
> Cada paso depende del anterior. No saltes pasos.

---

## Que vamos a construir

**Batuta Email Agent** — Un agente de IA que automatiza la organizacion de tu correo:

1. **Se conecta a tu Gmail** usando la API oficial de Google
2. **Lee correos nuevos** y analiza su contenido
3. **Clasifica cada correo** automaticamente (urgente, factura, newsletter, spam, personal, trabajo)
4. **Crea labels (etiquetas) en Gmail** si no existen
5. **Etiqueta los correos** segun la clasificacion
6. **Usa Gemini Flash** como clasificador de texto (rapido y barato)

### Ejemplo concreto

Llega un correo de "Factura #12345 de tu proveedor X" →
El agente lo lee → Gemini Flash lo clasifica como "factura" →
El agente crea la etiqueta "Facturas" si no existe →
El agente aplica la etiqueta al correo.

Todo esto sin que tu hagas nada.

---

## Glosario extra para esta guia

| Palabra | Que significa |
|---------|--------------|
| **LangChain** | Una libreria de Python para construir agentes de IA. Piensa en ella como un "kit de construccion" para hacer que la IA haga cosas utiles. |
| **Agente** | Un programa de IA que puede tomar decisiones y ejecutar acciones. No es solo un chatbot — puede conectarse a Gmail, leer correos, crear etiquetas, etc. |
| **Gemini Flash** | Un modelo de IA de Google. Es rapido y barato, perfecto para clasificar texto. |
| **Label (etiqueta)** | Las categorias de Gmail. Como las carpetas de tu escritorio pero mas flexibles — un correo puede tener varias etiquetas. |
| **API de Gmail** | La forma oficial de conectarse a Gmail desde un programa. Google te da una "llave" (credenciales) para acceder. |
| **OAuth** | El sistema de permisos de Google. Es como cuando una app te dice "Quieres dar acceso a tu Gmail?" y tu dices que si. |
| **Tool (herramienta)** | Una accion que el agente puede ejecutar. Ejemplo: "leer correo", "crear label", "aplicar etiqueta" son tools. |
| **Scope Agent** | Un "jefe de area" especializado de Claude. Coordina un grupo de tareas relacionadas. |
| **Execution Gate** | Un checklist automatico que Claude ejecuta ANTES de hacer cualquier cambio de codigo. |

---

## Antes de empezar — Configurar Google Cloud

Esta parte necesita hacerse UNA SOLA VEZ. Pide ayuda si es necesario.

### Crear proyecto en Google Cloud

1. Ve a [console.cloud.google.com](https://console.cloud.google.com)
2. Crea un proyecto nuevo (nombre: "Batuta Email Agent")
3. Activa la **Gmail API**: Busca "Gmail API" en la barra de busqueda y dale "Habilitar"
4. Activa la **Generative Language API** (para Gemini): Busca "Generative Language API" y dale "Habilitar"

### Crear credenciales OAuth

1. Ve a "APIs y servicios" → "Credenciales"
2. Click en "Crear credenciales" → "ID de cliente de OAuth"
3. Tipo: "Aplicacion de escritorio"
4. Nombre: "Batuta Email Agent"
5. Descarga el archivo JSON (se llamara algo como `client_secret_XXXXX.json`)
6. Renombralo a `credentials.json`

### Obtener API key de Gemini

1. Ve a [aistudio.google.com/apikey](https://aistudio.google.com/apikey)
2. Crea una API key
3. Guardala en un lugar seguro

> **IMPORTANTE**: Estos datos son secretos. No los compartas ni los subas a GitHub.

---

## Necesitas tener instalado

| Herramienta | Como verificar | Como instalar |
|-------------|---------------|---------------|
| **Python 3.11+** | `python --version` | [python.org](https://python.org) |
| **Node.js** | `node --version` | [nodejs.org](https://nodejs.org) |
| **Git** | `git --version` | [git-scm.com](https://git-scm.com) |
| **Claude Code** | `claude --version` | `npm install -g @anthropic-ai/claude-code` |

---

# PASO A PASO

> Sigue cada paso en orden. Cada uno depende del anterior.

---

## Paso 1 — Crear la carpeta del proyecto

1. Crea una carpeta llamada `Batuta Email Agent`
2. Abre una terminal
3. Navega a la carpeta:

```
cd "E:\Proyectos\Batuta Email Agent"
```

4. Copia el archivo `credentials.json` (del paso de Google Cloud) dentro de esta carpeta

5. Abre Claude Code:

```
claude
```

---

## Paso 2 — Instalar el ecosistema Batuta

```
/batuta-init batuta-email-agent
```

Esto instala las instrucciones del chef (CLAUDE.md), los jefes de area (scope agents), el sistema de calidad (.batuta/), todas las recetas (skills) y las alarmas automaticas (hooks). Si cierras la terminal y vuelves despues, Claude recuerda donde quedo gracias a `.batuta/session.md`.

---

## Paso 3 — Iniciar el proyecto

```
/sdd:init
```

| Pregunta | Tu respuesta |
|----------|-------------|
| Nombre del proyecto | `batuta-email-agent` |
| Tipo de proyecto | `ai-agent` |
| Descripcion | `Agente de IA con LangChain que se conecta a Gmail, clasifica correos usando Gemini Flash, crea labels automaticamente y etiqueta los correos` |

---

## Paso 4 — Explorar la idea

```
/sdd:explore batuta-email-classifier

Necesito explorar como construir un agente de IA que organice correos de Gmail:

AGENTE:
- Construido con LangChain en Python
- El agente tiene "tools" (herramientas) que puede usar
- El agente decide que hacer con cada correo basandose en su contenido

TOOLS DEL AGENTE:
1. gmail_list_messages — Lista los correos no leidos o sin etiquetar
2. gmail_get_message — Lee el contenido de un correo especifico
3. gmail_list_labels — Lista las etiquetas existentes en Gmail
4. gmail_create_label — Crea una nueva etiqueta en Gmail
5. gmail_apply_label — Aplica una etiqueta a un correo
6. classify_text — Envia el texto del correo a Gemini Flash para clasificarlo

CLASIFICACION CON GEMINI FLASH:
- Modelo: gemini-2.0-flash (rapido y barato)
- Categorias: urgente, factura, newsletter, spam, personal, trabajo, otro
- El clasificador recibe: asunto + primeras 500 palabras del cuerpo
- Responde SOLO con la categoria (una palabra)

FLUJO DEL AGENTE:
1. Obtener correos no procesados (ultimos 50 sin la etiqueta "Procesado")
2. Para cada correo:
   a. Leer el contenido
   b. Clasificar con Gemini Flash
   c. Verificar si existe la label para esa categoria
   d. Si no existe, crear la label
   e. Aplicar la label al correo
   f. Aplicar la label "Procesado" para no repetir
3. Generar un resumen: "Procesados X correos. Y urgentes, Z facturas, etc."

CONEXION A GMAIL:
- Usar la API REST de Gmail via google-api-python-client
- OAuth2 con credentials.json (ya lo tenemos en la carpeta del proyecto)
- El token se genera la primera vez (abre el navegador para dar permisos)

CONEXION A GEMINI:
- Usar google-generativeai Python SDK
- API key guardada en variable de entorno GOOGLE_API_KEY

EJECUCION:
- Se ejecuta como un script: python run_agent.py
- Opcionalmente, se puede programar para ejecutar cada 30 minutos
- Sin frontend — solo terminal

SEGURIDAD:
- Las credenciales de Gmail (credentials.json, token.json) NUNCA van a git
- La API key de Gemini va en un archivo .env
- El archivo .env NUNCA va a git
```

**Que esperar**: Claude detectara que necesita skills para LangChain, Gmail API, y Gemini. Di "Opcion 1" cada vez. Es normal y bueno.

---

## Paso 5 — Skills faltantes

Claude va a detectar que necesita:
- **LangChain** (o ai-agents) — construccion del agente
- **Gmail API** — conexion a Google
- **Gemini** — clasificador de texto

**Tu respuesta cada vez:**

```
Opcion 1 — Investiga y crea el skill acotado a nuestro proyecto
```

**Tip**: Este paso puede tomar 10-15 minutos. Es una inversion que se paga sola.

---

## Paso 6 — Propuesta y aprobacion

```
/sdd:new batuta-email-classifier
```

Lee el resumen. Si esta bien:

```
Aprobado, continua con el siguiente paso
```

---

## Paso 7 — Especificaciones, diseno y tareas

```
/sdd:continue batuta-email-classifier
```

Repite "Se ve bien, continua" para cada fase (specs, design, tasks).

---

## Paso 8 — Construir el agente

```
/sdd:apply batuta-email-classifier
```

Antes de escribir codigo, Claude ejecuta el **Execution Gate** — valida donde van los archivos, que impacto tienen y que todo siga las reglas del proyecto.

Di "Si, continua" por cada batch.

**Cuando Claude pida las credenciales:**

```
Las credenciales estan en:
- Gmail: credentials.json ya esta en la raiz del proyecto
- Gemini API key: GOOGLE_API_KEY=tu_api_key_aqui

Crea un archivo .env con la API key de Gemini.
El token de Gmail (token.json) se va a generar la primera vez que ejecute el script.
```

---

## Paso 9 — Verificar

```
/sdd:verify batuta-email-classifier
```

Corrige si hay errores:

```
Si, corrige todos los problemas que encontraste
```

Repite la verificacion hasta que todo este verde.

---

## Paso 10 — Probar el agente en tu computadora

**Que vamos a hacer**: Ejecutar el agente por primera vez y verificar que clasifica correos correctamente.

```
Ejecuta el agente para que procese mis correos.
Primero muestra que va a hacer SIN ejecutar las acciones (modo dry-run).
Cuando yo apruebe, ejecuta de verdad.
```

**Que esperar**:
1. Claude ejecutara el script
2. La primera vez, se abre tu navegador para dar permisos a Gmail
3. Click en "Permitir" (le estas dando acceso a tu Gmail)
4. El agente muestra que haria con cada correo (modo dry-run)
5. Tu apruebas y ejecuta de verdad

**Ejemplo de lo que veras:**

```
Modo dry-run — acciones que se ejecutarian:

Correo: "Factura #12345 de Proveedor X"
  → Clasificacion: factura
  → Accion: Crear label "Facturas" (no existe) + aplicar

Correo: "URGENTE: Servidor caido"
  → Clasificacion: urgente
  → Accion: Aplicar label "Urgente" (ya existe)

Correo: "Newsletter semanal de TechCrunch"
  → Clasificacion: newsletter
  → Accion: Crear label "Newsletter" (no existe) + aplicar

Ejecutar estas acciones? (si/no)
```

**Si las clasificaciones se ven bien**, di "si".
**Si algo no esta bien**, dile a Claude que ajuste.

---

## Paso 11 — Configurar ejecucion automatica

**Que vamos a hacer**: Hacer que el agente se ejecute solo cada cierto tiempo, sin que tengas que correrlo manualmente.

```
Configura el agente para que se ejecute automaticamente cada 30 minutos.

Opciones:
- Para desarrollo: un scheduler en Python (APScheduler o similar)
- Para produccion: un cron job o un servicio que corra continuamente

Necesito ambas opciones. Crea un archivo run_scheduled.py que ejecute
el agente cada 30 minutos y logee los resultados.
```

---

## Paso 12 — Configurar despliegue a produccion

**Que vamos a hacer**: Hacer que el agente viva en un servidor y se ejecute solo, sin tu computadora encendida.

```
Necesito configurar el despliegue del agente en Coolify para que corra
como un servicio continuo en produccion.

Tenemos:
- Coolify corriendo en: [TU URL DE COOLIFY]

Configura:
1. Un Dockerfile para el agente
2. El servicio en Docker que ejecute run_scheduled.py continuamente
3. Variables de entorno para las credenciales (Gmail y Gemini)
4. Health check que verifique que el agente esta procesando correos
5. Logs accesibles desde Coolify
6. Despliegue automatico cuando hagamos push a main

IMPORTANTE:
- El token de Gmail (token.json) necesita generarse la primera vez manualmente
- Despues de eso, el agente renueva el token automaticamente
- Las credenciales van como secretos en Coolify, NO en el codigo
```

**Que esperar**: Claude va a crear los archivos de configuracion para produccion y darte instrucciones de como configurar Coolify.

---

## Paso 13 — Subir a GitHub y desplegar

```
Crea un repositorio privado en GitHub llamado batuta-email-agent bajo la
organizacion jota-batuta, sube todo el codigo, y configura el webhook
de Coolify para despliegue automatico.

IMPORTANTE: Verifica que .gitignore incluya:
- credentials.json
- token.json
- .env
- Cualquier otro archivo con secretos

Haz el commit inicial con todo lo que hemos construido.
```

**Si Claude pide permisos de git** (commit, push), di "yes".

---

## Paso 14 — Verificar en produccion

```
Verifica que el despliegue del agente en Coolify esta funcionando:
1. El servicio esta corriendo
2. Los logs muestran que el agente se ejecuta cada 30 minutos
3. El ultimo ciclo proceso correos exitosamente
4. El token de Gmail no ha expirado
5. La API de Gemini esta respondiendo
```

**Si todo esta bien**, revisa tu Gmail en unas horas — deberias ver tus correos clasificados automaticamente.

**Si algo falla**, los errores mas comunes son:
- Token de Gmail expirado → hay que regenerar `token.json` manualmente una vez
- API key de Gemini invalida → verificar que esta bien en las variables de entorno
- Limites de API excedidos → verificar cuotas en Google Cloud Console

---

## Paso 15 — Archivar y celebrar

```
/sdd:archive batuta-email-classifier
```

Claude cierra el proyecto: verifica que todo esta completo, guarda las lecciones aprendidas, y actualiza `.batuta/session.md`.

**Tu agente de email esta en produccion, clasificando correos automaticamente. Felicidades!**

---

# DESPUES DE LA ENTREGA

---

## Agregar nuevas categorias

Para agregar mas categorias de clasificacion:

```
/sdd:new email-classifier-new-categories

Quiero agregar estas categorias al clasificador:
- "recibo" — para comprobantes de pago
- "reunion" — para invitaciones de calendario
- "soporte" — para tickets de soporte tecnico

Actualiza el prompt de Gemini y crea las labels nuevas.
```

---

## Mejorar la clasificacion

Si el agente se equivoca frecuentemente:

```
El clasificador esta poniendo newsletters como "trabajo".
Mejora el prompt de clasificacion con ejemplos mas claros
para distinguir entre newsletters y emails de trabajo.
```

---

## Estructura esperada del proyecto

```
batuta-email-agent/
├── core/                               # Singletons
│   ├── config.py                       # Configuracion central
│   └── auth/
│       └── gmail_auth.py               # OAuth2 con Gmail
├── features/
│   ├── classifier/                     # Feature: clasificacion
│   │   ├── services/
│   │   │   └── gemini_classifier.py    # Clasificador con Gemini Flash
│   │   └── models/
│   │       └── categories.py           # Categorias de clasificacion
│   ├── gmail/                          # Feature: operaciones Gmail
│   │   ├── services/
│   │   │   └── gmail_service.py        # CRUD de labels, lectura de correos
│   │   └── tools/
│   │       ├── list_messages.py        # Tool: listar correos
│   │       ├── get_message.py          # Tool: leer correo
│   │       ├── list_labels.py          # Tool: listar etiquetas
│   │       ├── create_label.py         # Tool: crear etiqueta
│   │       └── apply_label.py          # Tool: aplicar etiqueta
│   └── agent/                          # Feature: el agente LangChain
│       ├── agent.py                    # Definicion del agente
│       └── prompts/
│           └── system_prompt.py        # Instrucciones del agente
├── run_agent.py                        # Punto de entrada (una ejecucion)
├── run_scheduled.py                    # Ejecucion programada (cada 30 min)
├── Dockerfile                          # Para produccion
├── .env                                # API keys (NO va a git)
├── credentials.json                    # OAuth Gmail (NO va a git)
├── requirements.txt
└── .gitignore
```

---

## Costos estimados

| Servicio | Costo |
|----------|-------|
| **Gmail API** | Gratis (hasta 1 billon de requests/dia) |
| **Gemini Flash** | Practicamente gratis (~$0.075 por 1 millon de tokens). 1000 correos ≈ $0.01 |
| **Total por mes** | Menos de $1 USD para un uso normal |

---

## Tips especificos de este proyecto

| Situacion | Que decirle a Claude |
|-----------|---------------------|
| Quieres agregar una nueva categoria | `Agrega la categoria "recibo" al clasificador y actualiza el prompt de Gemini` |
| El clasificador se equivoca mucho | `El clasificador esta poniendo newsletters como "trabajo". Mejora el prompt de clasificacion con ejemplos mas claros` |
| Quieres procesar correos automaticamente cada hora | `Cambia el scheduler de cada 30 minutos a cada hora` |
| Quieres que el agente tambien responda correos | `Agrega un tool de gmail_send_reply que responda automaticamente los correos urgentes con un mensaje de "recibido"` |
| Quieres ver estadisticas | `Agrega un reporte que muestre cuantos correos de cada categoria se procesaron esta semana` |
| Quieres ver como mejorar tus instrucciones | `/batuta:analyze-prompts` para analizar la comunicacion con Claude |

---

## Seguridad — Protege tu agente y tus correos

Tu agente maneja correos reales con datos personales. Es MUY importante protegerlo.

### Pide una revision de seguridad

Despues de que tu agente funcione, copia y pega esto en Claude Code:

```
Ejecuta una revision de seguridad completa de este proyecto.
Quiero saber:
1. Si hay credenciales o tokens expuestos en el codigo
2. Si las dependencias tienen vulnerabilidades conocidas
3. Si hay riesgos de inyeccion o manipulacion de datos
4. Si los permisos de Gmail son los minimos necesarios
```

Claude activara el **skill de security-audit** y te dara un reporte con:
- Problemas encontrados (critico, alto, medio, bajo)
- Como arreglar cada problema (paso a paso)
- Buenas practicas para proteger tus credenciales de Google

### Reglas de oro para agentes con correo

| Regla | Por que |
|-------|---------|
| **Nunca guardes tokens de Google en el codigo** | Usa variables de entorno (.env) — si el codigo se comparte, tus credenciales quedan expuestas |
| **Usa los permisos minimos de Gmail** | Solo pide `gmail.readonly` y `gmail.modify` — nunca pidas acceso completo si no lo necesitas |
| **Agrega .env y credentials.json a .gitignore** | Evita subir secretos a GitHub por accidente |
| **Limita el acceso del agente** | El agente solo debe leer y etiquetar, no borrar ni enviar correos (a menos que lo necesites) |
| **Revisa los logs del agente** | Si el agente clasifica mal, revisa los logs antes de darle mas permisos |
| **Usa Presidio si manejas datos sensibles** | Si los correos tienen datos de clientes, Presidio puede anonimizar automaticamente |

> **Tip para no-tecnicos**: Piensa en la seguridad como el cinturon de seguridad del auto.
> No lo usas porque vayas a chocar, sino por si acaso. Lo mismo con tu agente — protegelo
> desde el principio para no tener sustos despues.

---

## Nivel Avanzado: Agent Teams (Equipos de Agentes)

Cuando domines los pasos anteriores, puedes usar **Agent Teams** para extender tu agente de Gmail con multiples capacidades al mismo tiempo.

### Cuando usar cada nivel

| Nivel | Cuando usarlo | Ejemplo en este proyecto |
|-------|--------------|------------------------|
| **Solo** (normal) | Ajustar clasificador, cambiar scheduler | "Mejora el prompt de clasificacion para distinguir newsletters de spam" |
| **Subagente** (automatico) | Investigar APIs o modelos | Claude investiga si Gemini Flash es mejor que GPT-4o-mini para tu caso |
| **Agent Team** (tu lo pides) | Agregar multiples tools al agente | Agregar respuesta automatica + resumen semanal + filtros avanzados |

### Ejemplos practicos para este proyecto

**Ejemplo 1 — Agregar multiples capacidades al agente:**
```
Tu: "Quiero que el agente tambien pueda: responder correos urgentes,
     generar un resumen diario, y detectar phishing. Crea un equipo
     para implementar las 3 capacidades en paralelo."
```

**Ejemplo 2 — Optimizar clasificacion con multiples enfoques:**
```
Tu: "El clasificador no es preciso. Que un asistente pruebe mejorando
     el prompt de Gemini, otro pruebe con embeddings, y comparemos
     cual funciona mejor."
```

**Ejemplo 3 — Integracion multi-servicio:**
```
Tu: "Quiero conectar el agente de Gmail con Slack y Notion. Que un
     asistente haga la integracion con Slack y otro con Notion al
     mismo tiempo."
```

### Metricas esperadas de rendimiento

Anota tus resultados reales para alimentar `/batuta:analyze-prompts`.

| Escenario | Nivel | Tiempo estimado | Costo tokens | Calidad esperada | Fortaleza | Debilidad |
|-----------|-------|----------------|-------------|-----------------|-----------|-----------|
| Ajustar prompt clasificador | Solo | 3-5 min | ~5K tokens | 90% primera vez | Rapido, iterativo | Solo un enfoque a la vez |
| Agregar 1 tool nuevo | Solo + Subagente | 15-20 min | ~40K tokens | 85% primera vez | Trazable, spec clara | Secuencial |
| Agregar 3 tools paralelo | Agent Team | 20-35 min | ~150K tokens | 80% primera vez | 3 tools simultaneos | Conflictos si comparten estado |
| Optimizar clasificacion A/B | Agent Team | 15-25 min | ~120K tokens | 85% comparacion util | Multiples enfoques rapido | Necesita datos de prueba reales |
| Integracion multi-servicio | Agent Team | 25-40 min | ~180K tokens | 75% primera vez | Cada integracion independiente | APIs externas pueden fallar |

> **Importante**: Para agentes de IA, el modo Solo con SDD suele ser el mas confiable
> para cambios que afectan la logica del clasificador (todo esta conectado). Los Agent Teams
> son mejores para agregar capacidades independientes (nuevos tools, nuevas integraciones).

---

> **Recuerda**: No necesitas entender COMO funciona la IA por dentro.
> Solo necesitas describir que quieres que el agente haga, y Claude se encarga del resto.
> Como aprender a manejar: primero sigues las instrucciones, despues lo haces naturalmente.
