### ST_CONVEXHULL

{{% bannerNote type="code" %}}
carto.ST_CONVEXHULL(geom)
{{%/ bannerNote %}}

**Description**

Aggregate function. The convex hull of a `Geometry` represents the minimum convex `Geometry` that encloses all geometries _geom_ in the aggregated rows.

* `geom`: `Geometry` input geom.

**Return type**

`Geometry`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_GEOMFROMWKT('GEOMETRYCOLLECTION(LINESTRING(1 1, 3 5),POLYGON((-1 -1, -1 -5, -5 -5, -5 -1, -1 -1)))') AS geom
)
SELECT carto.ST_ASTEXT(carto.ST_CONVEXHULL(geom)) FROM t;
-- POLYGON ((-5 -5, -5 -1, 3 5, -1 -5, -5 -5))
```
