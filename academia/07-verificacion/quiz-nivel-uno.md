# Quiz — Nivel Uno

Verifica que conoces las herramientas del ecosistema.

---

## Pregunta 1
**Cuantos skills tiene Batuta Dots v12.2?**

<details>
<summary>Ver respuesta</summary>

33 skills organizados en: 9 pipeline SDD, 6 capa CTO, 5 infraestructura, 3 patrones reutilizables, 10 tecnologias y metodologias.
</details>

---

## Pregunta 2
**Nombra los 3 agentes y su funcion principal.**

<details>
<summary>Ver respuesta</summary>

- **Pipeline Agent**: Coordina el flujo SDD (9 fases)
- **Infra Agent**: Organizacion de archivos, skills, seguridad
- **Observability Agent**: Calidad, registro, sesiones (motor O.R.T.A.)
</details>

---

## Pregunta 3
**Que es la Scope Rule y sus 3 ubicaciones?**

<details>
<summary>Ver respuesta</summary>

"Quien usa esto?" determina donde va:
- 1 feature -> `features/{feature}/{tipo}/`
- 2+ features -> `features/shared/{tipo}/`
- Toda la app -> `core/{tipo}/`
Nunca crear utils/, helpers/, lib/, components/ en la raiz.
</details>

---

## Pregunta 4
**Que son los 6 skills de la capa CTO?**

<details>
<summary>Ver respuesta</summary>

1. process-analyst: mapea variantes de procesos
2. recursion-designer: maneja cambio externo
3. compliance-colombia: regulacion colombiana
4. data-pipeline-design: ETL e integraciones
5. llm-pipeline-design: pipelines de IA
6. worker-scaffold: workers y deploy
</details>

---

## Pregunta 5
**Cuando se activa automaticamente el process-analyst?**

<details>
<summary>Ver respuesta</summary>

Cuando sdd-explore detecta 3+ variantes de caso, excepciones frecuentes, o multiples actores con roles diferentes. No se activa manualmente; el sistema lo sugiere.
</details>

---

## Pregunta 6
**Cuales son los 3 niveles de ejecucion?**

<details>
<summary>Ver respuesta</summary>

- Nivel 1 (Solo): 1 archivo, tarea simple. Costo normal.
- Nivel 2 (Subagente): 2-3 archivos, delegacion. Costo 1.2-1.5x.
- Nivel 3 (Agent Team): 4+ archivos, multi-scope. Costo 3-5x.
</details>

---

## Pregunta 7
**Que hace security-audit?**

<details>
<summary>Ver respuesta</summary>

Checklist de 10 puntos (OWASP), threat model, secrets scan, dependency audit. Seccion especial para IA (prompt injection, PII, cost control). Se activa en sdd-design y sdd-verify.
</details>

---

## Resultado

- **7/7**: Excelente — avanza al Nivel Dos.
- **5-6/7**: Bien — repasa las respuestas incorrectas.
- **< 5/7**: Recomendado repasar [Nivel Uno](../02-nivel-uno/).

---

-> [Quiz Nivel Dos](quiz-nivel-dos.md)
