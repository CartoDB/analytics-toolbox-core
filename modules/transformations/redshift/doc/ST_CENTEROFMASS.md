### ST_CENTEROFMASS

{{% bannerNote type="code" %}}
carto.ST_CENTEROFMASS(geom)
{{%/ bannerNote %}}

**Description**

Takes any Feature or a FeatureCollection and returns its center of mass using this formula: Centroid of Polygon. It's equivalent to the centroid.

* `geom`: `GEOMETRY` feature to be centered.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT carto.ST_CENTEROFMASS(ST_GEOMFROMTEXT('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'));
-- POINT (25.4545454545 26.9696969697)
```