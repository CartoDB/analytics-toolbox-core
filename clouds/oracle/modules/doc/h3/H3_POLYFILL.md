## H3_POLYFILL

```sql:signature
H3_POLYFILL(geom, resolution)
```

**Description**

Returns the H3 cell indexes whose centers are contained in the given polygon at the requested resolution (equivalent to `mode = 'center'` in other CARTO Analytics Toolbox implementations). The resulting H3 set does not fully cover the input geometry but is significantly faster than coverage-based modes.

For coverage modes (`center` and `intersects`) over an entire query, use the [H3_POLYFILL_TABLE](h3#h3_polyfill_table) procedure.

Returns no rows on error (invalid input, resolution out of bounds, or non-polygon geometry).

**Input parameters**

* `geom`: `SDO_GEOMETRY` polygon or multipolygon to cover (WGS84 / SRID 4326).
* `resolution`: `NUMBER` level of detail. The value must be between 0 and 15 ([H3 resolution table](https://h3geo.org/docs/core-library/restable)).

**Return type**

`H3_INDEX_ARRAY` (pipelined; `TABLE OF VARCHAR2(16)`).

**Examples**

Single-row polyfill:

```sql
SELECT COLUMN_VALUE AS h3
FROM TABLE(carto.H3_POLYFILL(
    SDO_UTIL.FROM_WKTGEOMETRY(
        'POLYGON ((-3.71219873428345 40.413365349070865,'
        ' -3.7144088745117 40.40965661286395,'
        ' -3.70659828186035 40.409525904775634,'
        ' -3.71219873428345 40.413365349070865))'
    ),
    9
));
-- 89390cb1b4bffff
```

Polyfill applied across a table of geometries (lateral join via comma + `TABLE(...)`):

```sql
SELECT t.h3
  FROM <my-schema>.<my-table> g,
       TABLE(carto.H3_POLYFILL(g.geom, 9)) t;
```
