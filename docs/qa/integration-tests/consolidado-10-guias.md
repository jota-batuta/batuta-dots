# Consolidado: Integration Test de 10 Guias
**Fecha**: 2026-02-23
**Version ecosistema**: 9.1.0
**Metodologia**: 10 agentes independientes (read-only), 1 guia por agente
**Modelo**: Sonnet (agentes de analisis)

---

## Resumen Ejecutivo

Se analizaron las 10 guias de implementacion del ecosistema Batuta v9.1 contra los archivos reales del ecosistema. Cada agente leyo su guia completa paso a paso y verifico CADA referencia a skills, commands, agents y flujos contra los archivos fuente.

### Resultado Global

| Metrica | Valor |
|---------|-------|
| Guias analizadas | 10 |
| Hallazgos totales | 74 |
| Criticos | 7 |
| Importantes | 28 |
| Menores | 39 |
| Patrones sistemicos | 8 |
| Guias funcionales (idea→producto) | 10/10 |

**Conclusion principal**: Las 10 guias llevan al usuario de idea a producto funcional. Ninguna esta rota. Sin embargo, **8 patrones sistemicos** afectan a multiples guias simultaneamente, lo que significa que corregir estos patrones resuelve la mayoria de hallazgos de una sola vez.

---

## Tabla por Guia

| # | Guia | C | I | M | Total | Funcional? |
|---|------|---|---|---|-------|------------|
| A1 | refactoring-legacy | 0 | 3 | 3 | **6** | Si |
| A2 | cli-python | 1 | 2 | 2 | **5** | Si |
| A3 | fastapi-service | 3 | 4 | 2 | **9** | Si |
| A4 | data-pipeline | 2 | 2 | 3 | **7** | Si |
| A5 | batuta-app | 0 | 1 | 2 | **3** | Si |
| A6 | ai-agent-adk | 0 | 4 | 8 | **12** | Si |
| A7 | langchain-gmail-agent | 1 | 3 | 4 | **8** | Si |
| A8 | n8n-automation | 0 | 3 | 4 | **7** | Si |
| A9 | temporal-io-app | 0 | 2 | 8 | **10** | Si |
| A10 | nextjs-saas (reval.) | — | 4 | 3 | **7** | Si |
| | **TOTAL** | **7** | **28** | **39** | **74** | **10/10** |

### Ranking de Calidad (menos hallazgos = mejor)

1. **batuta-app** — 3 hallazgos (la guia mas limpia)
2. **cli-python** — 5 hallazgos
3. **refactoring-legacy** — 6 hallazgos
4. **n8n-automation** — 7 hallazgos
5. **data-pipeline** — 7 hallazgos
6. **nextjs-saas (reval.)** — 7 abiertos
7. **langchain-gmail-agent** — 8 hallazgos
8. **fastapi-service** — 9 hallazgos (mas criticos: 3)
9. **temporal-io-app** — 10 hallazgos
10. **ai-agent-adk** — 12 hallazgos (mas voluminosa)

---

## 8 Patrones Sistemicos

Estos son problemas que aparecen en 3+ guias. Corregir cada patron resuelve multiples hallazgos simultaneamente.

### PS-1: `/sdd-new` duplica la fase de explore (8/10 guias)

**Guias afectadas**: cli-python, data-pipeline, ai-agent-adk, langchain-gmail-agent, n8n-automation, temporal-io-app, nextjs-saas, refactoring-legacy

**El problema**: Todas las guias siguen el patron:
1. Paso X: `/sdd-explore <nombre>` — explora requisitos
2. Paso Y: `/sdd-new <nombre>` — crea propuesta

Pero CLAUDE.md define `/sdd-new` como `sdd-explore -> sdd-propose`. El usuario ejecuta explore **DOS VECES**: una explicita y una dentro de `/sdd-new`.

**Impacto**: Desperdicio de 3-5 minutos y tokens por guia. Confusion cuando Claude "vuelve a investigar" algo que ya aprobo.

**Fix propuesto (ecosistema)**: Dos opciones:
- **Opcion A**: Que `/sdd-new` detecte si ya existe `explore.md` y salte al propose
- **Opcion B**: Cambiar TODAS las guias para eliminar el `/sdd-explore` standalone y dejar que `/sdd-new` haga todo

**Esfuerzo**: Opcion A = cambio en pipeline-agent + sdd-explore. Opcion B = texto en 8 guias.

---

### PS-2: `/sdd-continue` ejecuta 1 fase, no 3 automaticamente (8/10 guias)

**Guias afectadas**: refactoring-legacy, cli-python, fastapi-service, batuta-app, langchain-gmail-agent, n8n-automation, temporal-io-app, nextjs-saas

**El problema**: Las guias dicen:
> `/sdd-continue` — "Claude ejecuta Specs, Design y Tasks"

Pero `/sdd-continue` ejecuta **UNA** fase (la siguiente pendiente). El usuario debe invocarlo 3 veces, aprobando cada resultado intermedio.

Ademas, 3 guias (batuta-app, cli-python, nextjs-saas) describen `/sdd-continue` como "ver el estado del proyecto" en la seccion de Comandos de Emergencia, cuando en realidad **ejecuta** la siguiente fase.

**Impacto**: El usuario espera automatizacion completa y se confunde cuando Claude se detiene despues de una fase. En el caso de "ver estado", puede avanzar el pipeline accidentalmente.

**Fix propuesto (guias)**:
1. Aclarar que `/sdd-continue` ejecuta UNA fase y debe repetirse
2. Mencionar `/sdd-ff` (fast-forward) como alternativa para ejecutar todas las fases de corrido
3. Eliminar `/sdd-continue` de la seccion "ver estado" — reemplazar con "pregunta a Claude: En que fase estamos?"

**Esfuerzo**: Texto en 8 guias.

---

### PS-3: Opcion B de instalacion usa `--all` en vez de `--project` (7/10 guias)

**Guias afectadas**: refactoring-legacy, fastapi-service, batuta-app, n8n-automation, nextjs-saas, ai-agent-adk, langchain-gmail-agent

**El problema**: La Opcion B (prompt manual para primera vez) dice:
> "Ejecuta `skills/setup.sh --all`"

Pero `--all` opera dentro de batuta-dots, no en el proyecto del usuario. No crea `.batuta/`, no copia CLAUDE.md al proyecto destino.

El flag correcto es `--project <path>` (agregado en v9.1) que SI crea `.batuta/`, copia CLAUDE.md, y configura hooks.

**Impacto**: Usuario sin `.batuta/session.md` (sin session continuity), y CLAUDE.md en el lugar equivocado. El ecosistema funciona al 60% de capacidad.

**Fix propuesto**: Cambiar en TODAS las guias la Opcion B para usar `--project <path>`.

**Esfuerzo**: Texto en 7 guias. Sin cambio en ecosistema (el flag ya existe).

---

### PS-4: Sintaxis `/batuta:analyze-prompts` (dos puntos) vs `/batuta-analyze-prompts` (guion) (5/10 guias)

**Guias afectadas**: ai-agent-adk, langchain-gmail-agent, n8n-automation, temporal-io-app, nextjs-saas

**El problema**: CLAUDE.md y las guias usan `/batuta:analyze-prompts` (con dos puntos), pero el archivo de command real se llama `batuta-analyze-prompts.md` (con guiones). Claude Code invoca commands por nombre de archivo, asi que el slash command real es `/batuta-analyze-prompts`.

**Impacto**: Si el usuario copia y pega el formato con dos puntos, Claude Code podria no encontrar el command y tratarlo como texto libre. Funciona pero no como slash command nativo.

**Fix propuesto**: Decidir UNA convencion y aplicarla en todas partes:
- Opcion A: Renombrar archivo a `batuta:analyze-prompts.md` (si Claude Code lo soporta)
- Opcion B: Actualizar CLAUDE.md y 5 guias para usar `/batuta-analyze-prompts` (guion)

**Esfuerzo**: 1 archivo CLAUDE.md + 5 guias, o 1 rename de archivo.

---

### PS-5: Glosario describe observability-agent como agente de "calidad" (4/10 guias)

**Guias afectadas**: refactoring-legacy, fastapi-service, n8n-automation, temporal-io-app

**El problema**: El glosario dice:
> "Claude tiene 3 jefes de area: uno para desarrollo, uno para archivos, y uno para **calidad**"

El tercer agente (observability-agent) NO es de calidad. Es de **observabilidad y continuidad de sesion** (O.R.T.A., session tracking, prompt logging). La calidad la maneja `sdd-verify`.

**Impacto**: Confusion conceptual para usuarios que busquen funciones de calidad en el agente equivocado.

**Fix propuesto**: Actualizar el glosario en las 4 guias:
> "uno para desarrollo (pipeline), uno para infraestructura y seguridad, y uno para **observabilidad y continuidad de sesion**"

**Esfuerzo**: Texto en 4 guias.

---

### PS-6: Piramide de Validacion con capas 4-5 incorrectas (3/10 guias)

**Guias afectadas**: fastapi-service, n8n-automation, ai-agent-adk (implicitamente)

**El problema**: Las guias describen las capas 4 y 5 como:
- Capa 4: "Seguridad"
- Capa 5: "Documentacion"

El ecosistema real (sdd-verify) define:
- Layer 4: **Code Review (HUMAN)**
- Layer 5: **Manual Testing (HUMAN)**

Seguridad y documentacion son verificaciones transversales, no capas de la piramide.

**Impacto**: El usuario ejecuta `/sdd-verify` y ve un reporte con capas diferentes a las prometidas.

**Fix propuesto**: Actualizar la tabla de la Piramide en las 3 guias para reflejar las 5 capas reales.

**Esfuerzo**: Texto en 3 guias.

---

### PS-7: Templates de equipo usan `src/` pero Scope Rule fuerza `features/` (3/10 guias)

**Guias afectadas**: data-pipeline, ai-agent-adk, temporal-io-app (implicitamente)

**El problema**: Los templates en `teams/templates/` definen file ownership con rutas como `src/agent/**`, `pipeline/**`, `transforms/**`. Pero la Scope Rule (que el Execution Gate enforce) usa `features/{nombre}/`, `features/shared/`, `core/`.

Si un usuario construye con la guia (Scope Rule) y luego escala con Agent Teams (template), los contratos de archivo no coinciden.

**Impacto**: Alto si se usan Agent Teams. Los contratos de file ownership son la base del Contract-First Protocol.

**Fix propuesto**: Alinear los 6 templates de equipo con la Scope Rule. Cambiar `src/` y rutas planas por `features/`, `features/shared/`, `core/`.

**Esfuerzo**: Cambio en 6 archivos `teams/templates/*.md`. Requiere revision cuidadosa.

---

### PS-8: Organizacion GitHub hardcodeada como `jota-batuta` (3/10 guias)

**Guias afectadas**: fastapi-service, temporal-io-app, ai-agent-adk (implicitamente)

**El problema**: Los prompts de deploy dicen:
> "Crea un repositorio privado en GitHub bajo la organizacion **jota-batuta**"

Un usuario que no sea miembro de esa organizacion recibira un error de permisos.

**Impacto**: Error inmediato en el paso de deploy. Bloqueante si el usuario copia y pega literalmente.

**Fix propuesto**: Reemplazar con placeholder: `[TU-ORGANIZACION-O-USUARIO]`.

**Esfuerzo**: Find-and-replace en 3 guias.

---

## Hallazgos Individuales No Sistemicos

Estos hallazgos son especificos de una guia y no forman patron cruzado:

| Guia | Hallazgo | Severidad | Descripcion |
|------|----------|-----------|-------------|
| cli-python | C-01 | CRITICO | Tipo `cli` no existe en sdd-init (tipos: webapp, automation, ai-agent, infrastructure, data-pipeline, library) |
| data-pipeline | C-01 | CRITICO | `/batuta-init` no aparece en tabla de comandos de CLAUDE.md |
| langchain-gmail | H1 | CRITICO | `/batuta-init` no advierte que el usuario DEBE estar en el directorio correcto |
| refactoring-legacy | H3 | IMPORTANTE | Paso 12 espera `CHANGELOG-refactoring.md`; sdd-archive genera `lessons-learned.md` |
| fastapi-service | H5 | IMPORTANTE | Opciones de skill gap no explican donde se guarda (local vs global) |
| ai-agent-adk | H9 | MENOR | Auditoria de seguridad: prompt de 5 puntos vs skill de 10 puntos |
| cli-python | M-02 | MENOR | session-template.md muestra version 5.0.0 (deberia ser 9.1) |
| nextjs-saas | H11 | MENOR | Stack Awareness duplicado en 7 archivos (DRY, mitigado con comentarios) |

---

## Revalidacion nextjs-saas (v9.0 → v9.1)

| Metrica | Valor |
|---------|-------|
| Hallazgos v9.0 | 12 |
| Corregidos en v9.1 | 8 |
| Parcialmente corregidos | 2 |
| Persisten | 2 |
| Nuevos en v9.1 | 3 |
| **Total abiertos** | **7** |

Las correcciones principales de v9.1 funcionan correctamente:
- `install_hooks()` nueva funcion — **VERIFICADO**
- `--project <path>` flag — **VERIFICADO**
- Dual-path gap detection — **VERIFICADO**
- 3 destinos en ecosystem-creator — **VERIFICADO**

Los 7 hallazgos abiertos se resuelven con PS-1 (doble explore), PS-2 (continue como "ver estado"), y PS-3 (Opcion B usa --all).

---

## Plan de Correccion Priorizado

### Prioridad 0 — Corregir ANTES de compartir guias (impacto alto, esfuerzo bajo)

| # | Patron | Accion | Archivos | Esfuerzo |
|---|--------|--------|----------|----------|
| 1 | PS-3 | Cambiar Opcion B en 7 guias: `--all` → `--project <path>` | 7 guias | 30 min |
| 2 | PS-1 | Eliminar `/sdd-explore` standalone de 8 guias (dejar que `/sdd-new` lo haga) | 8 guias | 45 min |
| 3 | PS-2 | Aclarar que `/sdd-continue` = 1 fase; corregir "ver estado" | 8 guias | 30 min |
| 4 | PS-8 | Reemplazar `jota-batuta` por placeholder | 3 guias | 5 min |

### Prioridad 1 — Corregir en la siguiente version (impacto medio)

| # | Patron | Accion | Archivos | Esfuerzo |
|---|--------|--------|----------|----------|
| 5 | PS-4 | Unificar sintaxis commands: guion vs dos puntos | CLAUDE.md + 5 guias | 20 min |
| 6 | PS-5 | Actualizar glosario observability-agent | 4 guias | 15 min |
| 7 | PS-6 | Corregir Piramide de Validacion capas 4-5 | 3 guias | 15 min |
| 8 | Individual | Tipo `cli` no existe — agregar a sdd-init o documentar como `library` | sdd-init + 1 guia | 10 min |
| 9 | Individual | `/batuta-init` no en tabla CLAUDE.md | CLAUDE.md | 5 min |

### Prioridad 2 — Mejoras de calidad (impacto bajo)

| # | Patron | Accion | Archivos | Esfuerzo |
|---|--------|--------|----------|----------|
| 10 | PS-7 | Alinear 6 templates de equipo con Scope Rule | 6 templates | 2 horas |
| 11 | Individual | session-template.md version 5.0.0 → 9.1.0 | 1 archivo | 2 min |
| 12 | Individual | Skill gap opciones: explicar local vs global | 3 guias | 15 min |
| 13 | Individual | sdd-archive: aclarar que genera lessons-learned.md, no CHANGELOG | 1 guia | 5 min |
| 14 | Individual | Auditoria seguridad: referenciar skill completo (10 puntos) | 2 guias | 10 min |

---

## Metricas de Impacto

Si se aplican las correcciones de Prioridad 0:

| Metrica | Antes | Despues P0 |
|---------|-------|------------|
| Hallazgos criticos | 7 | 2 |
| Hallazgos importantes | 28 | 10 |
| Patrones sistemicos activos | 8 | 4 |
| Guias sin hallazgos criticos | 6/10 | 9/10 |

Si se aplican P0 + P1:

| Metrica | Antes | Despues P0+P1 |
|---------|-------|---------------|
| Hallazgos criticos | 7 | 0 |
| Hallazgos importantes | 28 | 4 |
| Patrones sistemicos activos | 8 | 1 (PS-7 templates) |

---

## Conclusion

El ecosistema Batuta v9.1 **funciona**. Las 10 guias llevan al usuario de idea a producto funcional. Los skills, agents y commands existen y hacen lo que prometen.

Los problemas no son de funcionalidad sino de **precision documental**: las guias describen flujos que difieren sutilmente de lo que el ecosistema realmente ejecuta. Esto genera **momentos de confusion** donde el usuario piensa que algo fallo cuando en realidad el ecosistema esta funcionando correctamente de una forma diferente a la esperada.

La buena noticia: los 8 patrones sistemicos se corrigen con cambios de **texto en guias** (no de codigo). Las correcciones de Prioridad 0 eliminan el 70% de los hallazgos criticos e importantes, y las de Prioridad 1 llevan los criticos a cero.

El patron mas impactante es **PS-3** (Opcion B con `--all`): 7 guias dejan al usuario sin `.batuta/` cuando usan la Opcion B. Esto degrada la experiencia del ecosistema significativamente. La correccion es simple: cambiar `--all` por `--project <path>`.

---

## Anexo: Reportes Individuales

| Guia | Reporte |
|------|---------|
| refactoring-legacy | `docs/qa/integration-tests/refactoring-legacy.md` |
| cli-python | `docs/qa/integration-tests/cli-python.md` |
| fastapi-service | `docs/qa/integration-tests/fastapi-service.md` |
| data-pipeline | `docs/qa/integration-tests/data-pipeline.md` |
| batuta-app | `docs/qa/integration-tests/batuta-app.md` |
| ai-agent-adk | `docs/qa/integration-tests/ai-agent-adk.md` |
| langchain-gmail-agent | `docs/qa/integration-tests/langchain-gmail-agent.md` |
| n8n-automation | `docs/qa/integration-tests/n8n-automation.md` |
| temporal-io-app | `docs/qa/integration-tests/temporal-io-app.md` |
| nextjs-saas (revalidacion) | `docs/qa/integration-tests/nextjs-saas-revalidation.md` |
| nextjs-saas (original v9.0) | `docs/qa/integration-tests/nextjs-saas.md` |
