# Optimizacion de Rutas de Despacho

## El problema

Una empresa con flota propia de vehiculos (o tercerizada) necesita hacer entregas diarias a decenas o cientos de puntos. Hoy las rutas se arman "por experiencia" del despachador: el conductor veterano sabe que a tal zona hay que ir temprano, que tal cliente solo recibe en la tarde, y que por cierta calle no se puede pasar a ciertas horas.

Ese conocimiento vive en la cabeza de una o dos personas. Cuando faltan, las rutas se arman mal. Cuando la demanda crece, el mismo metodo no escala. Los vehiculos recorren mas kilometros de los necesarios, consumen mas combustible, y los clientes reciben fuera de ventana. La empresa termina contratando mas vehiculos cuando lo que necesita es optimizar los que ya tiene.

El problema se complica porque no todas las entregas son iguales. Una entrega urbana tiene restricciones de hora pico y zonas de parqueo. Una entrega rural implica distancias largas y caminos sin pavimentar. Una entrega express tiene prioridad sobre las demas. Y una carga fragil necesita un vehiculo con condiciones especiales. Todas estas variantes deben convivir en la misma operacion diaria.

## Lo que vas a construir

- Generacion automatica de rutas optimizadas por vehiculo y dia
- Consideracion de restricciones: ventanas de tiempo, capacidad del vehiculo, tipo de carga
- Clasificacion de entregas: urbana, rural, express, fragil
- Asignacion vehiculo-conductor basada en tipo de entrega y zona
- Visualizacion de rutas en mapa con secuencia de paradas
- Recalculo de ruta en caso de cancelacion o adicion de entregas
- Metricas: kilometros recorridos, tiempo estimado vs real, entregas cumplidas vs fallidas
- Worker de calculo que procesa rutas sin bloquear la operacion

## Flujo SDD completo

### Fase 1 — Descubrimiento

```
sdd-new "Sistema de optimizacion de rutas de despacho"
```

`sdd-init` crea el expediente. `sdd-explore` mapea la operacion actual: cuantos vehiculos, cuantas entregas diarias, como se asignan hoy las rutas, cuales son las restricciones reales.

### Fase 2 — Analisis de variantes

```
→ process-analyst clasifica los tipos de entrega
```

El skill `process-analyst` identifica las variantes operativas:
- **Urbana**: restricciones de hora pico, zonas de parqueo limitado, multiples paradas cercanas
- **Rural**: distancias largas entre puntos, caminos sin pavimentar, ventanas de recepcion amplias
- **Express**: prioridad maxima, tiempo de entrega garantizado, penalizacion por incumplimiento
- **Fragil**: vehiculo con suspension especial o refrigeracion, velocidad limitada, manipulacion cuidadosa

Cada variante afecta el algoritmo de ruteo de manera diferente.

### Fase 3 — Propuesta y validacion

```
sdd-ff
```

El `sdd-ff` genera el PRD consolidado con la arquitectura. Se pasa por Design Approval. El diseno incluye el modelo de optimizacion y las restricciones que debe respetar.

### Fase 4 — Implementacion

```
sdd-apply
```

Se genera el codigo del sistema principal: gestion de entregas, asignacion de vehiculos, visualizacion de rutas.

### Fase 5 — Worker de calculo

```
→ worker-scaffold crea el worker de optimizacion
```

El skill `worker-scaffold` genera un worker dedicado al calculo de rutas. Este worker:
- Recibe la lista de entregas del dia con sus restricciones
- Ejecuta el algoritmo de optimizacion (puede tomar segundos o minutos segun la cantidad)
- Devuelve las rutas asignadas por vehiculo
- Se ejecuta en segundo plano sin bloquear la interfaz del despachador

Es un proceso separado porque el calculo de rutas es intensivo y no debe afectar la operacion normal del sistema.

### Fase 6 — Verificacion

```
sdd-verify
```

Se valida que las rutas generadas sean viables, que las restricciones se respeten, y que el worker funcione correctamente bajo carga.

## Skills que se activan

| Skill | Por que |
|-------|---------|
| `process-analyst` | Clasifica los 4 tipos de entrega (urbana, rural, express, fragil) con sus restricciones |
| `worker-scaffold` | Crea el worker de calculo de rutas que opera en segundo plano sin bloquear el sistema |

## Checkpoints que pasas

### Design Approval — Discovery Complete
- Los tipos de entrega estan documentados con sus restricciones especificas
- La flota actual esta mapeada (vehiculos, capacidades, conductores)
- Las zonas de operacion estan identificadas con sus particularidades
- Las ventanas de tiempo de los clientes estan registradas

### Design Approval — Solution Worth Building
- El algoritmo de optimizacion propuesto respeta todas las restricciones identificadas
- La arquitectura separa correctamente el calculo (worker) de la operacion (sistema principal)
- El recalculo de rutas ante cambios es viable en tiempo real
- El alcance es implementable con la infraestructura disponible

### Verificacion Final — Ready for Production
- Las rutas generadas son mas eficientes que las rutas manuales actuales
- El worker de calculo responde en tiempos aceptables para la operacion
- Las restricciones de cada tipo de entrega se respetan en todos los casos de prueba
- La piramide de validacion pasa completa

## Resultado final

Un sistema que transforma la operacion de despacho de "el conductor sabe" a "el sistema optimiza". Las rutas se generan automaticamente cada dia considerando todas las variables. Los despachadores pueden ajustar manualmente si hace falta, pero parten de una base optimizada. La empresa reduce kilometros recorridos, mejora tiempos de entrega, y puede crecer sin multiplicar vehiculos.

## Siguientes pasos

- Integrar con el modulo de tracking de envios (ver: `tracking-envios.md`)
- Agregar optimizacion multi-dia para entregas con flexibilidad de fecha
- Implementar aprendizaje de patrones: el sistema mejora las rutas con datos historicos
- Conectar con APIs de trafico en tiempo real para recalculos dinamicos
