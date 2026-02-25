# Comandos completos

Referencia rapida de todos los comandos disponibles en Batuta Dots v11.0.

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
**Que hace**: Implementa codigo siguiendo las tareas del cambio activo.
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
**Que hace**: Crea un agente nuevo.
**Cuando**: Tienes 3+ skills que necesitan coordinacion.

```
/create-sub-agent mobile-agent
```

### /create-workflow
**Que hace**: Crea un workflow automatizado.
**Cuando**: Tienes una secuencia repetitiva de pasos.

```
/create-workflow deploy-production
```

### /batuta-sync-skills
**Que hace**: Regenera tablas de ruteo de los agentes.
**Cuando**: Despues de crear o modificar skills.

```
/batuta-sync-skills
```

### /batuta-analyze-prompts
**Que hace**: Analiza el historial de interacciones y genera recomendaciones.
**Cuando**: Quieres mejorar tu flujo de trabajo.

```
/batuta-analyze-prompts
```

---

## Comandos de setup

### /batuta-init
**Que hace**: Configura el ecosistema Batuta en el proyecto actual.
**Cuando**: Primer uso en un proyecto.

### /batuta-update
**Que hace**: Actualiza el ecosistema a la ultima version.
**Cuando**: Hay una nueva version disponible.

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
| Sincronizar | — | `/batuta-sync-skills` |
| Analizar calidad | `/batuta-analyze-prompts` |
