### ST_CENTERMEAN

{{% bannerNote type="code" %}}
carto.ST_CENTERMEAN(geom)
{{%/ bannerNote %}}

**Description**

Takes a Feature or FeatureCollection as input and returns the mean center.

* `geom`: `GEOMETRY` for which to compute the mean center.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT carto.ST_CENTERMEAN(ST_GEOMFROMTEXT('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'));
-- POINT (25 27.5)
```
