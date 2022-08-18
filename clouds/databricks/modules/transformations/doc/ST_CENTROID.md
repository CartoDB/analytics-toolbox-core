### ST_CENTROID

{{% bannerNote type="code" %}}
carto.ST_CENTROID(geom)
{{%/ bannerNote %}}

**Description**

Returns the geometric center of a geometry.

* `geom`: `Geometry` input geom.

**Return type**

`Point`

**Example**

```sql
WITH t AS (
  select ST_MAKEBBOX(0, 0, 2, 2) as geom
)
SELECT ST_ASTEXT(ST_CENTROID(geom)) FROM t
-- POINT (1 1)
```