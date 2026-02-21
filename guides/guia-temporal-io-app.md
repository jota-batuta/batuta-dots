# Guia Paso a Paso: App con Temporal.io usando Claude Code

> **Para quien es esta guia**: Para cualquier persona que sepa copiar y pegar texto.
> Claude Code hace la programacion, tu solo le das las instrucciones.

---

## Que vamos a construir

**Batuta Workers** — Un sistema de automatizacion usando Temporal.io que:

1. **Orquesta workflows complejos**: Procesos de varios pasos que pueden fallar y reintentar automaticamente
2. **Dashboard de monitoreo**: Ver que workflows estan corriendo, cuales fallaron, cuales completaron
3. **Workers resilientes**: Si algo falla a mitad de camino, Temporal retoma exactamente donde quedo
4. **API REST**: Para lanzar workflows desde otras aplicaciones

### Ejemplo concreto

Vamos a construir un workflow de **onboarding de clientes** que:
- Paso 1: Valida los datos del cliente
- Paso 2: Crea la cuenta en la base de datos
- Paso 3: Envia email de bienvenida
- Paso 4: Configura permisos iniciales
- Si cualquier paso falla, reintenta automaticamente

---

## Glosario extra para Temporal

| Palabra | Que significa |
|---------|--------------|
| **Workflow** | Una serie de pasos automaticos, como una receta de cocina. Si el paso 3 falla, Temporal lo reintenta sin empezar de cero. |
| **Activity** | Un paso individual dentro del workflow. Ejemplo: "enviar email" es una activity. |
| **Worker** | El "cocinero" que ejecuta los workflows. Siempre esta escuchando, esperando trabajo. |
| **Task Queue** | La "fila de pedidos" donde se acumulan los workflows pendientes. |
| **Retry Policy** | Las reglas de reintento: cuantas veces reintentar, cuanto esperar entre intentos. |

---

## Antes de empezar

Necesitas tener instalado lo de siempre (Node.js, Git, Claude Code) mas:

| Herramienta | Para que sirve | Como instalar |
|-------------|---------------|---------------|
| **Docker** | Para correr Temporal Server en tu PC | Descarga de [docker.com](https://docker.com) |
| **Python 3.11+** | El lenguaje que usaremos para los workers | Descarga de [python.org](https://python.org) |

---

# LAS SLIDES

---

## Slide 1 — Crear la carpeta del proyecto

1. Crea una carpeta llamada `Batuta Workers`
2. Abre una terminal
3. Navega a la carpeta:

```
cd "E:\Proyectos\Batuta Workers"
```

4. Abre Claude Code:

```
claude
```

---

## Slide 2 — Instalar el ecosistema Batuta

Escribe:

```
/batuta-init batuta-workers
```

Si no tienes el comando instalado, usa el prompt largo de la guia principal (`guides/guia-batuta-app.md`, Slide 3 Opcion B).

---

## Slide 3 — Iniciar el proyecto

```
/sdd:init
```

Cuando Claude pregunte:

| Pregunta | Tu respuesta |
|----------|-------------|
| Nombre del proyecto | `batuta-workers` |
| Tipo de proyecto | `automation` |
| Descripcion | `Sistema de workflows con Temporal.io para orquestar procesos de negocio, con workers en Python y dashboard de monitoreo` |

---

## Slide 4 — Explorar la idea

```
/sdd:explore batuta-workers-onboarding

Necesito explorar como construir un sistema de workflows con Temporal.io:

WORKFLOWS INICIALES:
- Onboarding de clientes: validar datos → crear cuenta → enviar email → configurar permisos
- Procesamiento de pagos: verificar fondos → cobrar → generar factura → notificar
- Cada workflow debe poder reintentar pasos individuales si fallan

WORKERS:
- Workers en Python usando el SDK oficial de Temporal
- Cada worker escucha su propia task queue
- Workers separados para: onboarding, pagos, notificaciones

TEMPORAL SERVER:
- Correr Temporal Server en Docker para desarrollo local
- En produccion, ya tenemos Temporal corriendo en nuestro servidor

DASHBOARD:
- Una pagina web sencilla que muestre:
  - Workflows activos
  - Workflows completados hoy
  - Workflows fallidos (con el error)
  - Boton para reintentar workflows fallidos

API REST:
- Endpoint para lanzar un workflow de onboarding
- Endpoint para consultar el estado de un workflow
- Endpoint para listar workflows por tipo

BASE DE DATOS:
- PostgreSQL para guardar datos de clientes
- Multi-tenant: cada cliente de Batuta tiene sus datos separados

DEPLOY:
- Docker Compose para desarrollo local
- Coolify para produccion
```

**Que esperar**: Claude va a investigar y probablemente detecte que necesita skills para Temporal.io y otros.

---

## Slide 5 — Cuando Claude detecte skills faltantes

Claude va a decir que no tiene skills para:
- **Temporal.io** (workflows, activities, workers)
- **PostgreSQL multi-tenant** (base de datos)
- Posiblemente **Python** (convenciones de proyecto)

**Tu respuesta cada vez:**

```
Opcion 1 — Investiga y crea el skill acotado a nuestro proyecto
```

Temporal.io es la tecnologia mas importante aqui. Claude va a investigar en Context7 las mejores practicas actuales del SDK de Python para Temporal y crear un skill documentado.

---

## Slide 6 — Propuesta, especificaciones y diseno

```
/sdd:new batuta-workers-onboarding
```

Lee el resumen. Si te parece bien:

```
Aprobado, continua con el siguiente paso
```

Luego:

```
/sdd:continue batuta-workers-onboarding
```

Repite "Se ve bien, continua" para cada fase (specs, design, tasks).

---

## Slide 7 — Implementar

```
/sdd:apply batuta-workers-onboarding
```

Claude va a crear:
- Estructura de carpetas (siguiendo la Scope Rule)
- Docker Compose con Temporal Server + PostgreSQL
- Workers en Python
- Workflows y Activities
- API REST
- Dashboard basico
- Tests

Di "Si, continua" por cada batch.

**Cuando Claude pida datos de conexion:**

```
Para desarrollo local, usa estos valores:
- PostgreSQL: localhost:5432, user=batuta, password=batuta_dev, db=batuta_workers
- Temporal Server: localhost:7233
```

---

## Slide 8 — Verificar y probar

```
/sdd:verify batuta-workers-onboarding
```

Despues de la verificacion:

```
Levanta todo el sistema con Docker Compose para que pueda probarlo.
Dame las instrucciones paso a paso.
```

Claude va a ejecutar `docker-compose up` y te dira como acceder al dashboard.

**Prueba**:
1. Abre el dashboard en tu navegador
2. Lanza un workflow de onboarding desde la API o el dashboard
3. Verifica que los pasos se ejecutan en orden
4. Detener un worker y ver que Temporal reintenta

---

## Slide 9 — Archivar

```
/sdd:archive batuta-workers-onboarding
```

---

## Estructura esperada del proyecto

```
batuta-workers/
├── core/                           # Singletons de la app
│   ├── config.py                   # Configuracion central
│   ├── database.py                 # Conexion PostgreSQL
│   └── temporal_client.py          # Cliente Temporal
├── features/
│   ├── onboarding/                 # Feature: onboarding de clientes
│   │   ├── workflows/
│   │   │   └── onboarding_workflow.py
│   │   ├── activities/
│   │   │   ├── validate_data.py
│   │   │   ├── create_account.py
│   │   │   ├── send_welcome_email.py
│   │   │   └── setup_permissions.py
│   │   ├── workers/
│   │   │   └── onboarding_worker.py
│   │   ├── api/
│   │   │   └── routes.py
│   │   └── models/
│   │       └── client.py
│   ├── payments/                   # Feature: pagos (futuro)
│   ├── dashboard/                  # Feature: dashboard de monitoreo
│   │   ├── components/
│   │   └── api/
│   └── shared/                     # Shared entre 2+ features
│       └── notifications/
├── docker-compose.yml
├── Dockerfile
└── requirements.txt
```

> Nota como sigue la **Scope Rule**: cada feature tiene su carpeta, shared solo tiene lo que usan 2+ features, y core tiene los singletons.

---

## Tips especificos de Temporal

| Situacion | Que decirle a Claude |
|-----------|---------------------|
| Quieres agregar un nuevo workflow | `/sdd:new nombre-del-workflow` y describe los pasos |
| Un workflow falla consistentemente | `El workflow X esta fallando en el paso Y. Muestra los logs y sugiere como arreglarlo` |
| Quieres cambiar la politica de reintentos | `Cambia la retry policy del activity Z a maximo 5 intentos con backoff exponencial` |
| Necesitas un workflow mas complejo | `Necesito un workflow que tenga pasos condicionales: si el paso 2 falla, ejecuta el paso 2B en lugar de reintentar` |
