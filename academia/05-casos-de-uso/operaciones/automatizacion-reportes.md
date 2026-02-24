# Automatizacion de reportes

> **Industria:** Operaciones | **Dificultad:** Intermedio | **Tiempo estimado:** 3-4 horas con Batuta Dots

---

## El problema

El area de operaciones genera reportes semanales para gerencia. Cada lunes, alguien del equipo dedica medio dia a recopilar datos de 4 fuentes diferentes (el ERP, una hoja de Google Sheets, el sistema de tickets y un archivo de Excel local), copiar numeros a una plantilla, hacer calculos, generar graficos y enviar el PDF por email.

El proceso es manual, tedioso y propenso a errores. La semana pasada el reporte se envio con un dato de produccion del mes anterior porque alguien copio de la celda equivocada. Nadie se dio cuenta hasta la reunion del miercoles.

Lo peor es que cada area tiene su propia version del reporte. Ventas quiere ver cosas diferentes a Produccion, y Finanzas necesita los numeros en otro formato. Son 4 reportes diferentes que se generan con el mismo dolor.

## Lo que vas a construir

Un sistema automatizado de generacion de reportes que incluye:

- **Conectores de datos** para las 4 fuentes (ERP, Google Sheets, sistema de tickets, Excel)
- **Pipeline de transformacion** que limpia, calcula y consolida los datos
- **4 plantillas de reporte** personalizadas por area (Gerencia, Ventas, Produccion, Finanzas)
- **Generacion automatica** de PDF con graficos
- **Envio programado** por email cada lunes a las 7am
- **Dashboard web** para consultar los datos en tiempo real (sin esperar al lunes)

## Flujo SDD completo

### Paso 1: Explorar y entender los datos

```bash
sdd-explore
```

> El agente te pregunta sobre las fuentes de datos:
> --> Tenemos 4 fuentes: SAP (ERP) via API REST, Google Sheets con datos de ventas, Freshdesk para tickets de soporte, y un Excel en OneDrive con datos de produccion manual.

El agente mapea las fuentes, identifica los campos clave y detecta posibles problemas de calidad de datos.

> **Skill gap check:** El agente verifica si hay skills necesarios que no estan disponibles. En este caso, `data-pipeline-design` esta disponible y se marca para activacion.

### Paso 2: Analizar variantes por area

El `process-analyst` se activa para mapear las diferencias entre reportes:

```
process-analyst detecta 4 variantes:
- Gerencia: KPIs consolidados, tendencias, semaforos rojo/amarillo/verde
- Ventas: pipeline, conversion, top productos, comparativa vs mes anterior
- Produccion: OEE, paradas, cumplimiento de plan, desperdicios
- Finanzas: costos, margenes, desviaciones presupuestarias
```

> **Gate G0.5** — El agente te pregunta:
> "Encontre 4 variantes de reporte con estructuras muy diferentes. Queres que comparta campos base entre todos o que cada reporte sea completamente independiente?"
> --> Comparten la misma fuente de datos pero cada uno tiene su propia plantilla y calculos

### Paso 3: Disenar el pipeline de datos

El `data-pipeline-design` se activa:

```
Pipeline disenado:
1. EXTRACT: 4 conectores (SAP API, Google Sheets API, Freshdesk API, Excel via OneDrive API)
2. TRANSFORM: Limpieza + calculos por area + consolidacion
3. LOAD: Base de datos intermedia + cache para dashboard
4. REPORT: 4 plantillas PDF + graficos
5. DELIVER: Email programado + dashboard web
```

### Paso 4: Feature Freeze

```bash
sdd-ff
```

Se congela la especificacion con los 4 reportes definidos y el pipeline completo.

### Paso 5: Aplicar la implementacion

```bash
sdd-apply
```

El agente genera la estructura usando n8n para la orquestacion y Python para las transformaciones:

```
features/
  data-connectors/
    sap_connector.py        # Extraccion de SAP
    sheets_connector.py     # Extraccion de Google Sheets
    freshdesk_connector.py  # Extraccion de Freshdesk
    excel_connector.py      # Extraccion de Excel/OneDrive
  transformations/
    base_transform.py       # Limpieza comun
    gerencia_transform.py   # Calculos para gerencia
    ventas_transform.py     # Calculos para ventas
    produccion_transform.py # Calculos para produccion
    finanzas_transform.py   # Calculos para finanzas
  reports/
    templates/              # Plantillas HTML para cada reporte
    generator.py            # Motor de generacion PDF
  dashboard/
    app.py                  # Dashboard web con los datos
n8n/
  workflow-reportes.json    # Workflow de n8n para orquestar todo
```

### Paso 6: Verificar

```bash
sdd-verify
```

> **Gate G2** — Verificacion:

```
Layer 1 - Lint:           PASS
Layer 1 - Build:          PASS
Layer 1d - Documentacion: PASS (cada conector documentado)
Layer 2 - Unit Tests:     PASS (transformaciones validadas con datos de ejemplo)
Layer 3 - Integration:    PASS (pipeline completo genera PDF correctamente)

Resultado: LISTO PARA REVIEW HUMANO
```

## Skills que se activan

| Skill | Por que |
|-------|---------|
| **data-pipeline-design** | Disena el flujo completo Extract-Transform-Load-Report-Deliver |
| **process-analyst** | Identifica las 4 variantes de reporte y sus diferencias |
| **scope-rule** | Organiza el codigo en features/ separando conectores, transformaciones, reportes y dashboard |
| **n8n automation** | Orquesta la ejecucion programada del pipeline completo |

## Gates que pasas

### Gate G0.5 — Variantes de negocio
- **Que evalua:** Las diferencias entre los 4 reportes
- **Ejemplo concreto:** "Gerencia necesita semaforos de KPI, Ventas necesita pipeline y conversion, Produccion necesita OEE, Finanzas necesita margenes. Comparten fuentes pero no calculos."
- **Si no pasa:** Se clarifican las necesidades de cada area antes de seguir

### Gate G1 — Vale la pena construirlo?
- **Que evalua:** Si automatizar justifica la inversion vs seguir haciendolo manual
- **Ejemplo concreto:** "El equipo dedica 4 horas semanales a generar reportes manualmente. Con errores frecuentes. La automatizacion se amortiza en 3 semanas."
- **Si no pasa:** El agente sugiere automatizar solo los reportes mas criticos primero

### Gate G2 — Calidad de la implementacion
- **Que evalua:** Que el pipeline funcione de punta a punta con datos reales
- **Ejemplo concreto:** "Pipeline ejecutado con datos de la ultima semana. Los 4 PDFs se generaron correctamente. Los numeros coinciden con el reporte manual anterior."
- **Si no pasa:** Se revisan los conectores o las transformaciones que fallen

## Resultado final

Al terminar, tenes:

- 4 conectores de datos funcionando (SAP, Sheets, Freshdesk, Excel)
- Pipeline de transformacion automatizado
- 4 plantillas de reporte personalizadas por area
- Generacion automatica de PDFs con graficos cada lunes
- Envio por email programado
- Dashboard web para consultas en tiempo real
- Documentacion completa del pipeline y cada conector

## Siguientes pasos

- **Alertas:** Notificar si un KPI cruza un umbral critico (no esperar al lunes)
- **Historico:** Almacenar datos historicos para comparativas mes a mes, ano a ano
- **Self-service:** Permitir que cada area personalice su reporte desde el dashboard
- **Nuevas fuentes:** Agregar datos de redes sociales, Google Analytics, etc.
- **Reporte bajo demanda:** Boton en el dashboard para generar el reporte en cualquier momento
