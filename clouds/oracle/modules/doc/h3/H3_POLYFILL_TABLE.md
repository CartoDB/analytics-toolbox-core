## H3_POLYFILL_TABLE

```sql:signature
H3_POLYFILL_TABLE(input_query, resolution, mode, output_table)
```

**Description**

Materializes the H3 polyfill of every row in `input_query` into a new table. The resulting table joins each input row with the polyfill cells of its `geom` column, preserving every other column the input query exposes.

This is the procedural form of [H3_POLYFILL](h3#h3_polyfill) and supports the two coverage modes Oracle provides natively:

* `center`: keeps the H3 cells whose centers fall inside the input polygon. Faster, does not fully cover the input.
* `intersects`: keeps the H3 cells whose boundaries intersect the input polygon. Fully covers the input.

The procedure raises `ORA-20001` for an invalid `mode` and `ORA-20002` for a resolution outside `0..15`.

**Input parameters**

* `input_query`: `VARCHAR2` SELECT statement; must expose a column named `geom` of type `SDO_GEOMETRY`. Any other columns are passed through to the output table.
* `resolution`: `NUMBER` H3 resolution between 0 and 15 ([H3 resolution table](https://h3geo.org/docs/core-library/restable)).
* `mode`: `VARCHAR2` `'center'` or `'intersects'`.
* `output_table`: `VARCHAR2` fully-qualified name of the table to create. Sanitized via `DBMS_ASSERT.QUALIFIED_SQL_NAME`.

**Return type**

None — creates the named table as a side effect. The output table has columns:

* `h3` `VARCHAR2(16)` — the polyfill cell.
* every other column produced by `input_query`.

**Example**

```sql
BEGIN
    carto.H3_POLYFILL_TABLE(
        'SELECT SDO_UTIL.FROM_WKTGEOMETRY(''POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'') AS geom FROM DUAL',
        9,
        'intersects',
        'MY_SCHEMA.POLYFILL_OUT'
    );
END;
/

SELECT h3 FROM MY_SCHEMA.POLYFILL_OUT ORDER BY h3;
-- 89390ca3487ffff
-- 89390ca3497ffff
-- 89390ca34b3ffff
-- 89390cb1b4bffff
-- 89390cb1b4fffff
-- 89390cb1b5bffff
```
