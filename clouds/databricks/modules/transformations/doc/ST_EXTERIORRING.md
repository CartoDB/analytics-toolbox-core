### ST_EXTERIORRING

{{% bannerNote type="code" %}}
carto.ST_EXTERIORRING(geom)
{{%/ bannerNote %}}

**Description**

Returns a `LineString` representing the exterior ring of the geometry; returns null if the `Geometry` is not a `Polygon`.

* `geom`: `Geometry` input geom.

**Return type**

`LineString`

**Example**

```sql
WITH t AS (
  select ST_MAKEBBOX(0, 0, 1, 1) as geom
)
SELECT ST_ASTEXT(ST_EXTERIORRING(geom)) FROM t
-- LINESTRING (0 0, 0 1, 1 1, 1 0, 0 0)
```