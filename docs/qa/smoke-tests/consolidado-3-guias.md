# Reporte Consolidado: Prueba de Fuego — 3 Guias

**Fecha**: 2026-02-23
**Version del ecosistema**: v9.2 (pre smoke test)
**Ejecutor**: Claude Code (automatizado)

## Resumen Ejecutivo

Se ejecutaron las 3 guias con mas problemas documentados en la auditoria de integracion (v9.2). Las guias se ejecutaron como lo haria un usuario humano, paso a paso, verificando que el **sistema** funciona como las guias prometen. **Las guias NO fueron modificadas** — solo el sistema.

| Guia | Tests | Bugs Sistema | Bugs Proyecto | Veredicto |
|------|-------|-------------|---------------|-----------|
| fastapi-service | 24/24 | 2 (setup.sh) | 1 (passlib) | PASS WITH WARNINGS |
| ai-agent-adk | 34/34 | 0 | 1 (calculator) | PASS WITH WARNINGS |
| temporal-io-app | 18/18 | 0 | 0 | PASS |
| **TOTAL** | **76/76** | **2** | **2** | **PASS** |

## Bugs del Sistema Encontrados y Corregidos

### 1. setup.sh — Path Resolution (CRITICAL)
- **Archivo**: `infra/setup.sh`
- **Problema**: `SCRIPT_DIR` fallaba en Windows Git Bash con rutas relativas
- **Correccion**: Fallback con `cd` + `pwd`
- **Estado**: Corregido en sesion anterior, validado en las 3 guias

### 2. setup.sh — Python Merge Logic (CRITICAL)
- **Archivo**: `infra/setup.sh`
- **Problema**: Merge de hooks en settings.json sobreescribia en lugar de mergear
- **Correccion**: Python merge logic corregida para arrays
- **Estado**: Corregido en sesion anterior, validado en las 3 guias

## Bugs de Proyecto (NO del sistema)

### 1. passlib + bcrypt 5.x (Guide 1)
- **Causa**: passlib no soporta bcrypt 5.x (no actualizado desde 2020)
- **Solucion**: Usar `import bcrypt` directamente
- **Accion para guias**: Considerar nota en guia-fastapi-service

### 2. Calculator infinite loop (Guide 2)
- **Causa**: `while "**" in expr` creaba loop infinito
- **Solucion**: Reemplazar while con string replacements directos
- **Accion para guias**: Bug en codigo generado, no en guia

## Metricas de Calidad

| Metrica | Guide 1 | Guide 2 | Guide 3 | Total |
|---------|---------|---------|---------|-------|
| Archivos fuente | 12 | 13 | 20 | 45 |
| Tests escritos | 24 | 34 | 18 | 76 |
| Tests pasando | 24 | 34 | 18 | 76 |
| py_compile PASS | 12/12 | 13/13 | 20/20 | 45/45 |
| SDD artefactos | 7 | 7 | 6 | 20 |
| Tiempo aprox | 45 min | 30 min | 20 min | ~95 min |

## Validacion del SDD Pipeline

| Fase SDD | Guide 1 | Guide 2 | Guide 3 |
|----------|---------|---------|---------|
| init | PASS | PASS | PASS |
| explore | PASS | PASS | PASS |
| propose | PASS | PASS | PASS |
| spec | PASS | PASS | PASS |
| design | PASS | PASS | PASS |
| tasks | PASS | PASS | PASS |
| apply | PASS | PASS | PASS |
| verify | PASS | PASS | PASS |
| archive | PASS | PASS | PASS |

**9/9 fases funcionan correctamente** en las 3 guias.

## Validacion de setup.sh

| Ejecucion | Resultado | Notas |
|-----------|-----------|-------|
| Guide 1 (primera) | FAIL → FIX → PASS | 2 bugs encontrados y corregidos |
| Guide 2 (segunda) | PASS | Fixes validados |
| Guide 3 (tercera) | PASS | Triple validacion, flawless |

## Validacion de la Scope Rule

| Proyecto | Estructura | Cumple |
|----------|-----------|--------|
| test-fastapi-service | features/auth/, features/tasks/, features/shared/, core/ | SI |
| test-ai-agent | features/tools/, features/memory/, core/, config/ | SI |
| test-temporal-app | features/onboarding/{workflows,activities,workers,api,models}/, core/ | SI |

## Conclusion

**El ecosistema Batuta v9.2 funciona correctamente.** Las guias se ejecutan como prometen despues de los 2 fixes al setup.sh (que ya estaban aplicados de la sesion anterior). Los bugs encontrados en los proyectos generados (passlib, calculator) son especificos del codigo generado, no del ecosistema.

### Recomendaciones
1. **Considerar v9.3** para documentar los fixes de setup.sh y los smoke test results
2. **Agregar nota a guia-fastapi-service** sobre passlib deprecation (informativo, no critico)
3. **Los smoke tests validan que no se necesitan mas cambios** al ecosistema por ahora
