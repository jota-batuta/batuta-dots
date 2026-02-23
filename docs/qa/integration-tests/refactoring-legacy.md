# Integration Test: Guia Refactoring Legacy

## Metadata

- **Fecha**: 2026-02-23
- **Guia**: `docs/guides/guia-refactoring-legacy.md`
- **Version ecosistema**: v9.1
- **Archivos verificados**:
  - `BatutaClaude/commands/batuta-init.md`
  - `BatutaClaude/commands/batuta-analyze-prompts.md`
  - `BatutaClaude/agents/pipeline-agent.md`
  - `BatutaClaude/skills/sdd-explore/SKILL.md`
  - `BatutaClaude/skills/sdd-propose/SKILL.md`
  - `BatutaClaude/skills/sdd-apply/SKILL.md`
  - `BatutaClaude/skills/sdd-verify/SKILL.md`
  - `BatutaClaude/skills/sdd-archive/SKILL.md`
  - `BatutaClaude/skills/sdd-init/SKILL.md`
  - `BatutaClaude/skills/sdd-spec/SKILL.md`
  - `BatutaClaude/skills/sdd-tasks/SKILL.md`
  - `BatutaClaude/skills/scope-rule/SKILL.md`
  - `BatutaClaude/CLAUDE.md` (routing y comandos)
  - `E:\BATUTA PROJECTS\test-guias\ecosystem-snapshot.md`

---

## Resumen Ejecutivo

La guia de refactoring legacy es solida en su estructura pedagogica y cubre correctamente el flujo principal del ecosistema Batuta. Se verificaron todos los skills, agents y commands referenciados — todos existen y funcionan segun lo documentado. Sin embargo, se encontraron cuatro discrepancias reales: la Opcion B del Paso 2 usa `--all` con un bug conocido en lugar de los flags seguros `--sync` y `--hooks`; el Paso 6 promete avance automatico entre fases SDD cuando el pipeline-agent requiere confirmacion del usuario entre cada fase; el Paso 12 instruye al usuario a esperar un archivo `CHANGELOG-refactoring.md` en la raiz del proyecto cuando el skill `sdd-archive` crea `lessons-learned.md` dentro del folder archivado; y el glosario describe al observability-agent como agente de "calidad" cuando su responsabilidad real es continuidad de sesion y observabilidad, no aseguramiento de calidad. El journey idea-producto funciona correctamente cuando se usa la Opcion A del Paso 2 y se comprende que el pipeline siempre pide confirmacion entre fases.

---

## Hallazgos

### CRITICOS

Ninguno. No se encontraron discrepancias que rompan el flujo completo de la guia.

---

### IMPORTANTES

#### H1 — Paso 2 Opcion B: flag `--all` tiene bug conocido

**Donde**: Paso 2, Opcion B, linea 192-196 de la guia.

**Que dice la guia**:
```
Ejecuta el script skills/setup.sh --all para copiar CLAUDE.md, sincronizar skills e instalar hooks
```

**Que dice el ecosistema real**: El comando `batuta-init.md` usa dos flags separados:
```bash
bash "$BATUTA_DOTS_PATH/skills/setup.sh" --sync
bash "$BATUTA_DOTS_PATH/skills/setup.sh" --hooks
```
El ecosystem-snapshot.md documenta explicitamente: "`setup.sh --all` ejecuta DOBLE (output duplicado) — posible bug" y "Exit code 1 a pesar de que todo se instalo correctamente".

**Impacto**: Un usuario que sigue la Opcion B del Paso 2 recibe un exit code 1 que parece un error fatal, y ve output duplicado que genera confusion sobre si la instalacion funciono. Puede interrumpir el flujo del refactoring antes de comenzar.

**Fix propuesto**: Reemplazar en la Opcion B la instruccion de `--all` por los dos comandos separados `--sync` y `--hooks`, que es exactamente lo que hace `batuta-init.md`. Agregar nota: "Si el comando muestra exit code 1 pero los archivos se crearon correctamente, la instalacion fue exitosa."

**Archivo fuente**: `BatutaClaude/commands/batuta-init.md` (lineas 65-70), `E:\BATUTA PROJECTS\test-guias\ecosystem-snapshot.md` (lineas 26-29)

---

#### H2 — Paso 6: guia promete avance automatico; pipeline-agent requiere confirmacion

**Donde**: Paso 6, linea 368 de la guia: "Que esperar: Claude avanza automaticamente a la fase de diseno y luego a tareas."

**Que dice la guia**: El usuario solo responde "Se ve bien, continua" y Claude pasa de spec a design a tasks sin intervencion adicional.

**Que dice el ecosistema real**: El `pipeline-agent.md` tiene como Regla #2 explicitamente:
> "Between sub-agent calls, show the user what was done and ask to proceed."

Esto significa que entre spec, design y tasks hay al menos dos pausas donde Claude muestra el resultado y espera confirmacion del usuario antes de continuar.

**Impacto**: El usuario puede confundirse cuando Claude no avanza automaticamente y se detiene a mostrar resultados intermedios. Puede pensar que algo fallo cuando en realidad es el comportamiento esperado del pipeline.

**Fix propuesto**: Cambiar "Claude avanza automaticamente" por "Claude avanza fase por fase, mostrando el resultado de cada una y esperando tu confirmacion antes de continuar. Responde 'Se ve bien, continua' en cada pausa." Tambien actualizar la seccion de pasos con una nota que explique que hay 2-3 pausas entre el Paso 5 y el Paso 7.

**Archivo fuente**: `BatutaClaude/agents/pipeline-agent.md` (linea 32, Regla #2)

---

#### H3 — Paso 12: archivo esperado no coincide con lo que sdd-archive genera

**Donde**: Paso 12, lineas 647-659 de la guia. El prompt instruye:
```
/sdd:archive refactoring-modernizacion

Ademas del archivo normal, genera un documento "CHANGELOG-refactoring.md" que incluya:
1. RESUMEN: Que se hizo (en espanol simple, para no-tecnicos)
...
```

**Que dice el ecosistema real**: El skill `sdd-archive` (Step 4) genera automaticamente un archivo `lessons-learned.md` dentro del folder archivado:
```
openspec/changes/archive/YYYY-MM-DD-refactoring-modernizacion/lessons-learned.md
```
El skill NO genera un `CHANGELOG-refactoring.md` en la raiz del proyecto. El contenido de `lessons-learned.md` es similar (que fue bien, que mejorar, decisiones clave), pero el nombre, ubicacion y estructura son distintos a lo que la guia describe.

**Impacto**: El usuario termina el Paso 12 buscando un archivo `CHANGELOG-refactoring.md` en la raiz del proyecto que no existe. Puede pensar que el archive fallo. Si el usuario confia en ese archivo para comunicar cambios al equipo, no lo encontrara en el lugar esperado.

**Fix propuesto**: Dos opciones:
1. Actualizar la guia para que refleje que el archive genera `lessons-learned.md` en `openspec/changes/archive/YYYY-MM-DD-refactoring-modernizacion/` y que el usuario puede pedir a Claude que genere adicionalmente un CHANGELOG en la raiz como paso separado.
2. Ampliar el skill `sdd-archive` para aceptar un parametro que genere un CHANGELOG en la raiz cuando se lo pide explicitamente.

**Archivo fuente**: `BatutaClaude/skills/sdd-archive/SKILL.md` (Step 4, lineas 122-160)

---

### MENORES

#### H4 — Glosario: descripcion de Scope Agent de "calidad" es imprecisa

**Donde**: Paso 1 — Glosario, linea 37 de la guia:
> "**Scope Agent** | Un 'jefe de area' especializado. Claude tiene 3: uno para el proceso de desarrollo, uno para organizacion de archivos, y uno para calidad."

**Que dice el ecosistema real**: Los tres scope agents son:
- `pipeline-agent`: proceso de desarrollo SDD (correcto)
- `infra-agent`: organizacion de archivos, skills, security (correcto)
- `observability-agent`: continuidad de sesion, O.R.T.A., tracking de prompts (NO es "calidad")

El `observability-agent` no maneja calidad de codigo — eso lo hace `sdd-verify` (skill del pipeline). El observability-agent maneja observabilidad de sesiones, registro de interacciones, y analisis de satisfaccion de prompts.

**Impacto**: El usuario puede buscar en el observability-agent funciones de calidad que no estan ahi, o malentender por que existe ese tercer agente.

**Fix propuesto**: Cambiar la descripcion de "uno para calidad" a "uno para observabilidad y continuidad de sesion". Ejemplo: "Claude tiene 3: uno para el proceso de desarrollo (SDD), uno para organizacion de archivos y seguridad, y uno para continuidad entre sesiones y observabilidad."

**Archivo fuente**: `BatutaClaude/agents/observability-agent.md`, `BatutaClaude/CLAUDE.md` (Scope Routing Table)

---

#### H5 — Paso 3: argumento de `/sdd:explore` activa creacion de archivo inesperada

**Donde**: Paso 3, lineas 218-219 de la guia:
```
/sdd:explore refactoring-modernizacion
```

**Que dice el ecosistema real**: El skill `sdd-explore` tiene esta regla:
> "If no change name was provided (standalone `/sdd:explore`), skip file creation — just return the analysis."
> "If the orchestrator provided a change name (i.e., this exploration is part of /sdd:new), save your analysis to openspec/changes/{change-name}/explore.md"

Al pasar `refactoring-modernizacion` como argumento en el Paso 3, el skill interpreta que es un change name y crea `openspec/changes/refactoring-modernizacion/explore.md`. En el contexto del Paso 3 (diagnostico puro, sin intension de crear un change aun), esto genera un folder de SDD prematuro antes de que el usuario haya aprobado la propuesta en el Paso 4.

**Impacto**: Bajo — el folder se crea de todas formas cuando el usuario ejecuta `/sdd:new` en el Paso 4. Sin embargo, el usuario en el Paso 3 no esta intentando iniciar el pipeline SDD, solo quiere un reporte de diagnostico. Puede generar confusion sobre para que sirve el folder `openspec/`.

**Fix propuesto**: Cambiar el Paso 3 para usar `/sdd:explore` sin argumentos, o bien explicar explicitamente que este comando inicia el folder del proyecto SDD que se usara en los pasos siguientes. Alternativa: usar el prompt libre sin slash command para el diagnostico inicial y reservar `/sdd:explore` para cuando el nombre del cambio ya esta decidido.

**Archivo fuente**: `BatutaClaude/skills/sdd-explore/SKILL.md` (Step 4, lineas 132-141)

---

#### H6 — Paso 8: formato del Execution Gate en guia es aproximado

**Donde**: Paso 8, lineas 441-449 de la guia. La guia muestra:
```
Este cambio involucra scope infra + pipeline:
- Mover 23 archivos a nuevas ubicaciones
...
- Procedo?
```

**Que dice el ecosistema real**: CLAUDE.md define el formato exacto del Execution Gate (FULL mode) como:
```
Este cambio involucra scope {scope}: {file list}. Nivel recomendado: {1|2|3}. Procedo?
```
El formato real incluye `{file list}` en una sola linea y `Nivel recomendado` — elementos que el ejemplo de la guia no muestra.

**Impacto**: Minimo — el usuario puede sorprenderse de que el formato real es diferente al ejemplo, pero la funcionalidad es identica. No rompe el flujo.

**Fix propuesto**: Actualizar el ejemplo del Execution Gate para que refleje el formato real documentado en CLAUDE.md, incluyendo `Nivel recomendado: {1|2|3}`.

**Archivo fuente**: `BatutaClaude/CLAUDE.md` (seccion Execution Gate, Gate Modes — FULL)

---

## Tabla de Hallazgos

| ID | Severidad | Descripcion | Prioridad | Archivo de la guia | Archivo del ecosistema |
|----|-----------|-------------|-----------|-------------------|----------------------|
| H1 | IMPORTANTE | Paso 2 Opcion B usa `--all` con bug conocido en vez de `--sync` + `--hooks` | Alta | guia lineas 192-196 | `commands/batuta-init.md` L65-70 |
| H2 | IMPORTANTE | Paso 6 promete avance automatico; pipeline-agent siempre pide confirmacion entre fases | Alta | guia linea 368 | `agents/pipeline-agent.md` L32 |
| H3 | IMPORTANTE | Paso 12 espera `CHANGELOG-refactoring.md` en raiz; sdd-archive genera `lessons-learned.md` en archive | Alta | guia lineas 647-659 | `skills/sdd-archive/SKILL.md` L122-160 |
| H4 | MENOR | Glosario describe observability-agent como agente de "calidad" — es agente de sesion/observabilidad | Baja | guia linea 37 | `agents/observability-agent.md`, `CLAUDE.md` |
| H5 | MENOR | Paso 3 usa `/sdd:explore` con argumento, lo que crea folder SDD prematuro | Baja | guia lineas 218-219 | `skills/sdd-explore/SKILL.md` L132-141 |
| H6 | MENOR | Ejemplo del Execution Gate en Paso 8 no incluye `Nivel recomendado` ni `{file list}` | Baja | guia lineas 441-449 | `BatutaClaude/CLAUDE.md` (Gate FULL) |

---

## Conclusion

**El journey idea → producto funciona? Si, con condiciones.**

La guia de refactoring legacy cubre el flujo completo del ecosistema Batuta de forma correcta en sus pasos principales. Todos los skills y commands referenciados existen y contienen lo que la guia promete. El usuario que siga la guia puede completar un refactoring real de principio a fin.

Las tres discrepancias importantes (H1, H2, H3) no rompen el journey completo pero si generan momentos de confusion que pueden hacer que el usuario piense que algo salio mal cuando en realidad el ecosistema esta funcionando correctamente:

- **H1** puede hacer que el usuario abandone la instalacion al ver un exit code 1 falso positivo.
- **H2** puede hacer que el usuario piense que Claude esta "trabado" cuando en realidad esta esperando su confirmacion entre fases SDD — un comportamiento de seguridad, no un error.
- **H3** puede hacer que el usuario no encuentre el documento de cierre del proyecto que espera y pierda confianza en que el archive se completo exitosamente.

Las discrepancias menores (H4, H5, H6) son oportunidades de mejora en precision pero no afectan la funcionalidad del flujo.

**Recomendacion**: Corregir H1, H2 y H3 antes de compartir la guia con usuarios nuevos. Las correcciones son de texto — no requieren cambios al ecosistema.
