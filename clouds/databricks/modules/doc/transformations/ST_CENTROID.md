## ST_CENTROID

```sql:signature
carto.ST_CENTROID(geom)
```

**Description**

Returns the geometric center of a geometry.

* `geom`: `Geometry` input geom.

**Return type**

`Point`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_MAKEBBOX(0, 0, 2, 2) AS geom
)
SELECT carto.ST_ASTEXT(carto.ST_CENTROID(geom)) FROM t;
-- POINT (1 1)
```
