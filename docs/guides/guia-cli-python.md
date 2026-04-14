# Guia Paso a Paso: Herramienta CLI en Python con Claude Code

> **Para quien es esta guia**: Para cualquier persona, sin importar si nunca ha programado.
> Solo necesitas saber copiar y pegar texto. Claude Code hace el resto.
>
> **Formato**: Sigue los pasos en orden, como cuando aprendes a manejar un carro:
> primero el cinturon, luego el espejo, luego el freno, luego arrancar.
> Cada paso depende del anterior.
>
> **Nota especial**: Este proyecto es mas pequeno y sencillo que los otros de las guias.
> Lo haremos en modo Solo (Level 1) — tu y Claude, uno a uno, sin equipos de agentes.

---

## Glosario — Palabras que vas a ver

Antes de empezar, aqui tienes un mini-diccionario. No necesitas memorizarlo, vuelve aqui si ves una palabra que no entiendes.

| Palabra | Que significa (sin tecnicismos) |
|---------|-------------------------------|
| **CLI** | Command Line Interface (Interfaz de Linea de Comandos). Un programa que usas escribiendo comandos en la terminal, en vez de hacer click con el mouse. Piensa en ella como una app que se maneja con texto en vez de botones. |
| **Terminal** | La pantalla negra (o de colores) donde escribes comandos. Es como un chat con tu computadora: tu escribes, ella responde. |
| **Comando** | Una instruccion que le escribes a la terminal. Ejemplo: `ordenar fotos` le dice a la herramienta que organice tus fotos. |
| **Argumento** | Informacion extra que le das a un comando. Ejemplo: en `ordenar --carpeta Descargas`, la parte `--carpeta Descargas` es el argumento que le dice DONDE buscar. |
| **Python** | Un lenguaje de programacion muy popular. Es como el idioma en el que le hablas a la computadora para que haga cosas. |
| **pip** | El "instalador de apps" para Python. Cuando necesitas una libreria, pip la descarga e instala. Como la tienda de aplicaciones del celular, pero para Python. |
| **Entorno virtual (venv)** | Una carpeta especial que guarda las librerias de Python solo para tu proyecto. Evita que las librerias de un proyecto se mezclen con las de otro. Como tener una caja de herramientas separada para cada trabajo. |
| **Click/Typer** | Librerias de Python que facilitan crear herramientas CLI. En vez de manejar todo manualmente, ellas se encargan de leer los comandos, mostrar ayuda, y validar lo que el usuario escribe. |
| **Rich** | Una libreria de Python que hace que la terminal se vea bonita: colores, tablas, barras de progreso. Es como decorar un cuarto — el cuarto funciona sin decoracion, pero se ve mucho mejor con ella. |
| **pytest** | Una herramienta para verificar que tu programa funciona correctamente. Ejecuta pruebas automaticas y te dice si algo esta roto. Como un inspector de calidad en una fabrica. |
| **PyPI** | Python Package Index. La "tienda de apps" oficial de Python. Cuando publicas tu herramienta ahi, cualquier persona en el mundo puede instalarla con `pip install tu-herramienta`. |
| **Paquete (package)** | Tu programa empaquetado para que otras personas puedan instalarlo con un solo comando. Como envolver un regalo con todo incluido. |
| **Extension de archivo** | Las letras despues del punto en un nombre de archivo. Ejemplo: `.jpg` significa que es una imagen, `.pdf` significa que es un documento. La herramienta usa esto para saber que tipo de archivo es. |
| **Prompt** | El mensaje que le escribes a Claude. Como enviarle un WhatsApp con instrucciones. |
| **Claude Code** | Un asistente de programacion que vive en tu terminal. Tu le dices que quieres y el lo construye. |
| **Skill** | Un documento que le dice a Claude COMO hacer algo especifico. Como una receta de cocina. |
| **SDD** | Spec-Driven Development. Un proceso paso a paso para construir software: primero planeas, luego construyes. Como un arquitecto que primero dibuja el plano y luego construye la casa. |
| **Repositorio (repo)** | Una carpeta especial que guarda todo tu codigo y recuerda cada cambio que haces. |
| **Agente Contratado** | Un "jefe de area" especializado de Claude. Coordina un grupo de tareas relacionadas. |
| **Research-First** | Un checklist que Claude ejecuta ANTES de hacer cualquier cambio de codigo. Verifica que todo este en orden. |

---

## Que vamos a construir

**Ordena** — Una herramienta de linea de comandos que organiza los archivos de una carpeta automaticamente. Piensa en ella como un asistente que abre tu carpeta de Descargas (que es un desorden total) y mueve cada archivo a su lugar correcto: fotos con fotos, documentos con documentos, videos con videos.

### Que va a hacer

| Categoria | Extensiones | Carpeta destino |
|-----------|------------|-----------------|
| Imagenes | `.jpg`, `.jpeg`, `.png`, `.gif`, `.bmp`, `.svg`, `.webp` | `Imagenes/` |
| Documentos | `.pdf`, `.doc`, `.docx`, `.txt`, `.xlsx`, `.pptx`, `.csv` | `Documentos/` |
| Videos | `.mp4`, `.avi`, `.mov`, `.mkv`, `.wmv` | `Videos/` |
| Musica | `.mp3`, `.wav`, `.flac`, `.aac`, `.ogg` | `Musica/` |
| Comprimidos | `.zip`, `.rar`, `.7z`, `.tar`, `.gz` | `Comprimidos/` |
| Codigo | `.py`, `.js`, `.ts`, `.html`, `.css`, `.json` | `Codigo/` |
| Otros | Todo lo que no encaje arriba | `Otros/` |

### Comandos que va a tener

| Comando | Que hace | Ejemplo |
|---------|---------|---------|
| `ordena organizar` | Organiza los archivos de una carpeta | `ordena organizar ~/Descargas` |
| `ordena vista-previa` | Muestra que haria SIN mover nada | `ordena vista-previa ~/Descargas` |
| `ordena deshacer` | Deshace la ultima organizacion | `ordena deshacer` |
| `ordena stats` | Muestra estadisticas de una carpeta | `ordena stats ~/Descargas` |
| `ordena config` | Cambia las reglas de organizacion | `ordena config --agregar .sketch Diseno` |

### Ejemplo de como se va a ver

Cuando escribas `ordena vista-previa ~/Descargas` en la terminal, vas a ver algo asi:

```
 Vista previa — ~/Descargas (23 archivos)

 Imagenes/ (8 archivos)
  foto-vacaciones.jpg
  captura-pantalla.png
  logo-empresa.svg
  ...y 5 mas

 Documentos/ (6 archivos)
  informe-trimestral.pdf
  presupuesto-2026.xlsx
  notas-reunion.docx
  ...y 3 mas

 Videos/ (3 archivos)
  tutorial-python.mp4
  presentacion.mov
  clip-divertido.avi

 Comprimidos/ (2 archivos)
  backup-fotos.zip
  proyecto-viejo.rar

 Otros/ (4 archivos)
  archivo-raro.xyz
  sin-extension
  ...y 2 mas

 Resumen: 23 archivos → 5 carpetas
 Ejecuta "ordena organizar ~/Descargas" para mover los archivos.
```

Todo con colores y formatos bonitos gracias a la libreria Rich.

---

## Antes de empezar — Lo que necesitas tener instalado

Pide ayuda a alguien para instalar estas cosas si no las tienes:

| Herramienta | Para que sirve | Como instalar |
|-------------|---------------|---------------|
| **Python 3.10+** | El lenguaje en el que se construye la herramienta | Descarga de [python.org](https://python.org) la ultima version. Al instalar, marca la casilla "Add Python to PATH" |
| **Git** | Guarda el historial de tu proyecto | Descarga de [git-scm.com](https://git-scm.com) |
| **Claude Code** | El asistente que va a programar por ti | En la terminal escribe: `npm install -g @anthropic-ai/claude-code` |

> **Nota**: Para Claude Code necesitas tener Node.js instalado.
> Si no lo tienes, descargalo de [nodejs.org](https://nodejs.org) antes de instalar Claude Code.

### Verificar que todo esta instalado

Abre una terminal y escribe estos comandos uno por uno:

```
python --version
git --version
claude --version
```

Si los tres muestran un numero (como `Python 3.12.1`), estas lista.

> **En Windows**: Si `python` no funciona, prueba con `python3` o `py`.
> Si ninguno funciona, Python no esta en el PATH. Reinstala Python marcando "Add to PATH".

---

# PASO A PASO

> Sigue cada paso en orden. No saltes pasos — cada uno depende del anterior.
> Este proyecto es corto. En 1 hora puedes tenerlo listo.

---

## Paso 1 — Crear la carpeta del proyecto

**Que vamos a hacer**: Crear una carpeta vacia donde vivira nuestra herramienta CLI.

**Que hacer**:
1. Abre el Explorador de Archivos de Windows
2. Ve a donde quieras guardar tu proyecto (ejemplo: `E:\Proyectos\`)
3. Click derecho → Nueva Carpeta
4. Nombrala: `ordena-archivos`

> **IMPORTANTE**: Usa nombres SIN espacios y en minusculas (ejemplo: `ordena-archivos`, no `Ordena Archivos`).
> Los espacios causan problemas con Python y pip.
> Usa guiones (-) en lugar de espacios.

Ahora abre Claude Code:
1. Abre una terminal
2. Escribe:

```
cd "E:\Proyectos\ordena-archivos"
```

> Cambia la ruta si tu carpeta esta en otro lugar.

3. Escribe:

```
claude
```

**Resultado**: Claude Code esta abierto dentro de tu carpeta.

---

## Paso 2 — Instalar el ecosistema Batuta

**Que vamos a hacer**: Darle a Claude las "recetas" (skills) que necesita para trabajar al estilo Batuta.

> **IMPORTANTE**: Asegurate de estar dentro de la carpeta de tu proyecto antes de ejecutar este comando. Todo lo que Claude cree se guardara en la carpeta actual.

**Opcion A — Si ya tienes los commands de Batuta instalados** (recomendado):

```
/batuta-init ordena-archivos
```

**Opcion B — Si es la primera vez:**

Copia y pega este prompt:

```
Necesito configurar este proyecto con el ecosistema Batuta.

Haz lo siguiente:
1. Clona el repositorio github.com/jota-batuta/batuta-dots en una carpeta temporal
2. Ejecuta el script: bash <ruta-a-batuta-dots>/infra/setup.sh --project .
3. Inicializa git en esta carpeta si no existe
4. Confirma cuando todo este listo
```

Esto crea CLAUDE.md, la carpeta .batuta/, sincroniza skills, e instala hooks en tu proyecto.

**Que esperar**: Claude configura el ecosistema en 1-2 minutos. Crea:
- `CLAUDE.md` — Las instrucciones del chef
- `.batuta/session.md` — El cuaderno de continuidad

**Tip**: Si Claude te pide permiso para ejecutar comandos, di "yes" o "si".

---

## Paso 3 — Iniciar el proyecto con SDD

**Que vamos a hacer**: Decirle a Claude que tipo de proyecto vamos a construir para que se prepare correctamente. SDD es el proceso de "primero planear, luego construir".

**Copia y pega este prompt:**

```
/sdd-init
```

Cuando Claude pregunte:

| Si Claude pregunta... | Tu respondes... |
|----------------------|-----------------|
| Nombre del proyecto | `ordena-archivos` |
| Tipo de proyecto | `library` |
| Descripcion | `Herramienta CLI en Python que organiza archivos de una carpeta por tipo (imagenes, documentos, videos, musica, comprimidos, codigo). Con vista previa, deshacer, estadisticas y configuracion personalizable.` |

**Que esperar**: Claude puede detectar que necesita skills para Click/Typer, Rich, u otras tecnologias. Di "Opcion 1" si pregunta.

---

## Paso 4 — Propuesta y aprobacion

**Que vamos a hacer**: Pedirle a Claude que escriba un plan formal. Como cuando un carpintero te muestra el boceto del mueble antes de construirlo.

**Copia y pega este prompt:**

```
/sdd-new ordena-archivos-cli
```

Este comando primero explora tu proyecto y luego genera una propuesta automaticamente.

**Que esperar**: Claude crea una propuesta con:
- Que se va a construir
- Que tecnologias usa (Click o Typer, Rich)
- Como se organizan los archivos del proyecto

Lee el resumen. Si algo no te suena bien, dile. Por ejemplo:

```
Me parece bien pero quiero que tambien ignore las carpetas ocultas
(las que empiezan con punto, como .git) y que nunca mueva archivos del sistema.
```

**Cuando estes conforme, di:**

```
Aprobado, continua con el siguiente paso
```

---

## Paso 5 — Especificaciones, diseno y tareas

**Que vamos a hacer**: Dejar que Claude defina los detalles: exactamente como funciona cada comando, como se manejan los archivos, y en que orden se construye todo.

**Copia y pega este prompt:**

```
/sdd-continue ordena-archivos-cli
```

Ejecuta `/sdd-continue` UNA vez por fase. Claude mostrara el resultado y te pedira confirmacion antes de avanzar. Repite hasta completar las fases pendientes (specs, design, tasks).

> **Alternativa rapida**: `/sdd-continue <nombre>` ejecuta todas las fases pendientes de corrido sin pausas.

**Que esperar**: Claude ejecuta 3 fases:

| Fase | Que hace | Cuanto toma |
|------|---------|-------------|
| **Specs** | Define exactamente que hace cada comando, que errores maneja, que salida muestra | 2-3 min |
| **Design** | Decide: Click o Typer, estructura de archivos, como funciona el historial de deshacer | 2-3 min |
| **Tasks** | Divide el trabajo en tareas ordenadas | 1-2 min |

**Tu respuesta cada vez:**

```
Se ve bien, continua
```

**Si algo no entiendes:**

```
No entendi la parte de "entry points en pyproject.toml".
Explicame que significa eso en terminos simples.
```

---

## Paso 6 — Construir la herramienta completa

**Que vamos a hacer**: Pedirle a Claude que construya la estructura del proyecto y todos los comandos. Esta es la parte donde se escribe todo el codigo.

**Copia y pega este prompt:**

```
/sdd-apply ordena-archivos-cli

Implementa todo el proyecto. Incluye:

1. Estructura del proyecto con pyproject.toml configurado
2. Entorno virtual de Python (venv)
3. El framework CLI (Click o Typer, el que hayas elegido en el design)
4. Todos los comandos: organizar, vista-previa, deshacer, stats, config
5. Las categorias de archivos con sus extensiones
6. El historial de operaciones para poder deshacer (~/.ordena/historial.json)
7. La configuracion personalizable (~/.ordena/config.json)
8. Salida con Rich (colores, tablas, barras de progreso)
9. Que el comando "ordena" funcione despues de instalar

Crea tambien un entorno virtual para el proyecto.
```

**Que esperar**: Antes de escribir codigo, Claude ejecuta el **Research-First** que verifica donde van los archivos y que todo este en orden.

Te mostrara algo como:
```
Este cambio involucra scope pipeline + infra:
- Crear estructura del proyecto (15 archivos)
- Instalar dependencias en entorno virtual
- Procedo?
```

Di "si" y Claude construye todo.

**MOMENTO IMPORTANTE — Entorno virtual:**

Claude va a crear un entorno virtual. Si te pregunta, di:

```
Si, crea el entorno virtual con python -m venv venv
e instala todas las dependencias ahi.
```

**Si Claude pide permisos para ejecutar comandos**, di "yes". Va a necesitar:
- Crear el entorno virtual
- Instalar librerias (Click/Typer, Rich, etc.)
- Instalar el paquete en modo desarrollo

**Resultado**: Tu herramienta CLI esta construida con todos los comandos.

---

## Paso 7 — Escribir las pruebas

**Que vamos a hacer**: Crear pruebas automaticas que verifican que cada comando funciona correctamente. Las pruebas usan carpetas temporales con archivos falsos — nunca tocan tus archivos reales.

**Copia y pega este prompt:**

```
Continua con el siguiente batch: tests con pytest.

Implementa pruebas para:

1. Comando organizar:
   - Organizar una carpeta con archivos de diferentes tipos
   - Verificar que cada archivo termino en la carpeta correcta
   - Verificar que se crean las carpetas de destino
   - Verificar que archivos duplicados se renombran (foto(1).jpg)
   - Verificar que carpetas existentes no se mueven (solo archivos)

2. Comando vista-previa:
   - Verificar que muestra la clasificacion correcta
   - Verificar que NO mueve ningun archivo

3. Comando deshacer:
   - Organizar archivos, luego deshacer, verificar que volvieron al original
   - Intentar deshacer sin haber organizado antes (error amigable)

4. Comando stats:
   - Verificar que cuenta correctamente por tipo
   - Verificar que calcula el peso total correcto

5. Comando config:
   - Agregar una extension nueva
   - Quitar una extension
   - Resetear a valores por defecto

Usa carpetas temporales (tempfile) para todas las pruebas.
NO toques archivos reales del usuario en ningun test.
```

**Que esperar**: Claude creara archivos de pruebas y las ejecutara. Te mostrara los resultados:

```
tests/test_organizar.py .....         [30%]
tests/test_vista_previa.py ...        [48%]
tests/test_deshacer.py ....           [72%]
tests/test_stats.py ...               [89%]
tests/test_config.py ...              [100%]

18 passed in 2.1s
```

Si alguna prueba falla, Claude la corregira automaticamente.

**Si las pruebas fallan y Claude no las corrige solo, di:**

```
Hay pruebas fallando. Corrige el codigo para que todas las pruebas pasen.
No modifiques las pruebas, corrige el codigo de los comandos.
```

**Resultado**: Todas las pruebas pasan, confirmando que tu herramienta funciona bien.

---

## Paso 8 — Verificar todo

**Que vamos a hacer**: Una revision final de todo el proyecto para asegurarnos de que esta listo.

**Copia y pega este prompt:**

```
/sdd-verify ordena-archivos-cli
```

**Que esperar**: Claude verifica:
- Que todos los comandos funcionan
- Que las pruebas pasan
- Que el paquete se puede instalar
- Que la ayuda de cada comando es clara
- Que la estructura de archivos sigue la Scope Rule

Si encuentra problemas:

```
Si, corrige todos los problemas que encontraste
```

Repite hasta que todo este verde.

---

## Paso 9 — Probar en tu computadora

**Que vamos a hacer**: Instalar la herramienta y probarla con archivos reales. Es la prueba de manejo antes de salir a la carretera.

**Copia y pega este prompt:**

```
Empaqueta e instala la herramienta localmente para que pueda usarla
desde cualquier carpeta en mi terminal.

Necesito:
1. Verificar que pyproject.toml esta correcto con el entry point "ordena"
2. Instalar el paquete con pip install .
3. Verificar que el comando "ordena" funciona desde cualquier carpeta
4. Probar cada comando rapidamente para confirmar

Despues, dame un resumen de como usar cada comando con ejemplos.
```

**Que esperar**: Claude instalara el paquete y te dara una hoja de referencia rapida.

**Prueba tu herramienta**:

Abre una terminal NUEVA (no la de Claude Code) y prueba:

```
ordena vista-previa ~/Descargas
```

Si la vista previa se ve bien y muestra tus archivos clasificados correctamente:

```
ordena organizar ~/Descargas
```

Si te equivocaste o quieres revertir:

```
ordena deshacer
```

Para ver las estadisticas de una carpeta:

```
ordena stats ~/Documentos
```

**Resultado**: Tu herramienta CLI esta instalada y lista para usar.

---

## Paso 10 — Subir a GitHub

**Que vamos a hacer**: Guardar todo el proyecto en GitHub para que no se pierda y puedas compartirlo.

**Copia y pega este prompt:**

```
Crea un repositorio en GitHub llamado ordena-archivos bajo mi cuenta,
sube todo el codigo, y haz el commit inicial.

Verifica que .gitignore incluya:
- venv/
- __pycache__/
- *.egg-info/
- dist/
- build/
- .env
```

**Si Claude pide permisos de git** (commit, push), di "yes".

**Resultado**: Tu proyecto esta guardado en GitHub.

---

## Paso 11 (opcional) — Publicar en PyPI

**Que vamos a hacer**: Publicar tu herramienta en la tienda oficial de Python para que cualquier persona en el mundo pueda instalarla con un solo comando: `pip install ordena-archivos`.

> **NOTA**: Este paso es opcional. Solo hazlo si quieres compartir tu herramienta con otras personas.

**Copia y pega este prompt:**

```
Quiero publicar esta herramienta en PyPI para que cualquiera pueda
instalarla con "pip install ordena-archivos".

Necesito:
1. Verificar que pyproject.toml tiene toda la metadata necesaria
   (nombre, version, descripcion, autor, licencia, readme)
2. Crear un README.md con instrucciones de instalacion y uso
3. Construir el paquete con python -m build
4. Dame las instrucciones paso a paso para subirlo a PyPI

IMPORTANTE: No subas a PyPI automaticamente. Solo preparame todo
y dame las instrucciones para que yo lo haga manualmente.
```

**Que esperar**: Claude prepara todo y te da las instrucciones. Publicar en PyPI requiere crear una cuenta en [pypi.org](https://pypi.org) — eso lo haces tu.

**Resultado**: Tu herramienta esta lista para publicarse. Cuando la publiques, cualquiera podra instalarla con `pip install ordena-archivos`.

---

## Paso 12 — Archivar y celebrar

**Copia y pega este prompt:**

```
/sdd-archive ordena-archivos-cli
```

Claude cierra el proyecto: verifica que todo esta completo, guarda las lecciones aprendidas, y actualiza `.batuta/session.md`.

**Tu herramienta para organizar archivos esta lista. Felicidades!**

---

# SEGURIDAD — Lo que debes saber

> Las herramientas CLI manejan archivos en tu computadora. Estas son las protecciones
> que Claude implementa para que todo sea seguro.

---

## Solo mueve archivos, nunca los borra

**Que es**: La herramienta MUEVE archivos de un lugar a otro. Nunca borra, nunca modifica el contenido de un archivo. Lo peor que puede pasar es que un archivo termine en la carpeta equivocada — y para eso esta el comando deshacer.

**Que significa para ti**: Tus archivos siempre estan a salvo. Si algo sale mal, `ordena deshacer` los devuelve a donde estaban.

---

## Validacion de rutas

**Que es**: Proteccion contra rutas peligrosas. Si alguien intenta organizar carpetas del sistema operativo (como `C:\Windows\`) la herramienta lo rechaza.

**Como te protege Claude**: El comando valida que:
- La carpeta que quieres organizar existe
- No es una carpeta del sistema (Windows, Program Files, etc.)
- Tienes permiso para mover archivos ahi
- No intenta "subir" niveles con `../../` para acceder a carpetas peligrosas

**Que significa para ti**: No puedes romper tu computadora accidentalmente con esta herramienta.

---

## Manejo de archivos duplicados

**Que es**: Cuando un archivo con el mismo nombre ya existe en la carpeta destino, la herramienta no lo sobreescribe (eso perderia el archivo original). En cambio, le agrega un numero: `foto.jpg` se convierte en `foto(1).jpg`.

**Que significa para ti**: Nunca pierdes un archivo porque otro tiene el mismo nombre.

---

## Archivos ocultos y del sistema

**Que es**: La herramienta ignora automaticamente:
- Archivos ocultos (los que empiezan con `.` como `.gitignore`)
- Carpetas del sistema (como `.git`, `__pycache__`, `node_modules`)
- Archivos de sistema de Windows (`desktop.ini`, `thumbs.db`)

**Que significa para ti**: Solo organiza archivos que tu creaste o descargaste. No toca nada del sistema.

---

## Revision de seguridad

Despues de que la herramienta funcione, puedes pedirle a Claude una revision:

```
Ejecuta una revision de seguridad de este proyecto. Revisa:
1. Que las rutas de archivos se manejan de forma segura
2. Que no se pueden ejecutar comandos maliciosos a traves de nombres de archivos
3. Que las dependencias no tengan vulnerabilidades conocidas
4. Que el historial de operaciones no exponga informacion sensible
```

---

# Usando Agent Teams (Equipos de Agentes)

Este proyecto es lo suficientemente simple para trabajar en modo **Solo (Level 1)**. Tu y Claude, uno a uno, siguiendo los pasos. No necesitas equipos de agentes.

---

## Por que no necesitamos Agent Teams aqui

| Criterio | Este proyecto | Se necesita equipo? |
|----------|--------------|---------------------|
| Cantidad de archivos | 10-15 archivos | No (menos de 4 es ideal para solo) |
| Cantidad de scopes | 1 (pipeline) | No (equipos se justifican con 2+ scopes) |
| Capas de arquitectura | 1 capa (CLI → archivos) | No (Cross-Layer necesita 3+ capas) |
| Complejidad | Baja-Media | No |
| Tiempo estimado | ~1 hora | No vale la pena la coordinacion de un equipo |

---

## Cuando SI necesitarias Agent Teams

Si en el futuro decides extender esta herramienta significativamente, ahi si podria justificarse:

```
Quiero convertir ordena-archivos en una suite completa con:
1. Un organizador de archivos por tipo
2. Un limpiador de archivos duplicados
3. Un compresor masivo de imagenes
4. Un renombrador inteligente con patrones
5. Tests para cada modulo

Crea un equipo para implementar los 4 modulos en paralelo.
```

Eso si es un trabajo grande (4 modulos independientes) que se beneficia de Agent Teams.

---

## Niveles de trabajo: una referencia rapida

| Nivel | Cuando usarlo | Ejemplo con esta herramienta |
|-------|--------------|------------------------------|
| **Solo** (Level 1) | Todo en este proyecto | Construir la herramienta completa |
| **Subagente** (Level 2, automatico) | Claude investiga algo | Claude investiga si Click o Typer es mejor |
| **Agent Team** (Level 3) | Solo si creces mucho | Agregar 4+ modulos nuevos independientes |

---

# TROUBLESHOOTING — Problemas comunes y como resolverlos

> Los problemas mas frecuentes con herramientas CLI en Python y como solucionarlos.

---

## Problemas con Python y el entorno virtual

### "python: command not found" o "'python' no se reconoce"

**Que paso**: Python no esta en el PATH de tu sistema. Es como si tu computadora no supiera donde encontrar Python.

**Que hacer**:

En Windows, prueba estos comandos en orden hasta que uno funcione:
```
python --version
python3 --version
py --version
```

Si ninguno funciona, reinstala Python desde [python.org](https://python.org) y asegurate de marcar la casilla "Add Python to PATH" durante la instalacion.

### "El entorno virtual no se activa"

**Que paso**: El entorno virtual existe pero no esta "encendido".

**Que hacer**:

En Windows (CMD):
```
venv\Scripts\activate
```

En Windows (Git Bash):
```
source venv/Scripts/activate
```

Sabras que esta activo cuando veas `(venv)` al inicio de la linea de tu terminal.

### "pip install falla con error de permisos"

**Que hacer**:

```
Claude, el pip install fallo con un error de permisos.
Asegurate de que estoy usando el pip del entorno virtual, no el global.
Activa el venv primero y luego instala.
```

---

## Problemas al organizar archivos

### "Permiso denegado" (Permission denied)

**Que paso**: No tienes permiso para mover un archivo. Puede ser que otro programa lo este usando o que sea un archivo protegido del sistema.

**Que hacer**:

```
Claude, cuando intento organizar ~/Descargas me sale "Permission denied"
para algunos archivos. Agrega manejo de errores que salte los archivos
que no puede mover y muestre un aviso con el nombre del archivo.
```

### "La carpeta destino no se creo"

**Que hacer**:

```
Claude, el comando organizar no esta creando las carpetas de destino.
Verifica que el codigo crea las carpetas con os.makedirs o pathlib
antes de intentar mover los archivos.
```

### "Se movieron archivos que no deberian moverse"

**Que hacer**:

```
Claude, la herramienta movio archivos ocultos y carpetas del sistema.
Agrega filtros para ignorar:
- Archivos que empiezan con punto (.)
- Carpetas (solo mover archivos)
- Archivos del sistema de Windows (desktop.ini, thumbs.db)
```

---

## Problemas con el comando deshacer

### "No hay operacion para deshacer"

**Que paso**: No has organizado ninguna carpeta todavia, o el historial se borro.

**Que hacer**: Esto es normal si es la primera vez que usas la herramienta. El historial se crea automaticamente la primera vez que organizas archivos.

### "El deshacer fallo porque los archivos ya se movieron"

**Que hacer**:

```
Claude, el deshacer falla porque algunos archivos ya no estan donde
el historial dice. Agrega manejo de errores que salte los archivos
que ya no existen y deshaga los que si puede.
```

---

## Problemas con las pruebas (pytest)

### "pytest: command not found"

**Que hacer**: Asegurate de que el entorno virtual esta activo:

```
Claude, pytest no se encuentra. Activa el entorno virtual e instala pytest
si no esta instalado.
```

### "Los tests fallan en Windows por rutas de archivos"

**Que hacer**:

```
Los tests fallan en Windows con errores de rutas de archivos.
Verifica que todas las rutas usen pathlib.Path en vez de strings
para que funcionen en todos los sistemas operativos.
```

---

## Problemas con el empaquetado

### "El comando 'ordena' no se encuentra despues de instalar"

**Que hacer**:

```
Instale el paquete con pip install . pero el comando "ordena" no funciona.
Verifica:
1. Que pyproject.toml tiene el entry point correcto en [project.scripts]
2. Que la instalacion fue en el entorno virtual activo
3. Que el entorno virtual esta activo cuando intento usar el comando
```

---

## Comandos de emergencia

| Situacion | Que escribir |
|-----------|-------------|
| Claude se trabo y no responde | Cierra la terminal, abrela de nuevo, escribe `claude` |
| Quieres deshacer el ultimo cambio | `Deshaz el ultimo cambio que hiciste` |
| No entiendes algo | `Explicame [lo que no entiendes] como si tuviera 15 anos` |
| Quieres ver el estado del proyecto | Pregunta a Claude: "En que fase estamos?" |
| Los tests fallan y no sabes por que | `Ejecuta pytest con -v (verbose) y analiza cada fallo. Corrigelos todos.` |
| Moviste archivos que no querias | Usa `ordena deshacer` en la terminal (no en Claude Code) |

---

# DESPUES DE LA ENTREGA

---

## Agregar nuevas categorias

Para agregar una categoria nueva (ejemplo: archivos de diseno):

```
/sdd-new ordena-categoria-diseno

Quiero agregar una categoria "Diseno" que incluya archivos:
.psd, .ai, .sketch, .figma, .xd

Que los mueva a una carpeta llamada "Diseno/".
Actualiza la configuracion por defecto y los tests.
```

Y sigue el mismo flujo: design → apply → verify (el explore se ejecuta automaticamente dentro de `/sdd-new`).

---

## Ideas de mejoras futuras

| Mejora | Que decirle a Claude | Complejidad |
|--------|---------------------|-------------|
| Buscar duplicados | `Agrega un comando "ordena duplicados" que encuentre archivos identicos` | Media |
| Organizar por fecha | `Agrega la opcion --por-fecha que organice en carpetas por ano/mes` | Baja |
| Comprimir imagenes | `Agrega un comando "ordena comprimir" que reduzca el tamano de las imagenes` | Media |
| Renombrar en lote | `Agrega un comando "ordena renombrar" con patrones: foto_{n}.jpg` | Media |
| Modo automatico | `Haz que la herramienta vigile una carpeta y organice automaticamente cuando lleguen archivos nuevos` | Alta |

---

## Estructura esperada del proyecto

```
ordena-archivos/
├── core/                              # Singletons
│   ├── config.py                     # Configuracion (categorias, rutas)
│   └── history.py                    # Historial de operaciones (para deshacer)
├── features/
│   ├── organizer/                    # Feature: organizacion de archivos
│   │   ├── commands/
│   │   │   ├── organizar.py         # Comando: ordena organizar
│   │   │   ├── vista_previa.py      # Comando: ordena vista-previa
│   │   │   └── deshacer.py          # Comando: ordena deshacer
│   │   ├── services/
│   │   │   ├── classifier.py        # Clasificar archivos por extension
│   │   │   └── mover.py             # Mover archivos de forma segura
│   │   └── models/
│   │       └── file_info.py         # Modelo de datos de un archivo
│   ├── stats/                        # Feature: estadisticas
│   │   └── commands/
│   │       └── stats.py             # Comando: ordena stats
│   └── shared/                       # Shared entre features
│       └── formatters/
│           └── rich_output.py       # Formato bonito con Rich
├── tests/
│   ├── test_organizar.py
│   ├── test_vista_previa.py
│   ├── test_deshacer.py
│   ├── test_stats.py
│   ├── test_config.py
│   └── conftest.py                  # Configuracion compartida de tests
├── cli.py                            # Punto de entrada del CLI
├── pyproject.toml                    # Configuracion del paquete
└── .gitignore
```

> Nota como sigue la **Scope Rule**: la feature "organizer" tiene su carpeta, "stats" tiene la suya,
> shared solo tiene lo que usan 2+ features, y core tiene los singletons.

---

## Preguntas frecuentes

**P: Puedo usar esta herramienta en Mac o Linux?**
R: Si. Python funciona en todos los sistemas operativos. La herramienta usa `pathlib` para manejar rutas, asi que funciona igual en Windows, Mac y Linux.

**P: Cuanto tarda construir todo?**
R: Aproximadamente 1 hora, incluyendo la configuracion inicial. Es el proyecto mas rapido de todas las guias.

**P: Puedo cerrar la terminal y continuar despues?**
R: Si. Abre la terminal, navega a tu carpeta (`cd "ruta/ordena-archivos"`), escribe `claude`, y Claude lee `.batuta/session.md` para recordar donde quedo.

**P: Y si muevo archivos que no queria mover?**
R: Usa `ordena deshacer` inmediatamente. La herramienta guarda un historial de la ultima operacion y puede devolver todo a como estaba.

**P: La herramienta puede borrar mis archivos?**
R: No. Solo MUEVE archivos de un lugar a otro. Nunca borra nada.

**P: Puedo personalizar las categorias?**
R: Si. Usa `ordena config --agregar .sketch Diseno` para agregar una extension a una categoria nueva. Usa `ordena config --mostrar` para ver las reglas actuales.

**P: Necesito internet para usar la herramienta?**
R: No. Una vez instalada, funciona completamente sin internet. Solo necesitas internet durante la construccion (para que Claude Code funcione) y para instalar librerias.

**P: Que es el Research-First?**
R: Es un checklist automatico que Claude ejecuta antes de escribir codigo. Verifica donde van los archivos, que impacto tienen los cambios, y que todo siga las reglas del proyecto.

---

## Resumen visual del flujo completo

```
Tu (carpeta vacia)
 |
 +-- Paso 1-2:  Crear carpeta + Instalar Batuta + crear .batuta/
 |
 +-- Paso 3:    /sdd-init .................. "Que tipo de proyecto es?"
 |
 |   [Claude puede detectar skills faltantes → "Opcion 1"]
 |
 +-- Paso 4:    /sdd-new ................... "Explora + Propuesta formal"
 |     Tu: "Aprobado"
 |
 +-- Paso 5:    /sdd-continue .............. "Specs → Design → Tasks"
 |     Tu: "Continua" (3 veces)
 |
 +-- Paso 6:    /sdd-apply ................. "Framework CLI + comandos"
 |     [Research-First valida antes de cada cambio]
 |
 +-- Paso 7:    Tests ...................... "Verificar con pytest"
 |
 +-- Paso 8:    /sdd-verify ................ "Revision final"
 |
 +-- Paso 9:    pip install . .............. "Probar en tu PC"
 |
 +-- Paso 10:   Push a GitHub .............. "Codigo guardado"
 |
 +-- Paso 11:   (opcional) PyPI ............ "Publicar al mundo"
 |
 +-- Paso 12:   /sdd-archive ............... "Cerrar y celebrar"
 |
 [Tu herramienta para organizar archivos esta lista!]
 |
 Prueba: ordena vista-previa ~/Descargas
```

---

> **Recuerda**: No necesitas entender COMO funciona Python por dentro.
> Solo necesitas seguir los pasos y describir lo que quieres.
> Como aprender a manejar: primero sigues las instrucciones al pie de la letra,
> y con el tiempo lo haces naturalmente. Claude es tu asistente — el programa, tu decides.

---

## Deployment Programatico

Este tipo de proyecto puede deployarse via Agent SDK para automatizacion CI/CD. Ver [guia-sdk-deployment.md](guia-sdk-deployment.md).
