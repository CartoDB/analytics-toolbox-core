### ST_DISJOINT

{{% bannerNote type="code" %}}
carto.ST_DISJOINT(geomA, geomB)
{{%/ bannerNote %}}

**Description**

Returns `true` if the geometries do not “spatially intersect”; i.e., they do not share any space together. Equivalent to `NOT st_intersects(a, b)`.

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
SELECT ST_DISJOINT(lineA, lineB) as disjoint FROM t
-- false
```