### ST_CLOSESTPOINT

{{% bannerNote type="code" %}}
carto.ST_CLOSESTPOINT(geoA, geomB)
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
  select ST_GEOMFROMWKT("LINESTRING (3 1, 1 3)") as geomA,
  ST_POINT(0, 0) as geomb
)
SELECT ST_ASTEXT(ST_CLOSESTPOINT(geomA, geomB)) FROM t
-- POINT (2 2)
```