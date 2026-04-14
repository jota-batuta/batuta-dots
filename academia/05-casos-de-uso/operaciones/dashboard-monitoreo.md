# Dashboard de monitoreo en tiempo real

> **Industria:** Operaciones | **Dificultad:** Intermedio | **Tiempo estimado:** 3-4 horas con Batuta Dots

---

## El problema

Gerencia quiere ver los numeros de la operacion en tiempo real. Hoy, si el gerente general quiere saber como va la produccion, tiene que llamar al jefe de planta. Si quiere saber las ventas del dia, tiene que pedirle al area comercial que revise el sistema. Si quiere saber cuantos tickets de soporte hay abiertos, tiene que entrar al Freshdesk el mismo.

La informacion existe, pero esta dispersa en 5 sistemas diferentes. Nadie tiene una vista consolidada. Las reuniones semanales se gastan en "actualizar numeros" en vez de tomar decisiones.

El gerente quiere abrir una sola pantalla (en su oficina, en su celular, o proyectada en la sala de reuniones) y ver todo: produccion, ventas, soporte, inventario y finanzas. Todo actualizado. Sin tener que pedirle nada a nadie.

## Lo que vas a construir

Un dashboard de monitoreo operativo en tiempo real que incluye:

- **Panel de produccion:** OEE actual, unidades producidas vs plan, paradas activas
- **Panel de ventas:** Ventas del dia/semana/mes, top productos, pipeline comercial
- **Panel de soporte:** Tickets abiertos, tiempo promedio de respuesta, SLA compliance
- **Panel de inventario:** Stock critico, productos bajo minimo, rotacion
- **Panel financiero:** Ingresos vs egresos del mes, desviacion presupuestaria
- **Actualizacion automatica** cada 5 minutos (configurable)
- **Responsive** para pantalla grande, tablet y celular
- **Semaforos** rojo/amarillo/verde en cada KPI con umbrales configurables

## Flujo SDD completo

### Paso 1: Definir la funcionalidad

```bash
sdd-new
```

> Describe lo que necesitas:
> --> Dashboard de monitoreo para gerencia. 5 paneles: produccion (OEE, unidades, paradas), ventas (diarias, semanales, top productos), soporte (tickets, SLA), inventario (stock critico), finanzas (ingresos vs egresos). Actualizado cada 5 minutos. Con semaforos de estado. Responsive.

### Paso 2: Disenar el pipeline de datos

El `data-pipeline-design` se activa para mapear las fuentes:

```
Fuentes identificadas:
1. SAP (ERP) → Produccion + Inventario + Finanzas
2. CRM/Sistema de ventas → Pipeline + Ventas
3. Freshdesk → Tickets + SLA
4. Google Sheets → KPIs manuales que aun no estan en ningun sistema
```

> **Design Approval (variantes)** — El agente te pregunta:
> "Detecte 4 fuentes de datos. Los datos de produccion y finanzas vienen del mismo ERP (SAP). Los KPIs manuales en Sheets son temporales o permanentes?"
> --> Temporales, eventualmente todo estara en SAP. Pero por ahora necesitamos incluirlos.

Pipeline disenado:

```
EXTRACT (cada 5 min):
  - SAP API → produccion, inventario, finanzas
  - CRM API → ventas, pipeline
  - Freshdesk API → tickets, SLA
  - Sheets API → KPIs manuales

TRANSFORM:
  - Calcular KPIs derivados (OEE, conversion, SLA %)
  - Aplicar umbrales de semaforo
  - Generar tendencias (vs ayer, vs semana pasada)

LOAD:
  - Cache en Redis para acceso rapido
  - Base de datos para historico

SERVE:
  - API REST para el dashboard
  - WebSocket para actualizaciones push
```

### Paso 3: Feature Freeze

```bash
sdd-ff
```

Se congela con los 5 paneles, las 4 fuentes y los umbrales de semaforo definidos.

> **Design Approval (viabilidad)** — El agente evalua:
> "Un dashboard consolidado con 5 paneles y 4 fuentes de datos es un proyecto justificado. La alternativa (herramientas BI como Metabase o Grafana) podria cubrir parte, pero la integracion de fuentes heterogeneas y los semaforos personalizados requieren desarrollo custom."

### Paso 4: Aplicar la implementacion

```bash
sdd-apply
```

El agente genera la estructura:

```
features/
  data-layer/
    connectors/          # Un conector por fuente
    transformers/        # Calculo de KPIs y semaforos
    cache.py             # Redis cache layer
  dashboard/
    api/                 # Endpoints REST para cada panel
    websocket/           # Actualizaciones en tiempo real
    frontend/
      components/        # Componentes por panel
      layouts/           # Responsive layouts
      charts/            # Graficos reutilizables
  config/
    thresholds.yaml      # Umbrales de semaforo configurables
    sources.yaml         # Configuracion de fuentes de datos
```

### Paso 5: Verificar

```bash
sdd-verify
```

> **Verificacion Final** — Resultado:

```
Layer 1 - Lint:           PASS
Layer 1 - Build:          PASS
Layer 1d - Documentacion: PASS (cada conector y transformer documentado)
Layer 2 - Unit Tests:     PASS (calculos de KPI validados)
Layer 3 - Integration:    PASS (dashboard carga datos de todas las fuentes)

Resultado: LISTO PARA REVIEW HUMANO
```

## Skills que se activan

| Skill | Por que |
|-------|---------|
| **data-pipeline-design** | Disena el flujo Extract-Transform-Load para las 4 fuentes de datos |
| **scope-rule** | Separa data-layer, dashboard y config en la estructura de features |
| **process-analyst** | Identifica que cada panel tiene requerimientos diferentes de datos y frecuencia |

## Checkpoints que pasas

### Design Approval — Variantes + viabilidad
- **Que evalua:** Las diferencias entre paneles y si un dashboard custom se justifica
- **Ejemplo concreto:** "Produccion necesita datos cada 5 minutos pero Finanzas puede actualizarse cada hora. Las 4 fuentes heterogeneas y los semaforos personalizados requieren integracion custom."
- **Si no pasa:** Se clarifican que KPIs son criticos o el agente sugiere empezar con Metabase/Grafana

### Verificacion Final — Calidad de la implementacion
- **Que evalua:** Que todos los paneles carguen datos correctos en tiempo real
- **Ejemplo concreto:** "Los 5 paneles cargan en menos de 2 segundos, los semaforos cambian correctamente segun umbrales, el WebSocket actualiza sin recargar la pagina."
- **Si no pasa:** Se revisan los conectores lentos o los calculos incorrectos

## Resultado final

Al terminar, tenes:

- Dashboard web con 5 paneles operativos
- Datos actualizados cada 5 minutos desde 4 fuentes
- Semaforos rojo/amarillo/verde configurables por KPI
- Responsive para pantalla grande, tablet y celular
- Historico de datos para comparativas
- Configuracion de umbrales via archivo YAML (sin tocar codigo)
- Documentacion de cada conector y cada KPI

## Siguientes pasos

- **Alertas push:** Notificaciones por email o Slack cuando un KPI pasa a rojo
- **Drill-down:** Click en un KPI para ver el detalle (por linea, por vendedor, por producto)
- **TV mode:** Version optimizada para pantallas fijas en planta o sala de reuniones
- **Exportar:** Boton para descargar los datos de cualquier panel en Excel
- **Usuarios:** Diferentes vistas por rol (gerente ve todo, jefe de planta solo produccion)
- **Prediccion:** Agregar tendencias predictivas basadas en datos historicos
