### ST_DIMENSION

{{% bannerNote type="code" %}}
carto.ST_DIMENSION(geom)
{{%/ bannerNote %}}

**Description**

Returns the inherent number of dimensions of this `Geometry` object, which must be less than or equal to the coordinate dimension.

* `geom`: `Geometry` input geom.

**Return type**

`Int`

**Example**

```sql
SELECT carto.ST_DIMENSION(carto.ST_GEOMFROMWKT("LINESTRING(0 0, 1 1)"));
-- 1
```