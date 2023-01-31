## ST_DIFFERENCE

```sql:signature
carto.ST_DIFFERENCE(geomA, geomB)
```

**Description**

Return the part of geomA that does not intersect with geomB.

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
SELECT carto.ST_ASTEXT(carto.ST_DIFFERENCE(geomA, geomB)) AS difference FROM t;
-- POLYGON ((0 0, 0 2, 1 2, 1 1, 2 1, 2 0, 0 0))
```
