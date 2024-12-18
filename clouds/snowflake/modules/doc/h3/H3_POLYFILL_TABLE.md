## H3_POLYFILL_TABLE (BETA)

```sql:signature
H3_POLYFILL_TABLE(input_query, resolution, mode, output_table)
```

**Description**

Returns a table with the H3 cell indexes contained in the given polygon at a requested resolution. Containment is determined by the mode: center, intersects, contains. All the attributes except the polygon will be included in the output table, clustered by the h3 column.

* `input_query`: `STRING` input data to polyfill. It must contain a column `geom` with the shape to cover. Additionally, other columns can be included.
* `resolution`: `INT` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).
* `mode`: `STRING` `<center|contains|intersects>`. Optional. Defaults to 'center' mode.
  * `center` The center point of the H3 cell must be within the polygon
  * `contains` The H3 cell must be fully contained within the polygon (least inclusive)
  * `intersects` The H3 cell intersects in any way with the polygon (most inclusive)

Mode `center`:

![](h3_polyfill_mode_center.png)

Mode `intersects`:

![](h3_polyfill_mode_intersects.png)

Mode `contains`:

![](h3_polyfill_mode_contains.png)

**Output**

The results are stored in the table named `<output_table>`, which contains the following columns:

* `h3`: `STRING` the geometry of the considered point.
* The rest of columns included in `input_query` except `geom`.

**Examples**

```sql
CALL carto.H3_POLYFILL_TABLE(
  'SELECT TO_GEOGRAPHY(''POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'') AS geom',
  9, 'intersects',
  '<database>.<schema>.<output_table>'
);
-- The table `<database>.<schema>.<output_table>` will be created
-- with column: h3
```

```sql
CALL carto.H3_POLYFILL_TABLE(
  'SELECT geom, name, value FROM `<database>.<schema>.<table>`',
  9, 'center',
  '<database>.<schema>.<output_table>'
);
-- The table `<database>.<schema>.<output_table>` will be created
-- with columns: h3, name, value
```
