# Gestion de Inventarios Multi-Bodega

## El problema

Imagina una empresa con 3 o mas bodegas distribuidas en diferentes ciudades. El inventario se lleva en hojas de Excel que cada jefe de bodega actualiza "cuando puede". Nadie sabe con certeza cuanto hay de cada producto en cada ubicacion. Las transferencias entre bodegas se comunican por WhatsApp y se registran dias despues — si es que se registran.

El resultado es predecible: se compra lo que ya hay en otra bodega, se prometen entregas de productos que no estan disponibles, y el cierre de mes se convierte en un ejercicio de arqueologia digital tratando de reconstruir movimientos desde multiples archivos.

El problema real no es tecnologico — es de proceso. Cada bodega maneja categorias diferentes (materia prima, producto terminado, insumos, herramientas) con reglas distintas de almacenamiento, rotacion y reabastecimiento. Una solucion que no entienda estas variantes esta condenada a ser otro Excel con interfaz bonita.

## Lo que vas a construir

- Registro centralizado de inventario por bodega, categoria y ubicacion fisica
- Gestion de movimientos: entradas, salidas, transferencias entre bodegas, ajustes
- Clasificacion por tipo de producto (materia prima, producto terminado, insumos, herramientas)
- Alertas de stock minimo y maximo configurables por bodega
- Trazabilidad de movimientos con usuario, fecha y motivo
- Dashboard con vista consolidada y vista por bodega
- Integracion con fuentes de datos existentes (ERP, facturacion)

## Flujo SDD completo

### Fase 1 — Descubrimiento

```
sdd-new "Sistema de gestion de inventarios multi-bodega"
```

El pipeline arranca con `sdd-init` que crea el expediente del proyecto. Luego `sdd-explore` mapea el contexto: cuantas bodegas, que categorias manejan, como fluyen los productos hoy.

### Fase 2 — Analisis de proceso

```
→ process-analyst se activa automaticamente
```

El skill `process-analyst` identifica las variantes del proceso:
- **Materia prima**: entra de proveedores, se consume en produccion, requiere control de lotes
- **Producto terminado**: sale de produccion, se despacha a clientes, requiere control de disponibilidad
- **Insumos**: consumo interno, reposicion periodica, multiples proveedores
- **Herramientas**: no se consumen, se prestan y devuelven, requieren control de estado

Cada variante genera su propio flujo de estados y reglas de negocio.

### Fase 3 — Diseno de datos

```
→ data-pipeline-design mapea las fuentes
```

El skill `data-pipeline-design` identifica de donde vienen los datos:
- ERP existente (si hay): ordenes de compra, facturas de venta
- Sistema de facturacion: salidas confirmadas
- Registros manuales: conteos fisicos, ajustes

Define como se sincronizan estas fuentes y que pasa cuando hay conflictos.

### Fase 4 — Manejo de complejidad

```
→ recursion-designer entra en accion
```

El skill `recursion-designer` aborda un problema real: los codigos de producto del proveedor cambian. Un mismo producto puede tener 3 codigos diferentes segun el proveedor y la epoca. Este skill disena la estrategia de mapeo y reconciliacion.

### Fase 5 — Propuesta y validacion

```
sdd-ff
```

El `sdd-ff` genera el PRD consolidado en secuencia. Aqui se pasa por Design Approval. El PRD incluye arquitectura, modelo de datos, y plan de implementacion.

### Fase 6 — Implementacion

```
sdd-apply
```

Se genera el codigo siguiendo las tareas definidas. El pipeline aplica las validaciones automaticas (tipos, linting, build) antes de pasar a pruebas.

### Fase 7 — Verificacion

```
sdd-verify
```

Se ejecuta la piramide de validacion completa. La Verificacion Final confirma que el sistema esta listo para produccion.

## Skills que se activan

| Skill | Por que |
|-------|---------|
| `process-analyst` | Identifica las 4 variantes de producto y sus flujos distintos de movimiento |
| `data-pipeline-design` | Mapea las fuentes de datos (ERP, facturacion) y define sincronizacion |
| `recursion-designer` | Resuelve el problema de codigos de producto que cambian entre proveedores |
| `compliance-colombia` | Se activa si se almacenan datos de proveedores (personas naturales) — Ley 1581 |

## Checkpoints que pasas

### Design Approval — Discovery Complete
- Se confirma que las variantes de producto estan mapeadas (materia prima, terminado, insumos, herramientas)
- Las fuentes de datos existentes estan identificadas con sus formatos
- El problema de codigos variables del proveedor esta documentado
- Los usuarios clave de cada bodega estan identificados

### Design Approval — Solution Worth Building
- La propuesta cubre todas las variantes sin forzar un flujo unico
- El modelo de datos soporta multiples codigos por producto
- La estrategia de sincronizacion con el ERP es viable
- El alcance es realista para el equipo y el tiempo disponible

### Verificacion Final — Ready for Production
- Los movimientos entre bodegas se registran correctamente
- Las alertas de stock funcionan por bodega y categoria
- La sincronizacion con fuentes externas esta probada
- La piramide de validacion pasa completa (tipos, tests, integracion)

## Resultado final

Un sistema que reemplaza los Excel dispersos con una vista unificada del inventario. Cada bodega opera con autonomia pero la empresa tiene visibilidad total. Los movimientos se registran en tiempo real y las decisiones de compra se toman con datos reales, no con suposiciones.

## Siguientes pasos

- Agregar modulo de ordenes de compra automaticas basadas en stock minimo
- Integrar con el modulo de trazabilidad de lotes (ver: `trazabilidad-lotes.md`)
- Implementar reportes de rotacion por categoria y temporada
- Conectar con el sistema de despachos para reservar inventario automaticamente
