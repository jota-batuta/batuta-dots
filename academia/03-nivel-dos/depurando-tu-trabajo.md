# Depurando tu trabajo

Construir software es la mitad del trabajo. La otra mitad es verificar que funciona correctamente. Batuta tiene herramientas para esto: **sdd-verify** y la **Piramide de Validacion AI**.

---

## La Piramide de Validacion AI

5 capas, de abajo hacia arriba. Las primeras 3 las hace la IA automaticamente. Las ultimas 2 las haces tu.

```
        /\
       /  \
      / L5 \     Pruebas manuales (tu)
     /------\
    /   L4   \   Revision de codigo (tu)
   /----------\
  /    L3      \  Tests integracion/E2E (IA)
 /--------------\
/      L2        \ Tests unitarios (IA)
\------------------/
\       L1         / Linting, tipos, build, docs (IA)
 \________________/
```

### Regla de oro: Base rota = no hay revision humana

Si la Capa 1 falla (el codigo no compila, el linter tiene errores), no tiene sentido que tu revises el codigo. Primero se arregla la base.

### Que verifica cada capa

| Capa | Que | Quien | Que busca |
|------|-----|-------|-----------|
| L1 | Linting + tipos + build + docs | IA (quality-agent) | Errores de sintaxis, tipos incorrectos, que el proyecto compile |
| L2 | Tests unitarios | IA (quality-agent) | Que cada funcion individual funcione correctamente |
| L3 | Tests integracion/E2E | IA (quality-agent) | Que las partes funcionen juntas |
| L4 | Revision de codigo | Tu | Logica de negocio, patrones, mantenibilidad |
| L5 | Pruebas manuales | Tu | Que la experiencia de usuario sea correcta |

---

## Usando sdd-verify en v15

```
/sdd-verify
```

En v15, `/sdd-verify` contrata al **quality-agent** (con skills tdd-workflow, debugging-systematic, security-audit, e2e-testing). El quality-agent ejecuta las capas 1-3 automaticamente y produce un reporte:

```
Verificacion: todo-basico

Capa 1 — Estatica
  [PASS] TypeScript: 0 errores
  [PASS] ESLint: 0 warnings
  [PASS] Build: exitoso
  [WARN] Documentacion: 2 funciones sin docstring

Capa 2 — Tests Unitarios
  [PASS] 12/12 tests pasaron

Capa 3 — Integracion
  [PASS] 3/3 tests E2E pasaron

Capas 4-5: Pendientes de revision humana.
Items para tu revision:
- Verificar logica de filtrado en TodoList
- Probar flujo completo en navegador
```

### Sin gates formales

En v15, ya no hay 8 gates (G0-G7). El flujo simplificado:

- **Modo SPRINT** (0 gates): Research → Apply → Verify. Si verify falla, se arregla y se re-verifica.
- **Modo COMPLETO** (1 gate): Research → Explore → Design [USER STOP] → Apply → Verify. El unico gate es la aprobacion del diseno.

`/sdd-verify` corre siempre al final, sin importar el modo.

---

## Flujo practico de depuracion

1. Terminas de implementar con `/sdd-apply`
2. Ejecutas `/sdd-verify`
3. Si hay FAILs en L1-L3 → el quality-agent te dice que arreglar
4. Arreglas y ejecutas `/sdd-verify` de nuevo
5. Cuando L1-L3 pasan → revisas L4 (codigo) y L5 (usuario)
6. Listo para deploy

---

## Research-first tambien aplica a debugging

En v15, research-first es obligatorio en TODOS los modos, incluyendo debugging. Antes de que un agente intente arreglar algo:

1. Lee el codigo relevante (nunca asume por el nombre)
2. Verifica flujos de datos reales
3. Busca en Notion KB si ya se resolvio algo similar
4. Busca en web si el problema es de un framework externo

Esto previene el modo de fallo mas caro: asumir mal → implementar → usuario corrige → reimplementar.

---

## session.md: estado actualizado siempre

En v15, `session.md` se actualiza en CADA interaccion. Responde tres preguntas:
- **DONDE estamos**: proyecto, stack, fase actual
- **POR QUE llegamos ahi**: decisiones con razonamiento
- **COMO continuar**: siguiente paso concreto

Nunca incluye inventarios de archivos ni detalles de implementacion — esos viven en el codigo. Maximo 80 lineas. Si crece mas, se podan las entradas mas antiguas.

---

-> [Validando ideas](validando-ideas.md) — sdd-explore como herramienta de pensamiento
