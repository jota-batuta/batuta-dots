# Comandos completos

Referencia rapida de todos los comandos disponibles en Batuta Dots v13.

> **Auto-routing**: Normalmente no necesitas escribir estos comandos. Batuta detecta
> automaticamente lo que necesitas y ejecuta la fase correcta. Describe tu problema
> en lenguaje natural y Batuta actua. Estos comandos existen como **override manual**
> para cuando quieras controlar un paso especifico directamente.
> Ver: [Auto-routing](../01-nivel-cero/el-pipeline-sdd.md#auto-routing-conversacion-natural)

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
**Que hace**: Investiga un tema sin comprometerse a construir.
**Cuando**: Quieres analizar opciones, validar ideas, o entender el codebase.
**Resultado**: Analisis estructurado con opciones, riesgos, y recomendaciones.

```
/sdd-explore "Deberiamos migrar a microservicios?"
/sdd-explore "Como funciona el sistema de auth actual?"
```

---

### /sdd-new
**Que hace**: Inicia un cambio nuevo. Ejecuta explore + propose automaticamente.
**Cuando**: Decidiste construir algo.
**Resultado**: Exploracion + propuesta en `openspec/changes/{nombre}/`.
**Gates**: G0.5 (Discovery) + G1 (Worth Building).

```
/sdd-new conciliacion-bancaria
/sdd-new landing-page-producto
```

---

### /sdd-continue
**Que hace**: Detecta la fase actual de un cambio y ejecuta la siguiente.
**Cuando**: Retomas un cambio despues de una pausa.
**Resultado**: La siguiente fase del pipeline.

```
/sdd-continue
/sdd-continue conciliacion-bancaria
```

---

### /sdd-ff
**Que hace**: Fast-forward — ejecuta propose + spec + design + tasks en secuencia.
**Cuando**: Quieres avanzar rapido por las fases de planificacion.
**Resultado**: 4 artefactos en `openspec/changes/{nombre}/`.

```
/sdd-ff
/sdd-ff conciliacion-bancaria
```

---

### /sdd-apply
**Que hace**: Implementa codigo siguiendo las tareas del cambio activo. Durante la implementacion, los domain agents (backend, quality, data) se auto-invocan segun las tecnologias de cada tarea — no necesitas activarlos manualmente.
**Cuando**: Las fases de planificacion estan completas.
**Resultado**: Codigo implementado, documentado, con Scope Rule aplicada.

```
/sdd-apply
/sdd-apply conciliacion-bancaria
```

---

### /sdd-verify
**Que hace**: Ejecuta la Piramide de Validacion AI (5 capas).
**Cuando**: Despues de implementar.
**Resultado**: Reporte de verificacion. Gate G2 al final.

```
/sdd-verify
/sdd-verify conciliacion-bancaria
```

---

### /sdd-archive
**Que hace**: Archiva el cambio completado. Sincroniza specs, documenta lecciones.
**Cuando**: Despues de que G2 pasa.
**Resultado**: Cambio archivado en `openspec/changes/archive/`.

```
/sdd-archive
/sdd-archive conciliacion-bancaria
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
| Cerrar cambio | "Archiva el cambio" | `/sdd-archive` |
| Empezar proyecto | — | `/sdd-init` |
| Crear skill | — | `/create-skill nombre` |
| Evaluar skill | — | `/skill:eval nombre` |
| Benchmark skills | — | `/skill:benchmark` |
