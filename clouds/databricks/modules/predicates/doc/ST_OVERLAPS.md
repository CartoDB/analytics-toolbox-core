### ST_OVERLAPS

{{% bannerNote type="code" %}}
carto.ST_OVERLAPS(geomA, geomB)
{{%/ bannerNote %}}

**Description**

Returns `true` if the `Geometries` have some but not all points in common, are of the same dimension, and the intersection of the interiors of the two geometries has the same dimension as the geometries themselves.

* `geomA`: `Geometry` input geom A.
* `geomB`: `Geometry` input geom B.

**Return type**

`Boolean`

**Example**

```sql
WITH t AS (
  select ST_MAKEBBOX(0, 0, 2, 2) as geomA,
  ST_MAKEBBOX(1, 1, 3, 3) as geomB
)
SELECT ST_OVERLAPS(geomA, geomB) FROM t
-- true
```