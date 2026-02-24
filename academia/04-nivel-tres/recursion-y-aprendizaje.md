# Recursion y aprendizaje

Dos capacidades avanzadas que hacen que tus sistemas se adapten al cambio: **recursion-designer** para manejar cambio externo, y **prompt-tracker** para mejorar tu flujo de trabajo.

---

## Recursion Designer — Sistemas que manejan cambio

### El problema

Tu sistema clasifica movimientos bancarios usando un diccionario de conceptos. Un dia, el banco agrega un concepto nuevo que tu sistema no conoce. Sin preparacion, tu sistema:
- Clasifica mal (peor caso)
- Se rompe (caso medio)
- Ignora el movimiento (caso "menos malo" pero pierde datos)

### La solucion: 4 mecanismos

**1. Deteccion de desconocidos**
Si un valor no esta en el diccionario → no clasificar → registrar como DESCONOCIDO → escalar.

Comportamiento configurable:
- BLOQUEAR: para cosas criticas (resultados al cliente)
- CONTINUAR CON MARCA: para procesamiento interno
- ESCALAR INMEDIATO: para urgencias regulatorias

**2. Aprobacion humana**
El sistema propone, el humano decide: mapear a existente, crear nuevo, crear alias, o descartar.

Cada dominio tiene su aprobador:
- Conceptos bancarios → Tesorero
- Cuentas contables → Contador
- Competencias de cargo → Hiring manager

**3. Propagacion controlada**
Cuando se aprueba un cambio, como se aplica?
- FORWARD (default): solo casos nuevos
- BACKWARD: reclasificar pendientes (con autorizacion)
- Regla de oro: nunca modificar silenciosamente un resultado ya entregado

**4. Versionado inmutable**
Cada version del diccionario es permanente. Puedes preguntar: "Con que logica se clasifico este registro en enero?" y la respuesta existe.

---

## Prompt Tracker — Mejorando tu flujo

### Que hace

Registra como interactuas con Batuta y detecta patrones para mejorar:

- Cuantas veces aciertas a la primera?
- En que areas necesitas corregir mas?
- Que tipo de tareas generan mas friccion?

### Como usarlo

```
/batuta-analyze-prompts
```

Genera un reporte con:
- **Tasa de exito primer intento**: Que porcentaje de veces el resultado fue correcto sin correccion
- **Patrones de correccion**: En que areas corriges mas (scope? naming? logica?)
- **Recomendaciones**: Cambios sugeridos a tu forma de pedir o a las reglas de CLAUDE.md

### Ejemplo de reporte

```
Analisis de 150 prompts (ultimos 30 dias)

Metricas:
- First-shot success: 78%
- Correcciones frecuentes: naming (12x), scope placement (8x)
- Gate compliance: 95%

Recomendaciones:
1. Agrega convencion de naming a CLAUDE.md para reducir correcciones
2. Considera crear skill para tu patron de formularios React
3. Tu tasa de explore antes de apply es baja — explora mas antes de construir
```

---

## Cuando usar cada uno

| Herramienta | Cuando | Beneficio |
|------------|--------|-----------|
| recursion-designer | Tu sistema usa categorias externas | No se rompe cuando algo cambia |
| prompt-tracker | Siempre (es automatico) | Tu flujo mejora con el tiempo |

---

Felicidades — has completado los 4 niveles de la academia. Ahora elige un caso de uso real:

-> [Casos de uso](../05-casos-de-uso/) — 22 proyectos reales por industria
