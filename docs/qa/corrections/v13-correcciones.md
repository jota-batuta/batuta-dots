# Correcciones v13

Fecha: 2026-03-09

## Resumen

3 inconsistencias encontradas y corregidas durante la auditoria de calidad v13.

---

## Correccion 1: Command count en READMEs (11 -> 13)

**Problema**: README.md y README.es.md decian "11 commands" en la tabla "What Gets Installed", pero hay 13 archivos en `BatutaClaude/commands/`.

**Causa raiz**: Los comandos `batuta-sync.md` y `skill-eval.md` fueron agregados en v13 pero el conteo en los READMEs no se actualizo.

**Archivos modificados**:

| Archivo | Linea | Antes | Despues |
|---------|-------|-------|---------|
| `README.md` | 76 | `38 skills, 6 agents, 11 commands` | `38 skills, 6 agents, 13 commands` |
| `README.es.md` | 76 | `38 skills, 6 agentes, 11 comandos` | `38 skills, 6 agentes, 13 comandos` |

---

## Correccion 2: Guide count en arquitectura-diagrama.md (13 -> 14)

**Problema**: El diagrama Folder Structure en `docs/architecture/arquitectura-diagrama.md` decia "13 guias de uso" pero hay 14 guias en `docs/guides/`.

**Causa raiz**: La guia `guia-sdk-deployment.md` fue agregada en v13.1 pero el diagrama Mermaid no se actualizo.

**Archivos modificados**:

| Archivo | Linea | Antes | Despues |
|---------|-------|-------|---------|
| `docs/architecture/arquitectura-diagrama.md` | 940 | `guides/<br/>13 guias de uso` | `guides/<br/>14 guias de uso` |

---

## Correccion 3: Command count test en setup_test.sh (11 -> 13)

**Problema**: `infra/setup_test.sh` tenia un test `test_eleven_commands_synced` que verificaba 11 comandos, pero el ecosistema ahora tiene 13.

**Causa raiz**: Los comandos `batuta-sync.md` y `skill-eval.md` fueron agregados en v13 pero el test no se actualizo.

**Archivos modificados**:

| Archivo | Cambio |
|---------|--------|
| `infra/setup_test.sh` | Funcion renombrada de `test_eleven_commands_synced` a `test_thirteen_commands_synced`. Array de comandos esperados actualizado para incluir `batuta-sync.md` y `skill-eval.md`. Referencia de invocacion actualizada. |
