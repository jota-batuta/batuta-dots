# API REST con FastAPI

> **Industria:** Desarrollo Web | **Dificultad:** Intermedio | **Tiempo estimado:** 2-3 horas con Batuta Dots

---

## El problema

Tu empresa tiene un sistema de inventario que vive en una hoja de Excel compartida. Cada vez que alguien actualiza el stock, los demas no se enteran hasta que refrescan el archivo. Ya hubo problemas: se vendio producto que no habia, se hicieron compras duplicadas y nadie sabe con certeza cuanto hay de cada cosa.

Necesitas un microservicio que centralice la gestion de inventario. Que cualquier sistema (el punto de venta, la tienda online, el equipo de compras) pueda consultar y actualizar el stock en tiempo real a traves de una API.

El equipo de desarrollo ya decidio usar Python con FastAPI porque es rapido de construir, tiene documentacion automatica (Swagger) y el equipo lo conoce. Lo que falta es una metodologia para no terminar con un monolito desordenado.

## Lo que vas a construir

Una API REST completa para gestion de inventario que incluye:

- **CRUD de productos** (crear, leer, actualizar, eliminar)
- **Gestion de stock** (entradas, salidas, ajustes, transferencias entre bodegas)
- **Categorias y ubicaciones** para organizar el inventario
- **Autenticacion JWT** para que solo usuarios autorizados accedan
- **Historial de movimientos** para trazabilidad completa
- **Documentacion automatica** con Swagger/OpenAPI

## Flujo SDD completo

### Paso 1: Definir la nueva funcionalidad

```bash
sdd-new
```

> Describe lo que necesitas:
> --> API REST para gestion de inventario. CRUD de productos con categorias, movimientos de stock (entrada, salida, ajuste, transferencia), autenticacion JWT, historial de movimientos. Base de datos PostgreSQL.

El agente genera la especificacion funcional con los endpoints, modelos de datos y reglas de negocio.

### Paso 2: Feature Freeze

```bash
sdd-ff
```

Se congela la especificacion. El agente contrata un especialista que verifica que todos los endpoints esten definidos y que las reglas de negocio sean coherentes.

> **Design Approval** — El agente evalua:
> "El proyecto tiene un alcance claro y bien definido. Los endpoints cubren las operaciones basicas de inventario. No hay riesgo de over-engineering."

### Paso 3: Aplicar la implementacion

```bash
sdd-apply
```

Se activa el template `fastapi-service` y los skills especializados generan la estructura:

```
features/
  inventory/
    models/        # SQLAlchemy models (Product, Category, StockMovement)
    schemas/       # Pydantic schemas (request/response)
    services/      # Logica de negocio
    routes/        # Endpoints FastAPI
  auth/
    models/        # User model
    schemas/       # Login, Register schemas
    services/      # JWT logic
    routes/        # Auth endpoints
core/
  database.py      # Conexion a PostgreSQL
  config.py        # Variables de entorno
  dependencies.py  # Dependencias compartidas (auth middleware)
```

El agente aplica cada skill en orden:

1. **sqlalchemy-models** genera los modelos de base de datos
2. **fastapi-crud** genera los endpoints CRUD con validaciones
3. **jwt-auth** genera el sistema de autenticacion completo

### Paso 4: Verificar

```bash
sdd-verify
```

> **Verificacion Final** — Resultado:

```
Layer 1 - Lint:           PASS (ruff sin errores)
Layer 1 - Build:          PASS (uvicorn arranca sin errores)
Layer 1d - Documentacion: PASS (100% modulos, 92% funciones)
Layer 2 - Unit Tests:     PASS (28 tests, 0 fallos)

Resultado: LISTO PARA REVIEW HUMANO
```

## Skills que se activan

| Skill | Por que |
|-------|---------|
| **fastapi-crud** | Genera el patron CRUD completo: modelos, schemas, services y routes para cada entidad |
| **jwt-auth** | Implementa registro, login, validacion de tokens y middleware de autenticacion |
| **sqlalchemy-models** | Crea los modelos de base de datos con relaciones (Product -> Category, StockMovement -> Product) |
| **scope-rule** | Organiza el codigo en features/inventory y features/auth siguiendo la convencion |

## Checkpoints que pasas

### Design Approval — Variantes de negocio + viabilidad
- **Que evalua:** Los tipos de movimiento de stock y sus reglas, y si el alcance es razonable
- **Ejemplo concreto:** "Hay 4 tipos de movimiento: entrada (suma), salida (resta), ajuste (correccion), transferencia (resta de origen + suma en destino). API REST con 4 entidades principales y autenticacion. Alcance claro, sin funcionalidades innecesarias. Adelante."
- **Si no pasa:** Se clarifican las reglas o el agente sugiere simplificar

### Verificacion Final — Calidad de la implementacion
- **Que evalua:** Que los tests pasen, que el servidor arranque, que la documentacion este completa
- **Ejemplo concreto:** "28 tests pasando, Swagger generado automaticamente en /docs, todos los endpoints documentados."
- **Si no pasa:** Se corrigen los tests o la documentacion antes del review

## Resultado final

Al terminar, tenes:

- Una API REST funcionando en FastAPI con documentacion Swagger automatica
- CRUD completo de productos, categorias y ubicaciones
- Sistema de movimientos de stock con 4 tipos y validaciones
- Autenticacion JWT (registro, login, proteccion de endpoints)
- Base de datos PostgreSQL con migraciones
- 28+ tests unitarios cubriendo los flujos principales
- Estructura de codigo limpia organizada por features

## Siguientes pasos

- **Agregar paginacion:** Para endpoints que devuelven listas grandes
- **Filtros avanzados:** Buscar productos por categoria, ubicacion, rango de stock
- **Webhooks:** Notificar a otros sistemas cuando el stock baja de un minimo
- **Rate limiting:** Proteger la API de abuso
- **Docker:** Containerizar para deploy facil
- **Alertas de stock bajo:** Notificacion automatica cuando un producto llega al minimo
