---
name: recursion-designer
description: >
  Use when external categories change over time (bank concepts, tax codes, SKUs).
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-02-23"
  source: "CTO Layer skill 15"
  bucket: define
  auto_invoke: false
  platforms: [claude, antigravity]
allowed-tools: Read Glob Grep WebSearch
---

# Recursion Designer — Learning Systems

## Purpose

Disenar mecanismos para que sistemas automatizados detecten cambio externo,
lo procesen controladamente, y se actualicen sin romper resultados historicos.

**Regla**: Un sistema que no sabe que no sabe es mas peligroso que uno que sabe que no sabe.

## When to Invoke

- process-analyst detecta taxonomias externas
- Proceso usa categorias controladas por terceros
- Se necesita que el sistema aprenda sin romper lo existente

## 4 Mecanismos

### 1 — Deteccion de Desconocidos

Si valor NO esta en diccionario → NO clasificar → registrar DESCONOCIDO con contexto → escalar.

Comportamiento configurable por proceso:
- **BLOQUEAR**: resultado para cliente, regulatorio/legal
- **CONTINUAR CON MARCA**: procesamiento interno, alta frecuencia/bajo impacto
- **ESCALAR INMEDIATO**: regulatorio + urgente

### 2 — Aprobacion Humana

Sistema propone, humano decide: MAPEAR A EXISTENTE / CREAR NUEVO / CREAR ALIAS / DESCARTAR.

Aprobadores por dominio:
| Dominio | Aprobador | Backup |
|---------|-----------|--------|
| Conceptos bancarios | Tesorero | Dir. financiero |
| Cuentas contables | Contador | Dir. financiero |
| Competencias cargo | Hiring manager | RRHH |
| Categorias gasto | Aprobador presupuesto | Gerente |
| Codigos producto | Resp. inventario | Jefe compras |
| Tasas regulatorias | Contador/tributario | Esperar |

### 3 — Propagacion Controlada

- **FORWARD** (default): desde fecha aprobacion, nuevos casos usan nuevo mapeo
- **BACKWARD** (requiere autorizacion): calcular impacto primero
  - SOLO PENDING: reclasificar pendientes (recomendado)
  - TODOS HISTORICOS: incluir entregados (notificar receptores)
  - NO RECLASIFICAR: solo adelante

**Regla de oro**: Nunca modificar silenciosamente resultado ya entregado.

### 4 — Versionado Inmutable

Cada version del diccionario es inmutable. Solo una activa a la vez. Anteriores para audit.
Toda clasificacion registra version del diccionario usada.

Queries de auditoria:
- Con que logica se clasifico este registro en fecha X?
- Que habria pasado con diccionario vN desde el inicio?

## Output: 7 Decisiones de Diseno

1. Que diccionarios existen en el proceso?
2. Comportamiento ante desconocido (por diccionario)?
3. Quien aprueba nuevo conocimiento?
4. Se requiere doble aprobacion?
5. Politica de retroactividad?
6. Que necesita ver el aprobador para decidir?
7. Como se notifica cuando algo cambia externamente?

## Output Files

- `learning-design-{nombre}-{fecha}.md`
- `dictionary-schema-{nombre}-{fecha}.md`
- `approval-flow-{nombre}-{fecha}.md`
- `propagation-policy-{nombre}-{fecha}.md`

## Handoff

- **sdd-design**: 4 mecanismos con parametros especificos
- **sdd-design (LLM)**: Diccionario activo como contexto prompt
- **sdd-verify**: Test unknown detection + versioning reproducibility

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "Las categorias externas raramente cambian" | Bancos lanzan nuevos conceptos transaccionales mensualmente. DIAN actualiza tarifas anualmente. SKUs cambian con cada lanzamiento de producto. "Raramente" significa "no documentado" — siempre cambian, solo no se nota hasta que rompe produccion. |
| "Cuando aparezca una categoria nueva, la manejamos manualmente" | "Manual" significa: clasificacion silenciosa incorrecta hasta que alguien revise → resultados entregados con errores → re-trabajo de auditoria → perdida de confianza del cliente. La deteccion de desconocidos no es opcional. |
| "Si bloqueamos por desconocidos, el proceso para constantemente" | Solo bloqueas en dominios criticos (regulatorio/legal). Para dominios de baja criticidad usas "continuar con marca" — el proceso fluye, los desconocidos quedan registrados para revision en batch. |
| "Sobre-escribir resultados pasados con la nueva clasificacion es lo correcto" | NUNCA modifiques silenciosamente un resultado ya entregado al cliente. Esto destruye la auditabilidad y la confianza. Forward-only por defecto; backward solo con autorizacion explicita y notificacion. |
| "Versionado del diccionario es over-engineering" | Sin versionado no puedes responder: "que logica se uso para clasificar este registro en marzo?" Esa pregunta llega siempre — de la SIC, de la DIAN, de un cliente disputando un cobro. Versionado es requisito de auditoria, no lujo. |
| "Un solo aprobador acelera el flujo" | Un aprobador unico es un punto unico de falla y un riesgo de fraude. Define backups por dominio. Para cambios de alto impacto (tarifas, cuentas contables) requiere doble aprobacion. |

## Red Flags

- Sistema clasifica TODO sin reportar nunca un "DESCONOCIDO" — significa que esta forzando categorias incorrectas
- Diccionarios mutables sin historico de versiones (no se puede reproducir clasificaciones pasadas)
- Cambios al diccionario que se aplican retroactivamente sin autorizacion ni notificacion
- Aprobador unico definido para todos los dominios (sin backups, sin separacion de responsabilidades)
- Aprobaciones que no registran fecha, aprobador, y razon (sin trazabilidad de decisiones)
- "Continuar con marca" usado en dominios regulatorios donde deberia ser "bloquear" o "escalar"
- Logs de produccion sin la version del diccionario usada en cada clasificacion
- Sistema sin canal explicito para que el aprobador vea el contexto de la decision (raw data, frecuencia, impacto)
- Nuevas categorias creadas en produccion sin pasar por el flujo de aprobacion (shadow taxonomies)
- Reclasificaciones backward ejecutadas sin calculo previo de impacto ni notificacion a receptores
- "FORWARD only" interpretado como "no tocar nada del pasado" — incluso datos PENDING no se reclasifican
- Aprobadores fuera de horario laboral bloquean el proceso indefinidamente (sin politica de timeout/escalacion)

## Verification Checklist

- [ ] Cada diccionario externo identificado tiene definido: comportamiento ante desconocido (BLOQUEAR / CONTINUAR_MARCA / ESCALAR)
- [ ] Para cada dominio: aprobador primario definido + aprobador backup + criterios para doble aprobacion
- [ ] Politica de propagacion documentada por dominio (FORWARD default; BACKWARD solo con autorizacion + notificacion)
- [ ] Diccionarios versionados de forma inmutable: una sola version activa, anteriores preservadas para auditoria
- [ ] Cada clasificacion en logs incluye: version del diccionario usada, timestamp, decision tomada
- [ ] Test de auditoria: dado un registro X, se puede reproducir exactamente con que logica fue clasificado en fecha Y
- [ ] Test de unknown detection: registros con categorias no presentes en el diccionario activo se marcan correctamente (no se fuerzan a categoria existente)
- [ ] Aprobador recibe contexto completo: valor desconocido, frecuencia, ejemplos similares, impacto estimado
- [ ] Notificacion automatica al aprobador cuando aparece desconocido (con SLA de respuesta definido)
- [ ] Politica de timeout/escalacion si aprobador no responde en SLA (al backup, no bloqueo indefinido)
- [ ] Reclasificaciones BACKWARD calculan y notifican impacto antes de ejecutar
- [ ] Resultados ya entregados al cliente NUNCA se modifican silenciosamente — siempre con re-emision explicita
- [ ] Output files generados: learning-design, dictionary-schema, approval-flow, propagation-policy
- [ ] Handoff a sdd-design incluye los parametros especificos por dominio (no plantilla generica)
