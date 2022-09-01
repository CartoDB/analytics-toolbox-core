### ST_ANTIMERIDIANSAFEGEOM

{{% bannerNote type="code" %}}
carto.ST_ANTIMERIDIANSAFEGEOM(geom)
{{%/ bannerNote %}}

**Description**

If _geom_ spans the [antimeridian](https://en.wikipedia.org/wiki/180th_meridian), attempt to convert the `Geometry` into an equivalent form that is “antimeridian-safe” (i.e. the output `Geometry` is covered by `BOX(-180 -90, 180 90)`). In certain circumstances, this method may fail, in which case the input `Geometry` will be returned and an error will be logged.

* `geom`: `Geometry` input geom.

**Return type**

`Geometry`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_MAKEBBOX(178, 0, 190, 5) AS geom
)
SELECT carto.ST_ASTEXT(carto.ST_ANTIMERIDIANSAFEGEOM(geom)) FROM t;
-- MULTIPOLYGON (((-180 0, -180 5, -170 5, -170 0, -180 0)), ((180 5, 180 0, 178 0, 178 5, 180 5)))
```