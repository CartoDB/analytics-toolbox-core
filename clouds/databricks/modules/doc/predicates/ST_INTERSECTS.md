## ST_INTERSECTS

```sql:signature
carto.ST_INTERSECTS(geomA, geomB)
```

**Description**

Returns `true` if the geometries spatially intersect in 2D (i.e. share any portion of space). Equivalent to `NOT st_disjoint(a, b)`.

* `geomA`: `Geometry` input geom A.
* `geomB`: `Geometry` input geom B.

**Return type**

`Boolean`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_GEOMFROMWKT("LINESTRING (1 0, 1 2)") AS lineA,
  carto.ST_GEOMFROMWKT("LINESTRING (0 1, 2 1)") AS lineB
)
SELECT carto.ST_INTERSECTS(lineA, lineB) FROM t;
-- true
```