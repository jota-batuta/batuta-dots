# Guia Paso a Paso: Modernizar Codigo Existente con Claude Code

> **Para quien es esta guia**: Para cualquier persona que sepa copiar y pegar texto.
> Claude Code hace la programacion, tu solo le das las instrucciones.
>
> **Formato**: Sigue los pasos en orden, como cuando aprendes a manejar.
> Cada paso depende del anterior. No saltes pasos.
>
> **DIFERENCIA CLAVE**: Esta guia NO crea un proyecto desde cero.
> Toma un proyecto que ya existe (posiblemente desordenado) y lo moderniza
> sin romper nada de lo que ya funciona.

---

## Glosario — Palabras que vas a ver

Antes de empezar, aqui tienes un mini-diccionario. No necesitas memorizarlo, vuelve aqui si ves una palabra que no entiendes.

| Palabra | Que significa (sin tecnicismos) |
|---------|-------------------------------|
| **Refactoring** | Reorganizar y mejorar codigo SIN cambiar lo que hace. Es como renovar una casa por dentro (nuevas tuberias, cableado electrico, pintura) sin tumbar las paredes ni cambiar la fachada. Los que viven adentro no notan diferencia, pero todo funciona mejor. |
| **Codigo legacy** | Codigo antiguo que funciona pero es dificil de mantener. Como una casa vieja: tiene luz y agua, pero los cables estan al aire, no hay planos, y nadie sabe donde va cada tuberia. |
| **Branch (rama)** | Una copia de tu proyecto donde puedes hacer cambios sin afectar la version original. Como hacer una fotocopia del plano de la casa para dibujar los cambios, sin tocar el plano real. |
| **Tipos (types)** | Etiquetas que dicen que tipo de dato es cada cosa: "esto es un numero", "esto es texto", "esto es una fecha". Sin tipos, es como tener cajas sin etiquetas — no sabes que hay adentro hasta que las abres. |
| **Linter** | Un revisor automatico que detecta errores comunes y malas practicas en el codigo. Como un inspector de obras que dice "este cable esta mal conectado" o "falta un tornillo aqui". |
| **Tests** | Pruebas automaticas que verifican que el codigo funciona correctamente. Como probar que al girar la llave del bano sale agua. Si despues de una renovacion ya no sale agua, el test lo detecta inmediatamente. |
| **Dependencias** | Las librerias externas que tu proyecto necesita para funcionar. Como los materiales de construccion: si una marca de cemento ya no existe, necesitas encontrar un reemplazo compatible. |
| **Commit** | Un "punto de guardado" en el historial de tu proyecto. Como tomar una foto del estado de la casa en cada etapa de la renovacion: si algo sale mal, puedes volver a cualquier foto anterior. |
| **Prompt** | El mensaje que le escribes a Claude. Como enviarle un WhatsApp con instrucciones. |
| **Claude Code** | Un asistente de programacion que vive en tu terminal. Tu le dices que quieres y el lo construye. |
| **Terminal** | La pantalla negra donde escribes comandos. Piensa en ella como un chat con tu computadora. |
| **Skill** | Un documento que le dice a Claude COMO hacer algo especifico. Como una receta de cocina. |
| **SDD** | Spec-Driven Development. Un proceso paso a paso para construir software: primero planeas, luego construyes. Como un arquitecto que primero dibuja el plano y luego construye la casa. |
| **Repositorio (repo)** | Una carpeta especial que guarda todo tu codigo y recuerda cada cambio que haces. |
| **Scope Rule** | La regla que decide DONDE va cada archivo en el proyecto. "El uso determina la ubicacion" — si solo una parte del proyecto usa algo, va en esa parte. |
| **Scope Agent** | Un "jefe de area" especializado. Claude tiene 3: uno para el proceso de desarrollo, uno para organizacion de archivos, y uno para calidad. |
| **Execution Gate** | Un checklist que Claude ejecuta ANTES de hacer cualquier cambio de codigo. Verifica que todo este en orden. |
| **Docker** | Una herramienta que empaqueta aplicaciones para que funcionen en cualquier computadora igual. |
| **CI/CD** | Integracion Continua / Despliegue Continuo. Un sistema automatico que revisa y publica los cambios cada vez que guardas codigo. Como un servicio de mensajeria que automaticamente despacha cada paquete que dejas en el mostrador. |
| **Deuda tecnica** | Los "atajos" que se tomaron en el pasado y ahora causan problemas. Como reparar algo con cinta adhesiva en vez de arreglarlo bien — funciona por un tiempo, pero eventualmente se cae. |
| **Migracion** | Mover algo de una version vieja a una nueva. Como actualizar de Windows 10 a Windows 11 — las apps siguen funcionando pero con mejor base. |

---

## Que vamos a construir (o mejor dicho, que vamos a MEJORAR)

**No vamos a crear un proyecto nuevo**. Vamos a tomar un proyecto existente — posiblemente desordenado, sin tipos, sin tests, con archivos en cualquier lugar — y modernizarlo paso a paso.

Es como renovar una casa mientras las personas siguen viviendo en ella. No puedes tumbar todo y reconstruir. Tienes que trabajar **habitacion por habitacion**, asegurandote de que el bano siga funcionando mientras renuevas la cocina.

### Que vamos a hacer (en orden)

1. **Tomar una foto del estado actual**: Guardar todo como esta ahora (commit) y crear una copia de trabajo (branch)
2. **Investigar la casa**: Entender como esta organizado el proyecto, que tecnologias usa, donde estan los problemas
3. **Hacer el plan de renovacion**: Decidir que arreglar, que dejar como esta, y en que orden
4. **Reorganizar los archivos**: Mover archivos al lugar correcto segun la Scope Rule
5. **Agregar tipos y reglas de estilo**: Para que el codigo sea mas predecible y facil de leer
6. **Agregar tests**: Para verificar que no rompimos nada con los cambios
7. **Verificar que TODO sigue funcionando**: Los tests viejos + los nuevos deben pasar

### La analogia de la renovacion

```
REGLA DE ORO DE LA RENOVACION:

  Nunca demoler sin proteccion.

  Antes de mover una pared, asegurate de que no sea de carga (structural).
  Antes de cambiar una tuberia, cierra la llave principal.
  Antes de quitar un cable, desconecta la electricidad.

  En codigo:
  Antes de mover un archivo, verifica quien lo importa.
  Antes de cambiar una funcion, verifica que tests la cubren.
  Antes de eliminar algo, verifica que nadie mas lo usa.
```

Tu principio mas importante durante todo este proceso: **NADA de lo que ya funciona debe dejar de funcionar**. Si algo se rompe, se revierte (se vuelve al estado anterior).

---

## Antes de empezar — Lo que necesitas tener

| Que necesitas | Para que | Como verificar |
|---------------|---------|---------------|
| **Un proyecto existente** | Es lo que vamos a modernizar | Tienes una carpeta con codigo que funciona (o que al menos funcionaba) |
| **Git** | Guardar el historial y crear ramas seguras | `git --version` en la terminal |
| **Claude Code** | El asistente que va a hacer la renovacion | `claude --version` en la terminal |
| **Node.js** | Necesario para Claude Code | `node --version` en la terminal |

**NO necesitas**:
- Saber programar (Claude programa por ti)
- Entender el codigo actual (Claude lo investiga)
- Saber que esta mal (Claude lo diagnostica)

**SI necesitas**:
- Saber que hace el proyecto (su proposito, no su codigo)
- Poder ejecutar el proyecto para verificar que funciona
- Tener 1-2 horas de tiempo

---

# PASO A PASO

> Sigue cada paso en orden. Cada uno depende del anterior.
> Esta guia es especialmente sensible al orden: saltarse pasos
> puede causar que pierdas trabajo o rompas cosas.

---

## Paso 1 — Preparar el proyecto (el seguro antes de la renovacion)

**Que vamos a hacer**: Tomar una "foto" del estado actual del proyecto y crear una copia de trabajo segura. Es como sacar un seguro de hogar antes de empezar la renovacion — si algo sale mal, puedes volver a como estaba.

**Que hacer**:

1. Abre una terminal y navega a tu proyecto existente:

```
cd "E:\Proyectos\mi-proyecto-viejo"
```

> Cambia la ruta a la carpeta de TU proyecto.

2. Si tu proyecto NO tiene git inicializado (no tiene una carpeta `.git`), inicializalo:

```
git init
git add -A
git commit -m "estado actual antes de refactoring"
```

3. Si tu proyecto YA tiene git, asegurate de que no hay cambios sin guardar:

```
git status
```

Si hay cambios, guardalos:

```
git add -A
git commit -m "guardar cambios antes de refactoring"
```

4. Ahora crea una rama (branch) de trabajo. Esto es CRUCIAL — es tu red de seguridad:

```
git checkout -b refactoring/modernizacion
```

> Esto crea una copia llamada "refactoring/modernizacion" donde vamos a trabajar.
> Si algo sale mal, la rama `main` (o `master`) queda intacta.

**Resultado**: Tienes un punto de guardado seguro. Si la renovacion sale mal, puedes volver a este punto con `git checkout main`.

> **IMPORTANTE**: NUNCA trabajes directamente en la rama `main` durante el refactoring.
> Siempre trabaja en la rama de refactoring. Es como hacer la renovacion en un cuarto
> temporal y solo mover los muebles al cuarto real cuando todo esta perfecto.

---

## Paso 2 — Abrir Claude Code e instalar el ecosistema Batuta

**Que vamos a hacer**: Abrir Claude Code y darle las "recetas" del ecosistema Batuta. Esto le da a Claude el proceso de trabajo SDD, la Scope Rule, y el sistema de calidad.

**Que hacer**:

1. Abre Claude Code en la carpeta de tu proyecto:

```
claude
```

2. Instala el ecosistema:

**Opcion A — Si ya tienes los commands de Batuta instalados:**

```
/batuta-init mi-proyecto
```

> Cambia "mi-proyecto" por el nombre de tu proyecto.

**Opcion B — Si es la primera vez:**

Copia y pega este prompt:

```
Necesito configurar este proyecto con el ecosistema Batuta.

Haz lo siguiente:
1. Clona el repositorio github.com/jota-batuta/batuta-dots en una carpeta temporal
2. Ejecuta el script skills/setup.sh --all para copiar CLAUDE.md y sincronizar skills
3. Copia el archivo BatutaClaude/CLAUDE.md a la raiz de este proyecto como CLAUDE.md
4. Confirma cuando todo este listo

IMPORTANTE: Este proyecto YA EXISTE y tiene codigo. No borres ni modifiques
nada del codigo existente en este paso.
```

**Que esperar**: Claude instala el ecosistema SIN tocar tu codigo existente. Crea:
- `CLAUDE.md` — Las instrucciones del chef
- `.batuta/session.md` — El cuaderno de continuidad
- `.batuta/prompt-log.jsonl` — La bitacora de calidad

**Tip**: Si Claude te pide permiso para ejecutar comandos, di "yes".

---

## Paso 3 — Explorar el proyecto ("el detective")

**Que vamos a hacer**: Pedirle a Claude que investigue tu proyecto como un detective: que tecnologias usa, como esta organizado, donde estan los problemas, que funciona y que no. Claude va a leer TODOS los archivos y crear un "diagnostico" completo.

**Copia y pega este prompt** (adaptalo a tu proyecto):

```
/sdd:explore refactoring-modernizacion

Necesito que explores este proyecto existente para entender su estado actual.
Actua como un detective: investiga todo sin cambiar nada.

SOBRE EL PROYECTO:
- [Describe brevemente que hace tu proyecto]
- [Ejemplo: "Es una API en Python que maneja pedidos de un restaurante"]
- [O: "Es una app de React que muestra graficas de ventas"]
- [O: "Es un script que procesa facturas"]

NECESITO QUE INVESTIGUES:
1. Estructura de archivos: como esta organizado, donde estan las cosas
2. Tecnologias: que lenguajes, frameworks, librerias usa
3. Dependencias: cuales estan desactualizadas o tienen vulnerabilidades
4. Tipos: tiene tipos definidos? (TypeScript, type hints de Python, etc.)
5. Tests: tiene tests? cuantos? que cubren?
6. Organizacion: sigue algun patron? o los archivos estan en cualquier lugar?
7. Documentacion: tiene README? comentarios? algo que explique como funciona?
8. Problemas detectados: archivos duplicados, imports circulares, codigo muerto

NO MODIFIQUES NADA — solo investiga y dame un reporte completo.
Incluye una seccion "Estado de salud" con nota del 1 al 10 para cada area.
```

**Que esperar**: Claude va a leer tu proyecto entero y darte un reporte como:

```
REPORTE DE DIAGNOSTICO — mi-proyecto

Estado de salud:
- Estructura de archivos: 4/10 — archivos mezclados en la raiz, sin patron claro
- Tipos: 2/10 — sin tipos, todo es "any" implicito
- Tests: 3/10 — solo 5 tests, cubren 15% del codigo
- Dependencias: 5/10 — 3 paquetes con vulnerabilidades conocidas
- Documentacion: 3/10 — README basico, sin comentarios en el codigo
- Organizacion: 3/10 — utils/ con 47 archivos mezclados
```

**Lee el reporte con calma**. No necesitas entender todo — Claude te va a explicar lo que significa cada punto.

**Si Claude detecta skills faltantes** (tecnologias que no conoce), di:

```
Opcion 1 — Investiga y crea el skill acotado a nuestro proyecto
```

> **Detalle tecnico (opcional)**: Cuando Claude explora, activa el pipeline-agent
> (jefe del proceso de desarrollo) que usa el skill sdd-explore para hacer el diagnostico.

---

## Paso 4 — Crear la propuesta de refactoring

**Que vamos a hacer**: Basandose en el diagnostico, Claude va a crear un plan de que modernizar, que dejar como esta, y en que orden. Es como el plan de renovacion del arquitecto.

**Copia y pega este prompt**:

```
/sdd:new refactoring-modernizacion

Basandote en el diagnostico del explore, crea una propuesta de refactoring
con estos objetivos (en orden de prioridad):

1. REORGANIZAR ARCHIVOS con la Scope Rule
   - Mover cada archivo al lugar correcto segun quien lo usa
   - Eliminar carpetas "basurero" como utils/, helpers/, lib/ de la raiz
   - Crear estructura features/ + core/ + shared/

2. AGREGAR TIPOS
   - Agregar type hints (Python) o TypeScript types donde haga falta
   - Priorizar funciones publicas y modelos de datos

3. AGREGAR TESTS para las partes criticas
   - Cubrir las funciones que manejan datos importantes
   - Cubrir los flujos principales (happy path)
   - NO buscar 100% de cobertura — solo lo critico

4. ACTUALIZAR DEPENDENCIAS con vulnerabilidades

REGLAS INQUEBRANTABLES:
- TODO lo que funciona ahora DEBE seguir funcionando despues
- Si algun test existente se rompe, es un error nuestro, no del test
- Cada "lote" de cambios debe ser verificable independientemente
- Si algo sale mal, debe ser facil revertir al estado anterior
- NO agregar funcionalidad nueva — solo modernizar lo existente
```

**Que esperar**: Claude crea una propuesta con:
- Lista de cambios ordenados por prioridad
- Riesgos identificados y como mitigarlos
- Estimacion de esfuerzo por lote
- Plan de verificacion

**Lee la propuesta con calma**. Si algo no te convence, dile:

```
No quiero reorganizar los archivos de la carpeta X porque otro equipo
depende de esas rutas exactas. Dejala como esta y reorganiza el resto.
```

**Cuando estes conforme:**

```
Aprobado, continua con el siguiente paso
```

---

## Paso 5 — Especificaciones (las reglas del juego)

**Que vamos a hacer**: Definir reglas muy estrictas para el refactoring. La regla mas importante: MANTENER TODOS LOS COMPORTAMIENTOS EXISTENTES. No estamos cambiando que hace el software, solo como esta organizado por dentro.

**Copia y pega este prompt**:

```
/sdd:continue refactoring-modernizacion
```

Claude va a crear las especificaciones. Cuando te las muestre, verifica que incluya:

```
REQUISITO CRITICO: "Behavioral Preservation"
- Todas las funciones publicas mantienen exactamente la misma firma (mismos parametros, mismos resultados)
- Todos los endpoints de API (si aplica) mantienen exactamente las mismas URLs y respuestas
- Todos los tests existentes deben pasar SIN MODIFICAR los tests
- Si un test falla, el codigo de refactoring es incorrecto, NO el test
```

Si no lo incluye, dile:

```
Agrega un requisito explicito de "Behavioral Preservation": todas las funciones
publicas mantienen la misma firma, todos los endpoints mantienen las mismas URLs,
y TODOS los tests existentes deben pasar sin modificar los tests.
```

**Tu respuesta cuando estes conforme:**

```
Se ve bien, continua
```

---

## Paso 6 — Diseno (la estrategia de la renovacion)

**Que vamos a hacer**: Claude va a disenar la estrategia de refactoring: como reorganizar los archivos, en que orden mover las cosas, y como verificar que nada se rompe en cada paso.

**Que esperar**: Claude avanza automaticamente a la fase de diseno y luego a tareas.

Claude va a decidir:
1. **Mapeo de archivos**: A donde va cada archivo segun la Scope Rule
2. **Orden de migracion**: Que mover primero (generalmente los archivos sin dependencias)
3. **Estrategia de tipos**: Agregar tipos de forma incremental, empezando por los modelos de datos
4. **Plan de tests**: Que tests agregar y en que orden

**Tu respuesta por cada fase:**

```
Se ve bien, continua
```

**Tip**: En la fase de diseno, Claude va a crear un "mapa" que muestra de donde a donde va cada archivo. Ejemplo:

```
MAPEO DE ARCHIVOS:

Antes                          →  Despues
─────────────────────────────────────────────────────
utils/formatDate.ts            →  features/shared/utils/format_date.ts
utils/validateEmail.ts         →  features/shared/utils/validate_email.ts
utils/sendNotification.ts      →  features/notifications/services/send.ts
components/Header.tsx          →  core/components/header.tsx
components/ProductCard.tsx     →  features/products/components/product_card.tsx
components/CartButton.tsx      →  features/cart/components/cart_button.tsx
services/api.ts                →  core/services/api.ts
services/auth.ts               →  core/auth/service.ts
services/productService.ts     →  features/products/services/product.ts
```

Lee este mapa con calma. Si algo no tiene sentido, dile a Claude.

---

## Paso 7 — Dividir el trabajo en lotes seguros

**Que vamos a hacer**: Dividir todo el trabajo de refactoring en lotes pequeños y seguros. Cada lote es independiente — si algo falla, solo se revierte ese lote, no todo el trabajo.

**Que esperar**: Claude crea los lotes (tasks). Normalmente son algo asi:

| Lote | Que hace | Riesgo |
|------|---------|--------|
| Batch 1 | Reorganizar archivos (mover, crear carpetas, actualizar imports) | Medio — muchos archivos cambian de lugar |
| Batch 2 | Agregar linter y reglas de estilo | Bajo — no cambia logica, solo formato |
| Batch 3 | Agregar tipos a modelos de datos | Bajo — agrega informacion, no cambia logica |
| Batch 4 | Agregar tipos a funciones publicas | Bajo — agrega informacion, no cambia logica |
| Batch 5 | Agregar tests para rutas criticas | Bajo — solo agrega tests, no cambia codigo |
| Batch 6 | Actualizar dependencias | Medio — las versiones nuevas pueden tener cambios |

**Tu respuesta:**

```
Se ve bien, continua
```

> **IMPORTANTE**: Cada lote debe pasar los tests ANTES de continuar al siguiente.
> Claude esta configurado para verificar esto, pero si no lo hace, dile:
> "Ejecuta todos los tests existentes antes de continuar con el siguiente batch."

---

## Paso 8 — Batch 1: Reorganizar archivos (aplicar la Scope Rule)

**Que vamos a hacer**: Este es el lote mas grande e importante. Claude va a mover los archivos al lugar correcto segun la Scope Rule. Es como reorganizar todos los muebles de la casa.

**Copia y pega este prompt**:

```
/sdd:apply refactoring-modernizacion
```

**Que esperar**: Claude ejecuta el **Execution Gate** y te muestra el plan:

```
Este cambio involucra scope infra + pipeline:
- Mover 23 archivos a nuevas ubicaciones
- Crear 8 carpetas nuevas (features/, core/, shared/)
- Actualizar 47 imports en 15 archivos
- Eliminar 3 carpetas vacias despues de la migracion
- Procedo?
```

**Tu respuesta**:

```
Si, procede. Pero despues de mover los archivos, ejecuta TODOS los tests
existentes para verificar que no se rompio nada.
```

**QUE VIGILAR en este paso**:

1. **Imports rotos**: Cuando mueves un archivo, todos los archivos que lo importan deben actualizarse. Claude lo hace automaticamente, pero verifica:

```
Ejecuta el proyecto para verificar que arranca sin errores de "modulo no encontrado".
```

2. **Rutas hardcodeadas**: Si tu codigo tiene rutas escritas directamente (como `/api/products`), verificar que sigan funcionando.

3. **Archivos de configuracion**: Archivos como `package.json`, `tsconfig.json`, `pyproject.toml` pueden necesitar actualizacion de rutas.

**Si algo se rompe**, NO entres en panico:

```
Los tests fallan despues de mover los archivos. El error es:
[pega el error aqui]

Corrige el import roto sin revertir la reorganizacion.
```

**Cuando los tests pasen**, haz un commit de seguridad:

```
Haz un commit con los cambios de reorganizacion de archivos.
Mensaje: "refactor: reorganizar archivos con Scope Rule"
```

---

## Paso 9 — Batch 2: Agregar tipos y linting

**Que vamos a hacer**: Agregar "etiquetas" a los datos para que el codigo sea mas predecible. Tambien agregar un revisor automatico (linter) que detecte errores comunes.

**Que esperar**: Claude continua con el siguiente batch. Si no lo hace automaticamente:

```
Continua con el siguiente batch — agregar tipos y linting.
```

Claude va a:
- **Para Python**: Agregar type hints (`def saludar(nombre: str) -> str:`)
- **Para TypeScript/JavaScript**: Agregar tipos o convertir archivos `.js` a `.ts`
- **Para cualquier lenguaje**: Configurar un linter con reglas razonables

**CRITERIO IMPORTANTE**: Los tipos se agregan de forma **incremental**:

1. Primero los modelos de datos (las "cosas" del proyecto: productos, usuarios, pedidos)
2. Luego las funciones publicas (las que otros archivos llaman)
3. Ultimo las funciones internas (las que solo usa un archivo)

**Tu respuesta por cada batch**:

```
Si, continua con el siguiente batch
```

**Si el linter reporta muchos errores:**

```
El linter reporta 150 errores. Corrige solo los errores criticos
(errores de logica, variables no definidas) y deja los de estilo
(formato, espacios) para despues. No quiero que un cambio de formato
me rompa algo que funciona.
```

**Cuando los tests pasen**, haz commit:

```
Haz un commit con los cambios de tipos y linting.
Mensaje: "refactor: agregar type hints y configurar linter"
```

---

## Paso 10 — Batch 3: Agregar tests para las partes criticas

**Que vamos a hacer**: Agregar pruebas automaticas para las partes mas importantes del proyecto. Los tests son como alarmas: si algo se rompe en el futuro, las alarmas suenan inmediatamente.

**Que esperar**: Claude va a crear tests que cubran:

1. **Los flujos principales**: El "camino feliz" — lo que pasa cuando todo funciona bien
2. **Los modelos de datos**: Verificar que los datos se crean y transforman correctamente
3. **Las funciones criticas**: Las que manejan dinero, datos de usuarios, o logica de negocio

**Si Claude te pregunta que es "critico":**

```
Las partes criticas de mi proyecto son:
- [Ejemplo: "El calculo de precios con impuestos"]
- [Ejemplo: "El login de usuarios"]
- [Ejemplo: "El procesamiento de pedidos"]
- [Ejemplo: "La generacion de facturas"]

Crea tests para esas funciones primero.
```

**REGLA IMPORTANTE**: Claude NO debe modificar el codigo existente para que los tests pasen. Si un test falla, hay dos opciones:
1. El test esta mal escrito → Claude corrige el test
2. El codigo tiene un bug real → Claude te avisa y TU decides si corregirlo

```
Si un test falla, primero verifica si el test esta mal escrito.
Si el codigo realmente tiene un bug, avisame y dime que pasa
antes de corregirlo. No corrijas bugs del codigo existente sin avisarme.
```

**Cuando los tests pasen**, haz commit:

```
Haz un commit con los tests nuevos.
Mensaje: "test: agregar tests para funciones criticas"
```

---

## Paso 11 — Verificacion final (el momento de la verdad)

**Que vamos a hacer**: Ejecutar TODAS las verificaciones para confirmar que la renovacion no rompio nada. Este paso es critico — es la inspeccion final antes de entregar la casa renovada.

**Copia y pega este prompt**:

```
/sdd:verify refactoring-modernizacion

Ejecuta una verificacion COMPLETA:

1. TODOS los tests existentes (los que ya estaban antes del refactoring)
   - Si alguno falla, es un ERROR NUESTRO — el refactoring rompio algo
   - Lista TODOS los tests que fallan, no solo el primero

2. TODOS los tests nuevos (los que acabamos de agregar)
   - Si alguno falla, verifica si es error del test o del codigo

3. El linter pasa sin errores criticos
   - Advertencias estan bien, errores no

4. El proyecto arranca correctamente
   - Sin errores de import, modulo no encontrado, etc.

5. Verificacion de Scope Rule
   - No quedan archivos en utils/, helpers/, lib/ de la raiz
   - Cada archivo esta en el lugar correcto segun quien lo usa

6. Comparacion de comportamiento
   - Si hay endpoints de API, verifica que responden igual que antes
   - Si hay interfaz de usuario, verifica que las paginas cargan

Dame un reporte con el resultado de cada punto.
```

**Que esperar**: Claude ejecuta todas las verificaciones y te da un reporte:

```
REPORTE DE VERIFICACION FINAL:

1. Tests existentes: 12/12 PASAN
2. Tests nuevos: 8/8 PASAN
3. Linter: 0 errores, 5 advertencias (formato menor)
4. Proyecto arranca: SI, sin errores
5. Scope Rule: COMPLETA — 0 archivos en ubicaciones incorrectas
6. Comportamiento: API responde igual, interfaz carga correctamente

VEREDICTO: Refactoring EXITOSO
```

**Si algo falla:**

```
Los tests X y Y fallan. Corrige el refactoring para que vuelvan a pasar.
Recuerda: los tests existentes NO se modifican — el codigo debe adaptarse a ellos.
```

Repite la verificacion hasta que todo pase:

```
/sdd:verify refactoring-modernizacion
```

---

## Paso 12 — Archivar, documentar y celebrar

**Que vamos a hacer**: Cerrar formalmente el proyecto de refactoring, documentar que cambio, y guardar las lecciones aprendidas.

**Copia y pega este prompt**:

```
/sdd:archive refactoring-modernizacion

Ademas del archivo normal, genera un documento "CHANGELOG-refactoring.md" que incluya:

1. RESUMEN: Que se hizo (en espanol simple, para no-tecnicos)
2. ANTES Y DESPUES: Tabla mostrando la estructura vieja vs la nueva
3. ARCHIVOS MOVIDOS: Lista completa de de-donde a donde
4. TESTS AGREGADOS: Cuantos, que cubren
5. TIPOS AGREGADOS: Que archivos ahora tienen tipos
6. DEPENDENCIAS ACTUALIZADAS: Cuales y a que version
7. RIESGOS PENDIENTES: Que queda por mejorar en el futuro
8. COMO VERIFICAR: Comandos para que cualquiera pueda verificar que todo funciona

Este documento es para el equipo que va a mantener el proyecto despues.
```

**Despues de archivar**, guarda todo con un commit final:

```
Haz un commit final con todos los cambios del refactoring y el changelog.
Mensaje: "refactor: modernizacion completa — archivos reorganizados, tipos y tests agregados"
```

**Para "publicar" los cambios** (mover de tu rama de trabajo a la rama principal):

Este paso lo haces manualmente (o con Claude si te sientes comodo):

```
Necesito hacer merge de la rama refactoring/modernizacion a main.
Primero verifica que no hay conflictos, luego haz el merge.
```

> **IMPORTANTE**: Si trabajas en equipo, es mejor crear un Pull Request en GitHub
> para que otro miembro revise los cambios antes de hacer merge. Dile a Claude:
> ```
> Crea un Pull Request en GitHub con titulo "Modernizacion: reorganizar archivos,
> agregar tipos y tests" y descripcion basada en el CHANGELOG-refactoring.md
> ```

**Tu proyecto esta modernizado. Felicidades!**

---

# DESPUES DE LA ENTREGA

> Estos pasos son opcionales pero recomendados.

---

## Hacer cambios futuros con la nueva estructura

Ahora que tu proyecto esta organizado, los cambios futuros son mas faciles. Usa el proceso SDD:

```
/sdd:new nombre-del-cambio

Quiero agregar [descripcion del cambio].
```

Claude va a crear los archivos en el lugar correcto automaticamente porque la Scope Rule ya esta establecida.

---

## Continuar mejorando incrementalmente

El refactoring no tiene que ser "todo o nada". Puedes seguir mejorando de a poco:

```
/sdd:new mejorar-tests-modulo-X

Quiero agregar tests para el modulo de [nombre del modulo]
que todavia no tiene buena cobertura.
```

```
/sdd:new tipos-funciones-internas

Quiero agregar type hints a las funciones internas del modulo [nombre].
Ya tiene tipos en las funciones publicas, ahora faltan las internas.
```

---

## Mejorar tus instrucciones

Despues de varias sesiones de refactoring:

```
/batuta:analyze-prompts
```

Claude te dice como mejorar tus pedidos para futuras sesiones.

---

## Comandos de emergencia

| Situacion | Que escribir |
|-----------|-------------|
| Algo se rompio y quiero volver atras | En la terminal: `git checkout main` (vuelves a la version original) |
| Un lote salio mal pero los anteriores estan bien | `git revert HEAD` (deshace el ultimo commit) |
| Claude se trabo | Cierra la terminal, abrela de nuevo, escribe `claude` |
| No entiendes algo | `Explicame [lo que no entiendes] como si tuviera 15 anos` |
| Quieres ver donde quedamos | `/sdd:continue refactoring-modernizacion` |

---

# SECCION DE SEGURIDAD

> Refactorizar codigo tiene riesgos especificos. Lee esta seccion con atencion.

---

## No introducir vulnerabilidades nuevas

Cuando reorganizas codigo, puedes accidentalmente exponer cosas que antes estaban protegidas. Verifica estos puntos:

### Archivos de configuracion y secretos

| Verificar | Por que | Como |
|-----------|--------|------|
| `.gitignore` sigue incluyendo `.env` | Al reorganizar, el .gitignore podria haber cambiado | `Verifica que .env y archivos de secretos estan en .gitignore` |
| Variables de entorno no se hardcodearon | Al mover codigo, las variables pueden terminar escritas directamente | `Busca strings que parezcan contrasenas o API keys en el codigo` |
| Archivos sensibles no se movieron a carpetas publicas | Si mueves archivos a `public/` o `static/`, podrian ser accesibles desde internet | `Verifica que ningun archivo sensible esta en carpetas publicas` |

### Dile a Claude:

```
Haz una auditoria rapida de seguridad post-refactoring:
1. Verifica que .gitignore cubre todos los archivos sensibles
2. Busca contrasenas, API keys, o tokens hardcodeados en el codigo
3. Verifica que no hay archivos sensibles en carpetas publicas
4. Verifica que las rutas de la API no cambiaron (para no romper autenticacion)
```

---

## Actualizacion de dependencias

Cuando actualizas librerias a versiones nuevas, hay riesgos:

| Riesgo | Que pasa | Como mitigar |
|--------|---------|-------------|
| **Breaking changes** | La version nueva funciona diferente a la anterior | Actualizar una dependencia a la vez y ejecutar tests despues de cada una |
| **Vulnerabilidades nuevas** | La version nueva podria tener sus propios problemas | Verificar con `npm audit` o `pip audit` despues de actualizar |
| **Incompatibilidades** | Dos librerias no funcionan bien juntas en las versiones nuevas | Si algo se rompe, revertir esa dependencia especifica |

**Dile a Claude:**

```
Actualiza las dependencias UNA POR UNA, empezando por las que tienen
vulnerabilidades conocidas. Despues de actualizar CADA UNA, ejecuta
los tests para verificar que nada se rompio.

Si una actualizacion rompe algo, revertirla y avisarme antes de intentar
otra solucion.
```

---

## Backup antes de cada lote

Aunque git es tu red de seguridad, es buena practica hacer commit antes de cada lote grande:

```
Antes de empezar el siguiente batch, haz un commit con los cambios actuales.
Asi tenemos un punto de retorno por cada lote de cambios.
```

---

# USANDO AGENT TEAMS (Equipos de Agentes)

Cuando te sientas comodo con los pasos anteriores, puedes usar **Agent Teams** para que Claude trabaje con multiples "asistentes" en paralelo. Es como tener un equipo de contratistas renovando diferentes habitaciones al mismo tiempo.

---

## Cuando usar cada nivel

| Nivel | Cuando usarlo | Ejemplo en este proyecto |
|-------|--------------|------------------------|
| **Solo** (normal) | Cambios simples, mover 1-2 archivos | "Mueve el archivo X a features/Y/" |
| **Subagente** (automatico) | Investigar una dependencia o verificar algo | Claude investiga si una libreria es compatible con la nueva version |
| **Agent Team** (tu lo pides) | Refactoring grande en multiples areas | Reorganizar archivos, agregar tipos, y agregar tests al mismo tiempo |

## Equipo recomendado para refactoring

El patron recomendado es **Patron A (SDD Pipeline Team)** con 4 teammates:

| Teammate | Que hace | Que archivos son suyos |
|----------|---------|----------------------|
| `researcher` | Investiga el codebase, identifica problemas, mapea dependencias | Documentos de analisis, no modifica codigo |
| `restructurer` | Mueve archivos segun la Scope Rule, actualiza imports | Toda la reorganizacion de carpetas |
| `type-adder` | Agrega tipos (type hints, TypeScript types) | Solo agrega tipos, no mueve archivos |
| `test-writer` | Escribe tests para las partes criticas | Solo archivos en `tests/` |

El Lead (Claude principal) coordina que nadie toque los archivos de otro y verifica que los tests pasen despues de cada lote.

## Como pedirle a Claude que use un equipo

```
Tu: "Necesito modernizar este proyecto. Tiene 40 archivos desorganizados,
     sin tipos, y sin tests. Crea un equipo para que un asistente reorganice
     archivos mientras otro agrega tipos y otro escribe tests."
```

Claude va a:
1. Evaluar si el trabajo justifica un equipo (40 archivos + 3 tipos de trabajo = si)
2. Definir contratos: que archivos puede tocar cada asistente
3. Crear los asistentes especializados
4. Coordinar que no haya conflictos de archivos
5. Verificar que todo encaje al final

## Ejemplos practicos

**Ejemplo 1 — Refactoring en paralelo por areas:**
```
Tu: "El proyecto tiene 3 modulos grandes: productos, usuarios, y pedidos.
     Que cada asistente modernice un modulo diferente (reorganizar archivos,
     agregar tipos, agregar tests) en paralelo."
```

**Ejemplo 2 — Investigacion + implementacion:**
```
Tu: "Necesito actualizar de React 17 a React 19. Que un asistente investigue
     los breaking changes mientras otro empieza a actualizar los componentes
     que no van a cambiar."
```

**Ejemplo 3 — Auditoria completa en equipo:**
```
Tu: "Haz una auditoria completa del proyecto antes del refactoring.
     Que un asistente revise la seguridad, otro la estructura de archivos,
     otro los tests, y otro las dependencias. Denme un reporte unificado."
```

## Metricas esperadas de rendimiento

Anota tus resultados reales para mejorar el sistema con `/batuta:analyze-prompts`.

| Escenario | Nivel | Tiempo estimado | Costo tokens | Calidad esperada | Fortaleza | Debilidad |
|-----------|-------|----------------|-------------|-----------------|-----------|-----------|
| Mover 5 archivos + imports | Solo | 5-10 min | ~10K tokens | 95% primera vez | Rapido, bajo riesgo | N/A |
| Refactoring 1 modulo SDD | Solo + Subagente | 20-30 min | ~60K tokens | 85% primera vez | Trazable, spec completa | Secuencial |
| Refactoring 3 modulos paralelo | Agent Team | 30-45 min | ~200K tokens | 80% primera vez | 3 modulos al mismo tiempo | Conflictos de imports entre modulos |
| Auditoria completa pre-refactoring | Agent Team | 15-25 min | ~120K tokens | 90% diagnostico | Multiples perspectivas | Hallazgos pueden solaparse |
| Migracion de framework (React/Django) | Agent Team | 40-60 min | ~280K tokens | 70% primera vez | Paralelo en modulos independientes | Breaking changes son impredecibles |

> **Importante**: Para refactoring, el riesgo principal de los Agent Teams es que dos asistentes
> toquen el mismo archivo al mismo tiempo. Claude esta configurado para evitar esto con el
> sistema de "File Ownership", pero es especialmente critico en refactoring donde muchos imports
> cambian. Si tienes dudas, el modo Solo es mas seguro aunque mas lento.

---

# TROUBLESHOOTING — Problemas Comunes y Soluciones

---

## Tests se rompen despues de mover archivos

**Sintoma**: Tests que pasaban antes ahora fallan con errores como "module not found", "cannot resolve", "import error".

**Por que pasa**: Cuando mueves un archivo, los tests que lo importan siguen buscandolo en la ruta vieja.

**Que decirle a Claude**:

```
Los tests X, Y y Z fallan con "module not found" despues de reorganizar archivos.
Actualiza los imports en los archivos de test para que apunten a las nuevas
ubicaciones de los modulos. NO modifiques la logica de los tests, solo los imports.
```

---

## Imports circulares despues de reorganizar

**Sintoma**: Error que dice "circular import" o "circular dependency". El programa se queda atascado intentando importar cosas en circulo.

**Por que pasa**: El archivo A importa del archivo B, y el archivo B importa del archivo A. Es como dos personas esperandose mutuamente en una puerta: ninguna puede pasar.

**Que decirle a Claude**:

```
Hay un import circular entre [archivo A] y [archivo B].
Identifica que parte del codigo causa el circulo y mueve
ese codigo a features/shared/ para romper la dependencia circular.
```

---

## Dependencias incompatibles despues de actualizar

**Sintoma**: Despues de actualizar una libreria, otra deja de funcionar. Error como "version conflict" o "incompatible".

**Por que pasa**: Dos librerias necesitan versiones diferentes de una tercera. Como dos enchufes que necesitan diferente voltaje.

**Que decirle a Claude**:

```
Despues de actualizar [libreria X] a la version Y, [libreria Z] dejo de funcionar.
El error es: [pega el error].

Opciones:
1. Revertir la actualizacion de X
2. Buscar una version de X compatible con Z
3. Buscar alternativa para Z

Recomiendame la mejor opcion con las razones.
```

---

## El proyecto ya no arranca despues del refactoring

**Sintoma**: Al ejecutar el proyecto, da error inmediatamente (antes de la renovacion arrancaba).

**Que decirle a Claude**:

```
El proyecto no arranca despues del refactoring. El error es:
[pega el error completo]

REGLA: El proyecto DEBE arrancar igual que antes del refactoring.
Si algo se rompio, corrigelo para que arranque. No cambies la funcionalidad,
solo arregla lo que el refactoring rompio.
```

**Si el error es muy dificil de corregir** y quieres volver atras:

En la terminal (fuera de Claude Code):
```
git stash
git checkout main
```
Esto vuelve al estado original. Luego puedes volver a la rama de refactoring:
```
git checkout refactoring/modernizacion
git stash pop
```

---

## Claude quiere cambiar la funcionalidad (NO dejar que lo haga)

**Sintoma**: Claude sugiere "mejorar" el codigo cambiando como funciona algo, no solo como esta organizado.

**Que decirle a Claude**:

```
STOP. Este es un refactoring, no una mejora funcional.
NO cambies la logica ni el comportamiento del codigo.
Solo reorganiza, agrega tipos, y agrega tests.
Si encuentras un bug, avisame ANTES de corregirlo.
Yo decido si el bug se corrige ahora o en otra sesion.
```

---

## El equipo depende de rutas especificas de archivos

**Sintoma**: Otro sistema o equipo usa rutas exactas de archivos que vas a mover.

**Que decirle a Claude**:

```
ATENCION: Los siguientes archivos NO se pueden mover porque otros sistemas
dependen de su ubicacion exacta:
- [ruta/archivo1] — usado por el sistema de deploy
- [ruta/archivo2] — referenciado en la configuracion del CI/CD
- [ruta/archivo3] — importado por otro proyecto

Reorganiza TODO lo demas, pero deja estos archivos donde estan.
Si necesitas que esten en dos lugares, crea un archivo "puente" que
importe y re-exporte desde la nueva ubicacion.
```

---

## Preguntas frecuentes

**P: Puedo hacer refactoring en un proyecto que no tiene tests?**
R: Si, pero con mas cuidado. Los tests son tu red de seguridad. Sin ellos, cada cambio tiene mas riesgo. Por eso agregamos tests como parte del refactoring (Paso 10).

**P: Cuanto tiempo toma refactorizar un proyecto?**
R: Depende del tamano. Un proyecto de 20-30 archivos toma 1-2 horas. Uno de 100+ archivos puede tomar medio dia. La buena noticia es que puedes parar y continuar despues — `.batuta/session.md` guarda el progreso.

**P: Puedo refactorizar un proyecto en un lenguaje que no conozco?**
R: Si. Claude lee y entiende el codigo. Tu solo necesitas saber que hace el proyecto (su proposito), no como esta escrito. Describe en tus propias palabras que deberia hacer cada parte.

**P: Que pasa si refactorizo y el deploy se rompe?**
R: Por eso trabajamos en una rama separada. No hagas merge a `main` hasta que todo este verificado. Si ya hiciste merge y se rompio, usa `git revert` para deshacer.

**P: Puedo refactorizar solo una parte del proyecto?**
R: Absolutamente. Puedes refactorizar un solo modulo o carpeta. En la propuesta (Paso 4), dile a Claude exactamente que parte quieres modernizar y que parte dejar como esta.

**P: Puedo cerrar la terminal y continuar despues?**
R: Si. Abre la terminal, navega a tu carpeta, escribe `claude`, y Claude lee `.batuta/session.md` donde guardo en que quedo.

---

## Resumen visual del flujo completo

```
Tu (proyecto desordenado)
 |
 +-- Paso 1:  Commit + branch ............. "Seguro de hogar"
 |
 +-- Paso 2:  Instalar ecosistema Batuta ... "Darle recetas al chef"
 |
 +-- Paso 3:  /sdd:explore ................ "El detective investiga la casa"
 |
 |   [Claude detecta skills faltantes → "Opcion 1"]
 |
 +-- Paso 4:  /sdd:new .................... "Plan de renovacion"
 |     Tu: "Aprobado"
 |
 +-- Paso 5:  Specs ....................... "Regla de oro: no romper nada"
 |
 +-- Paso 6:  Design + Tasks .............. "Mapa de donde va cada cosa"
 |
 +-- Paso 7:  Dividir en lotes ............ "Habitacion por habitacion"
 |
 +-- Paso 8:  Batch 1 — Reorganizar ....... "Mover muebles"
 |     [Tests deben pasar → commit]
 |
 +-- Paso 9:  Batch 2 — Tipos + linting ... "Etiquetar todo"
 |     [Tests deben pasar → commit]
 |
 +-- Paso 10: Batch 3 — Agregar tests ..... "Instalar alarmas"
 |     [Tests deben pasar → commit]
 |
 +-- Paso 11: /sdd:verify ................. "Inspeccion final"
 |     [TODO debe pasar]
 |
 +-- Paso 12: /sdd:archive + merge ........ "Entregar la casa renovada"
 |
 [Proyecto modernizado, organizado, con tipos y tests!]
```

---

> **Recuerda**: Refactorizar es como renovar una casa mientras la gente vive adentro.
> La paciencia es tu mejor herramienta. Trabaja habitacion por habitacion, verifica
> despues de cada cambio, y nunca olvides que lo mas importante es que NADA de lo que
> ya funciona deje de funcionar. Claude es tu contratista — el hace el trabajo pesado,
> tu decides que se cambia y que se queda.
