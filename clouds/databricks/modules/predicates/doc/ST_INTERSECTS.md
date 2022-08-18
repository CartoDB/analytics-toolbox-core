### ST_INTERSECTS

{{% bannerNote type="code" %}}
carto.ST_INTERSECTS(geomA, geomB)
{{%/ bannerNote %}}

**Description**

Returns `true` if the geometries spatially intersect in 2D (i.e. share any portion of space). Equivalent to `NOT st_disjoint(a, b)`.

* `geomA`: `Geometry` input geom A.
* `geomB`: `Geometry` input geom B.

**Return type**

`Boolean`

**Example**

```sql
WITH t AS (
  select ST_GEOMFROMWKT("LINESTRING (1 0, 1 2)") as lineA,
  ST_GEOMFROMWKT("LINESTRING (0 1, 2 1)") as lineB
)
SELECT ST_INTERSECTS(lineA, lineB) FROM t
-- true
```