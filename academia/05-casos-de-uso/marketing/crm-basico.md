# CRM con Pipeline de Ventas

## El problema

El equipo comercial lleva la gestion de clientes en una hoja de Excel compartida. Cada vendedor tiene su propio estilo: uno escribe "llamar la semana que viene", otro pone "pendiente propuesta", otro simplemente marca la celda en amarillo. No hay un lenguaje comun ni un proceso estandarizado para saber en que estado esta cada oportunidad de negocio.

El gerente comercial pide reportes de ventas y recibe interpretaciones diferentes de cada vendedor. No hay forma confiable de saber cuantas oportunidades estan abiertas, cuantas se van a cerrar este mes, ni cuales se perdieron y por que. Las reuniones de equipo se convierten en sesiones de "contame que paso con tal cliente" en vez de analisis estrategico del pipeline.

El problema de fondo es que no existe un proceso claro de gestion comercial. Sin etapas definidas, sin criterios de avance, y sin registro historico, cada venta es un evento aislado. La empresa no aprende de sus exitos ni de sus fracasos porque no tiene datos para analizar. Y cuando un vendedor se va, se lleva toda la relacion con sus clientes en la cabeza.

## Lo que vas a construir

- Pipeline de ventas visual con etapas configurables (lead, oportunidad, propuesta, negociacion, cerrado, perdido)
- Ficha de contacto con historial completo de interacciones
- Gestion de actividades: llamadas, reuniones, correos, tareas pendientes
- Dashboard de pipeline: valor total por etapa, probabilidad de cierre, proyeccion de ingresos
- Asignacion de leads a vendedores con reglas configurables
- Motivos de perdida para analisis posterior
- Reportes: conversion por etapa, tiempo promedio de cierre, rendimiento por vendedor
- Proteccion de datos personales segun legislacion colombiana

## Flujo SDD completo

### Fase 1 — Descubrimiento

```
sdd-new "CRM con pipeline de ventas para equipo comercial"
```

`sdd-init` crea el expediente. `sdd-explore` mapea el proceso comercial actual: como llegan los leads, como se gestionan, como se cierra (o se pierde) una venta.

### Fase 2 — Analisis del proceso comercial

```
→ process-analyst modela las variantes
```

El skill `process-analyst` identifica los estados y transiciones del proceso:
- **Lead**: contacto nuevo, aun no calificado. Puede venir de multiples canales.
- **Oportunidad**: lead calificado con necesidad identificada y presupuesto. Se le asigna vendedor.
- **Cliente**: oportunidad cerrada exitosamente. Entra en gestion post-venta.
- **Perdido**: oportunidad que no se cerro. Se registra el motivo para aprendizaje.

Cada transicion tiene criterios claros: que tiene que pasar para que un lead se convierta en oportunidad, y que condiciones marcan el cierre o la perdida.

### Fase 3 — Cumplimiento de datos personales

```
→ compliance-colombia valida el manejo de datos
```

El skill `compliance-colombia` es critico aqui. Un CRM almacena datos personales de contactos: nombres, telefonos, correos, empresas, cargos. La Ley 1581 de Proteccion de Datos Personales en Colombia exige:
- Autorizacion explicita del titular para almacenar sus datos
- Politica de tratamiento de datos publicada y accesible
- Mecanismos para que el titular consulte, actualice o elimine sus datos
- Registro de bases de datos ante la SIC (Superintendencia de Industria y Comercio)

El skill define los requisitos tecnicos que el sistema debe cumplir para estar en regla.

### Fase 4 — Propuesta y validacion

```
sdd-ff
```

El `sdd-ff` genera el PRD consolidado con la arquitectura del CRM. Se pasa por Design Approval.

### Fase 5 — Implementacion

```
sdd-apply
```

Se genera el codigo del sistema: modelo de datos de contactos y oportunidades, pipeline visual, gestion de actividades, dashboard, reportes.

### Fase 6 — Auditoria de seguridad

```
→ security-audit revisa el sistema completo
```

El skill `security-audit` ejecuta su checklist de 10 puntos sobre el sistema generado. En un CRM, los puntos criticos son:
- Control de acceso: cada vendedor solo ve sus clientes (o los de su equipo)
- Encriptacion de datos sensibles en reposo y transito
- Registro de accesos (quien vio o modifico que dato y cuando)
- Proteccion contra inyeccion y manipulacion de datos
- Cumplimiento del principio de minimo privilegio

### Fase 7 — Verificacion

```
sdd-verify
```

Se valida funcionalidad, seguridad, y cumplimiento normativo. La Verificacion Final confirma que el CRM esta listo para produccion.

## Skills que se activan

| Skill | Por que |
|-------|---------|
| `process-analyst` | Modela los 4 estados del pipeline (lead, oportunidad, cliente, perdido) con sus transiciones |
| `compliance-colombia` | Asegura cumplimiento de Ley 1581 en manejo de datos personales de contactos |
| `security-audit` | Valida control de acceso, encriptacion, y registro de auditorias sobre datos sensibles |

## Checkpoints que pasas

### Design Approval — Discovery Complete
- Las etapas del pipeline estan definidas con criterios claros de transicion
- Los canales de captacion de leads estan identificados
- Los requisitos de la Ley 1581 aplicables estan documentados
- Los roles de usuario estan definidos (vendedor, gerente, administrador)

### Design Approval — Solution Worth Building
- El pipeline cubre el ciclo completo desde lead hasta cliente o perdido
- El modelo de datos soporta el historial completo de interacciones
- Los requisitos de compliance estan integrados en el diseno (no son un parche posterior)
- Los reportes propuestos responden a las preguntas reales del gerente comercial

### Verificacion Final — Ready for Production
- El pipeline funciona correctamente con todas las transiciones y validaciones
- El control de acceso respeta los permisos definidos por rol
- Los mecanismos de compliance (autorizacion, consulta, eliminacion) funcionan
- La auditoria de seguridad no reporta vulnerabilidades criticas
- La piramide de validacion pasa completa

## Resultado final

Un CRM que reemplaza el Excel compartido con un sistema estructurado. Cada vendedor tiene claridad sobre sus oportunidades y actividades pendientes. El gerente comercial tiene visibilidad real del pipeline sin depender de interpretaciones individuales. Los datos personales se manejan conforme a la ley. Y cuando un vendedor se va, el historial de relaciones queda en la empresa.

## Siguientes pasos

- Integrar con el modulo de captura y scoring de leads (ver: `automatizacion-leads.md`)
- Agregar modulo de cotizaciones directamente desde la ficha del contacto
- Implementar integracion con correo electronico para registro automatico de interacciones
- Conectar con el modulo de tracking de envios (ver: `tracking-envios.md`) para post-venta
