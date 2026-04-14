# Caso de Uso: Planificacion de Produccion (MRP Simplificado)

Un sistema para planificar ordenes de produccion basado en demanda, inventarios disponibles, y capacidad de planta. Un MRP (Material Requirements Planning) simplificado.

---

## El problema

En fabricas medianas colombianas, la planificacion de produccion funciona asi:
- El jefe de produccion recibe pedidos por email o WhatsApp
- Revisa manualmente si hay materia prima en bodega
- Calcula "de memoria" cuanto puede producir
- Programa la produccion en un Excel que nadie mas ve
- Cuando falta material a mitad de produccion, todo se detiene

Resultado: entregas tardias, desperdicio de materia prima, y turnos extra no planificados.

---

## Lo que vas a construir

Un sistema web con:
- Registro de ordenes de produccion (producto, cantidad, fecha requerida)
- Explosion de materiales: dada una orden, calcula que materias primas necesita
- Verificacion de inventario: compara necesidades vs disponible
- Lista de faltantes: que hay que comprar antes de producir
- Calendario de produccion con capacidad por linea
- Dashboard: ordenes pendientes, % utilizacion de capacidad, faltantes criticos

---

## Flujo SDD completo

### Paso 1: Preparar
```
/sdd-init
```

### Paso 2: Iniciar
```
/sdd-new planificacion-produccion
```
Contexto: "Sistema MRP simplificado para planta de manufactura. Debe explotar listas de materiales, verificar inventario, generar lista de faltantes, y programar produccion por capacidad de linea."

### Paso 3: Discovery

Las 5 preguntas:
1. **Tipos de caso**: Produccion sobre pedido, produccion para stock, reposicion de seguridad
2. **Excepciones**: Pedido urgente (altera prioridad), materia prima descontinuada, maquina en mantenimiento
3. **Categorias externas**: productos terminados, materias primas, listas de materiales (BOM), lineas de produccion
4. **Participantes**: planificador, jefe de produccion, compras, bodega
5. **Ramas**: recibir pedido → explotar BOM → verificar inventario → generar faltantes → programar → ejecutar → reportar

### Paso 4: Skills que se activan

| Skill | Por que se activa |
|-------|------------------|
| **process-analyst** | 3 tipos de produccion con flujos y prioridades distintas |
| **data-pipeline-design** | Integracion con ERP para inventarios y listas de materiales |
| **recursion-designer** | Las listas de materiales (BOM) cambian cuando cambian los productos |

### Paso 5: Fast-forward
```
/sdd-ff
```

### Paso 6-7: Implementar, verificar
```
/sdd-apply planificacion-produccion
/sdd-verify planificacion-produccion
```

---

## Checkpoints que pasas

| Checkpoint | Que verifica en este caso |
|------------|--------------------------|
| **Design Approval** | Documentaste los 3 tipos de produccion? Mapeaste la estructura BOM? El scope es MRP simplificado (no incluye costos de produccion ni nomina)? |
| **Verificacion Final** | La explosion de materiales calcula correctamente? Los faltantes se generan bien? El calendario respeta capacidad? |

---

## Resultado final

- Sistema MRP simplificado funcionando
- Explosion de materiales automatica desde BOM
- Verificacion de inventario en tiempo real
- Lista de faltantes para compras
- Calendario de produccion visual por linea
- Documentacion completa para futuras mejoras

---

## Siguientes pasos

- Agregar costos de produccion por orden
- Integrar con sistema de compras para generar ordenes automaticas de faltantes
- Implementar reglas de secuenciacion para optimizar cambios de producto
- → Ver [Control de calidad](control-calidad.md) para cerrar el ciclo produccion-calidad

---

→ [Volver al indice de casos](../README.md)
