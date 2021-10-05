### ST_CENTROID

{{% bannerNote type="code" %}}
transformations.ST_CENTROID(geom)
{{%/ bannerNote %}}

**Description**

Takes any Feature or a FeatureCollection and returns its centroid.

* `geom`: `GEOMETRY` feature to be centered.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT transformations.ST_CENTROID(ST_GEOMFROMTEXT('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'))
-- POINT (25.454545 26.969697)