# Caso de Uso: App de Checklist de Mantenimiento Preventivo

Una aplicacion movil-first para que tecnicos ejecuten rutinas de mantenimiento preventivo con checklists digitales, fotos de evidencia, y alertas de vencimiento.

---

## El problema

El mantenimiento preventivo en la mayoria de empresas funciona asi:
- Hay un calendario en Excel con las rutinas programadas
- El tecnico recibe una hoja impresa con los puntos a revisar
- Marca con lapiz "OK" o "NO OK" en cada punto
- Al final del mes, alguien digita todo en Excel
- Nadie sabe si realmente se hizo la inspeccion o solo se marco

Consecuencias: equipos que fallan por falta de mantenimiento real, auditorias que no se pasan, y cero trazabilidad.

---

## Lo que vas a construir

Una aplicacion web responsive (mobile-first) con:
- Catalogo de rutinas por equipo (diarias, semanales, mensuales)
- Checklist digital con campos: OK/NO OK, valor medido, foto de evidencia
- Alertas automaticas cuando una rutina se vence
- Dashboard de cumplimiento: % de rutinas ejecutadas vs programadas
- Historial de inspecciones por equipo con fotos

---

## Flujo SDD completo

### Paso 1: Preparar el proyecto
```
/sdd-init
```

### Paso 2: Iniciar el cambio
```
/sdd-new checklist-preventivo
```
Contexto: "App mobile-first para checklist de mantenimiento preventivo. Los tecnicos deben poder ejecutar rutinas en tablet o celular, adjuntar fotos, y el sistema debe alertar cuando una rutina se vence."

### Paso 3: Discovery

Las 5 preguntas clave:
1. **Tipos de caso**: Rutina diaria, semanal, mensual, trimestral, anual
2. **Excepciones**: Equipo fuera de servicio (saltar rutina), hallazgo critico (generar OT), rutina parcial
3. **Categorias externas**: tipos de equipo, puntos de inspeccion por equipo, unidades de medida
4. **Participantes**: tecnico, supervisor, planificador de mantenimiento
5. **Ramas**: programacion → asignacion → ejecucion → revision → cierre (+ rama de hallazgo critico → OT)

### Paso 4: Skills que se activan

| Skill | Por que se activa |
|-------|------------------|
| **process-analyst** | 5 frecuencias con flujos distintos + rama de hallazgo critico |
| **recursion-designer** | Los puntos de inspeccion cambian cuando se agregan equipos nuevos |

### Paso 5: Fast-forward
```
/sdd-ff
```

### Paso 6: Implementar
```
/sdd-apply checklist-preventivo
```

### Paso 7: Verificar
```
/sdd-verify checklist-preventivo
```

---

## Checkpoints que pasas

| Checkpoint | Que verifica en este caso |
|------------|--------------------------|
| **Design Approval** | Mapeaste todas las frecuencias? Documentaste que pasa con hallazgos criticos? La app se limita a checklists (no incluye gestion de repuestos ni compras)? |
| **Verificacion Final** | Los checklists funcionan offline? Las fotos se adjuntan correctamente? Las alertas se disparan? |

---

## Resultado final

- App mobile-first para ejecucion de checklists
- Catalogo de rutinas configurable por equipo y frecuencia
- Evidencia fotografica en cada punto de inspeccion
- Alertas automaticas de vencimiento
- Dashboard de cumplimiento para gerencia

---

## Siguientes pasos

- Integrar con el sistema de OT para generar ordenes automaticas desde hallazgos criticos
- Agregar modo offline con sincronizacion cuando hay conexion
- Implementar firma digital del tecnico como evidencia de ejecucion
- → Ver [Sistema de ordenes de trabajo](sistema-ordenes-trabajo.md) para la integracion natural

---

→ [Volver al indice de casos](../README.md)
