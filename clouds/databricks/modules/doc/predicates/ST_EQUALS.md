## ST_EQUALS

```sql:signature
carto.ST_EQUALS(geomA, geomB)
```

**Description**

Returns `true` if the given `Geometries` represent the same logical `Geometry`. Directionality is ignored.

* `geomA`: `Geometry` input geom A.
* `geomB`: `Geometry` input geom B.

**Return type**

`Boolean`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_GEOMFROMWKT("LINESTRING (0 0, 2 2)") AS lineA,
  carto.ST_GEOMFROMWKT("LINESTRING (0 0, 1 1, 2 2)") AS lineB
)
SELECT carto.ST_EQUALS(lineA, lineB) FROM t;
-- true
```