# El Pipeline SDD

SDD significa **Spec-Driven Development** — Desarrollo Dirigido por Especificaciones. Es la forma en que Batuta Dots organiza el trabajo: primero investigar, luego (opcionalmente) disenar, y al final construir y verificar.

---

## La analogia de la cocina

Imagina que vas a preparar un banquete para 50 personas.

**Sin proceso** (como programar sin SDD):
- Abres la nevera y empiezas a cocinar lo primero que ves
- A mitad de camino te das cuenta que no tienes suficientes ingredientes
- Los platos no combinan entre si
- Algunos invitados tienen alergias que no consideraste

**Con proceso** (como programar con SDD):

Para una cena rapida (modo **SPRINT**):
1. **Investiga**: Que quieren comer? Hay alergias? (siempre obligatorio)
2. **Cocina**: Siguiendo lo investigado
3. **Prueba**: Cada plato antes de servir

Para un banquete de 50 personas (modo **COMPLETO**):
1. **Investiga**: Cuantos invitados? Alergias? Preferencias?
2. **Explora**: Que cocinas disponemos? Cuantos cocineros?
3. **Disena el menu**: Que cocinero hace que, en que orden. **Aprobacion del cliente antes de cocinar.**
4. **Cocina**: Siguiendo el diseño aprobado
5. **Prueba**: Cada plato antes de servir

---

## Los 2 modos del pipeline

En v15, Batuta simplifica drasticamente el pipeline. En vez de 9 fases obligatorias con 8 gates, ahora tienes **2 modos** que se adaptan a la complejidad de tu tarea:

```
SPRINT (default):  Research → Apply → Verify         (0 gates)
COMPLETO (via PRD): Research → Explore → Design[STOP] → Apply → Verify  (1 gate)
```

### Por que el cambio?

Las 9 fases anteriores (init → explore → propose → spec → design → tasks → apply → verify → archive) eran como usar un contrato de obra para colgar un cuadro. La mayoria de tareas no necesitan 5 artefactos de planificacion separados (explore, proposal, spec, design, tasks). En v15, esos 5 artefactos se consolidan en un **PRD** (Product Requirements Document) unico cuando la tarea lo amerita.

---

## Modo SPRINT (el default — 0 gates)

Para la mayoria de tareas del dia a dia. No tiene gates formales, pero research es **obligatorio**.

### Fase 1: Research (Investigar — NO NEGOCIABLE)

**Que hace**: Antes de tocar una sola linea de codigo, Batuta investiga. Siempre. Sin excepciones. Lanza subagentes en paralelo que buscan en: (1) Notion KB (ya resolvimos algo similar?), (2) skills relevantes, (3) documentacion oficial via web, (4) busqueda web general.
**Resultado**: Conocimiento verificado y actualizado.
**Analogia**: Antes de cocinar, verificas que los ingredientes estan frescos y la receta es correcta.

> **Esto es lo mas importante de v15**: No existe tarea tan trivial que justifique saltar research. Los frameworks cambian cada dia. Conocimiento estatico es conocimiento peligroso.

### Fase 2: Apply (Construir)

**Comando**: `/sdd-apply`
**Que hace**: El main agent contrata agentes especializados que implementan con los skills verificados durante research. Cada agente reporta sus hallazgos (FINDINGS / FAILURES / DECISIONS / GOTCHAS).
**Resultado**: Codigo funcionando, documentado.
**Analogia**: Cocinar con ingredientes frescos y receta verificada.

### Fase 3: Verify (Verificar)

**Comando**: `/sdd-verify`
**Que hace**: Ejecuta la Piramide de Validacion AI — linting, tests, revision de codigo.
**Resultado**: Reporte de verificacion.
**Analogia**: Probar cada plato: sabor, presentacion, temperatura.

---

## Modo COMPLETO (via PRD — 1 gate)

Para proyectos complejos donde el CTO escribe un PRD (Product Requirements Document) en Notion. Batuta lo lee via MCP.

### Fase 1: Research (Investigar — NO NEGOCIABLE)

Identico al modo SPRINT. Research es obligatorio en AMBOS modos.

### Fase 2: Explore (Investigar en profundidad)

**Comando**: `/sdd-explore <tema>` o `/sdd-new <nombre>`
**Que hace**: Lanza subagentes en paralelo para explorar el problema desde multiples angulos. Investigan el codebase, buscan patrones, comparan opciones, detectan si necesitas especialistas.
**Resultado**: Reporte de exploracion con opciones y recomendaciones.
**Analogia**: Hablar con cada invitado para entender sus preferencias y restricciones.

### Fase 3: Design (Disenar — USER STOP)

**Que hace**: Consolida todo en un PRD unico (reemplaza los 5 artefactos anteriores: explore, proposal, spec, design, tasks). Define arquitectura, decisiones, y plan de implementacion.
**Resultado**: PRD aprobado.
**Analogia**: Presentar el menu completo al cliente para aprobacion.

> **Design Approval** — El unico gate. El usuario DEBE aprobar el diseno explicitamente antes de que Batuta empiece a construir. Sin aprobacion, no hay implementacion.

### Fase 4: Apply (Construir)

**Comando**: `/sdd-apply`
**Que hace**: Agentes contratados implementan siguiendo el PRD aprobado.
**Resultado**: Codigo funcionando, documentado.
**Analogia**: Cocinar siguiendo el menu aprobado por el cliente.

### Fase 5: Verify (Verificar)

**Comando**: `/sdd-verify`
**Que hace**: Ejecuta la Piramide de Validacion AI.
**Resultado**: Reporte de verificacion.
**Analogia**: Probar cada plato antes de servir.

---

## Flujo visual

### Modo SPRINT (default)
```
[Tu idea / tarea]
    |
    v
  RESEARCH ──→ Investigar (Notion KB → skills → web)
    |             5 subagentes en paralelo = minutos
    v
  APPLY ─────→ Agentes contratados implementan
    |             ↑
    v             │ bug? → fix directo
  VERIFY ────→ Piramide de Validacion
    |
    v
[Codigo funcionando + session.md actualizado]
```

### Modo COMPLETO (via PRD)
```
[PRD del CTO en Notion]
    |
    v
  RESEARCH ──→ Investigar (obligatorio, igual que SPRINT)
    |
    v
  EXPLORE ───→ Subagentes exploran en profundidad
    |
    v
  DESIGN ────→ Consolida en PRD
    |
    ▼
  ══════════════════════════════
  DESIGN APPROVAL (USER STOP)
  "Apruebas este diseno?"
  ══════════════════════════════
    |
    v
  APPLY ─────→ Agentes implementan segun PRD
    |
    v
  VERIFY ────→ Piramide de Validacion
    |
    v
[Software funcionando + PRD como documentacion]
```

### Retrocesos (backtracks)

A veces durante la implementacion descubres que falta algo. En v15, los retrocesos son mas simples porque hay menos fases:

| Estas en... | Descubres que... | Vuelves a... | Ejemplo |
|-------------|------------------|-------------|---------|
| APPLY | Falta investigar algo | RESEARCH | "El framework cambio su API, necesito verificar" |
| APPLY | El diseno no soporta algo | DESIGN (modo COMPLETO) | "pymssql no soporta async" |
| VERIFY | Tests revelan fallo | APPLY | "El query tiene un typo en el JOIN" |
| VERIFY | Fallo de diseno profundo | DESIGN (modo COMPLETO) | "El retry no maneja desconexiones" |

session.md se actualiza en CADA interaccion. CHECKPOINT.md captura el estado exacto para recuperacion.

---

## Auto-routing: conversacion natural

No necesitas memorizar slash commands. Batuta detecta automaticamente que necesitas y ejecuta la fase correcta:

| Tu dices... | Batuta hace... |
|------------|----------------|
| "Tengo un problema de inventarios negativos" | Detecta: problema nuevo → SPRINT: research → apply → verify |
| "El boton de login no funciona" | Detecta: bug puntual → research rapido → fix directo |
| "Donde quedamos?" | Lee session.md → retoma desde el ultimo estado |
| "Esto necesita un PRD completo" | Detecta: modo COMPLETO → research → explore → design [USER STOP] → apply → verify |
| "Que es SDD?" | Detecta: pregunta → responde directamente |

El flujo natural es:
1. Tu describes el problema
2. Batuta investiga (siempre, sin excepcion)
3. Batuta implementa (modo SPRINT) o te presenta un diseno para aprobacion (modo COMPLETO)
4. Batuta verifica
5. Tu revisas el resultado

**Los slash commands siguen existiendo** como override manual si quieres controlar cada paso directamente.

---

## Atajos utiles (override manual)

| Quieres... | Usa | Que hace |
|-----------|-----|---------|
| Empezar algo nuevo | `/sdd-new nombre` | explore + design |
| Continuar donde quedaste | `/sdd-continue` | Lee session.md y avanza |
| Solo investigar | `/sdd-explore tema` | Solo explore, sin crear cambio |
| Implementar | `/sdd-apply` | Implementar desde PRD/design |
| Verificar | `/sdd-verify` | Piramide de Validacion |

---

→ [Los gates](los-gates.md) — Design Approval: tu unico checkpoint de calidad
