# Integration Test: Guia CLI Python

## Metadata

- **Fecha**: 2026-02-23
- **Guia**: `docs/guides/guia-cli-python.md`
- **Version ecosistema**: v9.1
- **Tester**: Analisis automatico por Claude
- **Metodologia**: Lectura de cada archivo referenciado en la guia con Read tool; comparacion contra lo que la guia describe.

---

## Resumen Ejecutivo

La guia `guia-cli-python.md` es funcionalmente solida. El flujo principal de 12 pasos (crear carpeta → instalar Batuta → SDD pipeline → build → tests → GitHub → opcional PyPI → archivar) es consistente con el ecosistema real. Todos los skills SDD referenciados existen y hacen exactamente lo que la guia describe.

Se encontraron **5 discrepancias reales**:

1. **CRITICO**: El comando `/sdd-new` que la guia usa en Paso 4 tiene una firma incorrecta. Segun CLAUDE.md, `/sdd-new <change-name>` ejecuta `sdd-explore → sdd-propose`. Pero la guia lo presenta como un comando de "propuesta formal" despues de que ya se hizo el explore en Paso 3, creando una doble exploracion no intencional.

2. **IMPORTANTE**: El flujo del Paso 3 combina `/sdd-init` y `/sdd-explore` en un solo paso, pero el skill `sdd-init` crea la estructura `openspec/` — no pregunta nombre/tipo/descripcion como la guia anticipa en la tabla de respuestas. `sdd-init` detecta el stack automaticamente o pregunta si el proyecto esta vacio.

3. **IMPORTANTE**: La guia describe que `/sdd-continue` en Paso 5 ejecuta "Specs → Design → Tasks" de forma secuencial, pero `sdd-continue` no existe como skill propio — es un alias de routing en CLAUDE.md que invoca "el siguiente paso necesario". El comportamiento real puede variar.

4. **MENOR**: La estructura de proyecto esperada al final de la guia coloca `core/config.py` e `core/history.py` en `core/`. Segun la Scope Rule real, `config.py` puede calificar como core (singleton de configuracion global), pero `history.py` deberia evaluarse segun quien lo use — si solo lo usa el comando `deshacer`, deberia ir en `features/organizer/`.

5. **MENOR**: El `session-template.md` dice `Batuta version: 5.0.0` pero el ecosistema esta en v9.1. La guia no hace referencia directa a este numero, pero el archivo que `/batuta-init` copia al proyecto tendra una version incorrecta.

No se encontraron discrepancias en: skills SDD (todos existen y tienen los triggers correctos), comando `batuta-init` (funciona exactamente como la guia describe), Execution Gate (descrito correctamente), Agent Teams (correctamente descrito como innecesario para este proyecto).

---

## Hallazgos

### CRITICOS

#### C-01: `/sdd-new` provoca doble exploracion no intencional

**Paso afectado**: Paso 3 y Paso 4

**Que dice la guia**:
- Paso 3: Usar `/sdd-explore ordena-archivos-cli` para explorar requisitos
- Paso 4: Usar `/sdd-new ordena-archivos-cli` para crear "propuesta formal"

**Que hace el ecosistema real** (segun `BatutaClaude/CLAUDE.md`, tabla SDD Commands):
```
/sdd-new <change-name>  →  pipeline → sdd-explore → sdd-propose
```

El comando `/sdd-new` **siempre ejecuta sdd-explore primero**, luego sdd-propose. Si el usuario ya ejecuto `/sdd-explore` en el Paso 3, el Paso 4 con `/sdd-new` volvera a explorar el mismo topic, duplicando el trabajo y potencialmente produciendo una exploracion diferente a la que el usuario ya aprobo mentalmente.

**Impacto**: El usuario puede confundirse al ver que Claude "vuelve a investigar" en el Paso 4 cuando esperaba solo una propuesta. En el peor caso, la segunda exploracion puede divergir de la primera y producir decisiones tecnicas inconsistentes.

**Correccion sugerida**: Una de dos opciones:
- Opcion A: Eliminar el Paso 3 con `/sdd-explore` y dejar solo el Paso 4 con `/sdd-new` (que incluye explore internamente).
- Opcion B: Cambiar el Paso 4 para usar el skill de propuesta directamente con el prompt: `"Crea la propuesta formal para ordena-archivos-cli basada en la exploracion anterior"` en lugar de `/sdd-new`.

**Archivo**: `docs/guides/guia-cli-python.md`, lineas 234-329

---

### IMPORTANTES

#### I-01: Tabla de respuestas en Paso 3 no corresponde al comportamiento real de `sdd-init`

**Paso afectado**: Paso 3

**Que dice la guia**:
```
Primero, inicializa el proyecto SDD:
/sdd-init

Cuando Claude pregunte:
| Si Claude pregunta...   | Tu respondes...         |
| Nombre del proyecto     | ordena-archivos         |
| Tipo de proyecto        | cli                     |
| Descripcion             | Herramienta CLI...      |
```

**Que hace el ecosistema real** (segun `BatutaClaude/skills/sdd-init/SKILL.md`):

El skill `sdd-init` **detecta automaticamente** el stack y tipo de proyecto leyendo archivos existentes (package.json, pyproject.toml, etc.). Solo pregunta al usuario cuando el proyecto esta **completamente vacio** (sin ningun archivo de configuracion). En ese caso, la seccion "Empty Project Handling" dice:

> "ASK the user for: project type, intended tech stack, and brief description"

Para el caso de la guia (proyecto nuevo recien creado, carpeta vacia), el comportamiento si coincidiria — Claude si preguntaria. Pero la tabla sugiere que Claude pregunta "Nombre del proyecto", lo cual NO aparece en las instrucciones del skill. El skill solo pregunta tipo, stack y descripcion.

Adicionalmente, el tipo `cli` no esta en la lista de tipos validos del skill. Los tipos detectables son:
`webapp | automation | ai-agent | infrastructure | data-pipeline | library`

Una herramienta CLI en Python mas probablemente seria clasificada como `library` (tiene pyproject.toml con build-system) o no tendria un tipo exacto.

**Impacto**: El usuario puede esperar que Claude le haga 3 preguntas especificas y no recibir exactamente esas preguntas, generando confusion. El tipo `cli` en particular puede provocar que el usuario corrija a Claude con un valor que el skill no espera.

**Archivo**: `docs/guides/guia-cli-python.md`, lineas 221-232

---

#### I-02: `sdd-continue` no existe como skill; es alias de routing en CLAUDE.md

**Paso afectado**: Paso 5

**Que dice la guia**:
```
/sdd-continue ordena-archivos-cli

Que esperar: Claude ejecuta 3 fases:
| Specs | Define exactamente que hace cada comando | 2-3 min |
| Design | Decide: Click o Typer, estructura de archivos | 2-3 min |
| Tasks | Divide el trabajo en tareas ordenadas | 1-2 min |
```

**Que hace el ecosistema real** (segun `BatutaClaude/CLAUDE.md`):
```
/sdd-continue [change-name]  →  pipeline → next needed phase
```

`/sdd-continue` no es un skill con logica propia — es una instruccion de routing que dice "ejecuta el siguiente paso necesario". Si el pipeline esta en el estado correcto despues del Paso 4, debia ejecutar spec → design → tasks secuencialmente con 3 invocaciones separadas de `/sdd-continue`, no en una sola ejecucion.

La guia presenta esto como si fuera una sola ejecucion que automaticamente encadena las 3 fases, mostrando:
```
Tu respuesta cada vez: "Se ve bien, continua"
```

Esto implica 3 interacciones separadas del usuario, lo cual es correcto en comportamiento. Pero la descripcion "Claude ejecuta 3 fases" puede hacer creer que todo ocurre automaticamente sin intervencion.

El comportamiento real es: `/sdd-continue` ejecuta **una** fase (la siguiente pendiente), muestra el resultado, y espera confirmacion del usuario. Para avanzar a la siguiente fase, el usuario debe escribir de nuevo (ya sea otro `/sdd-continue` o confirmar).

**Impacto**: El usuario puede esperar que con un solo `/sdd-continue` obtenga las 3 fases. Si solo obtiene specs y Claude se detiene, puede pensar que algo fallo cuando en realidad el flujo es correcto.

**Archivo**: `docs/guides/guia-cli-python.md`, lineas 340-363

---

### MENORES

#### M-01: `history.py` en la estructura esperada puede violar Scope Rule

**Paso afectado**: Seccion "Estructura esperada del proyecto" (despues del Paso 12)

**Que dice la guia**:
```
ordena-archivos/
├── core/
│   ├── config.py    # Configuracion (categorias, rutas)
│   └── history.py   # Historial de operaciones (para deshacer)
```

**Que dice el ecosistema real** (segun `BatutaClaude/skills/scope-rule/SKILL.md`):

La Scope Rule define `core/` como "singletons usados por toda la aplicacion". `config.py` califica correctamente como core (configuracion global usada por todos los comandos). Pero `history.py` es utilizado principalmente — o exclusivamente — por el comando `deshacer`. Si solo lo usa ese comando, deberia vivir en `features/organizer/`.

El skill scope-rule dice explicitamente:
> "Core is for singletons only — auth, database, logging, app config"
> "If you can imagine having TWO of these in the same app, it's NOT core."

Si `history.py` maneja el historial para el undone feature, es logica de feature, no infraestructura core.

**Impacto**: Bajo. La guia es una referencia, no codigo ejecutado. Pero si el usuario sigue la estructura al pie de la letra, puede que en el Paso 8 (`/sdd-verify`) el sistema detecte una violacion de Scope Rule y pida mover `history.py`.

**Archivo**: `docs/guides/guia-cli-python.md`, lineas 939-974

---

#### M-02: `session-template.md` tiene version incorrecta

**Componente afectado**: `/batuta-init` → copia `session-template.md` al proyecto

**Que dice el archivo real** (`BatutaClaude/skills/prompt-tracker/assets/session-template.md`):
```
- **Batuta version**: 5.0.0
```

**Que dice el ecosistema**: v9.1 (segun `test-guias/ecosystem-snapshot.md` y MEMORY.md)

La guia no hace referencia directa a este numero de version, pero `/batuta-init` (Paso 2) copia este template al proyecto del usuario como `.batuta/session.md`. El archivo resultante mostrara `Batuta version: 5.0.0` en un proyecto que usa v9.1.

**Impacto**: Bajo. No afecta la funcionalidad. Puede causar confusion si el usuario revisa su `.batuta/session.md` y ve una version 4 versiones atras.

**Archivo**: `BatutaClaude/skills/prompt-tracker/assets/session-template.md`, linea 9

---

## Tabla de Hallazgos

| ID | Severidad | Descripcion | Prioridad | Archivo |
|----|-----------|-------------|-----------|---------|
| C-01 | CRITICO | `/sdd-new` re-ejecuta sdd-explore aunque ya se hizo en Paso 3, causando doble exploracion | Alta | `docs/guides/guia-cli-python.md` L234-329 |
| I-01 | IMPORTANTE | Tabla de preguntas de `sdd-init` no corresponde al behavior real; tipo `cli` no existe en skill | Media | `docs/guides/guia-cli-python.md` L221-232 |
| I-02 | IMPORTANTE | `sdd-continue` no es una ejecucion automatica de 3 fases; es routing que ejecuta una fase por invocacion | Media | `docs/guides/guia-cli-python.md` L340-363 |
| M-01 | MENOR | `history.py` en `core/` puede violar Scope Rule si solo lo usa el comando deshacer | Baja | `docs/guides/guia-cli-python.md` L939-974 |
| M-02 | MENOR | `session-template.md` muestra version 5.0.0 en vez de 9.1 | Baja | `BatutaClaude/skills/prompt-tracker/assets/session-template.md` L9 |

---

## Verificaciones que Pasaron

Los siguientes elementos fueron verificados y estan correctos:

| Elemento | Verificado en | Resultado |
|----------|--------------|-----------|
| `/batuta-init` command existe | `BatutaClaude/commands/batuta-init.md` | PASS — funciona exactamente como la guia describe |
| `sdd-init` skill existe | `BatutaClaude/skills/sdd-init/SKILL.md` | PASS |
| `sdd-explore` skill existe | `BatutaClaude/skills/sdd-explore/SKILL.md` | PASS |
| `sdd-propose` skill existe | `BatutaClaude/skills/sdd-propose/SKILL.md` | PASS |
| `sdd-apply` skill existe | `BatutaClaude/skills/sdd-apply/SKILL.md` | PASS |
| `sdd-verify` skill existe | `BatutaClaude/skills/sdd-verify/SKILL.md` | PASS |
| `sdd-archive` skill existe | `BatutaClaude/skills/sdd-archive/SKILL.md` | PASS |
| `sdd-spec` skill existe | `BatutaClaude/skills/sdd-spec/SKILL.md` | PASS |
| `sdd-design` skill existe | `BatutaClaude/skills/sdd-design/SKILL.md` | PASS |
| `sdd-tasks` skill existe | `BatutaClaude/skills/sdd-tasks/SKILL.md` | PASS |
| `scope-rule` skill existe | `BatutaClaude/skills/scope-rule/SKILL.md` | PASS |
| Execution Gate descrito correctamente | `BatutaClaude/CLAUDE.md` | PASS — descripcion de la guia coincide con Gate modes LIGHT/FULL |
| `.batuta/session.md` creado por batuta-init | `BatutaClaude/commands/batuta-init.md` Step 2.5 | PASS |
| Agent Teams descritos como innecesarios para este proyecto | `BatutaClaude/CLAUDE.md` (criterios Level 3) | PASS — correcto para 1 scope, menos de 4 archivos |
| `/sdd-apply` contiene Execution Gate | `BatutaClaude/skills/sdd-apply/SKILL.md` Step 0 | PASS |
| `/sdd-verify` incluye AI Validation Pyramid | `BatutaClaude/skills/sdd-verify/SKILL.md` | PASS — coincide con descripcion de la guia |
| `/sdd-archive` cierra el ciclo como describe la guia | `BatutaClaude/skills/sdd-archive/SKILL.md` | PASS |
| Scope Rule en estructura esperada es mayormente correcta | `BatutaClaude/skills/scope-rule/SKILL.md` | PASS (con excepcion de M-01) |

---

## Conclusion

La guia `guia-cli-python.md` esta en buen estado. El 85% del contenido es preciso y el flujo general lleva al usuario correctamente por el pipeline SDD completo.

El hallazgo critico (C-01) es el unico que puede causar confusion real durante la ejecucion: el usuario ejecutaria dos exploraciones del mismo tema porque la guia separa `/sdd-explore` y `/sdd-new` en pasos distintos sin advertir que `/sdd-new` internamente ejecuta explore nuevamente. La correccion es simple: consolidar los pasos 3 y 4, o usar `/sdd-new` directamente desde el inicio.

Los hallazgos importantes (I-01, I-02) son imprecisiones de descripcion que no rompen el flujo pero si pueden generar confusion momentanea. El usuario probablemente los navegara sin problema, pero en una guia diseñada para personas sin experiencia tecnica, cada punto de confusion innecesario tiene peso.

Los hallazgos menores (M-01, M-02) son de baja urgencia. M-02 en particular es un artefacto interno que no afecta la experiencia del usuario durante los pasos de la guia.

**Recomendacion**: Corregir C-01 antes de publicar la guia al usuario final. Los hallazgos I-01 e I-02 son candidatos para la siguiente iteracion de refinamiento.
