## ST_INTERSECTION

```sql:signature
ST_INTERSECTION(geomA, geomB)
```

**Description**

Returns the intersection of the input `Geometries`.

* `geomA`: `Geometry` input geom A.
* `geomB`: `Geometry` input geom B.

**Return type**

`Geometry`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_MAKEBBOX(0, 0, 2, 2) AS geomA,
  carto.ST_MAKEBBOX(1, 1, 3, 3) AS geomB
)
SELECT carto.ST_ASTEXT(carto.ST_INTERSECTION(geomA, geomB)) AS intersection FROM t;
-- POLYGON ((1 2, 2 2, 2 1, 1 1, 1 2))
```
