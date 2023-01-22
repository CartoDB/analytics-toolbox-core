## ST_CONTAINS

```sql:signature
carto.ST_CONTAINS(geomA, geomB)
```

**Description**

Returns `true` if and only if no points of _b_ lie in the exterior of _a_, and at least one `Point` of the interior of _b_ lies in the interior of _a_.

* `geomA`: `Geometry` input geom A.
* `geomB`: `Geometry` input geom B.

**Return type**

`Boolean`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_MAKEBBOX(0, 0, 2, 2) AS geom,
  carto.ST_MAKEPOINT(1, 1) as Point
)
SELECT carto.ST_CONTAINS(geom, point) FROM t;
-- true
```