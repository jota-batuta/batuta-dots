# Quiz Nivel Tres — Extension del Ecosistema

Autoevaluacion para confirmar que dominas la extension y personalizacion de Batuta Dots.

---

## Pregunta 1: Crear un skill

Necesitas un skill para generar migraciones de base de datos automaticamente. Que comando usas y que archivos se crean?

<details>
<summary>Ver respuesta</summary>

**Comando**: `/create-skill db-migrations`

**Archivos creados**:
```
BatutaClaude/skills/db-migrations/
  SKILL.md    ← Definicion del skill (description, tools, instructions)
```

El `ecosystem-creator` genera la estructura y el SKILL.md con campos obligatorios: `description` (para auto-invocacion), `tools` (que herramientas usa), e `instructions` (como ejecutar).

</details>

---

## Pregunta 2: Skill Gap Detection

Estas en `sdd-apply` implementando un worker con Temporal.io, pero no existe un skill para Temporal. Que deberia pasar?

<details>
<summary>Ver respuesta</summary>

El sistema debe **DETENERSE** antes de escribir codigo y ofrecer:

1. **Crear skill local** — solo para este proyecto
2. **Crear skill global** — en `~/.claude/skills/` para todos los proyectos
3. **Continuar sin skill** — con advertencia de que no hay guia especializada

Esto lo maneja el `infra-agent` con su protocolo de Skill Gap Detection. En este caso, probablemente ya existe el skill `worker-scaffold` que cubre Temporal.io, asi que primero verificaria si un skill existente aplica.

</details>

---

## Pregunta 3: Templates de equipo

Tienes un proyecto que necesita: API FastAPI + frontend Next.js + workers Temporal + pipeline de datos. Cuantos templates aplican y como los combinas?

<details>
<summary>Ver respuesta</summary>

**Templates que aplican**:
- `fastapi-service` — para la API
- `nextjs-saas` — para el frontend
- `temporal-io-app` — para los workers
- `data-pipeline` — para el pipeline de datos

**Como combinar**: No se usan todos simultaneamente. El `team-orchestrator` evaluaria la complejidad y crearia un equipo personalizado tomando roles de cada template. Ejemplo:

- Lead: Arquitecto (del template fastapi-service)
- Worker 1: Backend (fastapi-service)
- Worker 2: Frontend (nextjs-saas)
- Worker 3: Workers (temporal-io-app)
- Worker 4: Data (data-pipeline)

Con **Contract-First Protocol**: cada worker tiene archivos asignados sin solapamiento.

</details>

---

## Pregunta 4: Propagacion de skills

Creaste un skill `django-crud` en un proyecto local que resulto muy util. Como lo propagas al ecosistema global?

<details>
<summary>Ver respuesta</summary>

Al final del proyecto, el `infra-agent` ejecuta el **Ecosystem Auto-Update**:

1. **Evaluar**: El skill es reutilizable? (no tiene dependencias especificas del proyecto?)
2. **Generalizar**: Remover referencias hardcodeadas, parametrizar valores especificos
3. **Propagar**: Copiar a `~/.claude/skills/django-crud/SKILL.md`
4. **Sincronizar**: Ejecutar `/batuta-sync-skills` para actualizar las tablas de ruteo

Si ademas quieres que este disponible para otros usuarios de Batuta Dots:
5. Copiar al repo `batuta-dots/BatutaClaude/skills/django-crud/`
6. Actualizar CLAUDE.md con el nuevo skill en la tabla de ruteo
7. Commit y push

</details>

---

## Pregunta 5: Hooks personalizados

Quieres que cada vez que se complete un `sdd-verify`, se envie automaticamente un resumen al canal de Slack del equipo. Como lo implementarias?

<details>
<summary>Ver respuesta</summary>

Usarias el hook **TaskCompleted**:

1. **Crear script**: `infra/hooks/notify-slack.sh`
   - Recibe JSON por stdin con datos de la tarea completada
   - Filtra solo tareas de tipo `sdd-verify`
   - Usa `curl` para enviar al webhook de Slack

2. **Registrar en settings.json**:
   ```json
   {
     "hooks": {
       "TaskCompleted": [
         {
           "type": "command",
           "command": "bash infra/hooks/notify-slack.sh"
         }
       ]
     }
   }
   ```

3. **Alternativa**: Crear un workflow con `/create-workflow slack-notify` que el `observability-agent` invoque al detectar eventos de verificacion completada.

**Nota**: Los hooks nativos de Claude Code son: SessionStart, PreToolUse, Stop, TeammateIdle, TaskCompleted.

</details>

---

## Pregunta 6: Recursion Designer

Tu sistema de facturacion electronica usa las categorias de retencion de la DIAN, que cambian cada ano fiscal. Como diseñas el sistema para manejar estos cambios?

<details>
<summary>Ver respuesta</summary>

El `recursion-designer` aplicaria sus **4 mecanismos**:

1. **Deteccion de desconocidos**: Cuando llega una retencion con codigo nuevo, el sistema la detecta como "no clasificada" en vez de fallar
2. **Aprobacion humana**: Un operador revisa y clasifica la nueva retencion (nunca auto-clasificar datos fiscales)
3. **Propagacion controlada**: La nueva categoria se propaga a todos los documentos futuros pero NO retroactivamente
4. **Versionado inmutable**: Cada version de la tabla de retenciones se guarda con fecha de vigencia. Los documentos historicos siempre referencian la version con la que fueron creados

**Patron de datos**:
```
retenciones/
  v2025.json  ← Vigente hasta dic 2025
  v2026.json  ← Vigente desde ene 2026
  current → v2026.json (symlink o referencia)
```

Esto tambien activaria `compliance-colombia` para validar contra Art. 632 del Estatuto Tributario.

</details>

---

## Puntuacion

| Respuestas correctas | Nivel |
|----------------------|-------|
| 6/6 | Dominas la extension del ecosistema |
| 4-5 | Buen nivel, repasa templates y hooks |
| 2-3 | Revisa nivel tres completo |
| 0-1 | Empieza desde nivel dos |

---

→ [Checklist de graduacion](checklist-graduacion.md) — Confirma que dominas Batuta Dots
