### ST_CLOSESTPOINT

{{% bannerNote type="code" %}}
carto.ST_CLOSESTPOINT(geomA, geomB)
{{%/ bannerNote %}}

**Description**

Returns the `Point` on _a_ that is closest to _b_. This is the first `Point` of the shortest line.

* `geomA`: `Geometry` input geom A.
* `geomB`: `Geometry` input geom B.

**Return type**

`Point`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_GEOMFROMWKT("LINESTRING (3 1, 1 3)") AS geomA,
  carto.ST_POINT(0, 0) AS geomb
)
SELECT carto.ST_ASTEXT(carto.ST_CLOSESTPOINT(geomA, geomB)) FROM t;
-- POINT (2 2)
```
