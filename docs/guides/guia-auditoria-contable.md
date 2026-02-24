# Guia Paso a Paso: Automatizar Conciliacion Bancaria con Claude Code

> **Para quien es esta guia**: Para cualquier persona que sepa copiar y pegar texto.
> Claude Code hace la programacion, tu solo le das las instrucciones.
>
> **Formato**: Sigue los pasos en orden, como cuando aprendes a manejar.
> Cada paso depende del anterior. No saltes pasos.
>
> **Que tiene de especial esta guia**: Demuestra el flujo CTO completo (v10.0)
> — desde que un cliente te contacta con un problema hasta tener la solucion
> funcionando en produccion. Incluye Discovery, Process Analysis, y Cost-Benefit.

---

## Glosario — Palabras que vas a ver

Antes de empezar, aqui tienes un mini-diccionario. No necesitas memorizarlo, vuelve aqui si ves una palabra que no entiendes.

| Palabra | Que significa (sin tecnicismos) |
|---------|-------------------------------|
| **Conciliacion bancaria** | Comparar lo que dice tu sistema contable con lo que dice el extracto del banco, para encontrar diferencias. Como cruzar tu lista de compras con el recibo del supermercado para ver si coinciden. |
| **Extracto bancario** | El archivo que te da el banco con todos los movimientos de la cuenta: depositos, retiros, transferencias, comisiones. Puede venir en formato Excel, CSV, o PDF. |
| **ERP** | El sistema de contabilidad de la empresa (WorldOffice, Siigo, SAP, Alegra, Helisa). "Enterprise Resource Planning" — pero piensa en el como "el programa donde llevan los numeros". |
| **Partida** | Cada linea del extracto o del sistema contable. Un deposito es una partida, un retiro es otra. |
| **Partida cruzada** | Una partida que aparece tanto en el banco como en el sistema contable y coincide. Esta "conciliada". |
| **Partida pendiente** | Una partida que aparece en un lado pero no en el otro. Es la que hay que investigar. |
| **Concepto bancario** | La descripcion que el banco le pone a cada movimiento: "TRANSFERENCIA", "PAGO PSE", "COMISION IVA", etc. Cada banco usa sus propias palabras. |
| **Cuenta contable** | El "estante" donde se guarda cada tipo de movimiento en el sistema. Ejemplo: la cuenta 1110 es "Bancos", la 5305 es "Gastos financieros". |
| **Discovery** | El proceso de investigar y entender completamente el problema antes de escribir codigo. Como cuando un doctor te examina antes de recetarte. |
| **Process Analyst** | Un skill de Claude que mapea TODAS las variantes de un proceso. Descubre los casos raros que nadie menciona al principio. |
| **Recursion Designer** | Un skill de Claude que disena como el sistema aprende cuando aparecen conceptos nuevos (por ejemplo, el banco agrega un nuevo tipo de movimiento). |
| **Taxonomia externa** | Categorias que alguien fuera de tu sistema controla. Los conceptos del banco los define el banco, no tu. Las cuentas contables las define el plan contable, no tu sistema. |
| **Pipeline de datos** | Una "linea de ensamblaje" para datos. El extracto entra crudo, pasa por estaciones de limpieza y clasificacion, y sale conciliado. |
| **Golden dataset** | Un conjunto de datos donde ya sabes la respuesta correcta. Se usa para verificar que el sistema clasifica bien. |
| **Cost-Benefit** | Un analisis que compara cuanto cuesta hacer algo vs cuanto beneficio trae. Si automatizar la conciliacion cuesta $5M pero ahorra $3M al mes, se paga en menos de 2 meses. |
| **Gate** | Un punto de control obligatorio. Claude no avanza al siguiente paso hasta que pase el gate. Como un peaje: si no pagas, no pasas. |
| **SDD** | Spec-Driven Development. Un proceso paso a paso: primero planeas, luego construyes. Como un arquitecto que primero dibuja el plano. |
| **Prompt** | El mensaje que le escribes a Claude. Como enviarle un WhatsApp con instrucciones. |
| **Claude Code** | Un asistente de programacion en la terminal. Tu le dices que quieres y el lo construye. |

---

## El escenario — "Venta sobre arena movediza"

Un cliente te contacta:

> *"Necesito automatizar la conciliacion bancaria. Tenemos un contador que se
> demora 3 dias cada mes cruzando extractos de 4 bancos contra WorldOffice.
> Es un caos. Puedes ayudarme?"*

Tu no sabes exactamente como resolverlo todavia, pero dices "yo lo resuelvo". Este es el escenario de "venta sobre arena movediza" — necesitas moverte rapido desde entender el problema hasta tener una solucion, sin perder rigor.

**Esta guia te muestra el flujo completo**: Discovery → Process Analysis → Proposal con costos → Design con compliance → Implementation → Verificacion → Archive.

---

## Antes de empezar — Lo que necesitas tener instalado

| Herramienta | Para que sirve | Como instalar |
|-------------|---------------|---------------|
| **Python 3.11+** | El lenguaje de programacion | Descarga de [python.org](https://python.org) |
| **Git** | Guarda el historial del proyecto | Descarga de [git-scm.com](https://git-scm.com) |
| **Claude Code** | El asistente que programa por ti | `npm install -g @anthropic-ai/claude-code` |
| **Node.js** | Necesario para instalar Claude Code | Descarga de [nodejs.org](https://nodejs.org) la version LTS |

Para verificar, abre una terminal y escribe:
```
python --version
git --version
claude --version
```
Si todos muestran un numero, estas lista.

---

# PASO A PASO

> Sigue cada paso en orden. No saltes pasos — cada uno depende del anterior.

---

## Paso 1 — Crear la carpeta del proyecto

**Que vamos a hacer**: Crear el espacio de trabajo.

1. Crea una carpeta llamada `conciliacion-bancaria` (sin espacios, sin mayusculas)
2. Si tienes extractos bancarios de ejemplo (CSV, Excel), copialos en una subcarpeta `data/raw/`

> **IMPORTANTE sobre datos reales**: Si tus extractos tienen datos de clientes reales
> (nombres, cuentas, montos), trabaja con datos anonimizados o de prueba.
> Claude puede generar datos ficticios realistas.

---

## Paso 2 — Abrir Claude Code e instalar el ecosistema Batuta

**Que vamos a hacer**: Abrir el asistente y darle las "recetas" que necesita.

1. Abre una terminal
2. Navega a tu carpeta:

```
cd "E:\Proyectos\conciliacion-bancaria"
```

3. Abre Claude Code:

```
claude
```

4. Instala el ecosistema:

```
/batuta-init conciliacion-bancaria
```

**Si es la primera vez** y no tienes los commands:

```
Necesito configurar este proyecto con el ecosistema Batuta.

Haz lo siguiente:
1. Clona el repositorio github.com/jota-batuta/batuta-dots en una carpeta temporal
2. Ejecuta el script: bash <ruta-a-batuta-dots>/infra/setup.sh --project .
3. Inicializa git en esta carpeta si no existe
4. Confirma cuando todo este listo
```

**Que esperar**: Claude crea CLAUDE.md, .batuta/, sincroniza skills, e instala hooks. Cuando pregunte por tipo de proyecto, responde `data-pipeline`.

---

## Paso 3 — Iniciar SDD y configurar expertos de dominio

**Que vamos a hacer**: Registrar el proyecto formalmente y decirle a Claude que este proyecto toca finanzas.

```
/sdd-init
```

Cuando Claude pregunte:

| Si Claude pregunta... | Tu respondes... |
|----------------------|-----------------|
| Nombre del proyecto | `conciliacion-bancaria` |
| Tipo de proyecto | `data-pipeline` |
| Descripcion | `Pipeline que automatiza la conciliacion bancaria: lee extractos de 4 bancos (Bancolombia, Davivienda, BBVA, Bogota), cruza contra el ERP WorldOffice, clasifica diferencias, y genera reporte de partidas pendientes.` |
| Generar domain-experts? | `Si, con Finance` |

> **Que es el domain expert?** Es como decirle a Claude "en este proyecto,
> consulta siempre las reglas de contabilidad colombiana antes de tomar decisiones".
> Claude va a generar un archivo `openspec/domain-experts.md` con el experto
> Finance pre-configurado.

---

## Paso 4 — Explorar el problema (Discovery)

**Que vamos a hacer**: Investigar a fondo el problema antes de proponer una solucion. Este es el paso mas importante: el "examen medico" antes de la "receta".

```
/sdd-new conciliacion-automatica
```

Claude va a explorar el proyecto y hacerte preguntas. **Este es el momento de compartir todo lo que sabes del problema del cliente.**

**Copia y pega este contexto cuando Claude pida detalles**:

```
El cliente tiene este problema:
- 4 bancos: Bancolombia, Davivienda, BBVA, Banco de Bogota
- ERP: WorldOffice
- El contador tarda 3 dias al mes conciliando manualmente
- Extractos vienen en diferentes formatos (CSV de Bancolombia, Excel de Davivienda,
  CSV con separador diferente de BBVA, PDF de Bogota que hay que convertir)
- Cada banco usa conceptos diferentes para lo mismo:
  - Bancolombia: "TRANSF ELECTRONICA"
  - Davivienda: "TRANSFERENCIA ACH"
  - BBVA: "TR.ELECTRONICA"
  - Todos significan lo mismo: una transferencia
- El WorldOffice tiene su propio plan de cuentas
- Hay movimientos que nunca cruzan limpio: comisiones bancarias, GMF (4x1000),
  intereses, consignaciones sin identificar
- Volumen: ~2,000 movimientos por mes entre los 4 bancos
```

### Que va a pasar (Discovery Completeness)

Claude va a responder las **5 preguntas de Discovery** obligatorias:

1. **Todos los tipos de caso identificados?** — Transferencias, cheques, comisiones, GMF, intereses, consignaciones sin ID, notas debito/credito...
2. **Excepciones documentadas?** — Movimientos que nunca cruzan, diferencias de fecha, montos parciales...
3. **Categorias externas mapeadas?** — Conceptos de cada banco, plan de cuentas del ERP...
4. **Participantes listados?** — Contador, tesorero, gerente financiero, los 4 bancos, WorldOffice...
5. **Ramas del proceso cubiertas?** — Cruce exacto, cruce por monto, cruce manual, escalacion...

**Claude va a detectar complejidad** y decir algo como:

> *"Proceso complejo detectado: Se recomienda ejecutar /process-analyst para
> mapear el universo completo de variantes. Razones: 4+ tipos de caso,
> taxonomias externas (conceptos bancarios), multiples actores."*

**Tu respuesta**:

```
Si, ejecuta /process-analyst. Necesito el mapa completo antes de proponer.
```

---

## Paso 5 — Mapear todas las variantes del proceso

**Que vamos a hacer**: Usar el Process Analyst para descubrir TODOS los casos que la conciliacion maneja — no solo el "caso feliz" de transferencias que cruzan limpio.

Claude ejecuta las 6 fases del Process Analyst automaticamente:

### Fase 1 — Inventario (10 preguntas universales)

Claude te hara preguntas como:

| Pregunta | Ejemplo de respuesta |
|----------|---------------------|
| Que tipos de movimiento recibe? | Transferencias, cheques, consignaciones, comisiones, GMF, intereses, notas D/C |
| Hay casos donde se hace algo diferente? | Si: comisiones se registran directo sin cruzar. Consignaciones sin ID van a una cuenta puente |
| Cuales toman mas tiempo? | Las consignaciones sin identificar. A veces toca llamar al banco |
| Categorias externas? | Conceptos de cada banco (cada uno usa palabras diferentes) + plan de cuentas del ERP |

**Tip**: Responde con todo el detalle que puedas. Si no sabes algo, di "no se, habria que preguntarle al contador". Claude lo marca como gap pendiente.

### Fase 2 — Arbol de variantes

Claude genera algo como:

```
PROCESO: Conciliacion Bancaria
CRITERIO PRINCIPAL: Tipo de movimiento

+-- VARIANTE A: Transferencia electronica
|   +-- Identificacion: concepto contiene "TRANSF", "ACH", "TR.ELEC"
|   +-- Cruce: por monto exacto + fecha (+/- 1 dia)
|   +-- Excepciones: transferencia parcial, transferencia duplicada
|
+-- VARIANTE B: Consignacion
|   +-- Con referencia: cruce por referencia + monto
|   +-- Sin referencia: cuenta puente, esperar 48h, escalar
|
+-- VARIANTE C: Comision bancaria
|   +-- Fija (manejo cuenta): registro automatico
|   +-- Variable (GMF, IVA comision): calculo + registro
|
+-- VARIANTE D: Cheque
|   +-- Cobrado: cruce por numero cheque
|   +-- Devuelto: reversar + notificar
|
+-- CASO NO CLASIFICABLE:
    +-- Concepto desconocido → cola revision humana
```

### Fase 3 — Taxonomias externas (IMPORTANTE)

Claude va a detectar que hay **taxonomias externas** y decir:

> *"Taxonomias externas detectadas: Se recomienda ejecutar /recursion-designer.
> Taxonomias: conceptos bancarios (4 bancos), plan de cuentas ERP."*

**Tu respuesta**:

```
Si, ejecuta /recursion-designer para los conceptos bancarios.
Las cuentas contables del ERP son mas estables, no necesitan recursion.
```

---

## Paso 6 — Disenar el aprendizaje del sistema

**Que vamos a hacer**: Disenar como el sistema maneja cambios. Los bancos cambian sus conceptos sin avisar. El sistema necesita detectar lo nuevo y aprender.

Claude ejecuta el Recursion Designer con los 4 mecanismos:

### Lo que Claude va a producir

**Mecanismo 1 — Deteccion de desconocidos:**
```
Si concepto bancario NO esta en diccionario:
  → NO clasificar
  → Registrar como DESCONOCIDO con contexto
  → Comportamiento: CONTINUAR CON MARCA (procesamiento interno)
  → Escalar a tesorero para clasificacion
```

**Mecanismo 2 — Aprobacion humana:**
```
El sistema propone una clasificacion.
El tesorero decide: MAPEAR A EXISTENTE / CREAR NUEVO / DESCARTAR.
Backup: Director financiero.
```

**Mecanismo 3 — Propagacion:**
```
Politica: FORWARD (default) — solo movimientos nuevos usan el nuevo mapeo.
Movimientos anteriores marcados como DESCONOCIDO quedan pendientes.
Si el tesorero quiere reclasificar los pendientes: SOLO PENDING.
```

**Mecanismo 4 — Versionado:**
```
Cada version del diccionario de conceptos es inmutable.
Cada clasificacion registra: version del diccionario + fecha + quien aprobo.
```

**Cuando Claude termine, tu respuesta**:

```
Perfecto. Ahora continua con la propuesta.
```

---

## Paso 7 — Gate G0.5: Discovery Complete

**Que vamos a hacer**: Pasar el primer punto de control. Claude verifica que tenemos todo lo necesario para proponer una solucion.

Esto pasa **automaticamente**. Claude verifica las 5 preguntas de Discovery:

| Pregunta | Estado esperado |
|----------|----------------|
| Todos los tipos de caso? | Si (7+ variantes mapeadas) |
| Excepciones? | Si (catalogo del Process Analyst) |
| Categorias externas? | Si (Recursion Designer completo) |
| Participantes? | Si (contador, tesorero, bancos, ERP) |
| Ramas del proceso? | Si (arbol de variantes cerrado) |

**Si alguna falla**, Claude te dice que necesita y vuelve al paso 4.

**Si todas pasan**: Claude avanza automaticamente a la propuesta.

---

## Paso 8 — La propuesta con Cost-Benefit

**Que vamos a hacer**: Claude genera una propuesta formal que incluye cuanto cuesta y cuanto ahorra. Esto es lo que le presentas al cliente.

Claude genera la propuesta con 3 secciones nuevas (v10.0):

### Client Communication (lo que le envias al cliente)

Claude genera algo como:

> *"Vamos a automatizar su conciliacion bancaria. El sistema va a leer los
> extractos de los 4 bancos, cruzarlos contra WorldOffice, y generar un
> reporte con las diferencias. Lo que hoy le toma 3 dias al contador va a
> tomar 15 minutos de revision. El sistema aprende conceptos nuevos del banco
> automaticamente."*

### Cost-Benefit (lo que justifica la inversion)

| Concepto | Valor |
|----------|-------|
| Esfuerzo desarrollo | 40-60 horas (~3 semanas) |
| Infraestructura mensual | ~$50 USD (servidor Hetzner via Coolify) |
| Mantenimiento mensual | ~4 horas |
| Ahorro mensual | 3 dias/mes del contador (~$1.5M COP) |
| Tiempo para retorno | ~2 meses |
| Riesgo si no se hace | Errores humanos, demoras en cierre contable |

**Lee la propuesta con calma**. Si algo no esta bien:

```
En el cost-benefit, el ahorro mensual es mayor porque el contador gana $3M,
no $1.5M. Y agrega que hoy se pierden en promedio 2 comisiones al mes
que no se detectan (~$200K COP).
```

**Cuando estes conforme**:

```
Aprobado, continua
```

---

## Paso 9 — Gate G1: Solution Worth Building

**Que vamos a hacer**: Segundo punto de control. Claude verifica que la solucion vale la pena construirse.

Esto tambien es **automatico**. Claude verifica:
- El scope esta definido (que SI se hace, que NO se hace)
- Los stakeholders estan identificados
- Los riesgos tienen mitigacion
- El cost-benefit tiene sentido

**Si pasa**: Claude avanza a specs + design.

---

## Paso 10 — Especificaciones y diseno tecnico

**Que vamos a hacer**: Claude genera el "plano de construccion" completo. Es como el plano arquitectonico de un edificio — antes de poner el primer ladrillo.

```
/sdd-continue conciliacion-automatica
```

Ejecuta `/sdd-continue` UNA vez por fase. Repite hasta completar specs, design y tasks.

> **Alternativa rapida**: `/sdd-ff conciliacion-automatica` hace todo de corrido.

### Que tiene de especial el design (v10.0)

Claude incluye **secciones condicionales** que antes no existian:

**Data Pipeline Design** (porque es un pipeline de datos):
- Fuentes: 4 extractos bancarios + WorldOffice
- Transformaciones: normalizacion de conceptos, cruce de partidas
- Calidad: validaciones de montos, fechas, formatos
- Schema: diseño con tenant_id, UUID, timestamps

**Compliance Colombia** (porque toca datos financieros):
- Art. 632 ET: conservar registros 5 anos
- Si los extractos tienen nombres de personas: Ley 1581/2012

**Architecture Validation Checklist** (7 items):
- Scope Rule, shared state, interfaces, error paths, tenant isolation, observability, rollback

**Tu respuesta por cada fase**:

```
Se ve bien, continua
```

---

## Paso 11 — Implementar la solucion

**Que vamos a hacer**: Claude empieza a escribir codigo. Implementa en "lotes" (batches).

```
/sdd-apply conciliacion-automatica
```

**Claude va a implementar en este orden**:

| Batch | Estacion | Que hace |
|-------|----------|---------|
| 1 | Ingestion | Lee extractos de cada banco (4 parsers diferentes) |
| 2 | Normalizacion | Unifica conceptos bancarios al formato interno |
| 3 | Cruce | Compara extracto vs ERP, genera partidas cruzadas y pendientes |
| 4 | Clasificacion | Clasifica partidas pendientes (comision, GMF, sin identificar) |
| 5 | Diccionario | Implementa el Recursion Designer (deteccion de desconocidos, aprobacion) |
| 6 | Reporte | Genera reporte de conciliacion para el contador |
| 7 | Exportacion | Devuelve resultados a WorldOffice o CSV |

**Antes de cada batch**, Claude ejecuta el Execution Gate:

```
Este cambio involucra scope pipeline + infra:
- Crear N archivos en features/ingestion/
- Procedo?
```

**Tu respuesta por cada batch**:

```
Si, continua con el siguiente batch
```

### Si Claude pregunta sobre los extractos

**Si tienes extractos de ejemplo**:

```
Tengo extractos de ejemplo en data/raw/:
- bancolombia_202601.csv (separador punto y coma, encoding Latin-1)
- davivienda_202601.xlsx (hoja "Movimientos")
- bbva_202601.csv (separador coma, pero montos con punto decimal)
- bogota_202601.pdf (necesita conversion primero)
```

**Si no tienes extractos**:

```
No tengo extractos reales. Genera datos de prueba realistas para
4 bancos colombianos con ~500 movimientos por banco.
Incluye: transferencias, consignaciones, comisiones, GMF, intereses,
cheques, y al menos 10 conceptos desconocidos que no esten en el
diccionario para probar el Recursion Designer.
```

---

## Paso 12 — Verificar que todo funcione

**Que vamos a hacer**: Pedirle a Claude que revise su propio trabajo.

```
/sdd-verify conciliacion-automatica
```

### Testing por tipo de solucion (v10.0)

Claude aplica la **estrategia diferenciada** porque este proyecto usa LLM para clasificacion (si el design incluyo LLM) o puro automation (si no):

**Si es puro automation (Type A)**:
- Tests unitarios para cada parser de banco
- Tests de cruce por monto/fecha/referencia
- Tests de clasificacion de comisiones y GMF
- Tests end-to-end del pipeline completo

**Si incluye LLM para clasificacion (Type B)**:
- Todo lo anterior PLUS:
- Golden dataset de 50+ partidas con clasificacion correcta
- Validacion de confianza (>85% para aprobar automatico)
- Costo por clasificacion (<$0.01 USD por partida)
- Regression test de prompts

**Si encuentra problemas**:

```
Si, corrige todos los problemas que encontraste
```

Despues de correcciones, verifica de nuevo:

```
/sdd-verify conciliacion-automatica
```

---

## Paso 13 — Gate G2: Ready for Production

**Que vamos a hacer**: Tercer y ultimo punto de control antes de archivar.

Claude verifica automaticamente:
- AI Validation Pyramid completa (tests pasan)
- Documentacion completa (docstrings, WHY comments)
- Rollback plan existe
- Compliance revisado (Art. 632 si aplica)

**Si pasa**: Listo para archivar.

---

## Paso 14 — Probar con datos reales del cliente

**Que vamos a hacer**: El momento de la verdad. Ejecutar el pipeline con los extractos del cliente.

```
Ejecuta el pipeline completo con los datos de prueba.
Muestra el reporte de conciliacion al terminar.
Dame las instrucciones para ejecutarlo yo mismo.
```

**Que esperar**:

```
Pipeline ejecutado exitosamente.

Reporte de Conciliacion — Enero 2026:
- Movimientos leidos: 2,147 (4 bancos)
- Partidas cruzadas: 1,823 (84.9%)
- Partidas pendientes: 324 (15.1%)
  - Comisiones bancarias: 48 (auto-clasificadas)
  - GMF (4x1000): 156 (auto-clasificadas)
  - Consignaciones sin ID: 12 (pendiente revision)
  - Conceptos desconocidos: 8 (escalar a tesorero)
  - Diferencias de monto: 6 (revision manual)
  - Diferencias de fecha: 94 (cruce flexible +/-1 dia)
- Partidas sin resolver: 20 (necesitan intervencion humana)

Tiempo total: 12.3 segundos
Ahorro estimado: 2.8 dias de trabajo manual
```

**Verifica estos puntos**:
1. Las partidas cruzadas tienen sentido (montos y fechas coinciden)
2. Las comisiones y GMF se clasificaron correctamente
3. Los conceptos desconocidos se marcaron para revision
4. El reporte es claro para el contador

---

## Paso 15 — Archivar y capturar lecciones

**Que vamos a hacer**: Cerrar el proyecto formalmente. Claude archiva todo y captura las lecciones aprendidas.

```
/sdd-archive conciliacion-automatica
```

### Learning Loop (v10.0)

Claude responde 6 preguntas de mejora del ecosistema:

| Pregunta | Posible respuesta |
|----------|------------------|
| Descubrimos un patron reutilizable? | Si — el parser multi-banco podria ser un skill |
| Algun skill fallo? | No |
| Discovery se perdio algo? | Quizas — no preguntamos por tipos de cuenta (ahorros vs corriente) |
| El cost-benefit fue preciso? | Si — se tomo 50 horas, estimado era 40-60 |
| Los tests capturaron lo correcto? | Si — el golden dataset detecto 2 errores de clasificacion |
| El domain expert ayudo? | Si — el Finance expert evito un error con el redondeo de GMF |

Claude guarda estas lecciones en `lessons-learned.md` dentro del archivo.

---

# DESPUES DE LA ENTREGA

---

## Hacer cambios despues

Cuando el cliente pida algo nuevo, usa el mismo proceso:

**Agregar un nuevo banco:**
```
/sdd-new agregar-banco-occidente

El cliente ahora tambien tiene cuenta en Banco de Occidente.
Los extractos vienen en formato Excel con una estructura diferente.
```

**Cambiar reglas de clasificacion:**
```
/sdd-new actualizar-clasificacion-comisiones

Las comisiones de Bancolombia ahora incluyen IVA desglosado.
El formato cambio: antes era una sola linea, ahora son 2 lineas
(comision + IVA comision).
```

**Agregar reporte para gerencia:**
```
/sdd-new reporte-gerencial-conciliacion

El gerente financiero quiere un resumen mensual con:
- Total conciliado vs pendiente (grafico)
- Top 10 diferencias por monto
- Tendencia de los ultimos 6 meses
- Tiempo promedio de resolucion de pendientes
```

---

## Estructura esperada del proyecto

```
conciliacion-bancaria/
├── core/
│   ├── config.py                     # Configuracion central
│   ├── logging_service.py            # Servicio de logs
│   └── database.py                   # Conexion a PostgreSQL
├── features/
│   ├── ingestion/                    # Estacion 1: Leer extractos
│   │   ├── services/
│   │   │   ├── bancolombia_parser.py # Parser Bancolombia (CSV ;)
│   │   │   ├── davivienda_parser.py  # Parser Davivienda (Excel)
│   │   │   ├── bbva_parser.py        # Parser BBVA (CSV ,)
│   │   │   ├── bogota_parser.py      # Parser Bogota (PDF→CSV)
│   │   │   └── erp_reader.py         # Lee datos de WorldOffice
│   │   └── models/
│   │       └── raw_movement.py       # Modelo de movimiento crudo
│   ├── normalization/                # Estacion 2: Unificar conceptos
│   │   ├── services/
│   │   │   ├── concept_mapper.py     # Mapea conceptos bancarios
│   │   │   └── amount_normalizer.py  # Normaliza montos y fechas
│   │   └── models/
│   │       └── normalized_movement.py
│   ├── matching/                     # Estacion 3: Cruzar partidas
│   │   ├── services/
│   │   │   ├── exact_matcher.py      # Cruce por monto+fecha exacto
│   │   │   ├── fuzzy_matcher.py      # Cruce flexible (+/- 1 dia)
│   │   │   └── reference_matcher.py  # Cruce por referencia/cheque
│   │   └── models/
│   │       └── match_result.py       # Resultado: cruzada/pendiente
│   ├── classification/              # Estacion 4: Clasificar pendientes
│   │   ├── services/
│   │   │   ├── auto_classifier.py   # Clasifica comisiones, GMF, etc.
│   │   │   └── unknown_handler.py   # Maneja conceptos desconocidos
│   │   └── models/
│   │       └── classification.py
│   ├── dictionary/                  # Recursion Designer
│   │   ├── services/
│   │   │   ├── concept_dictionary.py # Diccionario versionado
│   │   │   ├── unknown_detector.py   # Detecta conceptos nuevos
│   │   │   └── approval_queue.py     # Cola de aprobacion humana
│   │   └── models/
│   │       └── dictionary_version.py
│   ├── reporting/                   # Estacion 5: Reportes
│   │   └── services/
│   │       ├── conciliation_report.py
│   │       └── pending_report.py
│   └── shared/                      # Compartido entre estaciones
│       ├── utils/
│       │   └── date_utils.py        # Utilidades de fecha
│       └── models/
│           └── movement.py          # Modelo unificado
├── data/
│   ├── raw/                         # Extractos bancarios (entrada)
│   ├── output/                      # Reportes de conciliacion
│   └── dictionaries/                # Diccionarios de conceptos
├── openspec/                        # Documentacion SDD
├── pipeline.yml                     # Configuracion del pipeline
├── run_pipeline.py                  # Punto de entrada
├── requirements.txt
└── .gitignore
```

---

## Flujo visual completo (CTO v10.0)

```
Cliente: "Necesito automatizar conciliacion bancaria"
 |
 +-- Paso 2:  Instalar Batuta + configurar dominio Finance
 |
 +-- Paso 3:  /sdd-init .................. "Registrar proyecto"
 |
 +-- Paso 4:  /sdd-new ................... "Discovery: 5 preguntas obligatorias"
 |     Claude detecta complejidad → sugiere /process-analyst
 |
 +-- Paso 5:  /process-analyst ........... "6 fases: inventario → arbol → taxonomias"
 |     Claude detecta taxonomias → sugiere /recursion-designer
 |
 +-- Paso 6:  /recursion-designer ........ "4 mecanismos: detectar → aprobar → propagar → versionar"
 |
 +-- Paso 7:  === GATE G0.5 === .......... "Discovery Complete? 5/5 Si → PASS"
 |
 +-- Paso 8:  Propuesta .................. "Cost-Benefit + Client Communication"
 |     Tu: "Aprobado"
 |
 +-- Paso 9:  === GATE G1 === ............ "Worth Building? Scope + ROI → PASS"
 |
 +-- Paso 10: /sdd-continue .............. "Specs → Design (data pipeline + compliance) → Tasks"
 |
 +-- Paso 11: /sdd-apply (7 batches) ..... "Ingestion → Normalizacion → Cruce → Clasificacion
 |                                           → Diccionario → Reporte → Exportacion"
 |
 +-- Paso 12: /sdd-verify ................ "AI Pyramid + Testing por tipo solucion"
 |
 +-- Paso 13: === GATE G2 === ............ "Production Ready? Tests + Docs + Rollback → PASS"
 |
 +-- Paso 14: Prueba con datos reales .... "84.9% cruzado, 12.3 segundos"
 |
 +-- Paso 15: /sdd-archive ............... "Lessons learned + Learning Loop"
 |
 [Conciliacion automatizada. De 3 dias a 15 minutos.]
```

---

## Preguntas frecuentes

**P: Y si mi cliente usa Siigo en vez de WorldOffice?**
R: El paso 4 cambia: describes "ERP: Siigo" en vez de "WorldOffice". Claude adapta los parsers. El skill `data-pipeline-design` tiene patrones para ERPs colombianos incluyendo Siigo, SAP B1, Alegra y Helisa.

**P: Y si el banco no da extractos en CSV/Excel sino solo PDF?**
R: Claude incluye un parser PDF (usando librerias como tabula-py o camelot). Es la variante mas compleja. Dile: "El banco X solo da extractos en PDF con tablas". Claude agregara el parser.

**P: Y si necesito que el pipeline corra automaticamente todos los dias?**
R: Despues de archivar, pide: "Configura el pipeline para que corra automaticamente cada dia a las 6 AM monitoreando data/raw/". Claude configura un scheduler o instrucciones para cron/Temporal.

**P: Como manejo los conceptos nuevos del banco?**
R: Exactamente para eso sirve el Recursion Designer (Paso 6). Cuando aparece un concepto que el sistema no conoce, lo marca como DESCONOCIDO y crea una tarea para que el tesorero lo clasifique. Una vez clasificado, el sistema aprende y no vuelve a preguntar.

**P: Necesito que esto cumpla con regulacion colombiana?**
R: El skill `compliance-colombia` se invoca automaticamente si el design detecta datos personales o registros financieros. Verifica Art. 632 ET (conservar 5 anos), y si hay datos personales, aplica Ley 1581/2012.

**P: Puedo cerrar la terminal y continuar despues?**
R: Si. Claude guarda su progreso en `.batuta/session.md`. Abre la terminal, navega a tu carpeta, escribe `claude`, y continua donde quedo.

---

## Comandos de emergencia

| Situacion | Que escribir |
|-----------|-------------|
| Claude se trabo | Cierra la terminal, abrela de nuevo, escribe `claude` |
| Quieres deshacer | `Deshaz el ultimo cambio que hiciste` |
| No entiendes algo | `Explicame [X] como si tuviera 15 anos` |
| Ver estado del proyecto | `/sdd-continue conciliacion-automatica` |
| El pipeline falla | `El pipeline falla con este archivo: [nombre]. El error es: [pega el error]` |
| El banco cambio formato | `El formato del extracto de [banco] cambio. Ahora tiene [describe cambio]` |

---

> **Recuerda**: No necesitas entender COMO funciona Python por dentro.
> Solo necesitas describir los datos que tienes, que quieres que pase con ellos,
> y a donde quieren que vayan. Claude se encarga del codigo.
> Lo importante es el Discovery — entre mas le cuentes sobre el proceso
> del cliente, mejor sera la solucion.
