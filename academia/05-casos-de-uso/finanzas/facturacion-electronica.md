# Integracion con Facturacion Electronica DIAN

## El problema

Desde 2019, la DIAN exige a las empresas colombianas emitir facturas electronicas. Lo que empezo como una obligacion para grandes contribuyentes hoy aplica a casi todos los negocios. El problema no es solo cumplir con la norma — es que la integracion entre el ERP de la empresa y el sistema de la DIAN tiene decenas de detalles tecnicos que fallan silenciosamente.

Una factura electronica no es un PDF bonito. Es un documento XML firmado digitalmente, con numeracion autorizada por la DIAN, que debe ser validado y aceptado antes de tener valor fiscal. Cada tipo de documento (factura de venta, nota credito, nota debito, factura de exportacion) tiene su propia estructura y reglas. Un campo mal formateado, un codigo de impuesto incorrecto o una firma digital vencida significa rechazo inmediato.

La mayoria de empresas resuelven esto contratando un proveedor tecnologico que hace de intermediario. Pero cuando el volumen de facturas crece, o cuando el negocio necesita personalizar el proceso (descuentos escalonados, facturacion por proyecto, notas credito parciales), el intermediario se convierte en un cuello de botella. Construir tu propio conector con la DIAN te da control total sobre el proceso.

## Lo que vas a construir

- Generador de documentos electronicos (XML UBL 2.1) para los 4 tipos de documento DIAN
- Modulo de firma digital con certificado de la empresa
- Conector con el servicio web de la DIAN (validacion y envio)
- Administrador de rangos de numeracion autorizados
- Conector con ERP para lectura de facturas y escritura de estado
- Modulo de recepcion de facturas de proveedores
- Gestion de eventos DIAN (acuse de recibo, aceptacion, rechazo)
- Archivo electronico con retencion legal

## Flujo SDD completo

### Paso 1 — Iniciar el proyecto
```
sdd-new facturacion-electronica
```
Crea la estructura base del proyecto dentro del pipeline SDD.

### Paso 2 — Analizar el proceso con process-analyst
```
process-analyst
```
Documenta los 4 tipos de documento electronico y sus variantes:

| Tipo de documento | Codigo DIAN | Variantes principales |
|---|---|---|
| Factura de venta | 01 | Nacional, con retencion, con descuentos |
| Nota credito | 91 | Anulacion total, correccion parcial, devolucion |
| Nota debito | 92 | Intereses, ajuste precio, penalizacion |
| Factura de exportacion | 02 | FOB, CIF, con agente aduanero |

El process-analyst tambien mapea el flujo completo de cada documento:
1. Creacion en ERP → 2. Generacion XML → 3. Firma digital → 4. Envio a DIAN → 5. Validacion → 6. Aceptacion/Rechazo → 7. Entrega al receptor → 8. Eventos posteriores

### Paso 3 — Validar cumplimiento con compliance-colombia
```
compliance-colombia
```
Este es el skill mas critico del proyecto. Valida:

- **Estructura XML**: Cumplimiento del estandar UBL 2.1 segun Anexo Tecnico DIAN
- **Firma digital**: Requisitos del certificado, algoritmos permitidos, cadena de confianza
- **Numeracion**: Rangos autorizados, prefijos, consecutivos sin saltos
- **Impuestos**: Codigos correctos de IVA, ICA, retefuente segun tipo de operacion
- **Retencion documental**: Tiempo minimo de almacenamiento de documentos electronicos
- **Datos del receptor**: NIT, razon social, regimen tributario — validacion cruzada con RUT

### Paso 4 — Disenar el flujo de datos con data-pipeline-design
```
data-pipeline-design
```
Define los pipelines de emision y recepcion:

- **Emision**: Lectura ERP → Generacion XML → Firma → Envio DIAN → Respuesta → Actualizacion ERP → Entrega receptor
- **Recepcion**: Bandeja entrada → Validacion XML → Registro en ERP → Eventos (acuse, aceptacion/rechazo)

Cada pipeline incluye manejo de errores, reintentos y notificaciones.

### Paso 5 — Generar especificacion y tareas
```
sdd-ff
```
Consolida el analisis de proceso, cumplimiento y flujo de datos en una especificacion completa con tareas de implementacion priorizadas.

### Paso 6 — Implementar
```
sdd-apply
```
Construye el sistema siguiendo el Scope Rule:
- `features/emision/` — Generacion XML, firma digital, envio DIAN
- `features/recepcion/` — Bandeja, validacion, eventos
- `features/shared/dian-connector/` — Cliente del servicio web DIAN (reutilizable)
- `features/shared/xml-signer/` — Modulo de firma digital

## Skills que se activan

| Skill | Por que |
|---|---|
| process-analyst | Mapea los 4 tipos de documento y el flujo completo de cada uno con sus variantes |
| compliance-colombia | Valida estructura UBL, firma digital, numeracion DIAN, impuestos y retencion documental |
| data-pipeline-design | Disena los pipelines de emision y recepcion con manejo de errores |
| scope-rule | Organiza el codigo separando emision, recepcion y componentes compartidos |
| security-audit | Protege la firma digital, credenciales DIAN y datos tributarios de la empresa |

## Checkpoints que pasas

### Design Approval — Discovery Complete
- Los 4 tipos de documento estan documentados con sus variantes y reglas especificas
- El flujo completo de emision y recepcion esta mapeado paso a paso
- Los requisitos de compliance-colombia estan catalogados con referencias normativas
- Las integraciones necesarias (ERP, DIAN, certificado digital) estan identificadas

### Design Approval — Solution Worth Building
- La especificacion cubre los escenarios de la operacion real de la empresa
- El analisis de compliance confirma que el diseno cumple la normativa vigente
- Los riesgos estan identificados (cambios en Anexo Tecnico, vencimiento de certificado, caida del servicio DIAN)
- El costo-beneficio vs proveedor tecnologico externo esta documentado

### Verificacion Final — Ready for Production
- Los XML generados pasan la validacion del servicio de pruebas de la DIAN (ambiente de habilitacion)
- La firma digital es valida y la cadena de confianza esta completa
- Los 4 tipos de documento se emiten y reciben correctamente
- El manejo de errores cubre los escenarios de rechazo DIAN y timeout
- El archivo electronico cumple los periodos de retencion legal
- Las pruebas cubren escenarios criticos: factura con multiples impuestos, nota credito parcial, documento rechazado

## Resultado final

Un sistema propio de facturacion electronica que se conecta directamente con la DIAN y con tu ERP. Puedes emitir y recibir los 4 tipos de documento electronico, manejar los eventos del ciclo de vida de cada factura, y cumplir con todos los requisitos normativos.

El codigo esta documentado, los requisitos de compliance tienen trazabilidad directa a la norma, y la arquitectura permite agregar nuevos tipos de documento cuando la DIAN los introduzca.

## Siguientes pasos

1. **Nomina electronica**: Extender el conector DIAN para documentos de nomina (estructura diferente pero misma logica de firma y envio)
2. **Documento soporte**: Integrar la emision de documentos soporte para compras a no obligados a facturar
3. **Reportes tributarios**: Generar automaticamente los reportes exogenos a partir de las facturas electronicas emitidas y recibidas
4. **Dashboard operativo**: Monitoreo en tiempo real del estado de documentos: emitidos, validados, rechazados, pendientes de aceptacion
