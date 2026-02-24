# Caso de Uso: Prototipo para Startup (MVP)

Como usar Batuta Dots para construir un MVP (Minimum Viable Product) rapido, documentado, y listo para mostrar a inversionistas o early adopters.

---

## El problema

Tienes una idea de negocio y necesitas un prototipo funcional, pero:
- No sabes por donde empezar (backend? frontend? base de datos?)
- Construyes features que nadie pidio porque "se ven cool"
- No tienes documentacion que mostrar a un inversionista o mentor
- El codigo crece sin estructura y a los 2 meses es imposible de mantener
- Cuando alguien pregunta "como funciona?", no puedes explicarlo claramente

---

## Lo que vas a construir

Un MVP funcional con:
- Las features minimas para validar tu hipotesis de negocio
- Arquitectura limpia que puedas escalar si funciona
- Documentacion que puedes mostrar a inversionistas
- Proceso documentado que demuestra pensamiento estrategico

---

## Flujo SDD completo

### Paso 1: Preparar
```
/sdd-init
```

### Paso 2: Explorar tu idea
```
/sdd-new mi-mvp-nombre
```
Ejemplo: "Quiero construir una plataforma donde restaurantes pequenos de Bogota puedan recibir pedidos directos de clientes sin pagar comisiones altas de apps de delivery. MVP: catalogo de productos, carrito, pedido por WhatsApp."

### Paso 3: Discovery — La parte mas importante para una startup

Las 5 preguntas aplicadas a tu startup:
1. **Tipos de caso**: Pedido normal, pedido con personalizacion, pedido cancelado, pedido para recoger
2. **Excepciones**: Restaurante cerrado, producto agotado, zona fuera de cobertura
3. **Categorias externas**: tipos de restaurante, categorias de menu, zonas de entrega
4. **Participantes**: cliente, restaurante, administrador de la plataforma
5. **Ramas**: ver catalogo → agregar al carrito → confirmar pedido → notificar restaurante → preparar → entregar

**Clave**: Discovery te obliga a pensar en tu modelo de negocio ANTES de escribir codigo. Esto es exactamente lo que un inversionista quiere ver.

### Paso 4: Skills segun tu MVP

| Skill | Por que |
|-------|---------|
| **process-analyst** | Si tu negocio tiene flujos complejos (marketplace, logistica) |
| **compliance-colombia** | Si manejas datos personales de usuarios colombianos |
| **security-audit** | Si manejas pagos, datos de tarjeta, o informacion sensible |
| **llm-pipeline-design** | Si tu MVP incluye IA (chatbot, recomendaciones, clasificacion) |

### Paso 5: Documentar (esto impresiona inversionistas)
```
/sdd-ff
```

La propuesta generada incluye:
- **Alcance del MVP** — exactamente que incluye y que NO incluye
- **Costo-beneficio** — estimacion de tiempo y recursos
- **Riesgos** — que puede salir mal y como mitigarlo

Esto es material listo para un pitch deck.

### Paso 6-8: Implementar, verificar, archivar
```
/sdd-apply mi-mvp-nombre
/sdd-verify mi-mvp-nombre
/sdd-archive mi-mvp-nombre
```

---

## Mapeo SDD → Materiales de startup

| Artefacto SDD | Material de startup |
|---------------|---------------------|
| Reporte de exploracion | Research de mercado / Analisis de competencia |
| Propuesta | Executive summary tecnico |
| Especificaciones | Product requirements document (PRD) |
| Diseno | Technical architecture (para CTO o co-fundador tecnico) |
| Codigo | El producto mismo |
| Reporte de verificacion | QA report (demuestra que funciona) |
| Archivo | Lecciones para la siguiente iteracion |

---

## Gates que pasas

| Gate | Que verifica (y que un mentor te preguntaria) |
|------|-----------------------------------------------|
| **G0.5** | Entiendes a tu usuario? Investigaste la competencia? Definiste que es MVP y que es "nice to have"? |
| **G1** | Este MVP valida tu hipotesis? No estas construyendo de mas? Puedes terminarlo en el tiempo que tienes? |
| **G2** | Funciona lo suficiente para que un early adopter lo use? Puedes mostrarlo sin verguenza? |

---

## El enfoque MVP con SDD

La tentacion mas grande de un emprendedor es agregar features. SDD te protege:

1. **G0.5 te obliga a definir alcance** — "esto SI, esto NO"
2. **La propuesta tiene costo-beneficio** — cada feature extra tiene un costo visible
3. **Las specs son verificables** — si no esta en la spec, no se construye
4. **G1 pregunta "vale la pena?"** — perfecto para priorizar

---

## Resultado final

- MVP funcional con features minimas validadas
- Documentacion profesional para inversionistas
- Arquitectura limpia lista para escalar
- Proceso documentado que demuestra disciplina
- Lecciones aprendidas para la V2

---

## Siguientes pasos

- Mostrar el MVP a 10 early adopters y recoger feedback
- Iniciar un nuevo `/sdd-new` para la V2 basada en feedback real
- Usar los artefactos SDD como material para aplicar a aceleradoras
- Si tu MVP es tu tesis → ver [Tesis de investigacion](tesis-investigacion.md)

---

→ [Volver al indice de casos](../README.md)
