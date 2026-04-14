# Comandos completos

Referencia rapida de todos los comandos disponibles en Batuta Dots v15.

> **Auto-routing**: Normalmente no necesitas escribir estos comandos. Batuta detecta
> automaticamente lo que necesitas y ejecuta la fase correcta. Describe tu problema
> en lenguaje natural y Batuta actua. Estos comandos existen como **override manual**
> para cuando quieras controlar un paso especifico directamente.
>
> **Dos modos SDD (v15)**: El pipeline opera en dos modos:
> - **SPRINT** (default): Research → Apply → Verify. Sin gates formales, flujo rapido.
> - **COMPLETO** (cuando el CTO lo pide via PRD): Research → Explore → Design (USER STOP) → Apply → Verify.
> El modo se detecta automaticamente por la presencia de un PRD en Notion.

---

## Comandos SDD (Pipeline)

### /sdd-init
**Que hace**: Inicializa SDD en un proyecto. Detecta tipo de proyecto y stack.
**Cuando**: Al empezar un proyecto nuevo.
**Resultado**: Carpeta `openspec/` con `config.yaml`.

```
/sdd-init
```

Ejemplo de salida:
```
SDD Initialized
Project: mi-app
Type: webapp
Stack: Next.js, PostgreSQL, Redis
```

---

### /sdd-explore
**Que hace**: Investiga un tema sin comprometerse a construir. Aplica **Discovery Depth**: lee codigo real antes de asumir, verifica flujos de datos, y documenta supuestos tecnicos.
**Cuando**: Quieres analizar opciones, validar ideas, o entender el codebase.
**Resultado**: Analisis estructurado con opciones, riesgos, recomendaciones, y Technical Assumptions verificables.
**Regla anti-shallow**: Si la exploracion no puede responder el flujo de datos para cada integracion, debe profundizar mas antes de avanzar a propuesta.

```
/sdd-explore "Deberiamos migrar a microservicios?"
/sdd-explore "Como funciona el sistema de auth actual?"
```

---

### /sdd-new
**Que hace**: Inicia un cambio nuevo. Ejecuta explore + design automaticamente.
**Cuando**: Decidiste construir algo y quieres planificacion completa.
**Resultado**: Exploracion + diseno en `openspec/changes/{nombre}/`.
**Aprobacion**: Despues de generar el design, se detiene para aprobacion del usuario.

```
/sdd-new conciliacion-bancaria
/sdd-new landing-page-producto
```

---

### /sdd-continue
**Que hace**: Detecta el modo (SPRINT o COMPLETO) y la fase actual de un cambio, luego ejecuta la siguiente.
**Cuando**: Retomas un cambio despues de una pausa.
**Resultado**: La siguiente fase del pipeline segun el modo detectado.
**SPRINT**: sin implementacion → apply → sin verify → verify → done.
**COMPLETO**: sin explore → explore → sin design → design (STOP) → apply → verify → done.

```
/sdd-continue
/sdd-continue conciliacion-bancaria
```

---

### /sdd-ff
**Que hace**: Fast-forward — ejecuta explore + design en secuencia (2 pasos).
**Cuando**: Quieres ir de idea a diseno accionable rapidamente.
**Resultado**: 2 artefactos en `openspec/changes/{nombre}/`: `explore.md` y `design.md`.
**Aprobacion**: Se detiene despues de generar el design para aprobacion del usuario.

```
/sdd-ff
/sdd-ff conciliacion-bancaria
```

---

### /sdd-apply
**Que hace**: Implementa codigo siguiendo el PRD o design del cambio activo. Los agentes especializados se contratan segun las tecnologias de cada tarea — el main agent delega, no ejecuta.
**Cuando**: El design fue aprobado (modo COMPLETO) o directamente despues de research (modo SPRINT).
**Resultado**: Codigo implementado, documentado, con Scope Rule aplicada.

```
/sdd-apply
/sdd-apply conciliacion-bancaria
```

---

### /sdd-verify
**Que hace**: Ejecuta la Piramide de Validacion AI (5 capas).
**Cuando**: Despues de implementar.
**Resultado**: Reporte de verificacion.

```
/sdd-verify
/sdd-verify conciliacion-bancaria
```

---

## Comandos de ecosistema

### /create-skill
**Que hace**: Crea un skill nuevo usando ecosystem-creator.
**Cuando**: Necesitas que Batuta aprenda algo nuevo.

```
/create-skill react-native-patterns
```

### /create-sub-agent
**Que hace**: Crea un agente nuevo con thick persona (expertise embebido). Despues de crearlo, `ecosystem-lifecycle` lo clasifica como generico o especifico del proyecto.
**Cuando**: Tienes 3+ skills que necesitan coordinacion y un dominio con convenciones propias.
**Ciclo de vida**: crear → clasificar → sincronizar → provisionar. Ver [Extendiendo el ecosistema](../04-nivel-tres/extendiendo-el-ecosistema.md).

```
/create-sub-agent mobile-agent
```

### /create-workflow
**Que hace**: Crea un workflow automatizado.
**Cuando**: Tienes una secuencia repetitiva de pasos.

```
/create-workflow deploy-production
```

---

## Comandos de evaluacion

### /skill:eval
**Que hace**: Evalua un skill con tests comportamentales definidos en SKILL.eval.yaml.
**Cuando**: Despues de crear o modificar un skill, para verificar que se activa correctamente y produce resultados de calidad.

```
/skill:eval mi-skill
```

### /skill:benchmark
**Que hace**: Ejecuta eval para todos los skills que tengan un archivo SKILL.eval.yaml. Genera un reporte de salud del ecosistema.
**Cuando**: Quieres verificar que ningun skill se rompio despues de cambios en el ecosistema.

```
/skill:benchmark
```

---

## Comandos de setup

### /batuta-init
**Que hace**: Configura el ecosistema Batuta en el proyecto actual.
**Cuando**: Primer uso en un proyecto.

### /batuta-update
**Que hace**: Actualiza el ecosistema a la ultima version desde batuta-dots.
**Cuando**: Hay una nueva version disponible o quieres los skills mas recientes.
**Proceso**: Localiza batuta-dots (`~/batuta-dots/` o `/tmp/batuta-dots/`), hace `git pull` (bloqueante — si falla, se detiene y explica), y ejecuta `setup.sh --update "$(pwd)"` (Claude Code) o `setup-antigravity.sh --update "$(pwd)"` (Antigravity).

```
/batuta-update
```

**Importante**: El `git pull` es bloqueante por seguridad. Si falla (dirty tree, wrong branch, sin red), se detiene y te dice que hacer. NUNCA continua con archivos desactualizados.

### /batuta-sync
**Que hace**: Sincroniza skills entre el proyecto actual y el hub batuta-dots. Detecta skills locales que no estan en el hub y skills del hub que no estan en el proyecto.
**Cuando**: Creaste skills nuevos en un proyecto y quieres propagarlos al hub, o quieres traer skills del hub a tu proyecto.
**Opciones**: (1) Sincronizar todo, (2) Solo propagar al hub, (3) Solo traer del hub, (4) Seleccionar individualmente.
**Cross-sync**: Si el skill tiene `platforms: [claude, antigravity]`, se sincroniza automaticamente a Antigravity.

```
/batuta-sync
```

---

## Comandos de desarrollador (terminal)

Estos comandos se ejecutan directamente en terminal, no dentro de Claude Code ni Antigravity:

### sync.sh --push
**Que hace**: Propaga skills locales de un proyecto al hub batuta-dots. Un solo comando que importa, cross-syncs a Antigravity, commit y push.
**Cuando**: Creaste skills nuevos en un proyecto y quieres que esten disponibles en todos los demas.

```bash
bash ~/batuta-dots/infra/sync.sh --push /path/to/mi-proyecto
```

### setup.sh --update
**Que hace**: Actualiza un proyecto existente (re-sync global + refrescar CLAUDE.md + ecosystem.json). Es lo que `/batuta-update` ejecuta internamente.
**Cuando**: Quieres actualizar manualmente sin pasar por Claude Code.

```bash
bash ~/batuta-dots/infra/setup.sh --update /path/to/mi-proyecto
```

---

## Referencia rapida

| Quiero... | Forma natural (auto-routing) | Override manual |
|-----------|------------------------------|-----------------|
| Construir algo nuevo | "Necesito un dashboard de ventas" | `/sdd-new nombre` |
| Investigar idea | "Como funciona el auth actual?" | `/sdd-explore "tema"` |
| Continuar donde quede | "Donde quedamos?" | `/sdd-continue` |
| Avanzar rapido por planificacion | "Dale, avanza con todo" | `/sdd-ff` |
| Implementar | "Arranca con el codigo" | `/sdd-apply` |
| Verificar | "Verifica que funcione" | `/sdd-verify` |
| Empezar proyecto | — | `/sdd-init` |
| Crear skill | — | `/create-skill nombre` |
| Evaluar skill | — | `/skill:eval nombre` |
| Benchmark skills | — | `/skill:benchmark` |
| Sincronizar skills con hub | — | `/batuta-sync` |
