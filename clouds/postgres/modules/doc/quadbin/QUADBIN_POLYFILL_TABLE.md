## QUADBIN_POLYFILL_TABLE

```sql:signature
QUADBIN_POLYFILL_TABLE(input_query, resolution, mode, output_table)
```

**Description**

Creates a table with the quadbin cell indexes contained in the geographies of the input query at a requested resolution. Containment is determined by the mode: center, intersects, contains. All the attributes except the geography will be included in the output table.

Unlike [`QUADBIN_POLYFILL`](quadbin#quadbin_polyfill), which returns the cells as an array, this procedure writes the result directly to a table. This avoids the array size limits that can be reached when polyfilling large geographies at high resolutions.

**Input parameters**

* `input_query`: `TEXT` input data to polyfill. It must contain a column `geom` with the shape to cover. Additionally, other columns can be included.
* `resolution`: `INT` level of detail. The value must be between 0 and 26.
* `mode`: `TEXT`.
  * `center` returns the indexes of the quadbin cells which centers intersect the input geography (polygon). The resulting quadbin set does not fully cover the input geography, however, this is **significantly faster** than the other modes. This mode is not compatible with points or lines. Equivalent to [`QUADBIN_POLYFILL`](quadbin#quadbin_polyfill).
  * `intersects` returns the indexes of the quadbin cells that intersect the input geography. The resulting quadbin set will completely cover the input geography (point, line, polygon).
  * `contains` returns the indexes of the quadbin cells that are entirely contained inside the input geography (polygon). This mode is not compatible with points or lines.
* `output_table`: `TEXT` qualified name of the output table, e.g. `<my-schema>.<my-output-table>`.

**Output**

The results are stored in the table named `<my-output-table>`, which contains the following columns:

* `quadbin`: `BIGINT` the quadbin cell index.
* The rest of columns included in `input_query` except `geom`.

**Examples**

```sql
CALL carto.QUADBIN_POLYFILL_TABLE(
  'SELECT ST_GEOMFROMTEXT(''POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'') AS geom',
  17, 'intersects',
  '<my-schema>.<my-output-table>'
);
-- The table `<my-schema>.<my-output-table>` will be created
-- with column: quadbin
```

```sql
CALL carto.QUADBIN_POLYFILL_TABLE(
  'SELECT geom, name, value FROM <my-schema>.<my-table>',
  17, 'center',
  '<my-schema>.<my-output-table>'
);
-- The table `<my-schema>.<my-output-table>` will be created
-- with columns: quadbin, name, value
```
