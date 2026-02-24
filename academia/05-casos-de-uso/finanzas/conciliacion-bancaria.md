# Automatizacion de Conciliacion Bancaria

## El problema

En la mayoria de empresas colombianas, el area de tesoreria dedica entre 2 y 3 dias al mes a una tarea que deberia ser automatica: comparar los movimientos del extracto bancario contra los registros del ERP. El tesorero abre el extracto en Excel, busca cada movimiento en el sistema, marca los que coinciden y anota los que no. Cuando hay multiples bancos, el proceso se multiplica.

El problema no es solo el tiempo. Es que cada banco presenta la informacion de forma diferente. Bancolombia llama "transferencia electronica" a lo que Davivienda llama "abono por transferencia" y BBVA llama "TRF electronica". Los debitos automaticos, los cheques cobrados, las notas bancarias — cada tipo de movimiento tiene sus propias reglas de coincidencia. Y cuando no coincide, el tesorero necesita investigar por que.

Las excepciones son la parte mas costosa. Un pago parcial que no coincide con ninguna factura exacta. Una comision bancaria que el ERP no tiene registrada. Un cheque que se cobro 45 dias despues de emitido. Cada excepcion requiere juicio humano, pero el 70% de las excepciones siguen patrones predecibles que se pueden automatizar.

## Lo que vas a construir

- Parser de extractos bancarios por entidad (Bancolombia, Davivienda, BBVA)
- Motor de conciliacion con reglas configurables por tipo de movimiento
- Clasificador de excepciones con sugerencias automaticas de resolucion
- Conector bidireccional con ERP (lectura de movimientos contables, escritura de conciliacion)
- Dashboard de estado: conciliado, pendiente, excepcion, resuelto
- Worker de procesamiento nocturno para conciliacion automatica
- Registro de auditoria cumpliendo retencion documental (Art. 632 E.T.)

## Flujo SDD completo

### Paso 1 — Iniciar el proyecto
```
sdd-new conciliacion-bancaria
```
Esto crea la estructura base del proyecto y prepara el pipeline SDD.

### Paso 2 — Analizar el proceso con process-analyst
```
process-analyst
```
El skill te guia para mapear las 4 variantes principales del proceso:

| Tipo de movimiento | Regla de coincidencia | Complejidad |
|---|---|---|
| Debitos automaticos | Referencia exacta + monto exacto | Baja |
| Transferencias | Concepto bancario + monto (tolerancia) | Media |
| Cheques | Numero de cheque + monto + ventana de tiempo | Alta |
| Notas bancarias (credito/debito) | Sin referencia directa — requiere clasificacion | Alta |

Ademas, el process-analyst te ayuda a documentar las 7+ excepciones mas frecuentes:
1. Pago parcial (monto no coincide con ninguna factura exacta)
2. Comision bancaria no registrada en ERP
3. Cheque cobrado fuera de ventana esperada
4. Movimiento duplicado en extracto
5. Concepto bancario no reconocido
6. Diferencia por redondeo (centavos)
7. Movimiento en transito entre cuentas propias

### Paso 3 — Modelar las variaciones con recursion-designer
```
recursion-designer
```
Aqui es donde se resuelve el problema central: los conceptos bancarios cambian por banco. El recursion-designer te ayuda a crear un modelo de mapeo:

```
Concepto generico: "Transferencia recibida"
├── Bancolombia: "ABONO TRANSFERENCIA ELECTRONICA"
├── Davivienda: "ABONO X TRANSFER"
└── BBVA: "TRF ELECTRONICA CR"
```

Esto genera un diccionario de conceptos normalizados que el motor de conciliacion usa para comparar sin importar el banco de origen.

### Paso 4 — Disenar el flujo de datos con data-pipeline-design
```
data-pipeline-design
```
Define dos pipelines principales:
- **Ingesta**: Parser por banco → Normalizador de conceptos → Almacenamiento temporal
- **Conciliacion**: Lectura ERP → Motor de reglas → Clasificacion (conciliado / excepcion) → Escritura resultado

### Paso 5 — Validar cumplimiento con compliance-colombia
```
compliance-colombia
```
Verifica requisitos del Art. 632 del Estatuto Tributario sobre retencion de documentos contables. Asegura que el sistema mantiene trazabilidad completa de cada conciliacion durante el periodo legal requerido.

### Paso 6 — Generar especificacion y tareas
```
sdd-ff
```
El fast-forward consolida todo el analisis en una especificacion tecnica detallada y genera las tareas de implementacion.

### Paso 7 — Implementar
```
sdd-apply
```
Construye el sistema siguiendo las tareas generadas. El Scope Rule organiza la estructura:
- `features/conciliacion/` — Motor de reglas y clasificador
- `features/parser-bancario/` — Parsers por entidad
- `features/shared/erp-connector/` — Conector reutilizable con ERP

### Paso 8 — Programar procesamiento nocturno
```
worker-scaffold
```
Crea el worker que ejecuta la conciliacion automatica cada noche. Incluye reintentos, logging y notificaciones cuando hay excepciones nuevas.

## Skills que se activan

| Skill | Por que |
|---|---|
| process-analyst | Mapea las 4 variantes de movimiento y las 7+ excepciones del proceso real |
| recursion-designer | Modela los conceptos bancarios que cambian por banco (Bancolombia, Davivienda, BBVA) |
| data-pipeline-design | Disena los pipelines de ingesta y conciliacion |
| compliance-colombia | Valida retencion documental segun Art. 632 del Estatuto Tributario |
| scope-rule | Organiza el codigo por features sin crear carpetas genericas |
| worker-scaffold | Crea el worker de procesamiento nocturno con reintentos y logging |
| security-audit | Protege las credenciales del ERP y los datos financieros |

## Gates que pasas

### G0.5 — Discovery Complete
- Tienes las 4 variantes de movimiento documentadas con sus reglas de coincidencia
- Tienes las 7+ excepciones catalogadas con frecuencia estimada
- Tienes el diccionario de conceptos bancarios por entidad
- El process-analyst y el recursion-designer completaron su analisis

### G1 — Solution Worth Building
- La especificacion demuestra que el 70%+ de las conciliaciones se pueden automatizar
- El analisis costo-beneficio justifica el desarrollo (2-3 dias/mes de tesorero vs costo del sistema)
- Los requisitos de compliance estan integrados en el diseno, no como parche posterior
- Los riesgos estan identificados (cambio de formato de extracto, nuevos bancos, etc.)

### G2 — Ready for Production
- Los parsers procesan extractos reales de cada banco sin errores
- El motor de conciliacion maneja correctamente los 4 tipos de movimiento
- Las excepciones se clasifican y sugieren resolucion automatica
- El worker nocturno funciona de forma estable con reintentos
- La trazabilidad de auditoria cumple Art. 632
- El build pasa limpio y las pruebas cubren los escenarios criticos

## Resultado final

Un sistema que reduce la conciliacion bancaria mensual de 2-3 dias a menos de 2 horas. El tesorero solo interviene en las excepciones genuinamente nuevas (menos del 10% de los movimientos). Cada conciliacion queda registrada con trazabilidad completa para auditoria.

El codigo esta organizado por features, documentado con docstrings en cada modulo, y los conceptos bancarios son configurables sin necesidad de modificar codigo cuando se agrega un nuevo banco.

## Siguientes pasos

1. **Agregar mas bancos**: El recursion-designer genera la plantilla de mapeo para cualquier banco nuevo
2. **Conciliacion en tiempo real**: Migrar del worker nocturno a procesamiento por eventos cuando el volumen lo justifique
3. **Machine Learning para excepciones**: Entrenar un modelo con las resoluciones historicas para mejorar las sugerencias automaticas
4. **Reportes gerenciales**: Dashboard con tendencias de excepciones, tiempos de resolucion y volumen por banco
