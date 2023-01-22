## ST_CROSSES

```sql:signature
carto.ST_CROSSES(geomA, geomB)
```

**Description**

Returns `true` if the supplied geometries have some, but not all, interior points in common.

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
SELECT carto.ST_CROSSES(lineA, lineB) FROM t;
-- true
```