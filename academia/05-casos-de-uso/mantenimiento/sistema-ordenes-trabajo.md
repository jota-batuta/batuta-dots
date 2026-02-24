# Caso de Uso: Sistema de Ordenes de Trabajo

Un sistema para crear, asignar, ejecutar y cerrar ordenes de trabajo (OT) con flujo de aprobacion, historial de equipos, y reportes de cumplimiento.

---

## El problema

En plantas industriales, talleres de mantenimiento, y empresas de servicios, las ordenes de trabajo viven en papel, WhatsApp, o Excel. Esto causa:

- **Ordenes perdidas**: alguien reporta una falla pero nadie la registra formalmente
- **Sin prioridad**: todo es "urgente" porque no hay forma de clasificar
- **Sin historial**: cuando un equipo falla de nuevo, nadie sabe que se le hizo antes
- **Sin metricas**: el jefe de mantenimiento no puede reportar tiempos de respuesta ni costos
- **Cuellos de botella**: la aprobacion de trabajos requiere firmas fisicas que demoran dias

---

## Lo que vas a construir

Un sistema web con:
- Formulario de solicitud de OT (cualquier empleado puede reportar)
- Flujo de aprobacion configurable (solicitante → supervisor → ejecucion → cierre)
- Catalogo de equipos con historial de intervenciones
- Dashboard con metricas: OT abiertas, tiempo promedio de atencion, costo por equipo
- Notificaciones por email cuando una OT cambia de estado

---

## Flujo SDD completo

### Paso 1: Preparar el proyecto
```
/sdd-init
```
Detecta que es una aplicacion web con base de datos.

### Paso 2: Iniciar el cambio
```
/sdd-new sistema-ordenes-trabajo
```
Describe el problema: "Necesitamos un sistema de ordenes de trabajo con flujo de aprobacion, historial de equipos, y dashboard de metricas."

### Paso 3: Discovery
Claude investiga y hace las 5 preguntas de Discovery Completeness:
1. **Tipos de caso**: OT correctiva, preventiva, predictiva, mejora
2. **Excepciones**: OT de emergencia (salta aprobacion), OT rechazada, OT cancelada
3. **Categorias externas**: tipos de equipo, areas de planta, niveles de prioridad
4. **Participantes**: solicitante, supervisor, tecnico, jefe de mantenimiento
5. **Ramas del proceso**: creacion → aprobacion → asignacion → ejecucion → cierre → evaluacion

### Paso 4: Skills que se activan

Claude detecta 4+ tipos de OT y sugiere:
```
Detecto 4 tipos de OT con flujos diferentes. Sugiero activar process-analyst.
```

| Skill | Por que se activa |
|-------|------------------|
| **process-analyst** | 4 tipos de OT con flujos distintos (correctiva vs preventiva vs emergencia) |
| **data-pipeline-design** | Integracion con ERP para costos y repuestos |
| **security-audit** | Control de acceso por rol (quien aprueba, quien ejecuta) |

### Paso 5: Fast-forward a documentacion
```
/sdd-ff
```
Genera propuesta, especificaciones, diseno y tareas.

### Paso 6: Implementar
```
/sdd-apply sistema-ordenes-trabajo
```

### Paso 7: Verificar
```
/sdd-verify sistema-ordenes-trabajo
```
La Piramide de Validacion verifica:
- L1: Tipos, linting, build
- L2: Tests unitarios (flujo de estados, validaciones)
- L3: Tests de integracion (flujo completo de OT)

### Paso 8: Archivar
```
/sdd-archive sistema-ordenes-trabajo
```

---

## Gates que pasas

| Gate | Que verifica en este caso |
|------|--------------------------|
| **G0.5** | Mapeaste los 4 tipos de OT? Documentaste el flujo de emergencia? Listaste todos los roles? |
| **G1** | El sistema justifica el esfuerzo? El scope esta acotado a OT (no inventarios, no compras)? |
| **G2** | Los flujos de aprobacion funcionan? El dashboard muestra datos correctos? Hay plan de rollback? |

---

## Resultado final

- Sistema de OT funcionando con 4 tipos de orden
- Flujo de aprobacion configurable por tipo
- Historial completo por equipo
- Dashboard con KPIs de mantenimiento
- Documentacion SDD completa para futuras mejoras

---

## Siguientes pasos

- Integrar con sistema de inventarios para reserva automatica de repuestos
- Agregar modulo de mantenimiento preventivo con calendario
- Conectar con IoT para OT automaticas por condicion de equipo
- → Ver [Checklist preventivo](checklist-preventivo.md) para el siguiente nivel

---

→ [Volver al indice de casos](../README.md)
