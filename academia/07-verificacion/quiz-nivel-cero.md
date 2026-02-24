# Quiz — Nivel Cero

Verifica que entendiste los conceptos basicos. Responde mentalmente cada pregunta antes de ver la respuesta.

---

## Pregunta 1
**Cual es el primer comando que ejecutas en un proyecto nuevo?**

<details>
<summary>Ver respuesta</summary>

`/sdd-init` — Inicializa la estructura de documentacion SDD y detecta el tipo de proyecto.
</details>

---

## Pregunta 2
**Cuantas fases tiene el pipeline SDD?**

<details>
<summary>Ver respuesta</summary>

9 fases: init, explore, propose, spec, design, tasks, apply, verify, archive.
</details>

---

## Pregunta 3
**Que hace el comando /sdd-new?**

<details>
<summary>Ver respuesta</summary>

Ejecuta explore + propose automaticamente. Es el punto de inicio para construir algo nuevo.
</details>

---

## Pregunta 4
**Que es el Execution Gate?**

<details>
<summary>Ver respuesta</summary>

Un hook que se ejecuta antes de escribir cualquier archivo. Verifica que el cambio fue aprobado. Tiene modo LIGHT (1 linea) y FULL (plan completo).
</details>

---

## Pregunta 5
**Que pasa si Gate G0.5 tiene items sin marcar?**

<details>
<summary>Ver respuesta</summary>

No avanzas a propose. Vuelves a explore para completar lo que falta. G0.5 verifica que entendemos el problema completamente.
</details>

---

## Pregunta 6
**Que comando usas para avanzar rapido por las fases de planificacion?**

<details>
<summary>Ver respuesta</summary>

`/sdd-ff` — Fast-forward ejecuta propose + spec + design + tasks en secuencia.
</details>

---

## Pregunta 7
**Donde se guardan los artefactos de un cambio?**

<details>
<summary>Ver respuesta</summary>

En `openspec/changes/{nombre-del-cambio}/`. Cada cambio tiene su carpeta con explore.md, proposal.md, spec.md, design.md, y tasks.md.
</details>

---

## Pregunta 8
**Para que sirve /sdd-verify?**

<details>
<summary>Ver respuesta</summary>

Ejecuta la Piramide de Validacion AI: linting (L1), tests unitarios (L2), tests integracion (L3), y prepara items para revision humana (L4-L5).
</details>

---

## Resultado

- **8/8**: Excelente — dominas los fundamentos. Avanza al Nivel Uno.
- **6-7/8**: Bien — repasa las respuestas incorrectas en [Nivel Cero](../01-nivel-cero/).
- **< 6/8**: Recomendado repasar el modulo completo antes de avanzar.

---

-> [Quiz Nivel Uno](quiz-nivel-uno.md)
