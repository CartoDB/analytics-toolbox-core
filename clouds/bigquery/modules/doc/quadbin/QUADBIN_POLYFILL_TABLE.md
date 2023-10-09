## QUADBIN_POLYFILL_TABLE (BETA)

```sql:signature
QUADBIN_POLYFILL_TABLE(input_query, resolution, mode, output_table)
```

**Description**

Returns a table with the quadbin cell indexes contained in the given geography at a given level of detail. Containment is determined by the mode: center, intersects, contains. All the attributes except the geography will be included in the output table, clustered by the quadbin column.

* `input_query`: `STRING` input data to polyfill. It must contain a column `geom` with the shape to cover. Additionally, other columns can be included.
* `resolution`: `INT64` level of detail. The value must be between 0 and 26.
* `mode`: `STRING`
  * `center` returns the indexes of the quadbin cells which centers intersect the input geography (polygon). The resulting quadbin set does not fully cover the input geography, however, this is **significantly faster** that the other modes. This mode is not compatible with points or lines. Equivalent to [`QUADBIN_POLYFILL`](quadbin#quadbin_polyfill).
  * `intersects` returns the indexes of the quadbin cells that intersect the input geography. The resulting quadbin set will completely cover the input geography (point, line, polygon).
  * `contains` returns the indexes of the quadbin cells that are entirely contained inside the input geography (polygon). This mode is not compatible with points or lines.
* `output_table`: `STRING` name of the output table to store the results of the polyfill.

Mode `center`:

![](quadbin_polyfill_mode_center.png)

Mode `intersects`:

![](quadbin_polyfill_mode_intersects.png)

Mode `contains`:

![](quadbin_polyfill_mode_contains.png)

**Output**

The results are stored in the table named `<output_table>`, which contains the following columns:

* `quadbin`: `INT64` the geometry of the considered point.
* The rest of columns included in `input_query` except `geom`.

**Examples**

```sql
CALL carto.QUADBIN_POLYFILL_TABLE(
  "SELECT ST_GEOGFROMTEXT('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))') AS geom",
  12, 'intersects',
  '<project>.<dataset>.<output_table>'
);
-- The table `<project>.<dataset>.<output_table>` will be created
-- with column: quadbin
```

```sql
CALL carto.QUADBIN_POLYFILL_TABLE(
  'SELECT geom, name, value FROM `<project>.<dataset>.<table>`',
  12, 'center',
  '<project>.<dataset>.<output_table>'
);
-- The table `<project>.<dataset>.<output_table>` will be created
-- with columns: quadbin, name, value
```
