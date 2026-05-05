## H3_POLYFILL_MODE

```sql:signature
H3_POLYFILL_MODE(geom, resolution, polyfill_mode)
```

**Description**

Returns the H3 cell indexes contained in the given polygon at a requested resolution. Containment is determined by `polyfill_mode`: `center`, `intersects`, or `contains`.

* `center`: keeps the H3 cells whose centers fall inside the input polygon. Faster, does not fully cover the input. Equivalent to [`H3_POLYFILL`](h3#h3_polyfill).
* `intersects`: keeps the H3 cells whose boundaries intersect the input polygon. Fully covers the input.
* `contains`: keeps the H3 cells whose boundaries are fully inside the input polygon. Strictest mode.

**Input parameters**

* `geom`: `SDO_GEOMETRY` **polygon** or **multipolygon** representing the shape to cover. **GeometryCollections** containing polygons or multipolygons are also allowed. Non-polygon geometries (`POINT`, `LINESTRING`, etc.) are silently ignored — no error is raised. Interpreted as WGS84 (EPSG:4326).
* `resolution`: `NUMBER` H3 resolution between 0 and 15 ([H3 resolution table](https://h3geo.org/docs/core-library/restable)).
* `polyfill_mode`: `VARCHAR2` `'center'`, `'intersects'`, or `'contains'`. (Named `polyfill_mode` rather than `mode` because `mode` is a reserved word in Oracle PL/SQL.)

**Return type**

`H3_INDEX_ARRAY` (pipelined; `TABLE OF VARCHAR2(16)`).

NULL inputs, an out-of-range resolution, or an unknown mode produce no rows.

**Example**

```sql
SELECT COLUMN_VALUE AS h3
FROM TABLE(carto.H3_POLYFILL_MODE(
    SDO_UTIL.FROM_WKTGEOMETRY(
        'POLYGON ((-3.71219873428345 40.413365349070865,'
        ' -3.7144088745117 40.40965661286395,'
        ' -3.70659828186035 40.409525904775634,'
        ' -3.71219873428345 40.413365349070865))'
    ),
    9,
    'intersects'
));
-- 89390ca3487ffff
-- 89390ca3497ffff
-- 89390ca34b3ffff
-- 89390cb1b4bffff
-- 89390cb1b4fffff
-- 89390cb1b5bffff
```
