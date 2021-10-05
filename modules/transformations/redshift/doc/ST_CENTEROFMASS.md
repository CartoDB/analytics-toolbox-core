### ST_CENTEROFMASS

{{% bannerNote type="code" %}}
transformations.ST_CENTEROFMASS(geom)
{{%/ bannerNote %}}

**Description**

Takes any Feature or a FeatureCollection and returns its center of mass using this formula: Centroid of Polygon.

* `geom`: `GEOMETRY` feature to be centered.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT transformations.ST_CENTEROFMASS(ST_GEOMFROMTEXT('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'))
-- POINT (25.454545 26.969697)
```