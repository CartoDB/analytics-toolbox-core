## QUADBIN_POLYFILL_TABLE (BETA)

```sql:signature
QUADBIN_POLYFILL_TABLE(input_query, resolution, mode, output_table)
```

**Description**

Creates a table with the quadbin cell indexes contained in the geographies of the input query at a requested resolution. All the attributes except the geography will be included in the output table, clustered by the quadbin column.

Unlike [`QUADBIN_POLYFILL`](quadbin#quadbin_polyfill), which returns the cells as an array, this procedure writes the result directly to a table. This avoids the array size limits that can be reached when polyfilling large geographies at high resolutions.

**Input parameters**

* `input_query`: `STRING` input data to polyfill. It must contain a column `geom` with the shape to cover. Additionally, other columns can be included.
* `resolution`: `INT` level of detail. The value must be between 0 and 26.
* `mode`: `STRING` `<center|contains|intersects>`. Accepted for forward compatibility. The native coverage produced by [`QUADBIN_POLYFILL`](quadbin#quadbin_polyfill) is used regardless of the value; mode-specific containment will be supported in a future release.
* `output_table`: `STRING` qualified name of the output table, e.g. `<my-database>.<my-schema>.<my-output-table>`.

**Output**

The results are stored in the table named `<my-output-table>`, which contains the following columns:

* `quadbin`: `BIGINT` the quadbin cell index.
* The rest of columns included in `input_query` except `geom`.

**Examples**

```sql
CALL carto.QUADBIN_POLYFILL_TABLE(
  'SELECT ST_GEOGFROMTEXT(''POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'') AS geom',
  17, 'intersects',
  '<my-database>.<my-schema>.<my-output-table>'
);
-- The table `<my-database>.<my-schema>.<my-output-table>` will be created
-- with column: quadbin
```

```sql
CALL carto.QUADBIN_POLYFILL_TABLE(
  'SELECT geom, name, value FROM <my-database>.<my-schema>.<my-table>',
  17, 'center',
  '<my-database>.<my-schema>.<my-output-table>'
);
-- The table `<my-database>.<my-schema>.<my-output-table>` will be created
-- with columns: quadbin, name, value
```
