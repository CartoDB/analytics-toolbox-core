## ST_BOUNDARY

```sql:signature
carto.ST_BOUNDARY(geom)
```

**Description**

Returns the boundary, or an empty `Geometry` of appropriate dimension, if _geom_ is empty.

* `geom`: `Geometry` input geom.

**Return type**

`Geometry`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_MAKEBBOX(0, 0, 2, 2) AS geom
)
SELECT carto.ST_ASTEXT(carto.ST_BOUNDARY(geom)) FROM t;
-- LINESTRING (0 0, 0 2, 2 2, 2 0, 0 0)
```
