## ST_EXTERIORRING

```sql:signature
carto.ST_EXTERIORRING(geom)
```

**Description**

Returns a `LineString` representing the exterior ring of the geometry; returns null if the `Geometry` is not a `Polygon`.

* `geom`: `Geometry` input geom.

**Return type**

`LineString`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_MAKEBBOX(0, 0, 1, 1) AS geom
)
SELECT carto.ST_ASTEXT(carto.ST_EXTERIORRING(geom)) FROM t;
-- LINESTRING (0 0, 0 1, 1 1, 1 0, 0 0)
```
