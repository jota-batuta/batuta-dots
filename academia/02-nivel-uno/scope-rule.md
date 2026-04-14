# Scope Rule

La Scope Rule es la regla mas importante de organizacion de archivos en Batuta Dots. Responde una pregunta simple: **"Quien usa esto?"**

---

## El problema que resuelve

Sin reglas de organizacion, los proyectos terminan asi:

```
src/
  utils/           <- 47 archivos sin relacion entre si
  helpers/         <- mas archivos sueltos
  components/      <- 200 componentes mezclados
  lib/             <- nadie sabe que hay aqui
```

Encontrar algo es un laberinto. Mover algo rompe 15 importaciones. Borrar algo da miedo porque no sabes quien lo usa.

---

## La regla

Antes de crear CUALQUIER archivo, pregunta: **"Quien va a usar esto?"**

| Quien lo usa | Donde va | Ejemplo |
|-------------|---------|---------|
| 1 sola feature | `features/{feature}/{tipo}/` | `features/checkout/components/CartItem.tsx` |
| 2+ features | `features/shared/{tipo}/` | `features/shared/components/Button.tsx` |
| Toda la app | `core/{tipo}/` | `core/services/database.ts` |

### Nunca crear en la raiz

Estos directorios estan **prohibidos** en la raiz del proyecto:
- `utils/` → Usa `features/{feature}/utils/` o `core/utils/`
- `helpers/` → Usa `features/{feature}/helpers/` o `core/helpers/`
- `lib/` → Usa `core/lib/`
- `components/` → Usa `features/{feature}/components/` o `features/shared/components/`

---

## Ejemplos visuales

### Ejemplo 1: Componente de una sola feature

Tienes un componente `InvoiceTable` que solo se usa en la feature de facturacion.

```
features/
  invoicing/
    components/
      InvoiceTable.tsx    <- Aqui. Solo facturacion lo usa.
```

### Ejemplo 2: Componente compartido

Tienes un `Button` que usan checkout Y facturacion.

```
features/
  shared/
    components/
      Button.tsx          <- Aqui. 2+ features lo usan.
```

### Ejemplo 3: Servicio de toda la app

Tienes un servicio de base de datos que usa toda la aplicacion.

```
core/
  services/
    database.ts           <- Aqui. Toda la app lo necesita.
```

---

## El arbol de decision

```
Necesito crear un archivo.
  |
  v
Quien lo va a usar?
  |
  +-- Solo 1 feature
  |     -> features/{feature}/{tipo}/{nombre}
  |
  +-- 2 o mas features
  |     -> features/shared/{tipo}/{nombre}
  |
  +-- Toda la aplicacion
        -> core/{tipo}/{nombre}
```

### Que pasa cuando algo crece

Si un componente empieza en 1 feature y luego lo necesita otra:

1. **Hoy**: `features/checkout/components/PriceTag.tsx` (solo checkout lo usa)
2. **Manana**: invoicing tambien lo necesita
3. **Accion**: Mover a `features/shared/components/PriceTag.tsx`

El Scope Rule es dinamico — los archivos se mueven cuando sus consumidores cambian.

---

## Quien aplica la Scope Rule en v15

En v15, el Scope Rule es un **skill** asignado al **infra-agent**. Cuando el agente principal contrata a un agente para crear archivos, el infra-agent (o cualquier agente con el skill `scope-rule`) valida la ubicacion:

1. Tu pides crear un archivo
2. El agente contratado consulta scope-rule
3. Sugiere la ubicacion correcta
4. Tu confirmas

Si intentas crear `utils/formatDate.ts` en la raiz, el agente lo detiene y sugiere la ubicacion correcta. Ya no hay un "Execution Gate" con 8 pasos — la validacion ocurre dentro del agente contratado como parte natural de su trabajo.

---

-> [Seguridad desde cero](seguridad-desde-cero.md) — Security audit explicado simple
