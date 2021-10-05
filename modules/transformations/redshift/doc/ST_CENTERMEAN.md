### ST_CENTERMEAN

{{% bannerNote type="code" %}}
transformations.ST_CENTERMEAN(geom)
{{%/ bannerNote %}}

**Description**

Takes a Feature or FeatureCollection and returns the mean center.

* `geom`: `GEOMETRY` feature to be centered.


**Return type**

`GEOMETRY`

**Example**

```sql
SELECT transformations.ST_CENTERMEAN(ST_GEOMFROMTEXT('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'))
-- POINT (26 24)
```