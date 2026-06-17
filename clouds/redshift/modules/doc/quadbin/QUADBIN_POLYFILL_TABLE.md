## QUADBIN_POLYFILL_TABLE (BETA)

```sql:signature
QUADBIN_POLYFILL_TABLE(input_query, resolution, mode, output_table)
```

**Description**

Creates a table with the quadbin cell indexes contained in the geographies of the input query at a requested resolution. All the attributes except the geography are included in the output table.

Unlike [`QUADBIN_POLYFILL`](quadbin#quadbin_polyfill), which returns the cells as an array, this procedure writes the result directly to a table.

**Input parameters**

* `input_query`: `VARCHAR(MAX)` SELECT statement to polyfill. It must contain a column `geom` with the shape to cover. Additionally, other columns can be included.
* `resolution`: `INT` level of detail. The value must be between 0 and 26.
* `mode`: `VARCHAR(MAX)` `<center|contains|intersects>`. Accepted for forward compatibility. The native coverage produced by [`QUADBIN_POLYFILL`](quadbin#quadbin_polyfill) is used regardless of the value; mode-specific containment will be supported in a future release.
* `output_table`: `VARCHAR(MAX)` qualified name of the output table, e.g. `<my-schema>.<my-output-table>`.

**Return type**

None — creates the named table as a side effect. The output table has columns:

* `quadbin`: `BIGINT` the quadbin cell index.
* The rest of columns included in `input_query` except `geom`.

**Note**

`QUADBIN_POLYFILL` is resolved through the AT Gateway, so the polyfill of each input geometry is bounded by the gateway response size. Very large single-geometry polyfills at high resolutions may exceed that bound.

**Example**

```sql
CALL carto.QUADBIN_POLYFILL_TABLE(
  'SELECT geom FROM <my-schema>.<my-table>',
  11, 'center',
  '<my-schema>.<my-output-table>'
);
-- The table `<my-schema>.<my-output-table>` will be created
-- with column: quadbin
```
