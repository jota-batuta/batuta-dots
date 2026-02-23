# Guia Paso a Paso: Crear un Pipeline de Datos con Python y Claude Code

> **Para quien es esta guia**: Para cualquier persona que sepa copiar y pegar texto.
> Claude Code hace la programacion, tu solo le das las instrucciones.
>
> **Formato**: Sigue los pasos en orden, como cuando aprendes a manejar.
> Cada paso depende del anterior. No saltes pasos.

---

## Glosario — Palabras que vas a ver

Antes de empezar, aqui tienes un mini-diccionario. No necesitas memorizarlo, vuelve aqui si ves una palabra que no entiendes.

| Palabra | Que significa (sin tecnicismos) |
|---------|-------------------------------|
| **Pipeline** | Una "linea de ensamblaje" para datos. Igual que en una fabrica donde cada estacion hace una cosa al producto (cortar, pintar, empacar), un pipeline toma datos crudos y los pasa por estaciones que los limpian, transforman y entregan listos. |
| **Datos crudos** | Informacion tal cual llega, sin procesar. Como ingredientes recien comprados del mercado: sin lavar, sin pelar, sin organizar. |
| **CSV** | Un archivo de texto donde los datos estan separados por comas. Piensa en una tabla de Excel guardada en formato simple. Ejemplo: `nombre,edad,ciudad`. |
| **Excel** | Las hojas de calculo de Microsoft. Archivos con extension `.xlsx` que contienen tablas con filas y columnas. |
| **Transformacion** | Cambiar los datos de una forma a otra. Ejemplo: convertir "15 de enero de 2025" a "2025-01-15", o quitar espacios extra de los nombres. |
| **Validacion** | Revisar que los datos esten correctos antes de usarlos. Como revisar que un paquete no venga roto antes de aceptar la entrega. |
| **Duplicados** | Datos repetidos. Ejemplo: el mismo cliente aparece 3 veces en la lista. El pipeline los detecta y deja solo uno. |
| **PostgreSQL** | Una base de datos profesional. Un "almacen organizado" donde guardas datos de forma segura y puedes buscarlos rapidamente. |
| **pandas** | Una libreria de Python (un "kit de herramientas") especializada en manipular tablas de datos. Es la herramienta mas popular para limpiar y transformar datos. |
| **Polars** | Otra libreria de Python para manipular datos, pero mas rapida que pandas. Ideal cuando tienes archivos muy grandes (millones de filas). |
| **Esquema** | La "plantilla" que describe como deben verse los datos. Ejemplo: "nombre es texto, edad es numero, email tiene formato X". Como el formato de un formulario. |
| **ETL** | Extraer, Transformar, Cargar. Las 3 etapas de un pipeline: sacar datos de alguna fuente, limpiarlos, y guardarlos en el destino. |
| **Prompt** | El mensaje que le escribes a Claude. Como enviarle un WhatsApp con instrucciones. |
| **Claude Code** | Un asistente de programacion que vive en tu terminal. Tu le dices que quieres y el lo construye. |
| **Terminal** | La pantalla negra donde escribes comandos. Piensa en ella como un chat con tu computadora. |
| **Skill** | Un documento que le dice a Claude COMO hacer algo especifico. Como una receta de cocina. |
| **SDD** | Spec-Driven Development. Un proceso paso a paso para construir software: primero planeas, luego construyes. Como un arquitecto que primero dibuja el plano y luego construye la casa. |
| **Repositorio (repo)** | Una carpeta especial que guarda todo tu codigo y recuerda cada cambio que haces. |
| **Scope Agent** | Un "jefe de area" especializado. Claude tiene 3: uno para el proceso de desarrollo, uno para organizacion de archivos, y uno para calidad. |
| **Execution Gate** | Un checklist que Claude ejecuta ANTES de hacer cualquier cambio de codigo. Verifica que todo este en orden. |
| **Docker** | Una herramienta que empaqueta aplicaciones para que funcionen en cualquier computadora igual. Como meter todo en una caja con instrucciones: "abre esto en cualquier PC y funciona". |
| **Scope Rule** | La regla que decide DONDE va cada archivo en el proyecto. "El uso determina la ubicacion" — si solo una parte del proyecto usa algo, va en esa parte. |

---

## Que vamos a construir

**Batuta Data Pipeline** — Una linea de ensamblaje automatica para tus datos que:

1. **Lee archivos CSV y Excel**: Toma datos de cualquier fuente en estos formatos
2. **Limpia y transforma los datos**: Quita duplicados, corrige formatos, estandariza nombres
3. **Valida la calidad**: Revisa que los datos cumplan reglas de negocio (emails validos, edades razonables, campos obligatorios)
4. **Genera reportes de resumen**: Te dice cuantos registros proceso, cuantos tuvieron errores, estadisticas generales
5. **Exporta el resultado**: Guarda los datos limpios en PostgreSQL o en un nuevo archivo CSV

### Ejemplo concreto

Imagina que tienes un archivo `clientes.csv` con 10,000 filas:
- 500 filas estan duplicadas
- 200 tienen el email mal escrito (sin @)
- 150 tienen el nombre en MAYUSCULAS cuando deberia ser "Primera Letra Mayuscula"
- 50 tienen la edad como texto ("treinta") en vez de numero (30)

Tu pipeline va a:
1. Leer el archivo
2. Eliminar las 500 filas duplicadas
3. Marcar los 200 emails invalidos
4. Corregir los 150 nombres
5. Convertir las 50 edades de texto a numero
6. Generar un reporte: "Procesados 10,000 registros. 9,100 validos, 900 corregidos, 200 con errores"
7. Exportar los datos limpios a PostgreSQL o un nuevo CSV

### La analogia de la fabrica

Piensa en una fabrica de chocolate:

```
Estacion 1 — RECEPCION (Ingestion):
  Llegan sacos de cacao de diferentes proveedores.
  Cada proveedor empaca diferente (CSV, Excel).
  Esta estacion abre todos los sacos y los pone en una misma mesa.

Estacion 2 — LIMPIEZA (Transformacion):
  Quita piedras y ramas del cacao (datos basura).
  Clasifica por tamano (estandariza formatos).
  Mezcla los granos de diferentes proveedores en un solo formato.

Estacion 3 — CONTROL DE CALIDAD (Validacion):
  Revisa que los granos cumplan el estandar.
  Los que no pasan, van a un reporte de "rechazados".
  Los que pasan, continuan a la siguiente estacion.

Estacion 4 — EMPAQUE (Exportacion):
  Los granos aprobados se empacan para distribucion.
  Pueden ir a una bodega grande (PostgreSQL) o a bolsas individuales (CSV).
  Se genera un reporte de produccion del dia.
```

Tu pipeline de datos funciona exactamente igual, pero con informacion en vez de chocolate.

---

## Antes de empezar — Lo que necesitas tener instalado

Pide ayuda a alguien para instalar estas cosas si no las tienes:

| Herramienta | Para que sirve | Como instalar |
|-------------|---------------|---------------|
| **Python 3.11+** | El lenguaje de programacion que usara el pipeline | Descarga de [python.org](https://python.org) la version mas reciente |
| **Git** | Guarda el historial de tu proyecto | Descarga de [git-scm.com](https://git-scm.com) |
| **Claude Code** | El asistente que va a programar por ti | En la terminal escribe: `npm install -g @anthropic-ai/claude-code` |
| **Node.js** | Necesario para instalar Claude Code | Descarga de [nodejs.org](https://nodejs.org) la version LTS |

**Opcional** (solo si quieres exportar a PostgreSQL):

| Herramienta | Para que sirve | Como instalar |
|-------------|---------------|---------------|
| **Docker** | Para correr PostgreSQL en tu PC sin instalar nada mas | Descarga de [docker.com](https://docker.com) |

Para verificar que todo esta instalado, abre una terminal y escribe:
```
python --version
git --version
claude --version
node --version
```
Si todos muestran un numero (como `v3.11.5`), estas lista.

### Archivos de datos de prueba

Necesitas al menos un archivo de datos para probar. Si no tienes uno, no te preocupes — Claude puede generar datos de prueba. Pero si tienes archivos reales (un CSV exportado de Excel, por ejemplo), tenlos a la mano.

> **IMPORTANTE sobre tus datos**: Si tus archivos tienen informacion personal de personas reales
> (nombres, telefonos, emails, direcciones), ten cuidado al compartirlos con Claude.
> Mas detalles en la Seccion de Seguridad al final de esta guia.

---

# PASO A PASO

> Sigue cada paso en orden. No saltes pasos — cada uno depende del anterior,
> como cuando aprendes a manejar.

---

## Paso 1 — Crear la carpeta del proyecto

**Que vamos a hacer**: Crear una carpeta vacia donde vivira todo nuestro pipeline.

**Que hacer**:
1. Abre el Explorador de Archivos de Windows
2. Ve a donde quieras guardar tu proyecto (ejemplo: `E:\Proyectos\`)
3. Click derecho → Nueva Carpeta
4. Nombrala: `batuta-data-pipeline`

> **IMPORTANTE**: Usa nombres SIN espacios y en minusculas (ejemplo: `batuta-data-pipeline`, no `Batuta Data Pipeline`).
> Los espacios y mayusculas causan problemas con las herramientas de Python como pip.
> Usa guiones (-) en lugar de espacios.

5. Si tienes archivos de datos de prueba (CSV o Excel), copialos dentro de una subcarpeta llamada `data/raw/` dentro de tu proyecto. Si no tienes datos, Claude los generara despues.

**Resultado**: Tienes una carpeta llamada `batuta-data-pipeline` lista para trabajar.

---

## Paso 2 — Abrir Claude Code e instalar el ecosistema Batuta

**Que vamos a hacer**: Abrir el asistente de programacion y darle las "recetas" (skills) que necesita para trabajar al estilo Batuta.

**Que hacer**:
1. Abre una terminal (busca "Terminal" o "Command Prompt" en Windows)
2. Escribe exactamente esto y presiona Enter:

```
cd "E:\Proyectos\batuta-data-pipeline"
```

> Cambia la ruta si tu carpeta esta en otro lugar.

3. Ahora escribe:

```
claude
```

4. Se abre Claude Code. Ahora instala el ecosistema:

**Opcion A — Si ya tienes los commands de Batuta instalados** (recomendado):

```
/batuta-init batuta-data-pipeline
```

**Opcion B — Si es la primera vez y no tienes los commands:**

Copia y pega este prompt:

```
Necesito configurar este proyecto con el ecosistema Batuta.

Haz lo siguiente:
1. Clona el repositorio github.com/jota-batuta/batuta-dots en una carpeta temporal
2. Ejecuta el script skills/setup.sh --all para copiar CLAUDE.md y sincronizar skills
3. Copia el archivo BatutaClaude/CLAUDE.md a la raiz de este proyecto como CLAUDE.md
4. Inicializa git en esta carpeta si no existe
5. Confirma cuando todo este listo
```

**Que esperar**: Claude va a descargar el ecosistema y configurar todo. Puede tomar 1-2 minutos. Cuando termine, veras estos archivos nuevos:
- `CLAUDE.md` — Las instrucciones del chef (router principal + scope agents + execution gate)
- `.batuta/session.md` — El cuaderno donde Claude anota en que quedo (para continuar despues)
- `.batuta/prompt-log.jsonl` — La bitacora de calidad (se llena automaticamente)

**Tip**: Si Claude te pide permiso para ejecutar comandos, di "yes" o "si".

---

## Paso 3 — Iniciar el proyecto con SDD y explorar la idea

**Que vamos a hacer**: Decirle a Claude que tipo de proyecto vamos a construir y que investigue como hacerlo. Es como cuando un ingeniero estudia el proceso de la fabrica antes de disenar la linea de ensamblaje.

**Paso 3A — Inicializar el proyecto:**

```
/sdd:init
```

Cuando Claude pregunte:

| Si Claude pregunta... | Tu respondes... |
|----------------------|-----------------|
| Nombre del proyecto | `batuta-data-pipeline` |
| Tipo de proyecto | `data-pipeline` |
| Descripcion | `Pipeline de datos en Python que lee archivos CSV y Excel, limpia y transforma datos (duplicados, formatos, validacion), genera reportes de resumen, y exporta a PostgreSQL o CSV limpio. Usa pandas o polars.` |

**Paso 3B — Explorar la idea:**

```
/sdd:explore batuta-data-pipeline

Necesito explorar como construir un pipeline de datos con estas caracteristicas:

FUENTES DE DATOS (Estacion 1 — Recepcion):
- Leer archivos CSV (con diferentes separadores: coma, punto y coma, tabulador)
- Leer archivos Excel (.xlsx, multiples hojas)
- Detectar automaticamente el encoding del archivo (UTF-8, Latin-1, etc.)
- Poder procesar multiples archivos a la vez (todos los CSV de una carpeta)
- Archivos pueden ser grandes: hasta 1 millon de filas

TRANSFORMACIONES (Estacion 2 — Limpieza):
- Eliminar filas completamente duplicadas
- Estandarizar nombres: "JUAN PEREZ" → "Juan Perez"
- Estandarizar fechas: convertir cualquier formato a YYYY-MM-DD
- Limpiar espacios extra en textos: "  Juan   Perez  " → "Juan Perez"
- Normalizar telefonos: quitar guiones, espacios, parentesis
- Convertir tipos: "30" (texto) → 30 (numero)
- Reemplazar valores vacios con un valor por defecto configurable
- Poder agregar transformaciones personalizadas (reglas de negocio)

VALIDACION (Estacion 3 — Control de calidad):
- Validar emails: debe tener formato correcto (algo@algo.algo)
- Validar rangos numericos: edad entre 0 y 150, precio mayor que 0
- Validar campos obligatorios: nombre y email no pueden estar vacios
- Validar unicidad: no debe haber dos registros con el mismo email
- Validar formato de telefono: minimo 7 digitos
- Generar reporte de errores: que fila, que columna, que error
- Registros invalidos van a un archivo separado (rechazados.csv) para revision

REPORTES:
- Total de registros leidos
- Total de duplicados eliminados
- Total de transformaciones aplicadas
- Total de registros validos vs invalidos
- Estadisticas por columna: conteo, valores unicos, valores nulos
- Reporte en formato legible (no tecnico)
- Exportar reporte como archivo de texto o JSON

EXPORTACION (Estacion 4 — Empaque):
- Opcion 1: Guardar en PostgreSQL (crear tabla si no existe, o agregar a tabla existente)
- Opcion 2: Guardar como CSV limpio
- Opcion 3: Ambas — PostgreSQL y CSV
- Log de lo que se exporto: cuantos registros, a donde, cuando

CONFIGURACION:
- Un archivo de configuracion sencillo donde se define:
  - Que archivos leer y de donde
  - Que transformaciones aplicar
  - Que validaciones ejecutar
  - A donde exportar
- Que sea facil de modificar sin tocar el codigo

EJECUCION:
- Se ejecuta desde la terminal: python run_pipeline.py
- Opcionalmente, programar para que se ejecute solo cada cierto tiempo
- Sin frontend — solo terminal y archivos
```

**Que esperar**: Claude va a investigar y probablemente detecte que necesita skills para pandas/polars, validacion de datos, y posiblemente PostgreSQL. Esto es normal — el sistema de deteccion de skills esta funcionando.

---

## Paso 4 — Cuando Claude detecte skills faltantes

**Que vamos a hacer**: Entender que pasa cuando Claude detecta que necesita aprender algo nuevo. Esto es como si un ingeniero de la fabrica dijera "necesito estudiar como funciona esta maquina nueva antes de instalarla".

Claude va a decir que no tiene skills para:
- **pandas/polars** (manipulacion de datos)
- **Validacion de datos** (reglas de calidad)
- Posiblemente **PostgreSQL** (base de datos)

**Tu respuesta cada vez que pregunte:**

```
Opcion 1 — Investiga y crea el skill acotado a nuestro proyecto
```

Esto puede pasar 2-4 veces. Cada vez, responde "Opcion 1". Claude va a investigar en Context7 (su base de conocimiento actualizada) y crear las recetas que necesita.

> **Detalle tecnico (opcional)**: El infra-agent (jefe de almacen) coordina la creacion
> de skills nuevos. Usa el ecosystem-creator para investigar y documentar la tecnologia.

**Tip**: Este paso puede tomar 10-15 minutos en total. Es una inversion que se paga sola — Claude va a escribir mejor codigo porque tiene las recetas correctas.

---

## Paso 5 — Crear la propuesta

**Que vamos a hacer**: Pedirle a Claude que escriba un plan formal de lo que va a construir. Como cuando el ingeniero de la fabrica te muestra el plano de la linea de ensamblaje antes de instalarla.

**Copia y pega este prompt**:

```
/sdd:new batuta-data-pipeline
```

**Que esperar**: Claude va a crear un documento llamado "proposal" que incluye:
- Que se va a construir (en lenguaje simple)
- Que riesgos hay
- Criterios de exito (como sabemos que funciona)

Claude te mostrara un **resumen** y te preguntara si esta bien.

**Lee el resumen con calma**. Si algo no te suena bien, dile. Por ejemplo:

```
Me parece bien pero agrega que los archivos rechazados deben incluir
la razon del rechazo en cada fila, no solo que fueron rechazados.
```

**Cuando estes conforme, di:**

```
Aprobado, continua con el siguiente paso
```

---

## Paso 6 — Especificaciones y diseno

**Que vamos a hacer**: Dejar que Claude avance por las fases de planificacion. El va a definir exactamente que hace cada estacion de la fabrica y como se conectan entre si.

**Copia y pega este prompt**:

```
/sdd:continue batuta-data-pipeline
```

**Que esperar**: Claude va a ejecutar estas fases en orden:

| Fase | Que hace (en terminos de fabrica) | Cuanto toma |
|------|----------------------------------|-------------|
| **Specs** | Define exactamente que hace cada estacion: que recibe, que entrega, que reglas sigue | 2-5 min |
| **Design** | Decide que maquinas usar: pandas vs polars, como conectar las estaciones, donde van los cables | 3-5 min |
| **Tasks** | Divide la instalacion en tareas pequenas: "primero instalar estacion 1, luego estacion 2..." | 2-3 min |

**Entre cada fase**, Claude te muestra un resumen y pregunta si continua.

**Tu respuesta cada vez**:

```
Se ve bien, continua
```

**Si algo no entiendes**, pregunta sin miedo:

```
No entendi la parte de "schema validation con pydantic". Explicame
que significa eso en terminos simples.
```

Claude esta configurado para explicarte las cosas de forma que cualquier persona las entienda.

**Tip**: Este paso puede tomar 10-15 minutos. Puedes ir por un cafe mientras Claude trabaja entre fases.

---

## Paso 7 — Construir la ingestion de datos (Estacion 1)

**Que vamos a hacer**: Pedirle a Claude que empiece a construir el pipeline. Empezamos por la primera estacion: la que lee los archivos de datos.

**Copia y pega este prompt**:

```
/sdd:apply batuta-data-pipeline
```

**Que esperar**: Antes de escribir codigo, Claude ejecuta el **Execution Gate** — un checklist automatico que verifica:
- Que archivos va a crear/modificar
- Donde van a ir (siguiendo la Scope Rule)
- Que impacto tienen los cambios
- Que todo este alineado con las especificaciones

Te mostrara algo como:
```
Este cambio involucra scope pipeline + infra:
- Crear 8 archivos nuevos en features/ingestion/
- Crear 3 archivos en core/
- Crear archivos de configuracion
- Procedo?
```

Claude va a implementar en "lotes" (batches). El primer lote generalmente es la estructura del proyecto y la ingestion de datos.

**Tu respuesta**:

```
Si, continua con el siguiente batch
```

**Cuando Claude pregunte sobre los datos de prueba:**

Si tienes archivos CSV o Excel de prueba:
```
Tengo archivos de prueba en la carpeta data/raw/:
- clientes.csv (tiene columnas: nombre, email, telefono, edad, ciudad)
- ventas.xlsx (hoja 1: ventas_2024, hoja 2: ventas_2025)
```

Si no tienes archivos:
```
No tengo datos de prueba. Genera un CSV de ejemplo con 1000 filas
que tenga: nombre, email, telefono, edad, ciudad.
Incluye errores intencionales: duplicados, emails invalidos, edades
imposibles, nombres en mayusculas, para poder probar todas las estaciones.
```

---

## Paso 8 — Construir las transformaciones (Estacion 2)

**Que vamos a hacer**: Claude continua con el segundo batch — las transformaciones que limpian los datos. Esta es la estacion que toma los datos crudos y los pone "bonitos".

**Que hacer**: Claude deberia continuar automaticamente al siguiente batch. Si no lo hace, escribe:

```
Continua con el siguiente batch de implementacion — las transformaciones de datos.
```

**Que esperar**: Claude va a crear funciones para:
- Eliminar duplicados
- Estandarizar nombres, fechas, telefonos
- Limpiar espacios extra
- Convertir tipos de datos
- Aplicar reglas personalizadas desde la configuracion

**Tu respuesta por cada batch**:

```
Si, continua con el siguiente batch
```

**Si Claude pide permisos para instalar dependencias** (librerias que el proyecto necesita):

Di "yes". Esto instala las herramientas de Python que tu pipeline necesita (como pandas para manipular datos).

---

## Paso 9 — Construir la validacion (Estacion 3)

**Que vamos a hacer**: Claude construye la estacion de control de calidad — la que revisa que los datos esten correctos.

**Que esperar**: Claude va a crear:
- Validadores de email, rangos numericos, campos obligatorios
- Un sistema de reportes que dice exactamente que fallo y en que fila
- Un archivo de "rechazados" con los registros que no pasaron el control

**Si Claude te pregunta sobre las reglas de validacion:**

```
Las reglas de validacion son:
- Email: debe tener formato valido (algo@algo.algo)
- Edad: entre 0 y 150 (si aplica)
- Telefono: minimo 7 digitos
- Nombre: no puede estar vacio
- Email: no puede estar vacio
- No puede haber dos registros con el mismo email
```

Si tu pipeline es para datos especificos de tu negocio, describe tus reglas:

```
Agrega estas reglas especificas de mi negocio:
- El campo "monto" debe ser mayor que 0 y menor que 1,000,000
- El campo "codigo_producto" debe empezar con "PRD-" seguido de 4 numeros
- El campo "fecha_compra" no puede ser una fecha futura
```

---

## Paso 10 — Construir la exportacion (Estacion 4)

**Que vamos a hacer**: Claude construye la ultima estacion — la que guarda los datos limpios en su destino final.

**Que esperar**: Claude va a crear:
- Exportacion a CSV limpio
- Exportacion a PostgreSQL (si lo pediste)
- Generacion de reportes de resumen
- Log de lo que se proceso

**Si quieres exportar a PostgreSQL**, Claude te preguntara los datos de conexion:

```
Para desarrollo local con Docker:
- Host: localhost
- Puerto: 5432
- Usuario: batuta
- Contrasena: batuta_dev
- Base de datos: batuta_pipeline
- Tabla: datos_limpios

Levanta PostgreSQL con Docker si no esta corriendo.
```

**Si solo quieres exportar a CSV** (mas sencillo):

```
Por ahora solo exporta a CSV. El archivo de salida debe ir en data/output/
con el nombre: datos_limpios_YYYY-MM-DD.csv (la fecha de hoy).
```

---

## Paso 11 — Verificar que todo funcione

**Que vamos a hacer**: Pedirle a Claude que revise su propio trabajo. Como cuando el gerente de la fabrica revisa cada estacion antes de arrancar la produccion.

**Copia y pega este prompt**:

```
/sdd:verify batuta-data-pipeline
```

**Que esperar**: Claude va a verificar:
- Que el codigo hace lo que las especificaciones dicen
- Que los tests pasan (pruebas automaticas)
- Que cada estacion del pipeline funciona individualmente
- Que el pipeline completo funciona de punta a punta

Si encuentra problemas, los va a listar y te va a preguntar si quieres que los corrija.

**Tu respuesta**:

```
Si, corrige todos los problemas que encontraste
```

Despues de las correcciones, ejecuta verify otra vez:

```
/sdd:verify batuta-data-pipeline
```

**Cuando todo este verde (sin errores)**, continua al siguiente paso.

---

## Paso 12 — Probar el pipeline completo en tu computadora

**Que vamos a hacer**: Ejecutar el pipeline de punta a punta con datos reales (o de prueba) y verificar que todo funciona. El momento de la verdad.

**Copia y pega este prompt**:

```
Ejecuta el pipeline completo con los datos de prueba para que pueda ver
los resultados. Muestra el reporte de resumen al terminar.

Dame las instrucciones paso a paso de como ejecutarlo yo mismo despues.
```

**Que esperar**: Claude va a ejecutar el pipeline y mostrarte algo como:

```
Pipeline ejecutado exitosamente.

Reporte de resumen:
- Archivos procesados: 2 (clientes.csv, ventas.xlsx)
- Total registros leidos: 10,500
- Duplicados eliminados: 523
- Transformaciones aplicadas: 1,247
  - Nombres estandarizados: 456
  - Fechas corregidas: 312
  - Telefonos normalizados: 479
- Validacion:
  - Registros validos: 9,650
  - Registros invalidos: 327
  - Errores por tipo:
    - Email invalido: 198
    - Edad fuera de rango: 45
    - Campo obligatorio vacio: 84
- Exportacion:
  - CSV: data/output/datos_limpios_2026-02-22.csv (9,650 registros)
  - Rechazados: data/output/rechazados_2026-02-22.csv (327 registros)

Tiempo total: 4.2 segundos
```

**Prueba estas cosas**:
1. Abre el archivo de salida (`data/output/datos_limpios_...csv`) en Excel para ver si los datos se ven bien
2. Abre el archivo de rechazados para ver si los errores estan bien explicados
3. Ejecuta el pipeline tu mismo desde la terminal:

```
python run_pipeline.py
```

**Si algo no funciona**, dile a Claude exactamente que ves:

```
Cuando ejecuto el pipeline me sale un error que dice "UnicodeDecodeError".
El archivo clientes.csv fue exportado de Excel en espanol.
```

Claude va a investigar y corregir el problema.

---

## Paso 13 — Programar ejecucion automatica y archivar

**Que vamos a hacer**: Si quieres que el pipeline se ejecute solo cada cierto tiempo (por ejemplo, cada dia a las 6 AM), este paso lo configura. Luego cerramos el proyecto formalmente.

**Si quieres ejecucion automatica**, copia y pega este prompt:

```
Configura el pipeline para que se ejecute automaticamente cada dia a las 6 AM.

Opciones:
- Para desarrollo: un scheduler en Python que ejecute el pipeline periodicamente
- Para produccion: instrucciones para configurar un "cron job" o tarea programada

Necesito ambas opciones. El pipeline debe monitorear una carpeta de entrada
(data/raw/) y procesar cualquier archivo nuevo que aparezca ahi.
```

**Para cerrar el proyecto:**

```
/sdd:archive batuta-data-pipeline
```

Claude cierra el proyecto formalmente: verifica que todo esta completo, guarda las lecciones aprendidas, y actualiza `.batuta/session.md`.

**Tu pipeline de datos esta funcionando. Felicidades!**

---

# DESPUES DE LA ENTREGA

> Estos pasos son opcionales pero recomendados para mantener tu pipeline saludable.

---

## Hacer cambios despues

Cuando quieras agregar algo nuevo al pipeline, NO edites el codigo directamente. Usa el mismo proceso:

```
/sdd:new nombre-del-cambio

Quiero agregar [descripcion de lo que quieres cambiar o agregar].
```

### Ejemplos de cambios comunes

**Agregar una nueva fuente de datos (JSON):**
```
/sdd:new agregar-fuente-json

Quiero que el pipeline tambien pueda leer archivos JSON ademas de CSV y Excel.
El JSON puede tener estructura anidada (datos dentro de datos).
```

**Agregar una nueva transformacion:**
```
/sdd:new nueva-transformacion-moneda

Quiero agregar una transformacion que convierta montos en pesos colombianos
a dolares usando una tasa de cambio configurable.
```

**Agregar una nueva validacion:**
```
/sdd:new validacion-nit

Quiero agregar una validacion para el campo "NIT" que verifique que
tenga el formato correcto de NIT colombiano (numeros + digito de verificacion).
```

Y sigue el mismo flujo: explore → propose → specs → design → tasks → apply → verify.

> **Importante**: Cada cambio pasa por el Execution Gate automaticamente.
> Claude valida que el cambio siga las reglas del proyecto antes de escribir codigo.

---

## Estructura esperada del proyecto

Asi se ve un pipeline de datos organizado con la Scope Rule:

```
batuta-data-pipeline/
├── core/                              # Singletons de la app
│   ├── config.py                     # Configuracion central (lee pipeline.yml)
│   ├── logging_service.py            # Servicio de logs
│   └── database.py                   # Conexion a PostgreSQL (si aplica)
├── features/
│   ├── ingestion/                    # Estacion 1: Leer datos
│   │   ├── services/
│   │   │   ├── csv_reader.py         # Lee archivos CSV
│   │   │   ├── excel_reader.py       # Lee archivos Excel
│   │   │   └── file_detector.py      # Detecta tipo y encoding
│   │   └── models/
│   │       └── raw_data.py           # Modelo de datos crudos
│   ├── transformation/               # Estacion 2: Limpiar datos
│   │   ├── services/
│   │   │   ├── deduplicator.py       # Elimina duplicados
│   │   │   ├── name_normalizer.py    # Estandariza nombres
│   │   │   ├── date_formatter.py     # Corrige fechas
│   │   │   ├── phone_cleaner.py      # Normaliza telefonos
│   │   │   └── type_converter.py     # Convierte tipos de datos
│   │   └── models/
│   │       └── transform_rules.py    # Reglas configurables
│   ├── validation/                   # Estacion 3: Control de calidad
│   │   ├── services/
│   │   │   ├── email_validator.py    # Valida emails
│   │   │   ├── range_validator.py    # Valida rangos numericos
│   │   │   ├── required_validator.py # Valida campos obligatorios
│   │   │   └── unique_validator.py   # Valida unicidad
│   │   ├── models/
│   │   │   └── validation_rules.py   # Reglas de validacion
│   │   └── reports/
│   │       └── error_reporter.py     # Genera reporte de errores
│   ├── export/                       # Estacion 4: Guardar resultados
│   │   ├── services/
│   │   │   ├── csv_exporter.py       # Exporta a CSV
│   │   │   ├── postgres_exporter.py  # Exporta a PostgreSQL
│   │   │   └── report_generator.py   # Genera reporte de resumen
│   │   └── models/
│   │       └── export_config.py      # Configuracion de destino
│   └── shared/                       # Compartido entre estaciones
│       ├── utils/
│       │   ├── encoding_detector.py  # Detecta encoding de archivos
│       │   └── data_types.py         # Tipos de datos comunes
│       └── models/
│           └── pipeline_record.py    # Modelo de un registro del pipeline
├── data/
│   ├── raw/                          # Archivos de entrada (datos crudos)
│   ├── output/                       # Archivos de salida (datos limpios)
│   └── rejected/                     # Archivos de rechazados
├── pipeline.yml                      # Configuracion del pipeline
├── run_pipeline.py                   # Punto de entrada principal
├── run_scheduled.py                  # Ejecucion programada (opcional)
├── docker-compose.yml                # PostgreSQL + servicios (si aplica)
├── requirements.txt                  # Dependencias de Python
├── .env                              # Variables de entorno (NO va a git)
└── .gitignore
```

> Nota como sigue la **Scope Rule**: cada estacion tiene su carpeta (ingestion, transformation, validation, export), shared solo tiene lo que usan 2+ estaciones, y core tiene los singletons (config, database, logging).

---

## Mejorar tus instrucciones

Despues de trabajar un rato con Claude (10+ interacciones):

```
/batuta:analyze-prompts
```

Claude analiza la bitacora de calidad y te dice:
- Cuantas veces tuvo que corregir algo
- Que tipo de errores comete mas seguido
- Recomendaciones concretas para que tus proximos pedidos sean mas claros

---

## Comandos de emergencia

| Situacion | Que escribir |
|-----------|-------------|
| Claude se trabo y no responde | Cierra la terminal, abrela de nuevo, escribe `claude` |
| Quieres deshacer el ultimo cambio | `Deshaz el ultimo cambio que hiciste` |
| No entiendes algo | `Explicame [lo que no entiendes] como si tuviera 15 anos` |
| Quieres ver el estado del proyecto | `/sdd:continue batuta-data-pipeline` (te muestra donde quedamos) |
| El pipeline falla con un archivo | `El pipeline falla con este archivo: [nombre]. El error es: [pega el error]` |

---

# SECCION DE SEGURIDAD

> Esta seccion es importante. Leela completa antes de usar el pipeline con datos reales.

---

## Datos personales en tus archivos (PII)

**PII** significa "Informacion Personal Identificable" — nombres, emails, telefonos, direcciones, numeros de identificacion. Piensa en PII como la informacion que le permitiria a alguien identificar a una persona especifica.

### Reglas de oro

| Regla | Por que | Que hacer |
|-------|--------|-----------|
| **Nunca subas datos reales a GitHub** | Cualquiera podria verlos si el repo es publico | Agrega los archivos de datos al `.gitignore` |
| **Usa datos de prueba cuando puedas** | Datos inventados no ponen en riesgo a nadie | Pide a Claude que genere datos de prueba realistas |
| **Si usas datos reales, trabaja local** | Tu computadora es mas segura que internet | No subas archivos con PII a ningun servicio en la nube |
| **Anonimiza datos sensibles** | Puedes probar el pipeline sin exponer a nadie | Pide a Claude que agregue un paso de anonimizacion |

### Como pedirle a Claude que anonimice datos

```
Agrega un paso al pipeline ANTES de la exportacion que anonimice los datos:
- Reemplazar nombres reales con nombres ficticios
- Reemplazar emails reales con emails ficticios (manteniendo el dominio)
- Reemplazar los ultimos 4 digitos de telefonos con XXXX
- Mantener la estructura de los datos intacta para que sigan siendo utiles

Esto solo debe activarse cuando el archivo de configuracion diga
"anonimizar: true".
```

---

## Rutas de archivos (Path Traversal)

Cuando tu pipeline lee archivos de una carpeta, un atacante podria intentar que lea archivos que no deberia (como archivos del sistema operativo) usando rutas maliciosas.

**Claude ya sabe proteger contra esto**, pero verifica que:
- El pipeline SOLO lea archivos de la carpeta `data/raw/`
- Nunca acepte rutas que contengan `..` (que significa "sube un nivel de carpeta")
- Valide que la extension del archivo sea `.csv` o `.xlsx` antes de leerlo

Si quieres estar seguro, dile a Claude:

```
Verifica que el pipeline tenga proteccion contra path traversal:
que solo lea archivos de data/raw/ y rechace rutas con ".." o
rutas absolutas que apunten fuera del proyecto.
```

---

## Inyeccion SQL (si exportas a PostgreSQL)

Cuando tu pipeline guarda datos en PostgreSQL, un dato malicioso podria contener codigo SQL que intente dañar tu base de datos. Esto se llama "inyeccion SQL" — es como si alguien escribiera en el campo "nombre" algo que borra toda la tabla.

**Claude usa "parametros" al escribir en la base de datos** (la forma segura de hacerlo), lo cual previene este ataque. Pero si quieres estar seguro:

```
Verifica que todas las consultas a PostgreSQL usen parametros
(parameterized queries) y nunca construyan SQL concatenando strings.
Muestra las lineas de codigo relevantes.
```

---

## Archivos de configuracion y secretos

| Archivo | Debe ir en .gitignore? | Por que |
|---------|----------------------|--------|
| `pipeline.yml` | No | No tiene secretos, solo configuracion del pipeline |
| `.env` | SI | Contiene contrasenas de la base de datos |
| `data/raw/*` | SI | Puede contener datos personales |
| `data/output/*` | SI | Contiene datos procesados (pueden tener PII) |
| `credentials.json` | SI | Credenciales de servicios externos |

---

# USANDO AGENT TEAMS (Equipos de Agentes)

Cuando te sientas comodo con los pasos anteriores, puedes usar **Agent Teams** para que Claude trabaje con multiples "asistentes" en paralelo. Es como tener un equipo de ingenieros instalando todas las estaciones de la fabrica al mismo tiempo.

---

## Cuando usar cada nivel

| Nivel | Cuando usarlo | Ejemplo en este proyecto |
|-------|--------------|------------------------|
| **Solo** (normal) | Cambios simples, 1-2 archivos | "Agrega un validador para el campo 'NIT'" |
| **Subagente** (automatico) | Investigar o verificar algo | Claude investiga si polars es mejor que pandas para tu volumen de datos |
| **Agent Team** (tu lo pides) | Trabajo grande en multiples partes | Implementar las 4 estaciones del pipeline de una vez |

## Cuando pedir un equipo

Pide un Agent Team cuando tu pipeline tiene **3 o mas fuentes de datos** o cuando necesitas implementar multiples estaciones al mismo tiempo. El template de referencia es **data-pipeline** (Patron D — Cross-Layer).

El equipo para un pipeline de datos se compone de:

| Teammate | Que hace | Que archivos son suyos |
|----------|---------|----------------------|
| `pipeline-dev` | Implementa la logica de extraccion, transformacion y carga | `features/ingestion/`, `features/transformation/`, `features/export/` |
| `data-validator` | Implementa validaciones y tests de calidad de datos | `features/validation/`, `tests/`, esquemas |
| `infra-dev` | Configura Docker, PostgreSQL, scheduling | `Dockerfile`, `docker-compose.yml`, configuracion |

El Lead (Claude principal) coordina todo: define los esquemas de datos, reparte las tareas, y verifica que todo encaje al final.

## Como pedirle a Claude que use un equipo

```
Tu: "Necesito implementar el pipeline completo con 3 fuentes de datos
     (CSV de ventas, Excel de clientes, CSV de productos).
     Crea un equipo para que las estaciones se implementen en paralelo."
```

Claude va a:
1. Evaluar si el trabajo justifica un equipo (3 fuentes + 4 estaciones = si)
2. Definir contratos: que recibe y que entrega cada asistente
3. Crear 3 asistentes especializados (pipeline-dev, data-validator, infra-dev)
4. Repartir el trabajo
5. Cada asistente trabaja en su parte al mismo tiempo
6. El Lead verifica que todo encaje al final

## Ejemplos practicos

**Ejemplo 1 — Multiples fuentes en paralelo:**
```
Tu: "Tengo 3 fuentes de datos: API REST, CSV, y base de datos MySQL.
     Que cada asistente implemente un extractor diferente mientras
     otro prepara las validaciones."
```

**Ejemplo 2 — Pipeline + infraestructura al mismo tiempo:**
```
Tu: "Implementa las transformaciones de datos mientras otro asistente
     configura Docker y PostgreSQL para la exportacion."
```

**Ejemplo 3 — Optimizacion en equipo:**
```
Tu: "El pipeline tarda 10 minutos con 1 millon de filas. Que un asistente
     pruebe con polars en vez de pandas, otro optimice las consultas SQL,
     y comparemos cual mejora mas el rendimiento."
```

## Metricas esperadas de rendimiento

Anota tus resultados reales para mejorar el sistema con `/batuta:analyze-prompts`.

| Escenario | Nivel | Tiempo estimado | Costo tokens | Calidad esperada | Fortaleza | Debilidad |
|-----------|-------|----------------|-------------|-----------------|-----------|-----------|
| Agregar 1 validador | Solo | 3-5 min | ~5K tokens | 95% primera vez | Rapido, preciso | N/A |
| Implementar 1 estacion SDD | Solo + Subagente | 15-25 min | ~50K tokens | 85% primera vez | Proceso trazable, spec completa | Secuencial |
| Pipeline completo (4 estaciones) | Agent Team | 25-40 min | ~180K tokens | 80% primera vez | Estaciones en paralelo | Integracion entre estaciones manual |
| Optimizacion A/B (pandas vs polars) | Agent Team | 15-25 min | ~120K tokens | 85% comparacion util | Multiples enfoques rapido | Necesita datos de prueba reales |
| Pipeline 3+ fuentes + validacion | Agent Team | 30-50 min | ~220K tokens | 80% primera vez | Cada fuente independiente | Esquemas deben estar bien definidos |

> **Importante**: Los Agent Teams brillan cuando tienes estaciones independientes del pipeline
> (cada una se puede implementar sin depender de las otras). Para cambios que afectan como
> las estaciones se conectan entre si, el modo Solo con SDD suele ser mas confiable.

---

# TROUBLESHOOTING — Problemas Comunes y Soluciones

---

## Errores de encoding (los caracteres se ven raro)

**Sintoma**: Los datos tienen caracteres como `Ã±` en vez de `n`, o `Â¡` en vez de `!`.

**Por que pasa**: El archivo fue guardado con un encoding diferente al que el pipeline espera. Es como intentar leer un libro en japones usando un diccionario de chino — las letras se mezclan.

**Que decirle a Claude**:

```
El archivo clientes.csv tiene problemas de encoding. Los caracteres con
tilde y ene se ven corruptos. El archivo fue exportado de Excel en espanol
(probablemente Latin-1 o Windows-1252). Arregla la deteccion de encoding.
```

---

## Columnas faltantes (el archivo no tiene los campos esperados)

**Sintoma**: Error que dice algo como "KeyError: 'email'" o "columna no encontrada".

**Por que pasa**: El archivo tiene nombres de columnas diferentes a los que el pipeline espera. Ejemplo: el pipeline busca "email" pero el archivo tiene "correo_electronico".

**Que decirle a Claude**:

```
El pipeline falla porque el archivo tiene columnas con nombres diferentes:
- El pipeline busca "email" pero el archivo tiene "correo_electronico"
- El pipeline busca "nombre" pero el archivo tiene "nombre_completo"

Agrega un paso de mapeo de columnas en la configuracion para poder
decirle al pipeline como se llaman las columnas en cada archivo.
```

---

## Archivos muy grandes (se queda sin memoria)

**Sintoma**: El pipeline se congela o da error de memoria con archivos de millones de filas.

**Por que pasa**: Python intenta cargar todo el archivo en la memoria de tu computadora a la vez. Si el archivo pesa 2 GB y tu PC tiene 8 GB de memoria, se queda sin espacio.

**Que decirle a Claude**:

```
El pipeline se queda sin memoria con archivos de 2 millones de filas.
Necesito que procese los datos en "pedazos" (chunks) de 50,000 filas
a la vez en lugar de cargar todo el archivo de una vez.

Si no es suficiente, evalua cambiar de pandas a polars que es mas
eficiente con archivos grandes.
```

---

## El pipeline no encuentra los archivos

**Sintoma**: Error que dice "FileNotFoundError" o "archivo no encontrado".

**Por que pasa**: La ruta del archivo esta mal escrita o el archivo esta en otro lugar.

**Que decirle a Claude**:

```
El pipeline no encuentra mis archivos. Estan en:
E:\Proyectos\batuta-data-pipeline\data\raw\clientes.csv

Verifica que la configuracion del pipeline apunte a la carpeta correcta
y que funcione en Windows (usa rutas con barras invertidas o Path de Python).
```

---

## Error al conectar con PostgreSQL

**Sintoma**: Error de conexion a la base de datos ("connection refused", "authentication failed").

**Que decirle a Claude**:

```
No puedo conectar con PostgreSQL. El error es: [pega el error aqui].
- Docker esta corriendo? Verifica con: docker ps
- Los datos de conexion en .env son correctos?
- El puerto 5432 esta disponible?
Diagnostica y arregla el problema.
```

---

## Los datos de salida no se ven bien en Excel

**Sintoma**: Cuando abres el CSV en Excel, las columnas estan mezcladas o los acentos se ven mal.

**Que decirle a Claude**:

```
Cuando abro el CSV de salida en Excel, las columnas no se separan bien
y los acentos se ven como caracteres raros.
Configura la exportacion CSV para que:
1. Use punto y coma (;) como separador en vez de coma (Excel en espanol lo prefiere)
2. Use encoding UTF-8 con BOM (para que Excel reconozca los acentos)
3. Ponga comillas alrededor de campos que contienen comas
```

---

## Preguntas frecuentes

**P: Puedo usar este pipeline para datos de Excel con formulas?**
R: El pipeline lee los VALORES finales de Excel, no las formulas. Si tu hoja tiene formulas, el pipeline ve el resultado de la formula, no la formula en si.

**P: Cuantas filas puede procesar?**
R: Con pandas, hasta ~500,000 filas comodamente en una PC normal. Para mas de 1 millon, es mejor usar polars (mas rapido y eficiente). Claude puede hacer el cambio por ti.

**P: Puedo programar el pipeline para que corra todos los dias?**
R: Si. El Paso 13 cubre esto. Puedes usar un scheduler de Python o un cron job del sistema operativo.

**P: El pipeline puede leer datos de una API en vez de archivos?**
R: No con la version basica, pero puedes pedirle a Claude que agregue un extractor de API. Usa el proceso SDD (`/sdd:new agregar-fuente-api`).

**P: Puedo cerrar la terminal y continuar despues?**
R: Si. Abre la terminal, navega a tu carpeta, escribe `claude`, y Claude automaticamente lee `.batuta/session.md` donde guardo en que quedo.

**P: Que pasa si mi archivo tiene hojas con nombres en espanol con acentos?**
R: El pipeline debe manejar esto correctamente. Si da error, dile a Claude el nombre exacto de la hoja y el error.

---

## Resumen visual del flujo completo

```
Tu (archivos CSV/Excel crudos)
 |
 +-- Paso 2:  Instalar ecosistema Batuta + crear .batuta/
 |
 +-- Paso 3:  /sdd:init + /sdd:explore ..... "Que tipo de fabrica necesitamos?"
 |
 |   [Claude detecta skills faltantes → Paso 4: "Opcion 1"]
 |
 +-- Paso 5:  /sdd:new .................... "Propuesta: plano de la fabrica"
 |     Tu: "Aprobado"
 |
 +-- Paso 6:  /sdd:continue ............... "Specs → Design → Tasks"
 |     Tu: "Continua" (3 veces)
 |
 +-- Paso 7:  /sdd:apply (Batch 1) ........ "Estacion 1: Ingestion"
 |     [Execution Gate valida antes de cada cambio]
 |
 +-- Paso 8:  /sdd:apply (Batch 2) ........ "Estacion 2: Transformacion"
 |
 +-- Paso 9:  /sdd:apply (Batch 3) ........ "Estacion 3: Validacion"
 |
 +-- Paso 10: /sdd:apply (Batch 4) ........ "Estacion 4: Exportacion"
 |
 +-- Paso 11: /sdd:verify ................. "Control de calidad final"
 |
 +-- Paso 12: Probar con datos reales ..... "Arrancar la fabrica"
 |
 +-- Paso 13: Ejecucion automatica ........ "La fabrica trabaja sola"
 |             + /sdd:archive .............. "Cerrar y celebrar"
 |
 [Datos limpios, validados y exportados!]
```

---

> **Recuerda**: No necesitas entender COMO funciona Python o pandas por dentro.
> Solo necesitas describir que datos tienes, que les quieres hacer, y a donde quieres
> que vayan. Claude se encarga del resto. Como aprender a manejar: primero sigues
> las instrucciones al pie de la letra, y con el tiempo lo haces naturalmente.
