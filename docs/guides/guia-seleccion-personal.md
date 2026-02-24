# Guia Paso a Paso: Automatizar Evaluacion de Hojas de Vida con Claude Code

> **Para quien es esta guia**: Para cualquier persona que sepa copiar y pegar texto.
> Claude Code hace la programacion, tu solo le das las instrucciones.
>
> **Formato**: Sigue los pasos en orden, como cuando aprendes a manejar.
> Cada paso depende del anterior. No saltes pasos.
>
> **Que tiene de especial esta guia**: Demuestra el flujo CTO completo (v10.0)
> con LLM pipeline — usa inteligencia artificial para evaluar y clasificar
> hojas de vida automaticamente, con garantias de calidad y compliance.

---

## Glosario — Palabras que vas a ver

Antes de empezar, aqui tienes un mini-diccionario. No necesitas memorizarlo, vuelve aqui si ves una palabra que no entiendes.

| Palabra | Que significa (sin tecnicismos) |
|---------|-------------------------------|
| **Hoja de vida (HV)** | El documento que una persona envia cuando aplica a un cargo. Puede venir en PDF, Word, o texto pegado en un formulario. |
| **Screening** | La primera revision rapida de hojas de vida. Separar las que cumplen requisitos minimos de las que no. Como filtrar solicitudes: "tiene titulo? tiene experiencia? cumple edad?". |
| **Competencia** | Una habilidad o conocimiento que el cargo necesita. Ejemplo: "Excel avanzado", "liderazgo de equipos", "contabilidad tributaria". |
| **Diccionario de competencias** | La lista oficial de competencias que la empresa usa. Es diferente para cada empresa y para cada cargo. |
| **LLM** | Large Language Model — un modelo de inteligencia artificial que entiende y genera texto. Es lo que hace que Claude pueda leer una hoja de vida y evaluarla. |
| **Confidence score** | Un puntaje de 0 a 100 que indica que tan seguro esta el LLM de su evaluacion. Si dice "92% confianza", esta bastante seguro. Si dice "45% confianza", mejor que revise un humano. |
| **Golden dataset** | Un conjunto de hojas de vida donde un experto humano ya hizo la evaluacion correcta. Se usa para calibrar y verificar que el LLM clasifica bien. |
| **Pipeline LLM** | Una cadena de 6 pasos que toma hojas de vida crudas, las analiza con IA, y entrega una evaluacion calibrada con nivel de confianza. |
| **Drift** | Cuando el LLM empieza a clasificar diferente a como lo hacia antes. Como un reloj que se va desajustando con el tiempo. Se detecta y se corrige. |
| **Langfuse** | Una herramienta que registra todo lo que hace el LLM: que leyo, que respondio, cuanto costo, cuanto tardo. Para auditoria y mejora continua. |
| **Presidio** | Una herramienta que detecta y oculta datos personales (nombres, cedulas, telefonos) antes de enviarlos al LLM. Protege la privacidad. |
| **PII** | Informacion personal identificable — nombres, cedulas, emails, telefonos, direcciones. Datos que identifican a una persona. |
| **Habeas data** | El derecho que tiene cualquier persona a saber que datos tuyos tiene una empresa, y a pedir que los corrijan o eliminen. En Colombia es la Ley 1581/2012. |
| **SIC 002/2024** | La circular de la Superintendencia de Industria y Comercio que regula el uso de IA sobre datos personales en Colombia. Requiere un test de proporcionalidad. |
| **Test de proporcionalidad** | 4 preguntas que debes responder antes de usar IA sobre datos personales: Es adecuado? Es necesario? El beneficio supera el riesgo? Que garantias hay? |
| **Process Analyst** | Un skill de Claude que mapea TODAS las variantes de un proceso. Descubre los casos que nadie menciona. |
| **Recursion Designer** | Un skill que disena como el sistema aprende. Los perfiles de cargo cambian, el sistema debe adaptarse. |
| **Discovery** | Investigar a fondo el problema antes de construir. El "examen medico" antes de la "receta". |
| **SDD** | Spec-Driven Development. Primero planeas, luego construyes. |
| **Prompt** | El mensaje que le escribes a Claude. |
| **Claude Code** | Un asistente de programacion en la terminal. |

---

## El escenario

Un cliente te contacta:

> *"Recibimos 200+ hojas de vida al mes para diferentes cargos. La persona
> de RRHH se demora una semana revisandolas y a veces se le pasan buenos
> candidatos. Necesito algo que haga el screening inicial automaticamente."*

Tu dices "yo lo resuelvo" — y necesitas moverte rapido desde entender el problema hasta tener una solucion, sin perder rigor.

**Lo que hace esta guia diferente**: Este proyecto usa un LLM (inteligencia artificial) para evaluar hojas de vida. Eso activa el **LLM Pipeline Design** y el **Compliance Colombia** automaticamente, porque estamos usando IA sobre datos personales.

---

## Antes de empezar — Lo que necesitas tener instalado

| Herramienta | Para que sirve | Como instalar |
|-------------|---------------|---------------|
| **Python 3.11+** | El lenguaje de programacion | Descarga de [python.org](https://python.org) |
| **Git** | Guarda el historial del proyecto | Descarga de [git-scm.com](https://git-scm.com) |
| **Claude Code** | El asistente que programa por ti | `npm install -g @anthropic-ai/claude-code` |
| **Node.js** | Necesario para instalar Claude Code | Descarga de [nodejs.org](https://nodejs.org) la version LTS |

Para verificar:
```
python --version
git --version
claude --version
```

---

# PASO A PASO

---

## Paso 1 — Crear la carpeta del proyecto

1. Crea una carpeta llamada `screening-hojas-de-vida`
2. Si tienes hojas de vida de ejemplo (PDF, Word), copialas en `data/raw/`

> **IMPORTANTE sobre datos personales**: Las hojas de vida tienen MUCHA informacion
> personal (nombres, cedulas, direcciones, fotos). Trabaja con datos anonimizados
> o ficticios siempre que sea posible. Esta guia incluye pasos de compliance
> para proteger esos datos.

---

## Paso 2 — Abrir Claude Code e instalar Batuta

1. Abre una terminal
2. Navega a tu carpeta:

```
cd "E:\Proyectos\screening-hojas-de-vida"
```

3. Abre Claude Code:

```
claude
```

4. Instala el ecosistema:

```
/batuta-init screening-hojas-de-vida
```

Cuando pregunte por tipo de proyecto, responde `ai-agent` (porque este proyecto usa LLM).

---

## Paso 3 — Iniciar SDD y configurar dominio HR

```
/sdd-init
```

| Si Claude pregunta... | Tu respondes... |
|----------------------|-----------------|
| Nombre del proyecto | `screening-hojas-de-vida` |
| Tipo de proyecto | `ai-agent` |
| Descripcion | `Sistema de screening automatico de hojas de vida. Recibe PDFs/Word, extrae competencias, las compara contra el perfil del cargo, y clasifica en Apto/Dudoso/No Apto con puntaje de confianza. Usa LLM para evaluacion. Cumple regulacion colombiana de datos personales.` |
| Generar domain-experts? | `Si, con HR` |

> **El domain expert HR** le dice a Claude cosas como: "los perfiles de cargo
> cambian frecuentemente", "las competencias no son universales — cada empresa
> tiene las suyas", "las hojas de vida vienen en formatos muy diferentes".

---

## Paso 4 — Explorar el problema (Discovery)

```
/sdd-new screening-automatico
```

**Copia y pega este contexto cuando Claude pida detalles**:

```
El cliente tiene este problema:
- Recibe ~200 hojas de vida al mes
- 5-8 cargos abiertos simultaneamente
- Tipos de cargo: administrativo, operativo, comercial, IT, gerencial
- Las HV llegan por: email (40%), formulario web (35%), LinkedIn (15%), referidos (10%)
- Formato: PDF (60%), Word (30%), texto pegado (10%)
- El screening hoy lo hace 1 persona de RRHH manualmente
- Criterios: requisitos minimos (titulo, experiencia), competencias del cargo,
  pretension salarial, disponibilidad
- Resultado esperado: clasificar en Apto (pasa a entrevista), Dudoso (revisar),
  No Apto (descartar) con justificacion
- El cliente quiere que el sistema SUGIERA, no que decida automaticamente
  - Siempre debe haber un humano que confirme antes de descartar
- Cargos tienen diferentes pesos: para IT importa mas la experiencia tecnica,
  para comercial importa mas las competencias blandas
- Las competencias del cargo las define el area solicitante (no RRHH)
```

### Discovery Completeness (5 preguntas)

Claude responde las 5 preguntas obligatorias. Si alguna queda como "No" o "Unknown", vuelve a investigar:

1. **Todos los tipos de caso?** — 5 tipos de cargo, 4 canales, 3 formatos, 3 clasificaciones
2. **Excepciones?** — HV ilegible, HV sin datos clave, cargo sin perfil definido, candidato sobrecalificado
3. **Categorias externas?** — Competencias (definidas por cada area), titulos academicos (MEN)
4. **Participantes?** — RRHH, area solicitante, candidato, gerencia
5. **Ramas del proceso?** — Flujo por canal, flujo por tipo de cargo, flujo por resultado

Claude detecta complejidad:

> *"Proceso complejo: 5+ tipos de caso, taxonomias externas (competencias por cargo).
> Se recomienda /process-analyst y /recursion-designer."*

**Tu respuesta**:

```
Si, ejecuta /process-analyst primero.
```

---

## Paso 5 — Mapear las variantes del proceso

Claude ejecuta el Process Analyst y genera el arbol de variantes:

```
PROCESO: Screening de Hojas de Vida
CRITERIO PRINCIPAL: Tipo de cargo

+-- VARIANTE A: Cargo Administrativo
|   +-- Requisitos: titulo profesional, experiencia 2+ anos
|   +-- Competencias clave: Excel, atencion al detalle, organizacion
|   +-- Peso evaluacion: 40% requisitos, 40% competencias, 20% fit cultural
|
+-- VARIANTE B: Cargo Operativo
|   +-- Requisitos: bachiller o tecnico, experiencia 1+ ano
|   +-- Competencias clave: habilidades manuales, seguridad industrial
|   +-- Peso evaluacion: 60% requisitos, 30% competencias, 10% fit cultural
|
+-- VARIANTE C: Cargo Comercial
|   +-- Requisitos: experiencia en ventas, disponibilidad viajes
|   +-- Competencias clave: comunicacion, negociacion, orientacion a resultados
|   +-- Peso evaluacion: 30% requisitos, 50% competencias, 20% fit cultural
|
+-- VARIANTE D: Cargo IT
|   +-- Requisitos: titulo en sistemas/afines, tecnologias especificas
|   +-- Competencias clave: tecnologias del stack, resolucion problemas
|   +-- Peso evaluacion: 50% requisitos, 40% competencias, 10% fit cultural
|
+-- VARIANTE E: Cargo Gerencial
|   +-- Requisitos: posgrado preferible, experiencia 5+ anos liderazgo
|   +-- Competencias clave: liderazgo, vision estrategica, gestion presupuesto
|   +-- Peso evaluacion: 30% requisitos, 40% competencias, 30% fit cultural
|
+-- EXCEPCIONES TRANSVERSALES:
|   +-- HV ilegible → notificar candidato, pedir nueva version
|   +-- HV sin datos clave → marcar como INCOMPLETA
|   +-- Candidato sobrecalificado → flag especial (potencial para otro cargo)
|   +-- Pretension salarial fuera de rango → flag (pero no descartar)
|
+-- CASO NO CLASIFICABLE:
    +-- Cargo sin perfil definido → no evaluar, escalar a area solicitante
```

### Taxonomias externas

Claude detecta que las competencias son controladas por el area solicitante (no por RRHH):

> *"Taxonomias externas: competencias por cargo (area solicitante las define).
> Se recomienda /recursion-designer."*

**Tu respuesta**:

```
Si, ejecuta /recursion-designer para las competencias.
```

---

## Paso 6 — Disenar el aprendizaje de competencias

Claude ejecuta el Recursion Designer:

**Mecanismo 1 — Deteccion de desconocidos:**
```
Si la HV menciona una competencia que NO esta en el diccionario del cargo:
  → Registrar como NUEVA COMPETENCIA con contexto
  → Comportamiento: CONTINUAR CON MARCA
  → Incluir en reporte mensual para RRHH
```

**Mecanismo 2 — Aprobacion humana:**
```
RRHH propone agregar competencia al diccionario.
Area solicitante (hiring manager) decide:
  AGREGAR / MAPEAR A EXISTENTE (es sinonimo) / DESCARTAR.
```

**Mecanismo 3 — Propagacion:**
```
FORWARD: nuevas evaluaciones usan el diccionario actualizado.
HVs ya evaluadas NO se re-evaluan automaticamente.
```

**Mecanismo 4 — Versionado:**
```
Cada perfil de cargo tiene version del diccionario.
Cada evaluacion registra: version + fecha + modelo LLM usado.
```

**Cuando termine**:

```
Perfecto. Ahora continua con la propuesta.
```

---

## Paso 7 — Gate G0.5 + Propuesta con Cost-Benefit

Claude pasa el Gate G0.5 (Discovery Complete) y genera la propuesta.

### Client Communication

> *"Vamos a crear un asistente inteligente que lee hojas de vida, las compara
> contra el perfil del cargo, y le sugiere al equipo de RRHH cuales candidatos
> son aptos, cuales son dudosos, y cuales no cumplen. El asistente NUNCA
> descarta solo — siempre espera la confirmacion de un humano. Lo que hoy
> toma una semana va a tomar 1-2 horas de revision."*

### Cost-Benefit

| Concepto | Valor |
|----------|-------|
| Esfuerzo desarrollo | 60-80 horas (~4 semanas) |
| Infraestructura mensual | ~$80 USD (servidor + API LLM) |
| Costo LLM por HV | ~$0.02-0.05 USD (200 HV/mes = ~$10 USD/mes) |
| Mantenimiento mensual | ~6 horas (calibracion + nuevos perfiles) |
| Ahorro mensual | 1 semana de RRHH (~$2M COP) |
| Tiempo para retorno | ~3 meses |
| Riesgo si no se hace | Buenos candidatos se pierden, proceso lento afecta contratacion |

### Cost-Benefit del LLM (especifico)

| Modelo | Costo por HV | Calidad | Uso recomendado |
|--------|-------------|---------|----------------|
| Haiku / gpt-4o-mini | $0.01-0.02 | Buena para screening basico | Cargo operativo, administrativo |
| Sonnet / gpt-4o | $0.03-0.05 | Alta para evaluacion matizada | Cargo IT, comercial, gerencial |

**Cuando estes conforme**:

```
Aprobado, continua
```

---

## Paso 8 — Gate G1 + Specs + Design + Tasks

```
/sdd-continue screening-automatico
```

Repite hasta completar specs, design y tasks.

### Lo especial del design (v10.0)

**LLM Pipeline Design** (se activa porque usamos IA):

| Fase | Que hace en este proyecto |
|------|--------------------------|
| 1. Extraccion | Lee PDF/Word, extrae texto estructurado |
| 2. Analisis estadistico | Patrones de formato, longitud, secciones |
| 3. ML Clasico (baseline) | Filtros por palabras clave (titulo, anos experiencia) |
| 4. Capa LLM | Evaluacion de competencias, fit cultural, redaccion |
| 5. Auto-supervision | Confidence scoring (4 niveles), drift detection |
| 6. Trazabilidad | Langfuse: que leyo, que evaluo, cuanto costo |

**Compliance Colombia** (se activa porque son datos personales + IA):

Test de proporcionalidad SIC 002/2024:
1. **Idoneidad**: El LLM es adecuado? Si — evalua texto no estructurado con matices
2. **Necesidad**: Hay alternativa menos invasiva? No para evaluacion de competencias
3. **Proporcionalidad**: Beneficio > riesgo? Si — humano siempre confirma, IA sugiere
4. **Garantias**: Presidio para PII stripping, Langfuse para auditoria

**Architecture Validation Checklist** (7 items verificados).

**Tu respuesta por cada fase**:

```
Se ve bien, continua
```

---

## Paso 9 — Implementar

```
/sdd-apply screening-automatico
```

Claude implementa en batches:

| Batch | Que hace |
|-------|---------|
| 1 | Parsers de documentos (PDF, Word, texto) |
| 2 | Extraccion de datos estructurados (nombre, experiencia, educacion) |
| 3 | PII stripping con Presidio (antes de enviar al LLM) |
| 4 | Evaluacion con LLM (prompt versionado, model routing por tipo de cargo) |
| 5 | Confidence scoring (4 niveles: structural, LLM-as-judge, self-consistency, self-report) |
| 6 | Diccionario de competencias (Recursion Designer) |
| 7 | Generacion de reporte para RRHH |
| 8 | Trazabilidad con Langfuse |

**Tu respuesta por cada batch**:

```
Si, continua con el siguiente batch
```

### Si Claude pregunta sobre las hojas de vida

**Si tienes HVs de ejemplo**:

```
Tengo HVs de ejemplo en data/raw/:
- 20 PDFs de diferentes candidatos
- 5 archivos Word
- 3 perfiles de cargo en Excel (administrativo, comercial, IT)
Los datos son ficticios (generados para pruebas).
```

**Si no tienes**:

```
No tengo hojas de vida de prueba. Genera 50 HVs ficticias distribuidas asi:
- 15 para cargo administrativo (8 aptos, 4 dudosos, 3 no aptos)
- 15 para cargo comercial (7 aptos, 5 dudosos, 3 no aptos)
- 20 para cargo IT (10 aptos, 6 dudosos, 4 no aptos)
Incluye variaciones: HVs bien redactadas, HVs con errores, HVs incompletas,
HVs sobrecalificadas. Tambien genera 3 perfiles de cargo con competencias.
```

---

## Paso 10 — Verificar con testing tipo B (auto + LLM)

```
/sdd-verify screening-automatico
```

### Testing diferenciado (v10.0 — Type B: Automation + LLM)

Claude aplica la **estrategia Type B** porque este proyecto usa LLM:

**Tests estandar (pyramid)**:
- Tests unitarios para parsers de documentos
- Tests de extraccion de datos
- Tests de PII stripping
- Tests end-to-end del pipeline

**Tests especificos LLM (Type B)**:
- **Golden dataset**: 50+ HVs con evaluacion correcta por un experto humano
- **Confidence validation**: promedio >85% para Apto/No Apto
- **Costo por evaluacion**: <$0.05 USD por HV
- **Prompt regression**: el prompt v1 sigue produciendo resultados consistentes
- **Model routing**: Haiku para cargos operativos, Sonnet para gerenciales

**Si encuentra problemas**:

```
Si, corrige todos los problemas
```

---

## Paso 11 — Gate G2 + Probar con datos reales

Claude pasa el Gate G2 (Production Ready).

```
Ejecuta el pipeline completo con las 50 HVs de prueba.
Muestra el reporte de screening para el cargo IT.
```

**Que esperar**:

```
Screening completado — Cargo: Desarrollador Backend IT

Candidatos evaluados: 20
- Apto (pasa a entrevista): 9
  - Confianza promedio: 91%
  - Top 3: Juan Garcia (95%), Maria Lopez (93%), Carlos Reyes (92%)
- Dudoso (revision RRHH): 7
  - Confianza promedio: 62%
  - Razon mas comun: experiencia parcial en tecnologia requerida
- No Apto: 4
  - Confianza promedio: 88%
  - Razon mas comun: no cumple requisito de experiencia minima

Competencias mas encontradas:
  Python (85%), SQL (75%), Docker (40%), AWS (35%), FastAPI (25%)

Competencias nuevas detectadas (no en diccionario):
  "Temporal.io" (2 candidatos) → pendiente clasificacion por hiring manager

Costo LLM total: $0.82 USD (20 evaluaciones)
Tiempo total: 45 segundos
```

---

## Paso 12 — Archivar y Learning Loop

```
/sdd-archive screening-automatico
```

### Learning Loop (6 preguntas)

| Pregunta | Posible respuesta |
|----------|------------------|
| Patron reutilizable? | Si — el evaluador de documentos con PII stripping podria ser un skill |
| Skill fallo? | No |
| Discovery se perdio algo? | Si — no preguntamos por idiomas (hay HVs en ingles) |
| Cost-benefit preciso? | Si — costo LLM fue $10 USD/mes, estimado era $10 |
| Tests correctos? | Si — golden dataset detecto que "liderazgo" se confundia con "gestion" |
| Domain expert ayudo? | Si — HR expert indico que competencias cambian por cargo |

---

# DESPUES DE LA ENTREGA

---

## Hacer cambios despues

**Agregar nuevo tipo de cargo:**
```
/sdd-new agregar-perfil-logistica

El cliente abrio una vacante nueva: Coordinador de Logistica.
Competencias: manejo de inventarios, rutas de distribucion, SAP MM.
El perfil lo define el Jefe de Operaciones.
```

**Mejorar precision del LLM:**
```
/sdd-new calibrar-evaluacion-comercial

El screening de cargos comerciales tiene mucha evaluacion "Dudoso" (40%).
El gerente comercial quiere que el criterio principal sea experiencia en
ventas B2B, no competencias generales. Ajustar el prompt y re-calibrar
con un golden dataset nuevo.
```

**Agregar evaluacion de idiomas:**
```
/sdd-new evaluar-idiomas-hv

Algunos cargos requieren ingles. El sistema debe:
1. Detectar si la HV esta en ingles o espanol
2. Si el cargo requiere ingles, evaluar competencia del candidato
3. Si la HV esta en ingles, hacer la evaluacion en ingles
```

---

## Estructura esperada del proyecto

```
screening-hojas-de-vida/
├── core/
│   ├── config.py                        # Configuracion central
│   ├── logging_service.py               # Servicio de logs
│   └── database.py                      # Conexion a PostgreSQL
├── features/
│   ├── parsing/                         # Estacion 1: Leer documentos
│   │   ├── services/
│   │   │   ├── pdf_parser.py            # Parser PDF
│   │   │   ├── word_parser.py           # Parser Word/DOCX
│   │   │   └── text_extractor.py        # Texto plano / formulario
│   │   └── models/
│   │       └── raw_resume.py            # Modelo de HV cruda
│   ├── extraction/                      # Estacion 2: Datos estructurados
│   │   ├── services/
│   │   │   ├── section_detector.py      # Detecta secciones (educacion, exp)
│   │   │   └── data_extractor.py        # Extrae campos estructurados
│   │   └── models/
│   │       └── structured_resume.py     # Modelo de HV estructurada
│   ├── privacy/                         # Estacion 3: PII stripping
│   │   └── services/
│   │       ├── pii_detector.py          # Detecta datos personales
│   │       └── pii_stripper.py          # Anonimiza antes de LLM
│   ├── evaluation/                      # Estacion 4: Evaluacion LLM
│   │   ├── services/
│   │   │   ├── prompt_manager.py        # Prompts versionados
│   │   │   ├── model_router.py          # Selecciona modelo por cargo
│   │   │   ├── evaluator.py             # Evaluacion principal
│   │   │   └── confidence_scorer.py     # 4 niveles de confianza
│   │   └── models/
│   │       └── evaluation_result.py     # Resultado: Apto/Dudoso/No Apto
│   ├── dictionary/                      # Recursion Designer
│   │   ├── services/
│   │   │   ├── competency_dictionary.py # Diccionario por cargo
│   │   │   ├── unknown_detector.py      # Detecta competencias nuevas
│   │   │   └── approval_queue.py        # Cola para hiring manager
│   │   └── models/
│   │       └── dictionary_version.py
│   ├── reporting/                       # Estacion 5: Reportes
│   │   └── services/
│   │       ├── screening_report.py      # Reporte por cargo
│   │       └── monthly_summary.py       # Resumen mensual RRHH
│   ├── observability/                   # Estacion 6: Trazabilidad
│   │   └── services/
│   │       ├── langfuse_tracker.py      # Logging a Langfuse
│   │       └── drift_detector.py        # Deteccion de drift
│   └── shared/
│       ├── utils/
│       │   └── text_utils.py
│       └── models/
│           └── candidate.py             # Modelo de candidato
├── data/
│   ├── raw/                             # HVs de entrada
│   ├── profiles/                        # Perfiles de cargo (YAML/JSON)
│   ├── golden/                          # Golden dataset para calibracion
│   ├── dictionaries/                    # Diccionarios de competencias
│   └── output/                          # Reportes de screening
├── openspec/                            # Documentacion SDD
├── pipeline.yml                         # Configuracion del pipeline
├── run_screening.py                     # Punto de entrada
├── requirements.txt
└── .gitignore
```

---

## Flujo visual completo (CTO v10.0 con LLM)

```
Cliente: "Necesito automatizar screening de hojas de vida"
 |
 +-- Paso 2:  Instalar Batuta + dominio HR
 |
 +-- Paso 3:  /sdd-init .................. "Tipo: ai-agent"
 |
 +-- Paso 4:  /sdd-new ................... "Discovery: 5 preguntas obligatorias"
 |     Claude detecta: 5+ tipos cargo, taxonomias (competencias)
 |     → sugiere /process-analyst + /recursion-designer
 |
 +-- Paso 5:  /process-analyst ........... "5 variantes de cargo + excepciones"
 |
 +-- Paso 6:  /recursion-designer ........ "Competencias como diccionario versionado"
 |
 +-- Paso 7:  === GATE G0.5 === .......... "Discovery Complete? 5/5 Si"
 |             Propuesta + Cost-Benefit + Client Communication
 |     === GATE G1 === ................... "Worth Building? ROI claro"
 |
 +-- Paso 8:  /sdd-continue .............. "Specs → Design:"
 |             - LLM Pipeline (6 fases)     ← NUEVO v10.0
 |             - Compliance SIC 002/2024    ← NUEVO v10.0
 |             - Architecture Checklist     ← NUEVO v10.0
 |             "→ Tasks"
 |
 +-- Paso 9:  /sdd-apply (8 batches) ..... "Parsing → Extraccion → PII → LLM
 |                                           → Confidence → Diccionario → Reporte
 |                                           → Langfuse"
 |
 +-- Paso 10: /sdd-verify ................ "Type B Testing (auto + LLM):"
 |             - Golden dataset 50+ HVs
 |             - Confidence >85%
 |             - Costo <$0.05/HV
 |             - Prompt regression
 |
 +-- Paso 11: === GATE G2 === ............ "Production Ready?"
 |             Probar con datos reales
 |
 +-- Paso 12: /sdd-archive ............... "Learning Loop: 6 preguntas mejora"
 |
 [Screening automatizado. De 1 semana a 2 horas de revision.]
```

---

## Preguntas frecuentes

**P: El LLM puede discriminar candidatos por genero, edad o raza?**
R: El paso de PII stripping (Presidio) elimina nombre, genero, edad, foto y direccion ANTES de enviar al LLM. El LLM solo ve competencias, experiencia y educacion. Esto mitiga sesgos. Ademas, el compliance test de SIC 002/2024 documenta estas garantias.

**P: Que pasa si un candidato pide eliminar sus datos (habeas data)?**
R: El skill `compliance-colombia` incluye el Tombstoning Pattern: se eliminan datos de acceso y evaluacion, pero se retienen registros del proceso para auditoria. La Ley 1581/2012 obliga a tener un canal de rectificacion/eliminacion.

**P: El sistema puede evaluar en ingles?**
R: Si, pero debes configurarlo. El LLM entiende multiples idiomas. Agrega el idioma como criterio en el perfil del cargo.

**P: Cuanto cuesta el LLM por mes?**
R: Para 200 HVs/mes: ~$4-10 USD con Haiku/gpt-4o-mini para screening basico, ~$10-20 USD con Sonnet/gpt-4o para evaluacion detallada. El model routing optimiza: usa el modelo barato para cargos operativos y el mejor para gerenciales.

**P: Como se que el LLM esta clasificando bien?**
R: Tres mecanismos: (1) el golden dataset prueba contra evaluaciones humanas conocidas, (2) el confidence score te dice cuando el LLM no esta seguro, (3) Langfuse registra todo para auditar despues.

**P: El area solicitante puede cambiar las competencias del cargo?**
R: Si — es exactamente para eso el Recursion Designer. El hiring manager actualiza competencias, el sistema versiona el diccionario y aplica los cambios a evaluaciones futuras sin modificar las historicas.

---

## Comandos de emergencia

| Situacion | Que escribir |
|-----------|-------------|
| Claude se trabo | Cierra terminal, reabre, `claude` |
| Deshacer cambio | `Deshaz el ultimo cambio que hiciste` |
| No entiendes algo | `Explicame [X] como si tuviera 15 anos` |
| Estado del proyecto | `/sdd-continue screening-automatico` |
| LLM clasifica mal | `El LLM esta clasificando mal los cargos [tipo]. Muestra las ultimas 10 evaluaciones de Langfuse para ese cargo.` |
| Candidato pide borrar datos | `Un candidato pidio eliminar sus datos (habeas data). Aplica el protocolo de eliminacion de datos personales.` |

---

> **Recuerda**: El sistema SUGIERE, no DECIDE. Siempre hay un humano que confirma.
> Esto no es solo buena practica — es un requisito de la Circular SIC 002/2024.
> La IA es tu asistente, no tu reemplazo.
