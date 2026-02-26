# Quiz — Nivel Dos

Verifica que dominas los flujos avanzados.

---

## Pregunta 1
**Cual es la "regla de oro" de la Piramide de Validacion?**

<details>
<summary>Ver respuesta</summary>

Base rota = no hay revision humana. Si la Capa 1 (linting/tipos/build) falla, no tiene sentido hacer revision de codigo (L4) o pruebas manuales (L5).
</details>

---

## Pregunta 2
**Nombra 3 formas de usar /sdd-explore sin construir nada.**

<details>
<summary>Ver respuesta</summary>

1. Validar una idea ("Deberiamos migrar a GraphQL?")
2. Comparar opciones tecnicas ("Temporal vs Celery")
3. Investigar antes de una reunion ("Impacto de agregar multi-tenancy")
4. Entender codigo existente ("Como funciona el auth actual?")
5. Detectar riesgos ("Riesgos en manejo de datos personales?")
(Cualquier 3 de estas son correctas)
</details>

---

## Pregunta 3
**Que significa O.R.T.A.?**

<details>
<summary>Ver respuesta</summary>

- **O**bservabilidad: Registrar acciones
- **R**epetibilidad: Mismo input = mismo resultado
- **T**razabilidad: Cada decision rastreable
- **A**uto-supervision: Detectar problemas temprano
</details>

---

## Pregunta 4
**Cuales son los 4 mecanismos del recursion-designer?**

<details>
<summary>Ver respuesta</summary>

1. Deteccion de desconocidos (valor nuevo -> no clasificar, escalar)
2. Aprobacion humana (sistema propone, humano decide)
3. Propagacion controlada (forward por defecto, backward con autorizacion)
4. Versionado inmutable (cada version del diccionario es permanente)
</details>

---

## Pregunta 5
**Nombra los 6 hooks de Batuta y cuando se activan.**

<details>
<summary>Ver respuesta</summary>

1. **SessionStart**: Al abrir Claude Code (restaura contexto)
2. **PreToolUse**: Antes de escribir archivo (Execution Gate)
3. **Stop**: Al cerrar sesion (guarda estado)
4. **TeammateIdle**: Cuando teammate termina (logging O.R.T.A.)
5. **TaskCompleted**: Cuando tarea se completa (quality gate)
</details>

---

## Pregunta 6
**Que es el Contract-First Protocol?**

<details>
<summary>Ver respuesta</summary>

Regla de Agent Teams: antes de crear cualquier teammate, se define su contrato:
- Que recibe (input)
- Que produce (output)
- Que archivos toca (ownership exclusivo)
Cada archivo pertenece a exactamente 1 teammate.
</details>

---

## Resultado

- **6/6**: Excelente — avanza al Nivel Tres.
- **4-5/6**: Bien — repasa los temas flojos.
- **< 4/6**: Recomendado repasar [Nivel Dos](../03-nivel-dos/).

---

-> [Quiz Nivel Tres](quiz-nivel-tres.md)
