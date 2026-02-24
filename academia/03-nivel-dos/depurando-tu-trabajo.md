# Depurando tu trabajo

Construir software es la mitad del trabajo. La otra mitad es verificar que funciona correctamente. Batuta tiene 3 herramientas para esto: **sdd-verify**, la **Piramide de Validacion**, y el framework **O.R.T.A.**

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
| L1 | Linting + tipos + build + docs | IA | Errores de sintaxis, tipos incorrectos, que el proyecto compile, que haya documentacion |
| L2 | Tests unitarios | IA | Que cada funcion individual funcione correctamente |
| L3 | Tests integracion/E2E | IA | Que las partes funcionen juntas |
| L4 | Revision de codigo | Tu | Logica de negocio, patrones, mantenibilidad |
| L5 | Pruebas manuales | Tu | Que la experiencia de usuario sea correcta |

---

## Usando sdd-verify

```
/sdd-verify
```

El skill ejecuta las capas 1-3 automaticamente y produce un reporte:

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

---

## O.R.T.A. — Tu sistema de calidad continuo

O.R.T.A. no es una herramienta que ejecutas una vez — es un framework que funciona siempre:

**Observabilidad**: Cada accion significativa queda registrada en `.batuta/prompt-log.jsonl`. No tienes que hacer nada; el sistema lo hace automaticamente.

**Repetibilidad**: El mismo input produce el mismo resultado. Si ejecutas `/sdd-verify` dos veces con el mismo codigo, el resultado es identico.

**Trazabilidad**: Cada decision se puede rastrear. "Por que se hizo asi?" → Mira la propuesta, el diseno, y los comentarios en el codigo.

**Auto-supervision**: El sistema detecta problemas antes de que escalen. Si no has actualizado el ecosistema en 7 dias, te avisa. Si un spec esta desactualizado respecto al diseno, te advierte.

---

## Flujo practico de depuracion

1. Terminas de implementar con `/sdd-apply`
2. Ejecutas `/sdd-verify`
3. Si hay FAILs en L1-L3 → Batuta te dice que arreglar
4. Arreglas y ejecutas `/sdd-verify` de nuevo
5. Cuando L1-L3 pasan → revisas L4 (codigo) y L5 (usuario)
6. Gate G2 confirma que todo esta listo

---

-> [Validando ideas](validando-ideas.md) — sdd-explore como herramienta de pensamiento
