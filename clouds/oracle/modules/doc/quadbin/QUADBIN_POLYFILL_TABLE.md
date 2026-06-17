## QUADBIN_POLYFILL_TABLE (BETA)

```sql:signature
QUADBIN_POLYFILL_TABLE(input_query, resolution, polyfill_mode, output_table)
```

**Description**

Materializes the quadbin polyfill of every row in `input_query` into a new table. The resulting table joins each input row with the polyfill cells of its `geom` column, preserving every other column the input query exposes.

This is the procedural form of [QUADBIN_POLYFILL](quadbin#quadbin_polyfill). Unlike the function, which returns the cells as a collection, this procedure writes the result directly to a table, avoiding the collection/array size limits that can be reached when polyfilling large geographies at high resolutions.

Invalid `polyfill_mode`, `resolution` outside `0..26`, or `NULL` arguments cause the procedure to silently no-op (output table is not created).

**Input parameters**

* `input_query`: `VARCHAR2` SELECT statement; must expose a column named `geom` of type `SDO_GEOMETRY`. Any other columns are passed through to the output table.
* `resolution`: `NUMBER` quadbin resolution (level of detail) between 0 and 26.
* `polyfill_mode`: `VARCHAR2` `'center'`, `'intersects'`, or `'contains'`. Accepted for forward compatibility. (Named `polyfill_mode` rather than `mode` because `mode` is a reserved word in Oracle PL/SQL.) The native coverage produced by [QUADBIN_POLYFILL](quadbin#quadbin_polyfill) is used regardless of the value; mode-specific containment will be supported in a future release.
* `output_table`: `VARCHAR2` fully-qualified name of the table to create. Sanitized via `DBMS_ASSERT.QUALIFIED_SQL_NAME`.

**Return type**

None — creates the named table as a side effect. The output table has columns:

* `quadbin` `NUMBER` — the polyfill cell.
* every other column produced by `input_query`.

**Example**

```sql
BEGIN
    carto.QUADBIN_POLYFILL_TABLE(
        'SELECT SDO_UTIL.FROM_WKTGEOMETRY(''POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'') AS geom FROM DUAL',
        17,
        'intersects',
        '<my-schema>.<my-output-table>'
    );
END;
/

SELECT quadbin FROM <my-schema>.<my-output-table> ORDER BY quadbin;
-- 5265786693153193983
-- 5265786693163941887
-- 5265786693164204031
-- 5265786693164466175
-- 5265786693164728319
-- 5265786693165514751
```
