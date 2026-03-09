# Guia Paso a Paso: App con Temporal.io usando Claude Code

> **Para quien es esta guia**: Para cualquier persona que sepa copiar y pegar texto.
> Claude Code hace la programacion, tu solo le das las instrucciones.
>
> **Formato**: Sigue los pasos en orden, como cuando aprendes a manejar.
> Cada paso depende del anterior. No saltes pasos.

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
| **Docker** | Una herramienta que empaqueta aplicaciones para que funcionen en cualquier computadora igual. |
| **Docker Compose** | Un archivo que le dice a Docker "levanta estos 3 servicios juntos". |
| **Scope Agent** | Un "jefe de area" especializado. Claude tiene 3: uno para desarrollo (SDD pipeline), uno para infraestructura y seguridad, y uno para observabilidad y continuidad de sesion. |
| **Execution Gate** | Un checklist automatico que Claude ejecuta ANTES de hacer cualquier cambio de codigo. |

---

## Antes de empezar

Necesitas tener instalado lo de siempre (Node.js, Git, Claude Code) mas:

| Herramienta | Para que sirve | Como instalar |
|-------------|---------------|---------------|
| **Docker** | Para correr Temporal Server en tu PC | Descarga de [docker.com](https://docker.com) |
| **Python 3.11+** | El lenguaje que usaremos para los workers | Descarga de [python.org](https://python.org) |

Para verificar:
```
docker --version
python --version
```

---

# PASO A PASO

> Sigue cada paso en orden. Cada uno depende del anterior.

---

## Paso 1 — Crear la carpeta del proyecto

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

## Paso 2 — Instalar el ecosistema Batuta

> **IMPORTANTE**: Asegurate de estar dentro de la carpeta de tu proyecto antes de ejecutar este comando. Todo lo que Claude cree se guardara en la carpeta actual.

Escribe:

```
/batuta-init batuta-workers
```

Esto instala las instrucciones del chef (CLAUDE.md), los jefes de area (scope agents), el sistema de calidad (.batuta/), todas las recetas (skills) y las alarmas automaticas (hooks). Si cierras la terminal y vuelves despues, Claude recuerda donde quedo gracias a `.batuta/session.md`.

Si no tienes el comando instalado, usa el prompt largo de la guia principal (`docs/guides/guia-batuta-app.md`, Paso 3 Opcion B).

---

## Paso 3 — Iniciar el proyecto

```
/sdd-init
```

Cuando Claude pregunte:

| Pregunta | Tu respuesta |
|----------|-------------|
| Nombre del proyecto | `batuta-workers` |
| Tipo de proyecto | `automation` |
| Descripcion | `Sistema de workflows con Temporal.io para orquestar procesos de negocio, con workers en Python y dashboard de monitoreo` |

---

## Paso 4 — Cuando Claude detecte skills faltantes

Claude va a decir que no tiene skills para:
- **Temporal.io** (workflows, activities, workers)
- **PostgreSQL multi-tenant** (base de datos)
- Posiblemente **Python** (convenciones de proyecto)

Opcion 1 crea el skill solo para este proyecto. Opcion 2 lo hace disponible para todos tus proyectos.

**Tu respuesta cada vez:**

```
Opcion 1 — Investiga y crea el skill acotado a nuestro proyecto
```

Temporal.io es la tecnologia mas importante aqui. Claude va a investigar en Context7 las mejores practicas actuales del SDK de Python para Temporal y crear un skill documentado.

**Tip**: Este paso puede tomar 10-15 minutos. Es una inversion que se paga sola — Claude va a escribir mejor codigo porque tiene las recetas correctas.

---

## Paso 5 — Propuesta y aprobacion

```
/sdd-new batuta-workers-onboarding
```

Este comando primero explora tu proyecto y luego genera una propuesta automaticamente.

Lee el resumen que Claude te muestra. Si te parece bien:

```
Aprobado, continua con el siguiente paso
```

---

## Paso 6 — Especificaciones, diseno y tareas

```
/sdd-continue batuta-workers-onboarding
```

Ejecuta `/sdd-continue` UNA vez por fase. Claude mostrara el resultado y te pedira confirmacion antes de avanzar. Repite hasta completar las fases pendientes (specs, design, tasks).

> **Alternativa rapida**: `/sdd-ff batuta-workers-onboarding` ejecuta todas las fases pendientes de corrido sin pausas.

Repite "Se ve bien, continua" para cada fase. Claude ejecuta estas 3 fases en orden:

1. **Specs**: Define exactamente que hace cada workflow, activity y worker
2. **Design**: Decide la arquitectura: como se conectan Temporal, PostgreSQL y la API
3. **Tasks**: Divide todo en tareas pequenas y ordenadas

---

## Paso 7 — Construir la aplicacion

```
/sdd-apply batuta-workers-onboarding
```

Antes de escribir codigo, Claude ejecuta el **Execution Gate** — valida donde van los archivos, que impacto tienen y que todo siga las reglas del proyecto.

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

## Paso 8 — Verificar que todo funcione

```
/sdd-verify batuta-workers-onboarding
```

Si hay errores, dile:

```
Si, corrige todos los problemas que encontraste
```

Repite la verificacion hasta que todo este verde.

---

## Paso 9 — Probar en tu computadora

**Que vamos a hacer**: Levantar todo el sistema en tu PC y verificar que funciona antes de subirlo a internet.

```
Levanta todo el sistema con Docker Compose para que pueda probarlo.
Dame las instrucciones paso a paso.
```

Claude va a ejecutar `docker-compose up` y te dira como acceder al dashboard.

**Prueba**:
1. Abre el dashboard en tu navegador (generalmente `http://localhost:3000`)
2. Lanza un workflow de onboarding desde la API o el dashboard
3. Verifica que los pasos se ejecutan en orden
4. Detener un worker y ver que Temporal reintenta

**Si algo no funciona**, dile a Claude exactamente que ves:

```
El worker de onboarding se cae con este error: [pega el error aqui]
```

---

## Paso 10 — Configurar el despliegue a produccion

**Que vamos a hacer**: Preparar todo para que la aplicacion viva en internet. Coolify se encarga del hosting.

```
Necesito configurar el despliegue en Coolify para produccion.

Tenemos:
- Coolify corriendo en: [TU URL DE COOLIFY]
- Temporal Server YA esta corriendo en produccion en: [URL DEL TEMPORAL SERVER]
- El dominio para el dashboard sera: [TU DOMINIO, ejemplo: workers.batutaai.com]

Configura:
1. Servicios para los workers (pueden correr como Docker containers)
2. Servicio para la API REST
3. Servicio para el dashboard
4. Base de datos PostgreSQL como servicio en Coolify
5. Variables de entorno para todas las conexiones
6. Despliegue automatico cuando hagamos push a main
7. Health checks para saber si los workers estan vivos

Dame los archivos necesarios (Dockerfiles, docker-compose.production.yml)
y las instrucciones para Coolify.
```

**Que esperar**: Claude va a crear archivos de configuracion para produccion y darte instrucciones paso a paso de como configurar Coolify.

---

## Paso 11 — Subir a GitHub y desplegar

```
Crea un repositorio privado en GitHub llamado batuta-workers bajo la
organizacion [TU-ORGANIZACION-O-USUARIO], sube todo el codigo, y configura el webhook
de Coolify para despliegue automatico.

Haz el commit inicial con todo lo que hemos construido.
```

**Si Claude pide permisos de git** (commit, push), di "yes".

---

## Paso 12 — Verificar que todo esta en internet

```
Verifica que el despliegue en Coolify esta funcionando correctamente.
Revisa los logs de los servicios y confirma que:
1. Los workers estan conectados al Temporal Server
2. La API REST esta respondiendo
3. El dashboard esta cargando
4. La base de datos esta conectada
5. Los health checks estan pasando
```

**Si todo esta bien**, abre tu navegador y ve a tu dominio (ejemplo: `https://workers.batutaai.com`).

**Si algo falla**, los errores mas comunes con Temporal son:
- Workers no conectan → verificar URL del Temporal Server y credenciales
- Task queues vacias → verificar que los workers esten registrados
- Base de datos no conecta → verificar cadena de conexion en variables de entorno

Claude te ayuda a diagnosticar y resolver cada uno.

---

## Paso 13 — Archivar y celebrar

```
/sdd-archive batuta-workers-onboarding
```

Claude cierra el proyecto formalmente: verifica que todo esta completo, guarda las lecciones aprendidas, y actualiza `.batuta/session.md`.

**Tu sistema de workflows esta en produccion. Felicidades!**

---

# DESPUES DE LA ENTREGA

---

## Agregar nuevos workflows

Para agregar un nuevo workflow (ejemplo: procesamiento de pagos):

```
/sdd-new batuta-workers-payments

Quiero agregar un workflow de procesamiento de pagos con estos pasos:
1. Verificar fondos del cliente
2. Cobrar el monto
3. Generar factura
4. Notificar al cliente
Si el paso de cobro falla, reintentar 3 veces con backoff exponencial.
```

Y sigue el mismo flujo: explore → propose → specs → design → tasks → apply → verify.

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
├── docker-compose.yml              # Desarrollo local
├── docker-compose.production.yml   # Produccion (Coolify)
├── Dockerfile
└── requirements.txt
```

> Nota como sigue la **Scope Rule**: cada feature tiene su carpeta, shared solo tiene lo que usan 2+ features, y core tiene los singletons.

---

## Tips especificos de Temporal

| Situacion | Que decirle a Claude |
|-----------|---------------------|
| Quieres agregar un nuevo workflow | `/sdd-new nombre-del-workflow` y describe los pasos |
| Un workflow falla consistentemente | `El workflow X esta fallando en el paso Y. Muestra los logs y sugiere como arreglarlo` |
| Quieres cambiar la politica de reintentos | `Cambia la retry policy del activity Z a maximo 5 intentos con backoff exponencial` |
| Necesitas un workflow mas complejo | `Necesito un workflow que tenga pasos condicionales: si el paso 2 falla, ejecuta el paso 2B en lugar de reintentar` |
| Quieres ver metricas del sistema | Pregunta a Claude: "Como ha ido la comunicacion en este proyecto? Que puedo mejorar?" |

---

## Seguridad — Protege tu aplicacion

Antes de poner tu aplicacion en produccion, Claude puede revisar que sea segura. Los workflows de Temporal manejan datos importantes — asegurate de que esten protegidos.

**Copia y pega este prompt antes del deploy**:

```
Ejecuta una auditoria de seguridad completa del proyecto.
```

Claude activara su checklist de seguridad AI-First automaticamente, que incluye los 10 puntos del OWASP para codigo generado por IA.

**Que esperar**: Claude revisara tu codigo con el checklist de seguridad AI-First y te dara un reporte con hallazgos y recomendaciones.

---

## Nivel Avanzado: Agent Teams (Equipos de Agentes)

Cuando domines los pasos anteriores, puedes usar **Agent Teams** para trabajos complejos de Temporal. Es como tener un equipo de desarrolladores especializados trabajando juntos.

### Cuando usar cada nivel

| Nivel | Cuando usarlo | Ejemplo en este proyecto |
|-------|--------------|------------------------|
| **Solo** (normal) | Un workflow simple, cambiar retry policy | "Cambia el timeout del activity de envio a 30 segundos" |
| **Subagente** (automatico) | Investigar patrones de Temporal | Claude consulta documentacion actualizada de Temporal |
| **Agent Team** (tu lo pides) | Multiples workflows, sistema complejo | Implementar todo el sistema de procesamiento de ordenes |

### Ejemplos practicos para este proyecto

**Ejemplo 1 — Implementar multiples workflows en paralelo:**
```
Tu: "Necesito 3 workflows: procesamiento de ordenes, envio de notificaciones,
     y generacion de reportes. Crea un equipo para implementarlos en paralelo."
```

**Ejemplo 2 — Debugging complejo:**
```
Tu: "El workflow de ordenes falla intermitentemente. Que un asistente analice
     los logs del worker, otro revise la configuracion de reintentos, y otro
     verifique la conexion a la base de datos."
```

**Ejemplo 3 — Migracion de workflows:**
```
Tu: "Necesito migrar 5 workflows de la version vieja a la nueva API de Temporal.
     Que el equipo los migre en paralelo y un revisor verifique compatibilidad."
```

### Metricas esperadas de rendimiento

Anota tus resultados reales cuando ejecutes cada paso. Eso mejora el sistema.

| Escenario | Nivel | Tiempo estimado | Costo tokens | Calidad esperada | Fortaleza | Debilidad |
|-----------|-------|----------------|-------------|-----------------|-----------|-----------|
| Cambiar retry policy | Solo | 2-3 min | ~3K tokens | 95% primera vez | Rapido, preciso | N/A |
| Crear 1 workflow SDD | Solo + Subagente | 20-30 min | ~60K tokens | 85% primera vez | Proceso trazable, spec completa | Secuencial |
| Crear 3 workflows paralelo | Agent Team | 25-40 min | ~180K tokens | 80% primera vez | 3 workflows al mismo tiempo | Integracion entre workflows manual |
| Debug workflow complejo | Agent Team | 15-20 min | ~100K tokens | 85% diagnostico | Multiples angulos simultaneos | Puede necesitar contexto compartido |
| Migracion 5 workflows | Agent Team | 30-50 min | ~250K tokens | 75% primera vez | Paralelo masivo | Cada workflow puede tener edge cases unicos |

> **Importante**: Temporal es un sistema complejo. Los Agent Teams brillan cuando tienes
> multiples workflows independientes. Para workflows que dependen entre si, el modo Solo
> con SDD suele ser mas confiable porque mantiene todo el contexto en un lugar.

---

> **Recuerda**: No necesitas entender COMO funciona Temporal por dentro.
> Solo necesitas describir los pasos de tu proceso, y Claude se encarga del resto.
> Como aprender a manejar: primero sigues las instrucciones, despues lo haces naturalmente.

---

## Deployment Programatico

Este tipo de proyecto puede deployarse via Agent SDK para automatizacion CI/CD. Ver [guia-sdk-deployment.md](guia-sdk-deployment.md).
