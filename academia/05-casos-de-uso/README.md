# Casos de Uso — Batuta Dots Academia

> 22 casos reales organizados por industria. Cada uno te lleva de un problema concreto a una solucion funcionando, paso a paso con el pipeline SDD.

---

## Como leer cada caso

Todos los casos siguen la misma estructura para que siempre sepas donde estas:

| Seccion | Que encontras |
|---------|---------------|
| **1. El problema** | Contexto real: que duele, por que duele, quien lo sufre |
| **2. Lo que vas a construir** | Descripcion concreta + lista de funcionalidades principales |
| **3. Flujo SDD completo** | Paso a paso con los comandos exactos que vas a ejecutar |
| **4. Skills que se activan** | Tabla con cada skill y por que se necesita en este caso |
| **5. Checkpoints que pasas** | Design Approval y verificacion final con ejemplos especificos del caso |
| **6. Resultado final** | Que tenes funcionando cuando terminas |
| **7. Siguientes pasos** | Como extender lo que construiste |

Esta estructura te garantiza que no importa si es tu primer caso o el vigesimo: siempre sabes que esperar.

---

## Indice por industria

### Desarrollo Web (3 casos)

| # | Caso | Archivo | Dificultad |
|---|------|---------|------------|
| 01 | SaaS con Next.js desde cero | [desarrollo-web/saas-nextjs.md](desarrollo-web/saas-nextjs.md) | Avanzado |
| 02 | API REST con FastAPI | [desarrollo-web/api-fastapi.md](desarrollo-web/api-fastapi.md) | Intermedio |
| 03 | Landing page rapida | [desarrollo-web/landing-page.md](desarrollo-web/landing-page.md) | Basico |

### Operaciones (3 casos)

| # | Caso | Archivo | Dificultad |
|---|------|---------|------------|
| 04 | Automatizacion de reportes | [operaciones/automatizacion-reportes.md](operaciones/automatizacion-reportes.md) | Intermedio |
| 05 | Dashboard de monitoreo en tiempo real | [operaciones/dashboard-monitoreo.md](operaciones/dashboard-monitoreo.md) | Intermedio |
| 06 | Integracion de sistemas (ERP + CRM) | operaciones/integracion-sistemas.md | Avanzado |

### Mantenimiento (3 casos)

| # | Caso | Archivo | Dificultad |
|---|------|---------|------------|
| 07 | Sistema de ordenes de trabajo | [mantenimiento/sistema-ordenes-trabajo.md](mantenimiento/sistema-ordenes-trabajo.md) | Intermedio |
| 08 | App de checklist preventivo | [mantenimiento/checklist-preventivo.md](mantenimiento/checklist-preventivo.md) | Basico |
| 09 | Gestion de repuestos y almacen | mantenimiento/gestion-repuestos.md | Intermedio |

### Produccion (3 casos)

| # | Caso | Archivo | Dificultad |
|---|------|---------|------------|
| 10 | Planificacion de produccion (MRP simplificado) | [produccion/planificacion-produccion.md](produccion/planificacion-produccion.md) | Avanzado |
| 11 | Control de calidad con trazabilidad | [produccion/control-calidad.md](produccion/control-calidad.md) | Intermedio |
| 12 | Registro de paradas y eficiencia (OEE) | produccion/registro-oee.md | Intermedio |

### Supply Chain (2 casos)

| # | Caso | Archivo | Dificultad |
|---|------|---------|------------|
| 13 | Gestion de proveedores | supply-chain/gestion-proveedores.md | Intermedio |
| 14 | Trazabilidad de materiales | supply-chain/trazabilidad-materiales.md | Avanzado |

### Logistica (2 casos)

| # | Caso | Archivo | Dificultad |
|---|------|---------|------------|
| 15 | Ruteo y despacho de entregas | logistica/ruteo-entregas.md | Intermedio |
| 16 | Control de inventario multi-bodega | logistica/inventario-multi-bodega.md | Intermedio |

### Marketing (2 casos)

| # | Caso | Archivo | Dificultad |
|---|------|---------|------------|
| 17 | CRM basico para equipo comercial | marketing/crm-basico.md | Basico |
| 18 | Automatizacion de campanas email | marketing/automatizacion-email.md | Intermedio |

### Finanzas (2 casos)

| # | Caso | Archivo | Dificultad |
|---|------|---------|------------|
| 19 | Dashboard financiero | finanzas/dashboard-financiero.md | Intermedio |
| 20 | Control de presupuestos por area | finanzas/control-presupuestos.md | Basico |

### RRHH (1 caso)

| # | Caso | Archivo | Dificultad |
|---|------|---------|------------|
| 21 | Portal de solicitudes de empleados | rrhh/portal-solicitudes.md | Basico |

### Estudiantes (1 caso)

| # | Caso | Archivo | Dificultad |
|---|------|---------|------------|
| 22 | Proyecto universitario full-stack | estudiantes/proyecto-universitario.md | Basico |

---

## Por donde empezar

- **Primera vez con Batuta Dots?** Arranca por el caso 03 (Landing page rapida). Es el mas simple y te muestra el flujo completo.
- **Ya manejas lo basico?** El caso 02 (API REST con FastAPI) te introduce skills especializados.
- **Queres ver todo el poder?** El caso 01 (SaaS con Next.js) usa equipos de agentes, seguridad y multi-tenancy.
- **No sos developer?** Los casos de operaciones (04, 05) y mantenimiento (07, 08) estan escritos para profesionales de esas areas.

---

## Convenciones

- Los comandos se muestran tal cual los escribis en la terminal
- `>` indica lo que el agente te va a preguntar
- `-->` indica lo que vos respondes
- Los checkpoints de aprobacion se marcan como **Design Approval** y **Verificacion Final**
- Las notas importantes van en bloques `> Nota:`
