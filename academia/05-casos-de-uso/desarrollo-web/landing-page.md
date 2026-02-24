# Landing page rapida

> **Industria:** Desarrollo Web | **Dificultad:** Basico | **Tiempo estimado:** 30-60 minutos con Batuta Dots

---

## El problema

Tu empresa esta por lanzar un producto nuevo y necesita una pagina de aterrizaje para la campana de marketing. El equipo de marketing ya tiene el copy, las imagenes y la fecha de lanzamiento. Lo que no tienen es la pagina.

Han usado constructores como Wix o Webflow antes, pero esta vez necesitan algo que se integre con el dominio de la empresa, que cargue rapido (porque van a invertir en publicidad y cada segundo cuenta) y que tenga un formulario conectado al CRM.

Es un proyecto simple: una sola pagina, sin login, sin base de datos compleja. Pero justamente por ser simple, el riesgo es caer en over-engineering. No necesitas un framework completo ni un backend robusto. Necesitas una pagina que funcione, que cargue rapido y que este lista para manana.

## Lo que vas a construir

Una landing page optimizada para conversion que incluye:

- **Hero section** con titulo, subtitulo y call-to-action principal
- **Seccion de beneficios** con iconos y descripciones cortas
- **Social proof** (testimonios o logos de clientes)
- **Formulario de captura** de leads conectado al CRM
- **Footer** con links legales y redes sociales
- **Responsive** para mobile, tablet y desktop
- **Optimizada** para velocidad de carga (Core Web Vitals)

## Flujo SDD completo

### Paso 1: Inicializar el proyecto

```bash
sdd-init
```

> El agente te pregunta: Que tipo de proyecto vas a crear?
> --> webapp

Se crea la estructura base. Para una landing page, la estructura es minima.

### Paso 2: Definir la funcionalidad

```bash
sdd-new
```

> Describe lo que necesitas:
> --> Landing page para lanzamiento de producto. Hero con CTA, seccion de beneficios (3), testimonios (3), formulario de captura de email que envia a nuestro CRM via webhook, footer. Debe cargar en menos de 2 segundos. Mobile-first.

### Paso 3: Aplicar directamente

```bash
sdd-apply
```

> **Gate G1** — El agente evalua:
> "Este proyecto es una landing page estatica con un formulario. No requiere autenticacion, base de datos ni logica de negocio compleja. Riesgo de over-engineering: ALTO si se usa un framework pesado. Recomendacion: HTML/CSS/JS vanilla o un framework ligero como Astro."

Este es un caso donde el pipeline se acorta. No necesitas `process-analyst` (no hay variantes de negocio complejas), no necesitas `recursion-designer` (no hay categorias recursivas), y el `sdd-ff` es casi inmediato porque el alcance ya esta claro.

El agente genera:

```
features/
  landing/
    index.html       # Estructura de la pagina
    styles.css        # Estilos responsive mobile-first
    script.js         # Formulario + envio a webhook
    assets/           # Imagenes optimizadas
```

> Nota: El scope-rule aplica incluso en proyectos simples. Todo va dentro de `features/landing/` porque es una sola funcionalidad.

### Paso 4: Verificar

```bash
sdd-verify
```

> **Gate G2** — Verificacion:

```
Layer 1 - Lint:           PASS (HTML valido, CSS sin errores)
Layer 1 - Build:          PASS (pagina carga correctamente)
Layer 1d - Documentacion: PASS (comentarios en secciones clave)
Layer 2 - Tests:          PASS (formulario envia correctamente)

Resultado: LISTO PARA REVIEW HUMANO
```

## Skills que se activan

| Skill | Por que |
|-------|---------|
| **scope-rule** | Aunque es un proyecto simple, organiza todo dentro de features/landing/ para mantener la convencion |

> Nota: En proyectos simples, se activan menos skills. Eso esta bien. No fuerces herramientas que no necesitas.

## Gates que pasas

### Gate G0.5 — Variantes de negocio
- **Que evalua:** En este caso, casi nada. Una landing es lineal.
- **Ejemplo concreto:** "No se detectan variantes de negocio significativas. El formulario captura un solo tipo de lead. Adelante."
- **Si no pasa:** Raro en una landing, pero podria pasar si hay multiples audiencias con paginas diferentes

### Gate G1 — No over-engineer
- **Que evalua:** Que no uses un canon para matar un mosquito
- **Ejemplo concreto:** "Se detecto riesgo de over-engineering. Una landing no necesita Next.js, base de datos ni autenticacion. Recomendacion: mantenerlo simple con HTML/CSS/JS o Astro."
- **Si no pasa:** El agente te frena y te sugiere simplificar. Este gate es especialmente importante en proyectos pequenos.

### Gate G2 — Calidad de la implementacion
- **Que evalua:** Que la pagina cargue, que el formulario funcione, que sea responsive
- **Ejemplo concreto:** "Pagina carga en 1.2 segundos, formulario envia al webhook correctamente, layout responsive verificado en 3 breakpoints."
- **Si no pasa:** Se optimizan imagenes, se corrige CSS o se arregla el formulario

## Resultado final

Al terminar, tenes:

- Una landing page lista para publicar
- Responsive para todos los dispositivos
- Formulario funcionando y conectado a tu CRM
- Carga optimizada (menos de 2 segundos)
- Codigo limpio y facil de modificar
- Sin dependencias innecesarias

## Siguientes pasos

- **A/B testing:** Crear una variante con diferente headline para medir conversion
- **Analytics:** Agregar Google Analytics o Plausible para medir trafico
- **SEO basico:** Meta tags, Open Graph, schema markup
- **Animaciones:** Micro-interacciones sutiles para mejorar la experiencia
- **Pagina de gracias:** Redirigir despues del formulario a una pagina de confirmacion
- **Mas landings:** Si funciona bien, replicar la estructura para otros productos
