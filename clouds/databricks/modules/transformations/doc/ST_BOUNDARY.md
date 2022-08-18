### ST_BOUNDARY

{{% bannerNote type="code" %}}
carto.ST_BOUNDARY(geom)
{{%/ bannerNote %}}

**Description**

Returns the boundary, or an empty `Geometry` of appropriate dimension, if _geom_ is empty.

* `geom`: `Geometry` input geom.

**Return type**

`Geometry`

**Example**

```sql
WITH t AS (
  select ST_MAKEBBOX(0, 0, 2, 2) as geom
)
SELECT ST_ASTEXT(ST_BOUNDARY(geom)) FROM t
-- LINESTRING (0 0, 0 2, 2 2, 2 0, 0 0)

```