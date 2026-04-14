# Los Gates

Los gates son **puntos de control** donde el sistema se detiene y te pregunta: "Estamos listos para continuar?"

---

## De 8 gates a 1: por que el cambio

En versiones anteriores de Batuta, el pipeline tenia 8 gates obligatorios (G0.25, G0.5, G1, G1.5, G2, y mas). Cada gate era un checkpoint donde el sistema se detenia y pedia confirmacion antes de avanzar.

En la practica, descubrimos que **8 gates eran excesivos**:

| Problema | Consecuencia |
|----------|-------------|
| Demasiadas pausas | El flujo se sentia burocratico — como llenar formularios para mover una silla |
| Gates redundantes | Varios gates verificaban cosas similares (G0.5 y G1 ambos evaluaban "entendemos el problema?") |
| Fatiga de aprobacion | Los usuarios empezaban a decir "si" automaticamente sin leer — el gate perdia su valor |
| Tarea simple = mismo proceso que tarea compleja | Colgar un cuadro requeria el mismo proceso que construir una casa |

La leccion: **un solo gate bien ubicado es mas efectivo que 8 gates que nadie lee**.

---

## El modelo v15: 0 o 1 gate

### Modo SPRINT (0 gates)

En modo SPRINT (el default para tareas del dia a dia), no hay gates formales. El pipeline es:

```
Research → Apply → Verify
```

No hay pausas formales. Pero ojo — **research es obligatorio y no negociable**. Batuta SIEMPRE investiga antes de implementar. La diferencia es que no te detiene para pedirte permiso despues de investigar — simplemente investiga y construye.

Por que funciona sin gates? Porque la investigacion obligatoria (research-first) reemplaza la funcion de los gates de descubrimiento (G0.25, G0.5, G1). Si la investigacion revela algo inesperado, Batuta lo reporta y ajusta automaticamente.

### Modo COMPLETO (1 gate: Design Approval)

En modo COMPLETO (para proyectos complejos con PRD), hay exactamente **1 gate**:

```
Research → Explore → Design ══[DESIGN APPROVAL]══ Apply → Verify
```

**Design Approval** es el unico punto donde el sistema se detiene y espera tu aprobacion explicita. Ocurre entre Design y Apply — despues de que Batuta ha investigado, explorado, y consolidado todo en un PRD.

---

## Design Approval en detalle

**Cuando**: Entre la fase Design y la fase Apply (solo en modo COMPLETO)
**Pregunta**: "Este es el diseno. Lo apruebas?"

| Que verifica | Si falta... |
|-------------|------------|
| Arquitectura definida? | Volver a Design |
| Decisiones documentadas con justificacion? | Completar PRD |
| Scope claro y acotado? | Ajustar PRD |
| Riesgos identificados? | Agregar al PRD |

**Ejemplo**: Batuta presenta el PRD para un sistema de conciliacion bancaria. El diseno incluye: 4 tipos de conciliacion, arquitectura de procesamiento, modelo de datos, integraciones con bancos. Tu revisas y apruebas. Batuta procede a implementar.

### Como se ve en la practica

```
Batuta presenta:

PRD: conciliacion-bancaria
━━━━━━━━━━━━━━━━━━━━━━━━━━

Arquitectura: FastAPI + Prefect + PostgreSQL
Componentes: 4 procesadores (por tipo de conciliacion)
Integraciones: Bancolombia, Davivienda (CSV/API)
Modelo: 3 tablas (transacciones, conciliaciones, excepciones)
Riesgos: formatos bancarios cambian sin aviso

¿Apruebas este diseno para proceder a implementacion?
```

Apruebas → Batuta contrata agentes e implementa.
No apruebas → Batuta ajusta el diseno y vuelve a preguntar.

---

## Por que Design Approval y no otro gate

De todos los gates anteriores, Design Approval es el que **mas valor genera por pausa invertida**:

| Gate antiguo | Valor | Por que se elimino |
|-------------|-------|-------------------|
| G0.25 (Skill Gaps) | Medio | Research-first lo cubre automaticamente |
| G0.5 (Discovery Complete) | Medio | Research obligatorio hace esto redundante |
| G1 (Solution Worth Building) | Medio | Se fusiono con Design Approval |
| **Design Approval** | **Alto** | **Unico gate que sobrevive — maximo impacto** |
| G2 (Ready for Production) | Bajo | Verify + Piramide de Validacion lo cubren |

El Design Approval sobrevive porque es el **punto de no retorno**: una vez que empiezas a construir, el costo de cambiar el diseno sube dramaticamente. Aprobar antes de construir = maximo impacto, minima burocracia.

---

## No necesitas gates cuando tienes research-first

El cambio filosofico de v15 es profundo: en vez de poner 8 checkpoints que dicen "para, piensa", el sistema **te obliga a pensar SIEMPRE** (research-first es no negociable). Los gates eran parches para compensar un pipeline que permitia saltarse la investigacion. Cuando la investigacion es obligatoria, la mayoria de los gates se vuelven redundantes.

| Sin research-first (v14 y anteriores) | Con research-first (v15) |
|---------------------------------------|--------------------------|
| 8 gates para asegurar que pensaste | Research obligatorio = piensas SIEMPRE |
| Pausas cada 2 fases | Flujo continuo (SPRINT) o 1 pausa (COMPLETO) |
| Fatiga de aprobacion | 1 aprobacion que realmente importa |
| Mismo proceso para todo | SPRINT para lo simple, COMPLETO para lo complejo |

---

## Gates y retrocesos (backtracks)

Los retrocesos siguen existiendo — a veces descubres problemas DURANTE la implementacion:

| Estas en... | Descubres que... | Vuelves a... |
|-------------|------------------|-------------|
| APPLY | La investigacion estaba incompleta | RESEARCH |
| APPLY | El diseno no soporta algo | DESIGN (modo COMPLETO) |
| VERIFY | Tests revelan fallo | APPLY (fix directo) |
| VERIFY | Fallo de diseno profundo | DESIGN (modo COMPLETO) |

session.md se actualiza en CADA interaccion para que siempre sepas donde estas. CHECKPOINT.md captura el estado exacto como seguro anti-compaction.

---

## Resumen

| Modo | Gates | Cuando usarlo |
|------|-------|--------------|
| **SPRINT** | 0 | Tareas del dia a dia, features simples, bug fixes |
| **COMPLETO** | 1 (Design Approval) | Proyectos complejos con PRD del CTO |

---

→ [Skills que tienes](../02-nivel-uno/skills-que-tienes.md) — Tu catalogo de especialistas
