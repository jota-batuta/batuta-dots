# Integrando con infraestructura

Batuta Dots no solo construye codigo — tambien te ayuda a desplegarlo. El skill **worker-scaffold** cubre el ciclo de vida completo: desde la estructura de directorios hasta el monitoreo en produccion.

---

## Worker Scaffold

### Que es un worker

Un worker es un proceso que se ejecuta en segundo plano. No es una pagina web ni una API — es un programa que hace trabajo continuamente o cuando se le pide.

Ejemplos:
- Procesar facturas cada hora
- Enviar emails cuando hay un evento
- Sincronizar datos entre sistemas cada noche

### Que genera worker-scaffold

```
mi-worker/
  src/
    activities/     <- Las tareas que el worker ejecuta
    workflows/      <- La orquestacion de tareas (Temporal)
    config/         <- Configuracion
  tests/            <- Tests del worker
  Dockerfile        <- Para empaquetar en contenedor
  docker-compose.yml <- Para correr localmente
  .env.example      <- Variables de entorno
```

---

## Temporal.io

Temporal es el sistema de orquestacion de workflows que usa Batuta. Piensa en el como un "director de tareas" que:

- **Garantiza** que las tareas se completen (si fallan, las reintenta)
- **Coordina** tareas que dependen unas de otras
- **Registra** todo lo que pasa (para auditoria)

### Ejemplo: workflow de conciliacion

```
Workflow: conciliacion-diaria
  |
  +-- Activity 1: Descargar extracto bancario
  |     (si falla, reintentar 3 veces)
  |
  +-- Activity 2: Parsear movimientos
  |
  +-- Activity 3: Clasificar por concepto
  |     (si hay desconocido, escalar)
  |
  +-- Activity 4: Generar reporte
  |
  +-- Activity 5: Notificar al tesorero
```

---

## Docker

Docker empaqueta tu aplicacion para que funcione igual en cualquier lugar — tu computador, un servidor de pruebas, o produccion.

worker-scaffold genera un Dockerfile optimizado:
- Multi-stage build (imagen pequena)
- Health checks incluidos
- Variables de entorno configurables

---

## Coolify

Coolify es la plataforma de deploy que usa el ecosistema Batuta. Es como un "Heroku privado" que corres en tu propio servidor.

### Flujo de deploy

```
Tu codigo (Git)
  |
  v
Coolify detecta cambio
  |
  v
Construye imagen Docker
  |
  v
Despliega en tu servidor
  |
  v
Health check confirma que funciona
  |
  v
Trafico se redirige a nueva version
```

worker-scaffold genera la configuracion necesaria para que Coolify despliegue automaticamente.

---

## Monitoreo

worker-scaffold incluye:
- **Health checks**: el worker reporta si esta vivo
- **Metricas**: cuantas tareas procesa, cuanto tarda cada una
- **Logs estructurados**: cada accion queda registrada con contexto

---

-> [Recursion y aprendizaje](recursion-y-aprendizaje.md) — Sistemas que aprenden
