# Compliance y datos

Si tu proyecto toca datos de personas o integra con sistemas colombianos, Batuta tiene dos skills especializados: **compliance-colombia** y **data-pipeline-design**. En v15, estos skills se cargan en los agentes contratados cuando la tarea lo requiere.

---

## Compliance Colombia

### Cuando se activa

- Tu proyecto almacena nombres, emails, cedulas, o cualquier dato personal
- Usas IA para procesar datos de personas
- Transfieres datos fuera de Colombia
- Tu sistema maneja retencion tributaria (DIAN)

En v15, el agente contratado carga `compliance-colombia` automaticamente al detectar estas senales durante research-first. No necesitas pedirlo.

### Que revisa

| Regulacion | Que cubre |
|-----------|----------|
| **Ley 1581/2012** | Proteccion de datos personales. Consentimiento, derechos ARCO (acceso, rectificacion, cancelacion, oposicion) |
| **Circular SIC 002/2024** | IA sobre datos personales. Test de proporcionalidad, evaluacion de impacto |
| **Art. 632 ET** | Retencion tributaria. Conservacion de documentos, periodos minimos |
| **Transferencias internacionales** | Datos que salen del pais. Clausulas contractuales, paises adecuados |

### El patron tombstoning

Cuando un usuario pide que borres sus datos, no los borras fisicamente. Los marcas como "eliminados" (tombstone) pero los mantienes para auditoria:

```
usuario.estado = "eliminado"
usuario.datos_personales = null
usuario.tombstone_fecha = ahora()
usuario.tombstone_razon = "solicitud habeas data"
```

Esto cumple con el derecho de supresion sin perder trazabilidad.

### Ejemplo practico

Construyes un CRM que almacena contactos de clientes:

```
Compliance Check: mi-crm

[FAIL] No hay formulario de consentimiento para tratamiento de datos
[FAIL] No hay mecanismo de supresion (derecho a ser olvidado)
[WARN] Datos almacenados sin encripcion at-rest
[PASS] No hay transferencia internacional de datos
[INFO] Recomendacion: agregar politica de retencion (Art. 632)

Acciones requeridas:
1. Agregar checkbox de consentimiento en formulario de registro
2. Implementar endpoint de supresion con tombstoning
3. Evaluar encripcion de columnas sensibles
```

---

## Data Pipeline Design

### Cuando se activa

- Necesitas extraer datos de un ERP (WorldOffice, Siigo, SAP B1, Alegra, Helisa)
- Procesas archivos planos o bancarios
- Integras con DIAN
- Necesitas reglas de calidad de datos

En v15, el **data-agent** carga este skill cuando lo contratan para trabajo de datos/ETL.

### Que disena

1. **Extraccion**: De donde vienen los datos y como se conecta
2. **Transformacion**: Reglas de limpieza, validacion, conversion
3. **Carga**: Esquemas PostgreSQL con RLS (row-level security)
4. **Calidad**: Reglas de validacion (NIT valido, fechas coherentes, montos positivos)

### ERPs colombianos soportados

| ERP | Tipo conexion | Formato datos |
|-----|--------------|--------------|
| WorldOffice | API REST | JSON |
| Siigo | API REST | JSON |
| SAP Business One | Service Layer | JSON/XML |
| Alegra | API REST | JSON |
| Helisa | Archivos planos | CSV/TXT |

### Ejemplo: pipeline de conciliacion

```
Fuente: Extracto bancario (archivo plano)
  |
  v
Extraccion: Parser por tipo de banco
  (Bancolombia, Davivienda, BBVA cada uno tiene formato diferente)
  |
  v
Transformacion:
  - Normalizar fechas (DD/MM/YYYY -> ISO 8601)
  - Clasificar conceptos segun diccionario
  - Validar montos (no negativos, no nulos)
  |
  v
Carga: PostgreSQL
  - Tabla: movimientos_bancarios
  - RLS: cada empresa solo ve sus movimientos
  - Indices: fecha, concepto, empresa_id
```

---

## Como se conectan en v15

Si tu proyecto necesita AMBOS (compliance + datos), el agente principal contrata los agentes apropiados:

1. El **data-agent** (con skill `data-pipeline-design`) disena el flujo de datos
2. El quality-agent o un agente con **compliance-colombia** valida que el flujo respete la regulacion
3. Si es modo COMPLETO, ambos analisis se integran en el artifact de diseno que aprueba el CTO

Los agentes pueden trabajar en paralelo: mientras uno disena el pipeline, otro verifica compliance. Resultado en minutos, no horas.

---

-> [Hooks y automatizacion](hooks-y-automatizacion.md) — Los automatismos del ecosistema
