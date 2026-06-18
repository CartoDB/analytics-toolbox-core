## H3_POLYFILL_TABLE

```sql:signature
H3_POLYFILL_TABLE(input_query, resolution, mode, output_table)
```

**Description**

Creates a table with the H3 cell indexes contained in the geographies of the input query at a requested resolution. Containment is determined by the mode: center, intersects, contains. All the attributes except the geography will be included in the output table.

Unlike [`H3_POLYFILL`](h3#h3_polyfill), which returns the cells as an array, this procedure writes the result directly to a table. This avoids the array size limits that can be reached when polyfilling large geographies at high resolutions.

**Input parameters**

* `input_query`: `TEXT` input data to polyfill. It must contain a column `geom` with the shape to cover. Additionally, other columns can be included.
* `resolution`: `INT` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).
* `mode`: `TEXT` `<center|contains|intersects>`.
  * `center`: The center point of the H3 cell must be within the polygon.
  * `contains`: The H3 cell must be fully contained within the polygon (least inclusive).
  * `intersects`: The H3 cell intersects in any way with the polygon (most inclusive).
* `output_table`: `TEXT` qualified name of the output table, e.g. `<my-schema>.<my-output-table>`.

**Output**

The results are stored in the table named `<my-output-table>`, which contains the following columns:

* `h3`: `VARCHAR` the H3 cell index.
* The rest of columns included in `input_query` except `geom`.

**Examples**

```sql
CALL carto.H3_POLYFILL_TABLE(
  'SELECT ST_GEOMFROMTEXT(''POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'') AS geom',
  9, 'intersects',
  '<my-schema>.<my-output-table>'
);
-- The table `<my-schema>.<my-output-table>` will be created
-- with column: h3
```

```sql
CALL carto.H3_POLYFILL_TABLE(
  'SELECT geom, name, value FROM <my-schema>.<my-table>',
  9, 'center',
  '<my-schema>.<my-output-table>'
);
-- The table `<my-schema>.<my-output-table>` will be created
-- with columns: h3, name, value
```
