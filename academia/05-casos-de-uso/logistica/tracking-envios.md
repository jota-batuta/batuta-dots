# Seguimiento de Envios en Tiempo Real

## El problema

"Donde esta mi pedido?" es la pregunta que mas tiempo consume en el area de servicio al cliente de cualquier empresa que haga despachos. Los clientes llaman, escriben por WhatsApp, envian correos — y la respuesta casi siempre es la misma: "dejeme averiguar y le confirmo". El agente de servicio entonces llama al conductor, revisa el sistema de la transportadora, busca en el registro de despachos, y finalmente responde (si es que el cliente no ha colgado ya).

El problema no es que la informacion no exista. Existe, pero esta dispersa en multiples fuentes que no se comunican entre si. El GPS del vehiculo dice una cosa, el sistema de la transportadora dice otra, y el registro de bodega dice otra. Ninguna de estas fuentes le habla directamente al cliente, asi que el area de servicio se convierte en un traductor manual de datos.

El costo real no es solo el tiempo del equipo de servicio al cliente. Es la insatisfaccion del cliente que no sabe cuando llega su pedido, la perdida de oportunidad de preparar la recepcion, y la desconfianza que genera no tener visibilidad sobre algo que ya se pago.

## Lo que vas a construir

- Portal de seguimiento para clientes con numero de pedido o guia
- Vista interna para el equipo de operaciones con todos los envios activos
- Integracion de fuentes: GPS de vehiculos, sistema de transportadora, registro de bodega
- Estados del envio: preparando, despachado, en transito, en zona de entrega, entregado
- Notificaciones automaticas al cliente en cada cambio de estado
- Estimacion de hora de llegada basada en datos reales de transito
- Registro de novedades: intentos fallidos, reprogramaciones, devoluciones
- Dashboard operativo: envios en tiempo, atrasados, con novedad

## Flujo SDD completo

### Fase 1 — Descubrimiento

```
sdd-new "Sistema de seguimiento de envios en tiempo real"
```

`sdd-init` crea el expediente. `sdd-explore` mapea el flujo actual de un envio desde que sale de bodega hasta que llega al cliente: que sistemas intervienen, que datos genera cada uno, donde se pierde la visibilidad.

### Fase 2 — Diseno de integracion de datos

```
→ data-pipeline-design mapea todas las fuentes
```

El skill `data-pipeline-design` es el protagonista de este caso. Identifica y estructura las fuentes de datos:
- **GPS de vehiculos**: posicion en tiempo real, velocidad, paradas. Puede venir de dispositivos propios o de apps moviles del conductor.
- **Sistema de transportadora**: cuando la entrega es tercerizada, la transportadora tiene su propio tracking con sus propios estados y tiempos de actualizacion.
- **Registro de bodega**: confirmacion de despacho, detalle de lo que se cargo, hora de salida.

El skill define:
- Como se normalizan los datos de fuentes con formatos diferentes
- Con que frecuencia se consulta cada fuente
- Que hacer cuando una fuente no responde o envia datos inconsistentes
- Como se consolida todo en una linea de tiempo unificada por envio

### Fase 3 — Propuesta y validacion

```
sdd-ff
```

La secuencia `sdd-propose` → `sdd-spec` → `sdd-design` → `sdd-tasks` define la arquitectura de integracion. Se pasa por G0.5 y G1. El diseno prioriza la confiabilidad del dato sobre la velocidad de actualizacion.

### Fase 4 — Implementacion

```
sdd-apply
```

Se genera el codigo del sistema: modulo de integracion de fuentes, logica de estados, portal de cliente, dashboard operativo, sistema de notificaciones.

### Fase 5 — Verificacion

```
sdd-verify → G2
```

Se valida que los datos de todas las fuentes se consoliden correctamente, que las notificaciones se envien en el momento correcto, y que el portal de cliente muestre informacion confiable.

## Skills que se activan

| Skill | Por que |
|-------|---------|
| `data-pipeline-design` | Integra 3 fuentes de datos heterogeneas (GPS, transportadora, bodega) en una vista unificada |

## Gates que pasas

### G0.5 — Discovery Complete
- Las fuentes de datos estan identificadas con sus formatos, frecuencias y limitaciones
- El flujo de un envio esta mapeado de punta a punta con los puntos de perdida de visibilidad
- Los estados del envio estan definidos con las condiciones de transicion entre ellos
- Los canales de notificacion al cliente estan identificados (email, SMS, WhatsApp, portal)

### G1 — Solution Worth Building
- La arquitectura de integracion soporta las 3 fuentes sin depender de una sola
- El manejo de datos inconsistentes o ausentes esta definido (que se muestra cuando GPS no responde)
- La estimacion de hora de llegada es viable con los datos disponibles
- La escalabilidad soporta el volumen de envios proyectado

### G2 — Ready for Production
- Los datos de las 3 fuentes se consolidan correctamente en la linea de tiempo
- Las notificaciones se envian en el momento correcto sin duplicados
- El portal del cliente muestra informacion coherente y actualizada
- La piramide de validacion pasa completa

## Resultado final

Un sistema donde el cliente puede ver en cualquier momento donde esta su pedido sin llamar a nadie. El equipo de servicio al cliente deja de ser un call center de "donde esta mi pedido" y puede enfocarse en problemas reales. Operaciones tiene visibilidad completa de todos los envios activos con alertas tempranas de retrasos. La confianza del cliente aumenta porque tiene control sobre la informacion.

## Siguientes pasos

- Integrar con el modulo de ruteo de despachos (ver: `ruteo-despachos.md`) para estimaciones mas precisas
- Agregar modulo de reprogramacion donde el cliente elige nueva fecha/hora
- Implementar analisis de patrones de entrega para identificar zonas problematicas
- Conectar con el CRM (ver: `crm-basico.md`) para enriquecer el perfil del cliente con datos de entrega
