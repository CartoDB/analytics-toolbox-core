### ST_CENTERMEDIAN

{{% bannerNote type="code" %}}
transformations.ST_CENTERMEDIAN(geom)
{{%/ bannerNote %}}

**Description**

Takes a FeatureCollection of points and calculates the median center, algorithimically. The median center is understood as the point that is requires the least total travel from all other points.

* `geom`: `GEOMETRY` feature to be centered.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT transformations.ST_CENTERMEDIAN(ST_GEOMFROMTEXT('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'))
-- POINT (26.384187 19.008815)
```