# Caso de Uso: Control de Calidad con Trazabilidad

Un sistema para registrar inspecciones de calidad en linea de produccion, con trazabilidad desde materia prima hasta producto terminado y reportes de no conformidades.

---

## El problema

En plantas de manufactura, el control de calidad suele ser:
- Inspecciones en papel que se archivan en carpetas
- Sin trazabilidad: si un cliente reclama, no se puede rastrear el lote
- Sin estadisticas: no se sabe que defectos son los mas frecuentes
- Sin alertas: un problema de calidad se detecta dias despues
- Auditorias de certificacion (ISO, INVIMA) requieren registros que no existen digitalmente

---

## Lo que vas a construir

Un sistema web con:
- Registro de inspecciones en cada punto de control (recepcion MP, en proceso, producto terminado)
- Trazabilidad lote a lote: desde proveedor de materia prima hasta despacho al cliente
- Registro de no conformidades con clasificacion (critica, mayor, menor)
- Dashboard: defectos por tipo, tendencia por periodo, porcentaje de rechazo
- Reportes para auditorias (ISO 9001, INVIMA, BPM)

---

## Flujo SDD completo

### Paso 1: Preparar
```
/sdd-init
```

### Paso 2: Iniciar
```
/sdd-new control-calidad
```
Contexto: "Sistema de control de calidad para planta de produccion. Inspecciones en 3 puntos de control, trazabilidad de lotes, registro de no conformidades, y reportes para auditorias ISO/INVIMA."

### Paso 3: Discovery

Las 5 preguntas:
1. **Tipos de caso**: Inspeccion de recepcion MP, en proceso, producto terminado, devolucion de cliente
2. **Excepciones**: Lote retenido, producto no conforme critico (paro de linea), reclamo de cliente
3. **Categorias externas**: tipos de defecto, criterios de aceptacion por producto, normas aplicables
4. **Participantes**: inspector QC, jefe de calidad, produccion, compras (para MP no conforme), cliente
5. **Ramas**: inspeccion → registro resultado → aprobado/rechazado → si rechazado: no conformidad → accion correctiva → verificacion

### Paso 4: Skills que se activan

| Skill | Por que se activa |
|-------|------------------|
| **process-analyst** | 4 tipos de inspeccion con flujos distintos |
| **recursion-designer** | Los criterios de aceptacion cambian por producto y por norma |
| **data-pipeline-design** | Integracion con produccion para datos de lotes |
| **compliance-colombia** | Si el producto tiene regulacion INVIMA (alimentos, farmaceuticos) |

### Paso 5: Fast-forward
```
/sdd-ff
```

### Paso 6-8: Implementar, verificar, archivar
```
/sdd-apply control-calidad
/sdd-verify control-calidad
/sdd-archive control-calidad
```

---

## Gates que pasas

| Gate | Que verifica en este caso |
|------|--------------------------|
| **G0.5** | Mapeaste los 4 tipos de inspeccion? Documentaste el flujo de no conformidades? Listaste las normas aplicables? |
| **G1** | El scope es QC e inspecciones (no incluye gestion completa de calidad ni acciones preventivas)? |
| **G2** | La trazabilidad funciona de punta a punta? Los reportes cumplen con los formatos requeridos? |

---

## Resultado final

- Sistema de inspecciones digitales en 3 puntos de control
- Trazabilidad completa lote a lote
- Registro y seguimiento de no conformidades
- Dashboard estadistico de calidad
- Reportes listos para auditorias

---

## Siguientes pasos

- Integrar con sistema de produccion para trazabilidad automatica de lotes
- Agregar modulo de acciones correctivas y preventivas (CAPA)
- Implementar alertas SPC (control estadistico de proceso) con limites automaticos
- → Ver [Planificacion de produccion](planificacion-produccion.md) para cerrar el ciclo

---

→ [Volver al indice de casos](../README.md)
