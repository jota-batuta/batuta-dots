# Los Gates

Los gates son **puntos de control** donde el sistema se detiene y te pregunta: "Estamos listos para continuar?"

---

## Por que existen

Sin gates, es tentador saltar directo a escribir codigo. El resultado: software que solo maneja el caso ideal, soluciones que nadie pidio, cambios sin documentacion. Los gates te obligan a detenerte y confirmar antes de invertir tiempo.

---

## Gate G0.5 — Discovery Complete

**Cuando**: Entre explore y propose
**Pregunta**: "Entendemos bien el problema?"

| Pregunta | Si falta... |
|----------|------------|
| Todos los tipos de caso identificados? | Volver a explore |
| Excepciones documentadas? | Volver a explore |
| Categorias externas mapeadas? | Volver a explore |
| Participantes y fuentes listados? | Volver a explore |
| Todas las ramas cubiertas? | Volver a explore |

**Ejemplo**: Cliente dice "automatizar nomina". Sin G0.5, propones para nomina mensual. Con G0.5, descubres que hay mensual, quincenal, retroactiva, y liquidaciones — cada una funciona diferente.

---

## Gate G1 — Solution Worth Building

**Cuando**: Entre propose y spec
**Pregunta**: "La solucion vale la pena?"

| Pregunta | Si la respuesta es NO... |
|----------|------------------------|
| Problema justifica esfuerzo? | Reconsiderar scope |
| Scope acotado? | Reducir alcance |
| Stakeholders informados? | Comunicar primero |
| Riesgos aceptables? | Mitigar o replantear |

**Ejemplo**: Propones sistema completo para un proceso que usan 2 personas una vez al mes. G1 pregunta "Justifica el esfuerzo?" y descubres que un script simple resuelve el 90%.

---

## Gate G2 — Ready for Production

**Cuando**: Entre verify y archive
**Pregunta**: "Esta listo para produccion?"

| Pregunta | Si la respuesta es NO... |
|----------|------------------------|
| Piramide de Validacion completa? | Volver a verify |
| Documentacion actualizada? | Completar docs |
| Plan de rollback verificado? | Crear plan |
| Sin warnings criticos? | Resolver warnings |

**Ejemplo**: Tests pasan pero no hay forma de deshacer si algo sale mal. G2 pregunta "Hay rollback?" y documentas como revertir.

---

## En la practica

Batuta muestra el checklist y espera tu respuesta:

```
Antes de proponer, confirma:
- [x] Todos los tipos de caso (4 tipos de conciliacion)
- [x] Excepciones documentadas (7 edge cases)
- [x] Categorias externas (conceptos bancarios)
- [x] Participantes (tesorero, contador, ERP)
- [x] Todas las ramas (incluyendo rechazos)

Continuamos a propose?
```

Todo marcado → "si" y avanzas. Algo sin marcar → vuelves a completar.

---

## No son burocraticos

| Sin gates | Con gates |
|-----------|-----------|
| Empiezas rapido, terminas lento | Empiezas informado, terminas rapido |
| Problemas al final | Problemas al principio |
| Retrabajas 3-4 veces | Bien la primera vez |

---

## Gates y retrocesos (backtracks)

Los gates no son la unica forma de volver atras. A veces descubres problemas DURANTE la implementacion o verificacion. El pipeline SDD es una maquina de estados — puedes retroceder a cualquier fase anterior:

| Estas en... | Descubres que... | Vuelves a... |
|-------------|------------------|-------------|
| APPLY | Falta un caso en el spec | SPEC |
| APPLY | La arquitectura no soporta algo | DESIGN |
| APPLY | El problema es diferente | EXPLORE |
| VERIFY | Tests revelan fallo de diseno | DESIGN |

Cada retroceso se registra en `backtrack-log.md` para que quede documentado QUE cambio y POR QUE. Los artefactos se actualizan in-place — git guarda el historial.

> Los gates son **preventivos** (verifican ANTES de avanzar). Los backtracks son **correctivos** (arreglan DESPUES de descubrir un problema). Ambos son normales y saludables — no son señal de error.

---

| Gate | Cuando | Pregunta | Si falla |
|------|--------|----------|----------|
| G0.5 | explore → propose | Entendemos? | Volver a explore |
| G1 | propose → spec | Vale la pena? | Iterar propose |
| G2 | verify → archive | Listo? | Volver a verify/apply |

---

→ [Skills que tienes](../02-nivel-uno/skills-que-tienes.md) — Tu catalogo de 24 especialistas
