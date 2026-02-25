# El Pipeline SDD

SDD significa **Spec-Driven Development** — Desarrollo Dirigido por Especificaciones. Es la forma en que Batuta Dots organiza el trabajo: primero pensar, luego documentar, y al final construir.

---

## La analogia de la cocina

Imagina que vas a preparar un banquete para 50 personas.

**Sin proceso** (como programar sin SDD):
- Abres la nevera y empiezas a cocinar lo primero que ves
- A mitad de camino te das cuenta que no tienes suficientes ingredientes
- Los platos no combinan entre si
- Algunos invitados tienen alergias que no consideraste

**Con proceso** (como programar con SDD):
1. **Investiga**: Cuantos invitados? Alergias? Preferencias?
2. **Propone menu**: 3 opciones con costos y tiempos
3. **Especifica recetas**: Ingredientes exactos, cantidades, tiempos
4. **Disena la cocina**: Que cocinero hace que, en que orden
5. **Divide tareas**: "Tu: entradas. Tu: plato fuerte. Tu: postre."
6. **Cocina**: Siguiendo las recetas
7. **Prueba**: Cada plato antes de servir
8. **Documenta**: Las recetas que funcionaron para el proximo banquete

---

## Las 9 fases (maquina de estados)

El camino feliz (happy path) es lineal:

```
init → explore → [G0.5] → propose → [G1] → spec → design → tasks → apply → verify → [G2] → archive
```

Pero la realidad no siempre es lineal. A veces descubres en la fase de implementacion que falta algo en el spec, o que el diseno no soporta un caso. Por eso el pipeline es una **maquina de estados** — puedes retroceder a la fase que necesites corregir y luego re-avanzar:

### Fase 1: Init (Preparar la cocina)

**Comando**: `/sdd-init`
**Que hace**: Prepara el proyecto para trabajar con SDD. Detecta que tipo de proyecto es, que tecnologias usa, y crea la estructura de documentacion.
**Resultado**: Carpeta `openspec/` con configuracion.
**Analogia**: Equipar la cocina con las herramientas correctas antes de cocinar.

### Fase 2: Explore (Investigar el banquete)

**Comando**: `/sdd-explore <tema>` o `/sdd-new <nombre>`
**Que hace**: Investiga el problema. Lee codigo existente, busca patrones, compara opciones, detecta si necesitas especialistas.
**Resultado**: Reporte de exploracion con opciones y recomendaciones.
**Analogia**: Hablar con los invitados para entender sus preferencias y restricciones.

### Gate G0.5: Discovery Complete

**Antes de proponer, verificamos**: Identificamos todos los tipos de caso? Documentamos excepciones? Mapeamos dependencias externas? Listamos participantes? Cubrimos todas las ramas?

### Fase 3: Propose (Proponer el menu)

**Comando**: Se ejecuta con `/sdd-new` o `/sdd-continue`
**Que hace**: Presenta una propuesta formal con alcance, costos, beneficios, y un resumen en lenguaje simple para stakeholders no-tecnicos.
**Resultado**: Documento de propuesta (`proposal.md`).
**Analogia**: Presentar 3 opciones de menu con presupuesto y tiempo.

### Gate G1: Solution Worth Building

**Antes de disenar, verificamos**: El problema justifica el esfuerzo? El scope esta acotado? Los stakeholders estan informados? Los riesgos son aceptables?

### Fase 4: Spec (Escribir las recetas)

**Comando**: `/sdd-ff` o `/sdd-continue`
**Que hace**: Escribe los requisitos exactos en formato Given/When/Then. Cada escenario describe un comportamiento esperado.
**Resultado**: Especificacion (`spec.md`).
**Analogia**: Las recetas con ingredientes, cantidades, y pasos exactos.

### Fase 5: Design (Disenar la cocina)

**Comando**: `/sdd-ff` o `/sdd-continue`
**Que hace**: Define la arquitectura tecnica — que componentes, como se comunican, que decisiones se tomaron y por que. Si el proyecto toca LLM, datos, o infra, agrega secciones especiales.
**Resultado**: Documento de diseno (`design.md`).
**Analogia**: El layout de la cocina — que cocinero trabaja en que estacion.

> **Nota**: Spec y Design pueden ejecutarse en paralelo.

### Fase 6: Tasks (Dividir el trabajo)

**Comando**: `/sdd-ff` o `/sdd-continue`
**Que hace**: Divide el diseno en tareas concretas, ordenadas por dependencia, con estimaciones.
**Resultado**: Lista de tareas (`tasks.md`).
**Analogia**: "Tu: corta verduras (20 min). Tu: prepara la salsa (15 min)."

### Fase 7: Apply (Cocinar)

**Comando**: `/sdd-apply`
**Que hace**: Implementa el codigo siguiendo las tareas. Cada archivo pasa por el Execution Gate. El codigo se documenta con el estandar de documentacion (docstrings, comentarios WHY).
**Resultado**: Codigo funcionando.
**Analogia**: Cocinar siguiendo las recetas, plato por plato.

### Fase 8: Verify (Probar cada plato)

**Comando**: `/sdd-verify`
**Que hace**: Ejecuta la Piramide de Validacion AI — 5 capas desde linting automatico hasta pruebas manuales.
**Resultado**: Reporte de verificacion.
**Analogia**: Probar cada plato: sabor, presentacion, temperatura.

### Gate G2: Ready for Production

**Antes de archivar, verificamos**: La piramide de validacion esta completa? La documentacion esta actualizada? Hay plan de rollback? No hay warnings criticos?

### Fase 9: Archive (Documentar las recetas exitosas)

**Comando**: `/sdd-archive`
**Que hace**: Sincroniza los cambios con las specs principales, documenta lecciones aprendidas, mueve artefactos al archivo.
**Resultado**: Cambio archivado, lecciones documentadas.
**Analogia**: Guardar las recetas que funcionaron para el proximo banquete.

---

## Flujo visual (maquina de estados)

```
[Tu idea]
    |
    v
  INIT ───→ Prepara proyecto
    |
    v
  EXPLORE ──→ Investiga problema ◄──────────────┐
    |                                            │
   G0.5 ───→ Entendemos bien? (si/no)           │
    |                                            │
    v                                            │
  PROPOSE ──→ Propone solucion ◄─────────┐      │
    |                                    │      │
   G1 ─────→ Vale la pena? (si/no)      │      │
    |                                    │      │
    v                                    │      │
  SPEC ←──→ DESIGN (paralelo) ◄────┐    │      │
    |                               │    │      │
    v                               │    │      │
  TASKS ───→ Divide trabajo         │    │      │
    |                               │    │      │
    v                               │    │      │
  APPLY ───→ Escribe codigo ────────┴────┴──────┘
    |            ↑                backtrack triggers
    v            │
  VERIFY ──→ Prueba todo ───→ issues? → APPLY (fix) o DESIGN (re-pensar)
    |
   G2 ─────→ Listo para produccion? (si/no)
    |
    v
  ARCHIVE ──→ Documenta y cierra
    |
    v
[Software funcionando + documentado]
```

### Retrocesos (backtracks)

A veces en la cocina descubres que te falta un ingrediente que no estaba en la receta. En vez de empezar de cero, vuelves a corregir la receta y continuas desde ahi.

| Estas en... | Descubres que... | Vuelves a... | Ejemplo |
|-------------|------------------|-------------|---------|
| APPLY | Falta un caso en el spec | SPEC | "Necesitamos manejar mensajes de audio" |
| APPLY | La arquitectura no soporta algo | DESIGN | "pymssql no soporta async" |
| APPLY | El problema es diferente | EXPLORE | "Hay un segundo servidor que no mapeamos" |
| DESIGN | El alcance cambio | PROPOSE | "El cliente quiere incluir la Planta" |
| VERIFY | Tests revelan fallo de diseno | DESIGN | "El retry no maneja desconexiones de VPN" |
| VERIFY | Bug puntual | APPLY | "El query tiene un typo en el JOIN" |

Los artefactos no se borran — se actualizan in-place. Git guarda el historial. Y cada retroceso se registra en `backtrack-log.md` para trazabilidad.

---

## Auto-routing: conversacion natural

No necesitas memorizar slash commands. Batuta detecta automaticamente que necesitas y ejecuta la fase correcta:

| Tu dices... | Batuta hace... |
|------------|----------------|
| "Tengo un problema de inventarios negativos" | Detecta: problema nuevo → explora → propone solucion |
| "El boton de login no funciona" | Detecta: bug puntual → fix directo (sin SDD) |
| "Donde quedamos?" | Detecta: continuar → busca la fase actual y avanza |
| "Esto no funciona como pense, falta manejar audios" | Detecta: backtrack → ajusta spec + re-avanza |
| "Que es SDD?" | Detecta: pregunta → responde directamente |

El flujo natural es:
1. Tu describes el problema
2. Batuta investiga y te presenta una propuesta
3. Tu apruebas (o ajustas)
4. Batuta disena, planifica e implementa
5. Tu revisas el resultado

**Los slash commands siguen existiendo** como override manual si quieres controlar cada paso directamente.

---

## Atajos utiles (override manual)

| Quieres... | Usa | Que hace |
|-----------|-----|---------|
| Empezar algo nuevo | `/sdd-new nombre` | explore + propose |
| Avanzar rapido | `/sdd-ff` | propose + spec + design + tasks |
| Continuar donde quedaste | `/sdd-continue` | Detecta fase actual y avanza |
| Solo investigar | `/sdd-explore tema` | Solo explore, sin crear cambio |

---

→ [Los gates](los-gates.md) — Tus checkpoints de calidad
