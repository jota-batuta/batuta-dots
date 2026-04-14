# Captura y Scoring de Leads

## El problema

Los leads llegan de todos lados: el formulario del sitio web, mensajes en redes sociales, referidos de clientes actuales, contactos de ferias y eventos. Cada canal tiene su propio formato, su propio nivel de detalle, y su propia velocidad. El equipo comercial recibe todo mezclado y sin priorizacion. El resultado: se le dedica el mismo tiempo a un lead que lleno un formulario por curiosidad que a uno referido por un cliente estrella.

Sin un sistema de priorizacion, los vendedores trabajan los leads en orden de llegada o por instinto. Los leads calientes se enfrian mientras se atienden los frios. Los leads que vienen de canales de mayor conversion se mezclan con los de menor conversion. No hay forma de saber cual canal genera mejores oportunidades ni cual necesita mas inversion.

El problema se agrava cuando el volumen crece. Con 10 leads al mes se puede atender a todos. Con 100, ya no. Sin un mecanismo automatico de calificacion y priorizacion, el equipo comercial se satura y los leads de mayor valor se pierden en la cola.

## Lo que vas a construir

- Captura unificada de leads desde multiples canales (web, redes sociales, referidos, ferias)
- Normalizacion de datos: sin importar el canal, todos los leads tienen la misma estructura base
- Scoring automatico con IA: cada lead recibe una puntuacion basada en multiples criterios
- Criterios de scoring: canal de origen, completitud de datos, perfil empresarial, comportamiento web, similitud con clientes exitosos
- Cola de leads priorizada para el equipo comercial
- Asignacion automatica segun score, zona, o especialidad del vendedor
- Gestion de consentimiento: autorizacion de tratamiento de datos y consentimiento de marketing
- Dashboard de conversion por canal, por score, por vendedor
- Trazabilidad: de donde vino cada lead y que camino recorrio hasta ser cliente (o perderse)

## Flujo SDD completo

### Fase 1 — Descubrimiento

```
sdd-new "Sistema de captura y scoring automatico de leads"
```

`sdd-init` crea el expediente. `sdd-explore` mapea los canales actuales de captacion, el volumen por canal, y como se gestionan hoy los leads entrantes.

### Fase 2 — Analisis de canales

```
→ process-analyst clasifica los canales de captacion
```

El skill `process-analyst` identifica las variantes por canal:
- **Web**: formulario del sitio, landing pages de campanas. Datos estructurados, se puede rastrear comportamiento previo.
- **Redes sociales**: mensajes directos, comentarios, formularios nativos de la plataforma. Datos parciales, contexto limitado.
- **Referido**: un cliente o contacto recomienda a alguien. Alta calidad pero datos minimos al inicio.
- **Feria/evento**: contacto presencial, tarjetas de presentacion, escaneo de QR. Volumen alto en poco tiempo, datos variables.

Cada canal tiene un nivel de confianza diferente y aporta datos distintos al scoring.

### Fase 3 — Diseno del scoring con IA

```
→ llm-pipeline-design estructura el motor de scoring
```

El skill `llm-pipeline-design` es clave en este caso. Disena el pipeline de inteligencia artificial que califica automaticamente cada lead:

- **Entrada**: datos del lead normalizados + datos de contexto (canal, campana, comportamiento web)
- **Procesamiento**: modelo que evalua multiples senales — no es una formula fija, es un modelo que aprende de los resultados historicos
- **Salida**: score numerico (0-100) + clasificacion (frio, tibio, caliente) + razon principal del score

El skill define:
- Que modelo usar y como entrenarlo con datos historicos de la empresa
- Como manejar el arranque en frio (cuando no hay datos historicos suficientes)
- Como actualizar el modelo conforme se acumulan resultados
- Los guardrails para evitar sesgos (que el modelo no discrimine por canal sin razon valida)
- El costo estimado de operacion del modelo

### Fase 4 — Cumplimiento de datos y consentimiento

```
→ compliance-colombia valida consentimiento de marketing
```

El skill `compliance-colombia` aborda un aspecto critico: no basta con almacenar datos, hay que tener autorizacion para usarlos con fines de marketing. La normativa colombiana exige:
- Autorizacion explicita e informada del titular antes de almacenar sus datos
- Consentimiento especifico para comunicaciones de marketing (separado de la autorizacion de datos)
- Opcion de revocacion del consentimiento en cualquier momento
- Registro demostrable de cuando y como se obtuvo cada autorizacion

El skill define los flujos de consentimiento que el sistema debe implementar por cada canal de captacion.

### Fase 5 — Propuesta y validacion

```
sdd-ff
```

El `sdd-ff` genera el PRD consolidado con la arquitectura completa. Se pasa por Design Approval. El diseno integra la captura multicanal, el motor de scoring, y los flujos de consentimiento.

### Fase 6 — Implementacion

```
sdd-apply
```

Se genera el codigo del sistema: conectores por canal, normalizacion de datos, motor de scoring, cola priorizada, dashboard, gestion de consentimiento.

### Fase 7 — Verificacion

```
sdd-verify
```

Se valida que la captura funcione desde todos los canales, que el scoring sea coherente, que el consentimiento se gestione correctamente, y que la asignacion a vendedores opere segun las reglas definidas.

## Skills que se activan

| Skill | Por que |
|-------|---------|
| `process-analyst` | Clasifica los 4 canales de captacion (web, redes, referido, feria) con sus datos y confiabilidad |
| `llm-pipeline-design` | Disena el motor de scoring con IA: modelo, entrenamiento, actualizacion, costos, guardrails |
| `compliance-colombia` | Gestiona consentimiento de marketing separado del tratamiento de datos — Ley 1581 + reglas SIC |

## Checkpoints que pasas

### Design Approval — Discovery Complete
- Los canales de captacion estan documentados con sus volumenes, formatos y niveles de confianza
- Los criterios de calificacion de un "buen lead" estan identificados con el equipo comercial
- Los requisitos de consentimiento por canal estan mapeados
- Los datos historicos disponibles para entrenar el modelo estan evaluados (volumen, calidad)

### Design Approval — Solution Worth Building
- La arquitectura integra captura multicanal, scoring, y consentimiento de forma coherente
- El modelo de scoring es viable con los datos disponibles (o tiene estrategia de arranque en frio)
- Los flujos de consentimiento no generan friccion excesiva en la captacion
- El costo de operacion del modelo de IA esta dentro del presupuesto
- La asignacion automatica a vendedores respeta las reglas del equipo comercial

### Verificacion Final — Ready for Production
- Los leads de todos los canales se capturan y normalizan correctamente
- El scoring produce resultados coherentes y explicables
- El consentimiento se registra correctamente para cada canal
- La asignacion a vendedores opera segun las reglas definidas
- La piramide de validacion pasa completa

## Resultado final

Un sistema donde ningun lead se pierde y los de mayor valor se atienden primero. El equipo comercial recibe una cola priorizada con contexto: de donde viene el lead, por que tiene ese score, y que datos aporto. Los gerentes pueden ver que canales generan mejores oportunidades y ajustar la inversion en marketing con datos reales. Y todo opera dentro del marco legal colombiano de proteccion de datos.

## Siguientes pasos

- Integrar con el CRM (ver: `crm-basico.md`) para que los leads calificados pasen directamente al pipeline de ventas
- Agregar nutricion automatica de leads frios con secuencias de contenido
- Implementar retroalimentacion del scoring: cuando un lead se cierra o se pierde, el modelo aprende
- Conectar con herramientas de automatizacion de marketing (email, WhatsApp Business)
