## ST_TOUCHES

```sql:signature
ST_TOUCHES(geomA, geomB)
```

**Description**

Returns `true` if the geometries have at least one `Point` in common, but their interiors do not intersect.

* `geomA`: `Geometry` input geom A.
* `geomB`: `Geometry` input geom B.

**Return type**

`Boolean`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_MAKEBBOX(0, 0, 2, 2) AS geomA,
  carto.ST_GEOMFROMWKT("LINESTRING (3 1, 1 3)") AS geomB
)
SELECT carto.ST_TOUCHES(geomA, geomB) FROM t;
-- true
```
