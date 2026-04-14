# Trazabilidad de Lotes

## El problema

En la industria de alimentos y farmaceutica, cada lote de producto tiene que poder rastrearse desde su origen hasta el consumidor final. No es opcional — es una exigencia regulatoria. El INVIMA en Colombia puede pedir en cualquier momento la trazabilidad completa de un lote, y la empresa tiene un plazo limitado para responder.

La realidad de muchas empresas es que la trazabilidad se lleva en registros fisicos, hojas de calculo, o sistemas que no se comunican entre si. Cuando hay un recall (retiro de producto), el equipo de calidad entra en modo crisis: revisar carpetas, cruzar lotes con fechas de produccion, identificar a que clientes se despacho. Un proceso que deberia tomar minutos toma dias.

El reto adicional es que los codigos regulatorios cambian. El INVIMA actualiza formatos, agrega campos obligatorios, y modifica las categorias de productos. Un sistema rigido se vuelve obsoleto con cada actualizacion normativa.

## Lo que vas a construir

- Registro de lotes con informacion completa: materia prima, fecha de produccion, operarios, maquinaria
- Cadena de custodia: desde recepcion de insumos hasta despacho al cliente
- Vinculacion lote de materia prima → lote de producto terminado
- Busqueda inversa: dado un lote de producto terminado, obtener todos los lotes de materia prima usados
- Busqueda directa: dado un lote de materia prima, obtener todos los productos terminados afectados
- Generacion de reportes en formato INVIMA vigente
- Alertas de vencimiento por lote
- Registro de eventos de calidad (rechazos, reprocesos, retiros)

## Flujo SDD completo

### Fase 1 — Descubrimiento

```
sdd-new "Sistema de trazabilidad de lotes para industria regulada"
```

`sdd-init` crea el expediente. `sdd-explore` mapea el proceso productivo actual: como se reciben materias primas, como se asignan lotes, como se vinculan con produccion.

### Fase 2 — Analisis de variantes

```
→ process-analyst clasifica los tipos de trazabilidad
```

El skill `process-analyst` identifica que la trazabilidad no es igual para todos:
- **Alimentos**: requiere control de temperatura, fechas de vencimiento cortas, lotes de materia prima perecedera
- **Farmaceutico**: requiere registro de condiciones ambientales, trazabilidad de principios activos, documentacion GMP
- **Quimico**: requiere hojas de seguridad, control de compatibilidad entre sustancias, registros de manipulacion

Cada tipo tiene campos obligatorios diferentes y reglas de vinculacion distintas.

### Fase 3 — Manejo de cambios regulatorios

```
→ recursion-designer aborda los codigos INVIMA
```

El skill `recursion-designer` enfrenta un problema critico: los codigos y formatos regulatorios del INVIMA cambian periodicamente. Disena una estrategia donde las plantillas de reporte son configurables y los campos regulatorios se gestionan como metadatos, no como columnas fijas en la base de datos.

### Fase 4 — Diseno de datos

```
→ data-pipeline-design estructura el flujo de informacion
```

El skill `data-pipeline-design` define como fluyen los datos:
- Recepcion de materia prima → creacion de lote de entrada
- Produccion → vinculacion lotes de entrada con lote de salida
- Despacho → vinculacion lote de salida con cliente y fecha
- Calidad → eventos asociados a cualquier lote en cualquier etapa

### Fase 5 — Propuesta y validacion

```
sdd-ff
```

Genera el PRD consolidado con propuesta, especificacion, diseno y tareas. El Design Approval valida que la solucion cubra los requisitos regulatorios y operativos.

### Fase 6 — Implementacion

```
sdd-apply
```

Se genera el codigo con enfasis en la integridad de la cadena de trazabilidad. Cada movimiento de lote es inmutable una vez registrado.

### Fase 7 — Verificacion

```
sdd-verify
```

Pruebas especificas de trazabilidad: busqueda directa, busqueda inversa, generacion de reportes. La Verificacion Final valida que un recall simulado se pueda resolver en minutos.

## Skills que se activan

| Skill | Por que |
|-------|---------|
| `process-analyst` | Clasifica los 3 tipos de trazabilidad (alimento, farmaceutico, quimico) con sus reglas propias |
| `recursion-designer` | Maneja los cambios en codigos regulatorios INVIMA sin reescribir el sistema |
| `data-pipeline-design` | Estructura el flujo de datos desde recepcion hasta despacho con vinculacion de lotes |

## Checkpoints que pasas

### Design Approval — Discovery Complete
- Los tipos de trazabilidad (alimento, farmaceutico, quimico) estan documentados con sus campos obligatorios
- El proceso productivo actual esta mapeado con sus puntos de creacion de lotes
- Los requisitos regulatorios vigentes del INVIMA estan identificados
- Los puntos de falla en la trazabilidad actual estan documentados

### Design Approval — Solution Worth Building
- La propuesta soporta busqueda directa e inversa de lotes
- El modelo de datos es flexible ante cambios regulatorios
- La vinculacion materia prima → producto terminado es solida
- El tiempo de respuesta ante un recall simulado es aceptable (minutos, no dias)

### Verificacion Final — Ready for Production
- Un recall simulado se resuelve en menos de 5 minutos
- Los reportes en formato INVIMA se generan correctamente
- La cadena de custodia es inmutable (no se pueden borrar o alterar registros)
- La piramide de validacion pasa completa

## Resultado final

Un sistema donde cualquier lote se puede rastrear de punta a punta en minutos. Ante una alerta de calidad o un requerimiento del INVIMA, el equipo puede responder con datos exactos: que materia prima se uso, cuando se produjo, a quien se despacho. La trazabilidad deja de ser un dolor de cabeza y se convierte en una ventaja operativa.

## Siguientes pasos

- Integrar con el modulo de inventarios multi-bodega (ver: `gestion-inventarios.md`)
- Agregar modulo de auditorias internas con checklist configurable
- Implementar notificaciones automaticas de vencimiento proximo
- Conectar con el portal del INVIMA para envio directo de reportes (cuando la API este disponible)
