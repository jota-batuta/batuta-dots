# Quiz — Nivel Uno

Verifica que conoces las herramientas del ecosistema.

---

## Pregunta 1
**Cuantos skills tiene Batuta Dots v15?**

<details>
<summary>Ver respuesta</summary>

43 skills organizados en: 5 pipeline SDD, 6 capa CTO, 10 infraestructura, 13 tecnologias y metodologias, 7 integraciones y plataformas. Se distribuyen en 2 niveles: global (~/.claude/skills/) y proyecto (.claude/skills/).
</details>

---

## Pregunta 2
**Nombra los 5 agentes y su funcion principal.**

<details>
<summary>Ver respuesta</summary>

- **Pipeline Agent**: Coordina el flujo SDD
- **Infra Agent**: Organizacion de archivos, skills, seguridad
- **Backend Agent**: Expertise en APIs, bases de datos, patrones de backend
- **Data Agent**: Pipelines de datos, ETL, integraciones
- **Quality Agent**: Testing, verificacion, calidad de codigo
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
**Que es la Delegacion por Contrato?**

<details>
<summary>Ver respuesta</summary>

El main agent es un GESTOR — no implementa, no investiga directamente, no escribe codigo. Para toda tarea, contrata un agente especializado via el skill `agent-hiring`. NUNCA se crean agentes inline (ad-hoc) — siempre se crea el archivo en `.claude/agents/` primero. Los agentes reportan con: FINDINGS / FAILURES / DECISIONS / GOTCHAS.
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
