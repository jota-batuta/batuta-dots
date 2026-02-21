# Guia Paso a Paso: Agente LangChain + Gmail con Claude Code

> **Para quien es esta guia**: Para cualquier persona que sepa copiar y pegar texto.
> Claude Code hace la programacion, tu solo le das las instrucciones.

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

---

## Antes de empezar — Configurar Google Cloud

Esta parte necesita hacerse UNA SOLA VEZ. Pide ayuda si es necesario.

### Paso 1: Crear proyecto en Google Cloud

1. Ve a [console.cloud.google.com](https://console.cloud.google.com)
2. Crea un proyecto nuevo (nombre: "Batuta Email Agent")
3. Activa la **Gmail API**: Busca "Gmail API" en la barra de busqueda y dale "Habilitar"
4. Activa la **Generative Language API** (para Gemini): Busca "Generative Language API" y dale "Habilitar"

### Paso 2: Crear credenciales OAuth

1. Ve a "APIs y servicios" → "Credenciales"
2. Click en "Crear credenciales" → "ID de cliente de OAuth"
3. Tipo: "Aplicacion de escritorio"
4. Nombre: "Batuta Email Agent"
5. Descarga el archivo JSON (se llamara algo como `client_secret_XXXXX.json`)
6. Renombralo a `credentials.json`

### Paso 3: Obtener API key de Gemini

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

# LAS SLIDES

---

## Slide 1 — Crear la carpeta del proyecto

1. Crea una carpeta llamada `Batuta Email Agent`
2. Abre una terminal
3. Navega a la carpeta:

```
cd "E:\Proyectos\Batuta Email Agent"
```

4. Copia el archivo `credentials.json` (del paso 2 de Google Cloud) dentro de esta carpeta

5. Abre Claude Code:

```
claude
```

---

## Slide 2 — Instalar el ecosistema Batuta

```
/batuta-init batuta-email-agent
```

---

## Slide 3 — Iniciar el proyecto

```
/sdd:init
```

| Pregunta | Tu respuesta |
|----------|-------------|
| Nombre del proyecto | `batuta-email-agent` |
| Tipo de proyecto | `ai-agent` |
| Descripcion | `Agente de IA con LangChain que se conecta a Gmail, clasifica correos usando Gemini Flash, crea labels automaticamente y etiqueta los correos` |

---

## Slide 4 — Explorar la idea

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

**Que esperar**: Claude detectara que necesita skills para LangChain, Gmail API, y Gemini. Di "Opcion 1" cada vez.

---

## Slide 5 — Skills faltantes

Claude va a detectar que necesita:
- **LangChain** (o ai-agents) — construccion del agente
- **Gmail API** — conexion a Google
- **Gemini** — clasificador de texto

**Tu respuesta cada vez:**

```
Opcion 1 — Investiga y crea el skill acotado a nuestro proyecto
```

---

## Slide 6 — Propuesta y pipeline

```
/sdd:new batuta-email-classifier
```

Lee el resumen. Si esta bien:

```
Aprobado, continua con el siguiente paso
```

Luego:

```
/sdd:continue batuta-email-classifier
```

Repite "Se ve bien, continua" para cada fase.

---

## Slide 7 — Implementar

```
/sdd:apply batuta-email-classifier
```

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

## Slide 8 — Verificar

```
/sdd:verify batuta-email-classifier
```

Corrige si hay errores:

```
Si, corrige todos los problemas que encontraste
```

---

## Slide 9 — Probar el agente

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

---

## Slide 10 — Archivar

```
/sdd:archive batuta-email-classifier
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
├── run_agent.py                        # Punto de entrada
├── .env                                # API keys (NO va a git)
├── credentials.json                    # OAuth Gmail (NO va a git)
├── requirements.txt
└── .gitignore
```

---

## Tips especificos de este proyecto

| Situacion | Que decirle a Claude |
|-----------|---------------------|
| Quieres agregar una nueva categoria | `Agrega la categoria "recibo" al clasificador y actualiza el prompt de Gemini` |
| El clasificador se equivoca mucho | `El clasificador esta poniendo newsletters como "trabajo". Mejora el prompt de clasificacion con ejemplos mas claros` |
| Quieres procesar correos automaticamente cada hora | `Configura un cron job o un scheduler para ejecutar run_agent.py cada hora` |
| Quieres que el agente tambien responda correos | `Agrega un tool de gmail_send_reply que responda automaticamente los correos urgentes con un mensaje de "recibido"` |
| Quieres ver estadisticas | `Agrega un reporte que muestre cuantos correos de cada categoria se procesaron esta semana` |

---

## Costos estimados

| Servicio | Costo |
|----------|-------|
| **Gmail API** | Gratis (hasta 1 billon de requests/dia) |
| **Gemini Flash** | Practicamente gratis (~$0.075 por 1 millon de tokens). 1000 correos ≈ $0.01 |
| **Total por mes** | Menos de $1 USD para un uso normal |
