### ST_IDLSAFEGEOM
{{% bannerNote type="code" %}}
carto.ST_IDLSAFEGEOM(geom)
{{%/ bannerNote %}}

**Description**

Alias of `st_antimeridianSafeGeom`.

* `geom`: `Geometry` input geom.

**Return type**

`Geometry`

**Example**

```sql
WITH t AS (
  select ST_MAKEBBOX(178, 0, 190, 5) as geom
)
SELECT ST_ASTEXT(ST_IDLSAFEGEOM(geom)) as geom FROM t
-- MULTIPOLYGON (((-180 0, -180 5, -170 5, -170 0, -180 0)), ((180 5, 180 0, 178 0, 178 5, 180 5)))

```