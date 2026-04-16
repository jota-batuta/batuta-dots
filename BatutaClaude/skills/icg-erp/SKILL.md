---
name: icg-erp
description: >
  Schema and gotchas for ICG ERP (restaurant management system) on SQL Server 2017.
  Trigger: "ICG", "ERP", "KIOSCO database", "MOVIMENTS", "STOCKS table", "TRASPASOSCAB",
  "regularizacion", "stock negativo", "inventory query".
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-04-07"
  bucket: review
  auto_invoke: "When writing queries against the KIOSCO database or working with ICG ERP data"
  platforms: [claude]
  category: "capability"
allowed-tools: Read Edit Write Glob Grep Bash
---

## Purpose

Verified schema, business rules, and gotchas for the ICG ERP database (KIOSCO on SQL Server 2017). Prevents query errors caused by incorrect assumptions about field meanings. Every fact here was verified against real data on 2026-04-06.

## When to Use

- Writing T-SQL queries against the KIOSCO database
- Analyzing inventory data (stock, movements, transfers, counts)
- Building checks that detect anomalies
- Interpreting data from STOCKS, MOVIMENTS, TRASPASOSCAB, or purchase tables

## Critical Tables

### STOCKS — Current stock per article/warehouse

| Column | Type | Meaning |
|--------|------|---------|
| CODARTICULO | int | Article code (FK to ARTICULOS) |
| CODALMACEN | nvarchar(3) | Warehouse code (FK to ALMACEN) |
| STOCK | float | **Current calculated stock** |
| STOCKREGUL | float | **Last physical count value** (the REAL count entered by user) |
| FECHAREGUL | datetime | **NOT RELIABLE — DO NOT USE for last count date** |
| ENTRANSITO | float | Units in transit (sent but not confirmed received) |
| PEDIDO | float | Units on purchase order |
| ASERVIR | float | Units pending to serve |

### MOVIMENTS — All movements (1.48M records)

| Column | Type | Meaning |
|--------|------|---------|
| ID | int | Auto-increment PK |
| CODALMACENORIGEN | nvarchar(3) | Source warehouse |
| CODALMACENDESTINO | nvarchar(3) | Destination warehouse |
| CODARTICULO | int | Article code |
| TIPO | nvarchar(3) | Movement type: REG, ENV, TMP, CON |
| UNIDADES | float | **For REG: stock AFTER regularization (NOT the count)** |
| STOCK | float | **For REG: stock BEFORE regularization** |
| FECHA | datetime | Date |
| HORA | datetime | Time |

### TRASPASOSCAB — Transfer headers (74K records)

| Column | Type | Meaning |
|--------|------|---------|
| SERIE | nvarchar(4) | Series (MITC=Parque, MITD=Tradicional, etc.) |
| NUMERO | int | Document number |
| CODALMACENORIGEN | nvarchar(3) | Source warehouse |
| CODALMACENDESTINO | nvarchar(3) | Destination warehouse |
| RECIBIDO | nchar(1) | **'T' = received, 'F' = pending** (NOT 'S'/'N') |
| ANULADO | nchar(1) | 'T' = cancelled, 'F' = active |
| FECHA | datetime | Transfer date |
| FECHARECIBIDO | datetime | Date received (null if pending) |

### ALMACEN — Warehouse master (25 records)

| Column | Type | Meaning |
|--------|------|---------|
| CODALMACEN | nvarchar(3) | PK warehouse code (PQ, PT, PSB, etc.) |
| **NOMBREALMACEN** | nvarchar(30) | **Display name (NOT "NOMBRE")** |
| POBLACION | nvarchar(30) | City |
| PROVINCIA | nvarchar(30) | Province |
| CENTROCOSTE | nvarchar(6) | Cost center |
| STOCKMINIMO | float | Min stock threshold |
| STOCKMAXIMO | float | Max stock threshold |

**GOTCHA**: The column is `NOMBREALMACEN`, NOT `NOMBRE`. Querying `a.NOMBRE` raises `Invalid column name 'NOMBRE'`.

### ALBVENTACAB — Sales/remission headers

| Column | Type | Meaning |
|--------|------|---------|
| NUMSERIE | nvarchar(4) | Series code (MVY = B2B remission) |
| NUMALBARAN | int | Document number |
| FECHA | datetime | Sale date |
| CODCLIENTE | int | Customer code |
| TOTALNETO | float | Net total |

Serie MVY = B2B remissions from plant to stores (~250-350/month).

### ALBCOMPRACAB — Purchase receipt headers

| Column | Type | Meaning |
|--------|------|---------|
| **NUMSERIE** | nvarchar(4) | **Series code (NOT "SERIE")** |
| **NUMALBARAN** | int | **Document number (NOT "NUMERO")** |
| CODPROVEEDOR | int | FK to PROVEEDORES |
| **FECHAALBARAN** | datetime | **Receipt date (NOT "FECHA")** |
| FACTURADO | nchar(1) | 'T'/'F' — IRRELEVANT for inventory (accounting not in ICG) |
| TOTALBRUTO | float | Gross total |
| TOTALNETO | float | Net total |

Serie MCR = Purchase remissions (plant receives from suppliers).

**GOTCHA**: Columns are `NUMSERIE`, `NUMALBARAN`, `FECHAALBARAN` — NOT `SERIE`, `NUMERO`, `FECHA`.

### ALBCOMPRALIN — Purchase receipt lines

| Column | Type | Meaning |
|--------|------|---------|
| NUMSERIE | nvarchar(4) | FK to ALBCOMPRACAB |
| NUMALBARAN | int | FK to ALBCOMPRACAB |
| NUMLIN | int | Line number |
| CODARTICULO | int | Article code |
| DESCRIPCION | nvarchar(40) | Article description (snapshot) |
| **UNIDADESTOTAL** | float | **Total units (NOT "UNIDADES")** |
| PRECIO | float | Unit price |
| TOTAL | float | Line total |
| **CODALMACEN** | nvarchar(3) | **Destination warehouse (per LINE, not header)** |

**GOTCHA**: Quantity field is `UNIDADESTOTAL`, NOT `UNIDADES`. The destination warehouse is on the LINE (`ALBCOMPRALIN.CODALMACEN`), not the header. A single albaran can deliver to multiple warehouses.

### ALBVENTACONSUMO — Recipe explosion lines (sales-side)

| Column | Type | Meaning |
|--------|------|---------|
| NUMSERIE | nvarchar(4) | FK to ALBVENTACAB (composite key part 1) |
| NUMALBARAN | int | FK to ALBVENTACAB (composite key part 2) |
| N | nchar(1) | FK to ALBVENTACAB (composite key part 3 — multi-empresa flag) |
| NUMLINEA | int | FK to the parent ALBVENTALIN line |
| CODARTICULO | int | The INGREDIENT consumed (not the parent product) |
| **CONSUMO** | float | Quantity of the ingredient consumed by this line |
| CODALMACEN | nvarchar(3) | Warehouse where the consumption was charged |

When a composite product (combo, plate) is sold, ICG writes one parent line in ALBVENTALIN with the combo's CODARTICULO and one child row PER INGREDIENT here. CONSUMO is the absolute quantity (e.g., 2 empanadas in a combo → CONSUMO=2.0). To get the real consumption of an ingredient, sum `ALBVENTALIN.UNIDADESTOTAL` + `ALBVENTACONSUMO.CONSUMO` for the same CODARTICULO.

### PEDCOMPRACAB — Purchase order headers

| Column | Type | Meaning |
|--------|------|---------|
| NUMSERIE | nvarchar(4) | PK part 1 |
| NUMPEDIDO | int | PK part 2 |
| N | nchar(1) | PK part 3 (multi-empresa) |
| CODPROVEEDOR | int | FK to PROVEEDORES |
| FECHAPEDIDO | datetime | Date order was placed |
| FECHAENTREGA | datetime | Promised delivery date |
| **SERIEALBARAN** | nvarchar(4) | Cross-reference to ALBCOMPRACAB (NULL/'' = not crossed) |
| **NUMEROALBARAN** | int | Cross-reference to ALBCOMPRACAB |
| **TODORECIBIDO** | nchar(1) | 'T' = fully received, 'F' = not |
| **NORECIBIDO** | nchar(1) | 'T' = nothing received yet, 'F' = partial/full |
| IDESTADO | int | Order state code |

`PEDCOMPRALIN` (lines): NUMSERIE/NUMPEDIDO/N + NUMLINEA + CODARTICULO + CODALMACEN + UNIDADESTOTAL.

**GOTCHA**: ALBCOMPRACAB has NO field referencing the originating PEDCOMPRA. The cross is one-way (pedido → albarán). Detecting "albarán without pedido" is therefore not possible from the schema alone — only "pedido without crossed albarán" is queryable.

### INVENTARIOS — Inventory session HEADERS (no count lines)

| Column | Type | Meaning |
|--------|------|---------|
| FECHA | datetime | Day the session was opened |
| CODALMACEN | nvarchar(3) | Warehouse |
| SERIE | nvarchar(4) | Document series. Empty = "quick count", filled (e.g. MIIA) = "formal inventory" |
| NUMERO | int | Document number. 0 when SERIE is empty |
| CODVENDEDOR | int | Employee who opened the session (-1 = system) |
| **ESTADO** | smallint | 0=draft, 1=in progress, 2=open/uncommitted, 3=closed |
| **ESCIERRE** | bit | True = formally closed cycle inventory, False = still open |
| INICIAL | nchar(1) | T = initial baseline, F = subsequent |
| COMPLETO | nchar(1) | T = entire warehouse counted, F = partial |
| BLOQUEADO | nchar(1) | T = another user holds the session lock |
| METODO | int | Methodology code (always 1 in production) |
| TIPOVALORACION | int | Accounting valuation method |
| ENLACE_* | mixed | Pointers to accounting journal entry. Always NULL in production (accounting not in ICG) |

**CRITICAL**: This table contains ONLY headers. There is NO related table with the
counted lines. The actual counted quantities live in:
- `STOCKS.STOCKREGUL` — last counted value (overwritten on each count)
- `MOVIMENTS` with `TIPO='REG'` — full history of regularizations with stock_before/stock_after

5,085 total rows in production:
- 4,150 "loose" counts (SERIE='', NUMERO=0) — quick per-product regularizations
- 906 formal sessions opened but NEVER closed (SERIE!='', ESCIERRE=False)
- 29 formally closed cycle inventories (ESCIERRE=True)

Implication for El Kiosco operations: stores open formal cycle sessions but only
3.2% are closed. Most regularization happens via loose counts. The TABLE is useful
ONLY for two things in BATOVF:
1. **Activity heartbeat**: `MAX(FECHA) GROUP BY CODALMACEN` to detect stores
   with no inventory activity for N days (process hygiene signal).
2. **Stuck formal sessions**: `WHERE SERIE!='' AND ESCIERRE=0 AND FECHA < today-N`
   to find formal inventories left open (process broken).

### INVENTARIOSZONA — Per-zone counts (DISCARD)

Only 6 rows in production. Designed to subdivide a warehouse into zones (shelf,
fridge, backroom) but El Kiosco does not use it. **Do not query.**

### TEMP_INVENTARIO_<n>_<n> — Client-side scratch tables (DISCARD)

ICG client creates these dynamically when a user opens the "Compare inventories
across warehouses" screen. Each is 989 rows × 131 columns of pre-aggregated data
for up to 5 warehouses simultaneously (`STOCK0..4`, `VENTAS0..4`, `UDSREGUL0..4`,
`FECHAREGUL0..4`, etc.). 15 of these tables are currently orphaned in production —
the client failed to clean them up. **Do not query.** They are not a source of truth
and the schema is volatile (table names change per session).

### PROVEEDORES — Supplier master

| Column | Type | Meaning |
|--------|------|---------|
| CODPROVEEDOR | int | PK |
| **NOMPROVEEDOR** | nvarchar | **Supplier name (NOT "NOMBRE")** |
| NOMCOMERCIAL | nvarchar | Commercial name |
| CIF | nvarchar | Tax ID |
| DIRECCION1 | nvarchar | Address |

**GOTCHA**: The column is `NOMPROVEEDOR`, NOT `NOMBRE`. Same pattern as ALMACEN.NOMBREALMACEN.

### ARTICULOS — Product master (1,590 articles)

| Column | Meaning |
|--------|---------|
| CODARTICULO | int PK |
| DESCRIPCION | nvarchar(40) — product name |
| DPTO | smallint — FK to DEPARTAMENTO.NUMDPTO |
| SECCION | smallint — FK to SECCIONES.NUMSECCION (compound with DPTO) |
| FAMILIA | smallint — FK to FAMILIAS (not used, empty table) |
| SUBFAMILIA | smallint — FK to SUBFAMILIAS (not used, empty table) |
| MARCA | int — FK to MARCA.CODMARCA |

### DEPARTAMENTO — Top-level product category (5 records)

Values:
1. PRODUCTO DE VENTA (675 articles) — items sold to customers
2. INSUMOS PDV (282) — supplies for point of sale
3. INSUMOS PLANTA (189) — production plant supplies
4. PROCESADOS (91) — processed items
5. MODIFICADORES (109) — modifiers/add-ons
6. OTROS INSUMOS (153)
7. DOMICILIOS (28)
8. LEVAPAN (28)
100. IMPUESTOS SALUDABLES (2)

### SECCIONES — Subcategories (66 records)

Compound key: (NUMDPTO, NUMSECCION). Top sections with articles:
- Dpto 1 Sec 109: EMPANADAS (38)
- Dpto 1 Sec 108: DESAYUNOS (47)
- Dpto 1 Sec 123: DIAFANO (109)
- Dpto 1 Sec 116: POSTRES COMPLETOS (42)
- Dpto 1 Sec 117: POSTRES PORCION (35)
- Dpto 1 Sec 115: POSTOBON (42)
- Dpto 1 Sec 106: BEBIDAS FRIAS (33)
- Dpto 1 Sec 111: HELADOS (32)
- Dpto 2 Sec 202: DESECHABLES PDV (86) — NOT sold to customers
- Dpto 3 Sec 306: SECOS PLANTA (86)

**CRITICAL**: Section filtering avoids confusion. Searching "EMPANADA" alone returns BOTH "EMPANADA DE CARNE" (section EMPANADAS, department PRODUCTO DE VENTA) AND "BOLSA PARA EMPANADA" (section DESECHABLES PLANTA). Use section filter to show only the customer-facing products.

### MARCA — Brand (4 records)

Values: EL KIOSCO GOLOSINAS, DIAFANO, ALIMENTOS EL KIOSCO, MULTIEMPRESA

### FAMILIAS / SUBFAMILIAS

Both tables are EMPTY in production. Do not use for categorization.

### ALMACEN — Warehouses (25 total)

| Code | Name | Type |
|------|------|------|
| PQ | Parque | Store (6 POS) |
| PT | Tradicional | Store (7 POS) |
| PSB | Santa Barbara | Store (2 POS) |
| CHP | Chapinero | Store (3 POS) |
| PVV | Chia | Store (2 POS) |
| PRD | DK Colina | Store (1 POS) |
| A2 | Alimentos Planta | Production plant |
| KG | Golosinas Planta | Production plant |
| C | Calidad | Quality control |
| ZP,ZT,ZB,ZV,ZCH,ZHK | Bajas * | Waste/losses |
| COP,CAD,CEV | Consumos * | Internal consumption |

## GOTCHAS — MANDATORY KNOWLEDGE

### G1: STOCKS.FECHAREGUL is NOT reliable

This field does NOT reflect the actual last count date. Many records show 1960-01-01 (system default) even though the article has hundreds of recent REG records in MOVIMENTS.

**The REAL last count date** comes from MOVIMENTS:
```sql
SELECT TOP 1 FECHA
FROM MOVIMENTS
WHERE CODARTICULO = @art AND CODALMACENORIGEN = @alm AND TIPO = 'REG'
ORDER BY FECHA DESC
```

### G2: MOVIMENTS REG fields are NOT what they seem

For TIPO = 'REG':
- `UNIDADES` = stock **AFTER** regularization (the RESULT, not the physical count)
- `STOCK` = stock **BEFORE** regularization

The physical count entered by the user is in `STOCKS.STOCKREGUL`.

A physical count can NEVER be negative. If `UNIDADES < 0` in a REG record, that is the resulting stock, not the count.

### G3: Accounting is NOT managed in ICG

`ALBCOMPRACAB.FACTURADO = 'F'` is IRRELEVANT for inventory. Purchase receipts (albaranes) DO move stock when saved. The FACTURADO field only tracks accounting invoices, which are managed externally.

### G4: Plants send via B2B module, not via TRASPASOSCAB

Plants (A2, KG) send product to stores using series MVY in ALBVENTACAB (B2B remissions, ~250-350/month). Stores are configured as "B2B clients" in the system.

### G5: Sales destock directly from POS

Sales do NOT generate records in MOVIMENTS. The only types in MOVIMENTS are: REG (1.13M), ENV (343K), TMP (5988), CON (2598). All four types are inter-warehouse or regularization movements — never POS sales.

Real sales/consumption lives in TWO complementary tables that MUST be summed:
1. `ALBVENTALIN` — direct sales lines (item sold standalone in the ticket)
2. `ALBVENTACONSUMO` — recipe explosion: when a composite product (combo, plate) is sold, ICG writes child rows here with each ingredient and its `CONSUMO` quantity. The parent line in ALBVENTALIN holds the combo's CODARTICULO, NOT the ingredient's. So these tables do NOT double-count the same article — they are complementary.

To get real consumption of an article, query BOTH and sum by day:
```sql
-- Direct sales
SELECT CAST(cab.FECHA AS DATE) AS dia, SUM(lin.UNIDADESTOTAL) AS unidades
FROM ALBVENTALIN lin
JOIN ALBVENTACAB cab ON lin.NUMSERIE=cab.NUMSERIE AND lin.NUMALBARAN=cab.NUMALBARAN AND lin.N=cab.N
WHERE lin.CODARTICULO=@art AND lin.CODALMACEN=@alm AND cab.FECHA >= @desde
GROUP BY CAST(cab.FECHA AS DATE);

-- Recipe consumption
SELECT CAST(cab.FECHA AS DATE) AS dia, SUM(con.CONSUMO) AS unidades
FROM ALBVENTACONSUMO con
JOIN ALBVENTACAB cab ON con.NUMSERIE=cab.NUMSERIE AND con.NUMALBARAN=cab.NUMALBARAN AND con.N=cab.N
WHERE con.CODARTICULO=@art AND con.CODALMACEN=@alm AND cab.FECHA >= @desde
GROUP BY CAST(cab.FECHA AS DATE);
```

Composite key for joining sales: `(NUMSERIE, NUMALBARAN, N)`. The `N` column is the negocio/empresa flag in ICG multi-empresa setups — required for correct joins.

### G5b: VENTASACUMULADAS is INCOMPLETE — DO NOT USE for total consumption

The pre-aggregated monthly summary `VENTASACUMULADAS` (with `ANYO/MES/CODARTICULO/CODALMACEN/UNIDADES/IMPORTE`) only reflects DIRECT sales (`ALBVENTALIN`). It does NOT include recipe consumption (`ALBVENTACONSUMO`).

Verified for art 344 EMPANADA DE CARNE in PQ, March 2026:
- VENTASACUMULADAS: 12,170 units
- ALBVENTALIN raw: 12,170 units (matches — confirms VENTASACUMULADAS source)
- ALBVENTACONSUMO raw: 17,946 additional units via recipe
- **Real total consumption: 30,116 — VENTASACUMULADAS underreports by 60%**

Any check, alert, or report that uses `VENTASACUMULADAS` for products sold mainly as combo ingredients (empanadas, gaseosas, helados) will see less than half the real movement. Always sum ALBVENTALIN + ALBVENTACONSUMO when accuracy matters. Use VENTASACUMULADAS only for revenue/finance queries where directs-only is the intended scope.

### G5c: Anulaciones are stored in a separate table — already excluded

When a sale is voided, ICG MOVES the rows from `ALBVENTALIN` to `ANUL_ALBVENTALIN` (224 rows total in production — negligible volume). Queries against `ALBVENTALIN` therefore already exclude anulaciones and do NOT need a `WHERE NOT ANULADO` filter. Same pattern applies to ALBVENTACAB → ANUL_ALBVENTACAB.

### G6: Product disambiguation is required

The catalog has semantically similar products:
- Empanada de carne, de pollo, de queso, horneada de carne, horneada de pollo, de lentejas, mini
- Coca Cola 250ml, 1.5L, 2.5L, Zero, Zero 250ml
- Various helados, tamales, etc.

ALWAYS search by LIKE and present options if multiple matches. NEVER assume which product the user means.

### G7: Column name antipatterns (memorize these)

ICG uses NON-OBVIOUS column names. NEVER assume — always use these exact names:

| Wrong (assumed) | Right (real in ICG) | Table |
|-----------------|---------------------|-------|
| `NOMBRE` | `NOMBREALMACEN` | ALMACEN |
| `NOMBRE` | `NOMPROVEEDOR` | PROVEEDORES |
| `SERIE` | `NUMSERIE` | ALBCOMPRACAB, ALBCOMPRALIN, ALBVENTACAB |
| `NUMERO` | `NUMALBARAN` | ALBCOMPRACAB, ALBCOMPRALIN, ALBVENTACAB |
| `FECHA` | `FECHAALBARAN` | ALBCOMPRACAB |
| `UNIDADES` | `UNIDADESTOTAL` | ALBCOMPRALIN |
| `ARTICLES` | `ARTICULOS` | (table name itself) |
| `DESCRIPCIO` | `DESCRIPCION` | ARTICULOS |

EXCEPTION — These tables DO use the simple names:
- `TRASPASOSCAB.SERIE`, `.NUMERO`, `.FECHA` — uses simple names
- `MOVIMENTS.FECHA`, `.UNIDADES`, `.STOCK` — uses simple names (but UNIDADES means different things per TIPO)
- `STOCKS.STOCK`, `.STOCKREGUL` — uses simple names

When in doubt, query INFORMATION_SCHEMA.COLUMNS:
```sql
SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = '<table_name>' ORDER BY ORDINAL_POSITION
```

### G9: ALL READ QUERIES MUST USE WITH (NOLOCK) — MANDATORY

KIOSCO is a busy operational SQL Server. POS terminals, sync processes, and queue
workers hold locks on tables like ALBVENTACAB, ALBVENTALIN, MOVIMENTS, and STOCKS
constantly. A read query without `WITH (NOLOCK)` will frequently get blocked,
returning slow or timing out, and BATO will look "broken" to users even though
the data is fine.

BATOVF only reads — never writes. Dirty reads (uncommitted data, phantom rows)
are acceptable: at worst, BATO sees a stock value 1-2 seconds stale, which is
already true for any cached operational system.

**Pattern**: add `WITH (NOLOCK)` after EVERY table reference, including in JOINs
and subqueries:

```sql
SELECT s.STOCK, a.DESCRIPCION
FROM STOCKS s WITH (NOLOCK)
JOIN ARTICULOS a WITH (NOLOCK) ON s.CODARTICULO = a.CODARTICULO
WHERE s.CODALMACEN = @almacen
```

DO NOT use `SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED` as a session-level
setting — pymssql connections are pooled and the setting can leak across queries.
Per-table `WITH (NOLOCK)` is explicit and self-documenting.

Tables that MUST use NOLOCK in BATOVF queries (because they are write-hot):
- STOCKS, MOVIMENTS, ARTICULOS
- ALBVENTACAB, ALBVENTALIN, ALBVENTACONSUMO
- ALBCOMPRACAB, ALBCOMPRALIN
- TRASPASOSCAB
- PROVEEDORES, ALMACEN (less hot but apply NOLOCK anyway for consistency)
- INVENTARIOS, PEDCOMPRACAB, PEDCOMPRALIN
- INFORMATION_SCHEMA.* — NOLOCK not needed (system catalog views)

If a query in BATOVF is observed to time out or return inconsistently, the FIRST
thing to check is whether every table in the query has `WITH (NOLOCK)`. Missing
hint = blocked by an operational lock = silent failure.

### G10: Pedido↔Albarán cross is one-way and rarely populated

`PEDCOMPRACAB` has `SERIEALBARAN`/`NUMEROALBARAN` columns to cross-reference the
purchase receipt that fulfilled the order. `ALBCOMPRACAB` has NO reverse field —
you cannot go from albarán to pedido by FK.

In production (last 3 months, 1032 orders):
- 8 orders crossed with their albarán (0.8%)
- 948 orders marked TODORECIBIDO='T' but with no SERIEALBARAN — "received without crossing"
- 76 orders pending (NORECIBIDO='T')

**Implication**: PEDCOMPRA tables are NOT a reliable source for "incoming product"
because nobody crosses them. Use `STOCKS.PEDIDO` (the aggregate) only as a hint,
never as ground truth for arrivals.

**Hygiene check feasible**: detect orders older than N days marked TODORECIBIDO='T'
but with no SERIEALBARAN — these are "claimed received but not crossed", which
indicates process drift. Do NOT try the reverse ("albaranes without pedido")
because the schema does not support it.

### G8: VALIDATE EVERY QUERY AGAINST REAL DATA BEFORE COMMITTING

NEVER write a SQL query and assume it works. ALWAYS:
1. Run the exact query against the live KIOSCO database with test parameters
2. Verify it returns expected data shape
3. If it returns empty, confirm whether that's correct (no data) or a bug (wrong column)

A silently failing query (wrong column → exception caught → empty result) causes the LLM to hallucinate "Proveedor A", "Proveedor B" or similar plausible-but-fake data. This violates the deterministic-first principle.

## Query Patterns

All patterns below use `WITH (NOLOCK)` per G9 — mandatory for BATOVF reads.

### Stock of a product in a store
```sql
SELECT s.CODARTICULO, a.DESCRIPCION, s.STOCK, s.STOCKREGUL, s.ENTRANSITO
FROM STOCKS s WITH (NOLOCK)
JOIN ARTICULOS a WITH (NOLOCK) ON s.CODARTICULO = a.CODARTICULO
WHERE s.CODALMACEN = @almacen
AND a.DESCRIPCION LIKE @search_term
```

### Last real count date (from MOVIMENTS, not FECHAREGUL)
```sql
SELECT TOP 1 FECHA, UNIDADES as stock_resultante, STOCK as stock_previo
FROM MOVIMENTS WITH (NOLOCK)
WHERE CODARTICULO = @art AND CODALMACENORIGEN = @alm AND TIPO = 'REG'
ORDER BY FECHA DESC
```

### Pending transfers
```sql
SELECT SERIE, NUMERO, FECHA, CODALMACENORIGEN, CODALMACENDESTINO
FROM TRASPASOSCAB WITH (NOLOCK)
WHERE RECIBIDO = 'F' AND ANULADO = 'F'
AND (CODALMACENORIGEN = @alm OR CODALMACENDESTINO = @alm)
ORDER BY FECHA DESC
```

### Negative stock with cause analysis
```sql
SELECT s.CODARTICULO, a.DESCRIPCION, s.STOCK, s.STOCKREGUL, s.ENTRANSITO
FROM STOCKS s WITH (NOLOCK)
JOIN ARTICULOS a WITH (NOLOCK) ON s.CODARTICULO = a.CODARTICULO
WHERE s.CODALMACEN = @almacen AND s.STOCK < 0
ORDER BY s.STOCK ASC
```
Then for each negative item, determine cause:
- If STOCKREGUL = 0 and STOCK < 0 → "Counted zero, kept selling"
- If STOCKREGUL > 0 and STOCK < 0 → "More exits than entries since last count"
- If ENTRANSITO > 0 → "Product sent but not confirmed received"

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "NOLOCK is optional — most queries work fine without it" | KIOSCO is a write-hot operational database. POS terminals, sync processes, and queue workers hold locks constantly. A query without `WITH (NOLOCK)` will frequently block, time out, or return inconsistently. BATO will look "broken" even though the data is fine. NOLOCK is MANDATORY (G9), not optional. |
| "Column names are consistent across tables — I can guess them" | ICG uses NON-OBVIOUS, inconsistent column names across tables. ALMACEN uses `NOMBREALMACEN` (not NOMBRE). ALBCOMPRACAB uses `NUMSERIE`/`NUMALBARAN`/`FECHAALBARAN` (not SERIE/NUMERO/FECHA). MOVIMENTS uses simple names. Guessing produces "Invalid column name" errors at runtime. ALWAYS query INFORMATION_SCHEMA.COLUMNS first. |
| "VENTASACUMULADAS is the source of truth for sales totals" | WRONG. VENTASACUMULADAS only includes direct sales (ALBVENTALIN). It MISSES recipe consumption (ALBVENTACONSUMO). Verified March 2026: VENTASACUMULADAS reported 12,170 units when the real total was 30,116 — under-reporting by 60%. Always sum BOTH tables for accurate consumption. |

## Red Flags

- SQL query against KIOSCO without `WITH (NOLOCK)` on every table reference (G9 violation).
- Code references `ALMACEN.NOMBRE`, `PROVEEDORES.NOMBRE`, or `ALBCOMPRACAB.SERIE`/`NUMERO`/`FECHA` — these columns DO NOT EXIST.
- Stock count or inventory analysis using `STOCKS.FECHAREGUL` — this field is NOT reliable; use MOVIMENTS REG instead (G1).
- Sales totals computed from `ALBVENTALIN` alone, ignoring `ALBVENTACONSUMO` (G5/G5b).
- Filter by `ALBCOMPRACAB.FACTURADO` to determine inventory state — accounting is NOT in ICG (G3).
- `WHERE NOT ANULADO` filter on ALBVENTALIN — anulaciones are in separate `ANUL_ALBVENTALIN` table (G5c).
- Query returns empty result set — verify it's not a silent column-name failure before assuming "no data."
- Hardcoded list of suppliers/products in code instead of querying ARTICULOS/PROVEEDORES.
- Composite key joins missing the `N` column (multi-empresa flag) for ALBVENTACAB/ALBVENTALIN/ALBVENTACONSUMO.
- Trying to detect "albarán without pedido" — schema does not support this direction (G10).
- Setting `SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED` at session level — leaks across pooled pymssql connections.

## Verification Checklist

- [ ] EVERY table reference in EVERY query has `WITH (NOLOCK)` (including JOINs and subqueries) — G9 mandatory
- [ ] Column names verified against `INFORMATION_SCHEMA.COLUMNS` before writing the query
- [ ] Last count date queried from `MOVIMENTS WHERE TIPO='REG'`, NOT from `STOCKS.FECHAREGUL` (G1)
- [ ] Sales/consumption queries sum BOTH `ALBVENTALIN.UNIDADESTOTAL` AND `ALBVENTACONSUMO.CONSUMO` (G5/G5b)
- [ ] Composite key joins use full `(NUMSERIE, NUMALBARAN, N)` triple — `N` column included
- [ ] No filter on `ALBCOMPRACAB.FACTURADO` for inventory queries (G3 — accounting is external)
- [ ] No `WHERE NOT ANULADO` filter on ALBVENTALIN (G5c — anulaciones in separate table)
- [ ] Product searches use `LIKE` and present multiple matches when ambiguous (G6)
- [ ] Query tested against live KIOSCO database with real parameters BEFORE committing (G8)
- [ ] Empty result sets verified as legitimate (no data) vs silent failure (wrong column)
- [ ] Pedido↔Albarán cross queries go in the supported direction only: pedido → albarán (G10)
- [ ] No `INVENTARIOSZONA` queries (only 6 rows, El Kiosco doesn't use it)
- [ ] No `TEMP_INVENTARIO_*` queries (client-side scratch tables, schema is volatile)
- [ ] All transfer status checks use `'T'`/`'F'` (NOT `'S'`/`'N'`) for RECIBIDO/ANULADO fields
