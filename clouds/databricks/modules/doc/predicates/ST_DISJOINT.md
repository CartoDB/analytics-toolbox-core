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
  SELECT carto.ST_GEOMFROMWKT("LINESTRING (1 0, 1 2)") AS lineA,
  carto.ST_GEOMFROMWKT("LINESTRING (0 1, 2 1)") AS lineB
)
SELECT carto.ST_DISJOINT(lineA, lineB) AS disjoint FROM t;
-- false
```