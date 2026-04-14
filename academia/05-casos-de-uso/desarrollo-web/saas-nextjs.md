# SaaS con Next.js desde cero

> **Industria:** Desarrollo Web | **Dificultad:** Avanzado | **Tiempo estimado:** 4-6 horas con Batuta Dots

---

## El problema

Una empresa de servicios necesita un portal web donde sus clientes puedan acceder a sus datos, gestionar su suscripcion y administrar usuarios dentro de su organizacion. Hoy todo se hace por email y hojas de calculo compartidas.

El equipo tecnico evaluo WordPress con plugins, pero la personalizacion necesaria para multi-tenancy (que cada cliente vea solo sus datos) y los flujos de suscripcion hacen que WordPress se quede corto. Necesitan algo a medida, pero construirlo desde cero sin una metodologia clara llevaria meses.

Este es exactamente el tipo de proyecto donde Batuta Dots brilla: es lo suficientemente complejo para justificar el pipeline completo, pero lo suficientemente definido para no perderse en el camino.

## Lo que vas a construir

Un portal SaaS multi-tenant con Next.js que incluye:

- **Autenticacion segura** con registro, login y recuperacion de contrasena
- **Multi-tenancy** donde cada organizacion ve solo sus datos
- **Gestion de suscripciones** con 3 planes (Free, Pro, Enterprise)
- **Panel de administracion** por organizacion (invitar usuarios, asignar roles)
- **Dashboard principal** con metricas personalizadas por tenant
- **API interna** para todas las operaciones del backend

## Flujo SDD completo

### Paso 1: Inicializar el proyecto

```bash
sdd-init
```

> El agente te pregunta: Que tipo de proyecto vas a crear?
> --> webapp

Se crea la estructura base del proyecto con `.batuta/` y los archivos de configuracion.

### Paso 2: Definir la nueva funcionalidad

```bash
sdd-new
```

> Describe lo que necesitas:
> --> Portal SaaS multi-tenant con Next.js. Los clientes se registran, eligen un plan de suscripcion (Free, Pro, Enterprise), crean su organizacion e invitan a su equipo. Cada organizacion solo ve sus propios datos.

El agente genera el primer borrador de la especificacion funcional.

### Paso 3: Analizar variantes de suscripcion

El `process-analyst` se activa automaticamente al detectar que hay variantes de negocio (los 3 planes de suscripcion):

```
process-analyst detecta:
- Plan Free: 1 usuario, funcionalidades basicas
- Plan Pro: hasta 10 usuarios, reportes avanzados
- Plan Enterprise: usuarios ilimitados, API access, soporte prioritario
```

> **Design Approval (variantes)** — El agente te pregunta:
> "Encontre 3 tipos de suscripcion con diferencias significativas en permisos y limites. Confirmas estos planes antes de continuar?"
> --> Si, pero el plan Enterprise tambien incluye SSO

### Paso 4: Feature Freeze

```bash
sdd-ff
```

Se congela la especificacion. A partir de aca, no se agregan funcionalidades nuevas.

> **Design Approval (viabilidad)** — El agente evalua:
> "Este proyecto requiere autenticacion custom, multi-tenancy y gestion de suscripciones. WordPress con plugins NO cubre multi-tenancy real ni permisos por plan. Veredicto: vale la pena construirlo a medida."

### Paso 5: Aplicar la implementacion

```bash
sdd-apply
```

El agente evalua la complejidad del proyecto:

```
Evaluacion de complejidad:
- Archivos estimados: 25+
- Scopes afectados: autenticacion, tenancy, suscripciones, dashboard
- Veredicto: MULTI-SCOPE → se recomienda Agent Team
```

Se activa el **team-orchestrator** con el template `nextjs-saas`:

| Teammate | Responsabilidad | Archivos |
|----------|----------------|----------|
| Auth Agent | Registro, login, JWT, roles | features/auth/* |
| Tenant Agent | Multi-tenancy, organizaciones | features/tenants/* |
| Billing Agent | Suscripciones, planes, limites | features/billing/* |
| Lead Agent | Dashboard, integracion, review | core/*, pages/* |

Cada teammate trabaja en sus archivos asignados siguiendo el **Contract-First Protocol**.

### Paso 6: Verificar

```bash
sdd-verify
```

> **Verificacion Final** — Resultado:

```
Layer 1 - Type Check:     PASS (0 errores TypeScript)
Layer 1 - Lint:           PASS (0 warnings)
Layer 1 - Build:          PASS (build exitoso)
Layer 1d - Documentacion: PASS (100% modulos, 87% funciones)
Layer 2 - Unit Tests:     PASS (42 tests, 0 fallos)
Layer 3 - Security Audit: PASS (JWT seguro, no secrets expuestos)

Resultado: LISTO PARA REVIEW HUMANO
```

## Skills que se activan

| Skill | Por que |
|-------|---------|
| **scope-rule** | Organiza el codigo en features/auth, features/tenants, features/billing siguiendo la regla de scope |
| **security-audit** | Valida que JWT este bien implementado, que no haya secrets en el codigo, que los permisos por plan sean correctos |
| **jwt-auth** | Provee el patron reutilizable para registro, login y validacion de tokens |
| **team-orchestrator** | Decide que se necesita un equipo de 4 agentes y asigna contratos y archivos |
| **process-analyst** | Identifica las variantes de suscripcion y sus implicaciones en permisos |

## Checkpoints que pasas

### Design Approval — Variantes + viabilidad
- **Que evalua:** Las diferencias entre planes de suscripcion y si la solucion justifica desarrollo custom
- **Ejemplo concreto:** "El plan Free permite 1 usuario sin reportes. El plan Enterprise permite SSO. Multi-tenancy real con aislamiento de datos no es posible con WordPress plugins estandar. Veredicto: construir a medida."
- **Si no pasa:** Se pausan las variantes o el agente sugiere alternativas (WordPress + plugin, Webflow, etc.)

### Verificacion Final — Calidad de la implementacion
- **Que evalua:** Tests, build, seguridad, documentacion
- **Ejemplo concreto:** "42 unit tests pasando, 0 errores de TypeScript, JWT auditado, 100% de modulos documentados."
- **Si no pasa:** No se permite review humano hasta corregir

## Resultado final

Al terminar, tenes:

- Un portal SaaS funcionando con Next.js
- Autenticacion completa con JWT (registro, login, recuperacion)
- Multi-tenancy real: cada organizacion aislada
- 3 planes de suscripcion con permisos diferenciados
- Panel de admin por organizacion
- Tests automatizados cubriendo los flujos criticos
- Codigo organizado por features siguiendo la Scope Rule

## Siguientes pasos

- **Agregar pagos:** Integrar Stripe o MercadoPago para cobrar suscripciones
- **Notificaciones:** Agregar emails transaccionales (bienvenida, recuperacion de contrasena)
- **Analytics:** Dashboard de uso por tenant para el admin general
- **CI/CD:** Configurar deploy automatico con Vercel o similar
- **Internacionalizacion:** Soporte multi-idioma si tus clientes lo necesitan
