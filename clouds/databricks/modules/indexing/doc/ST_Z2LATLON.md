### ST_Z2LATLON

{{% bannerNote type="code" %}}
carto.ST_Z2LATLON(geom, z2Index)
{{%/ bannerNote %}}

**Description**

Creates a `Z2Index` with the given coordinate Geometry.

* `geom`: `Geometry` input geom.

**Return type**

`Z2Index`

**Example**

```sql
SELECT ST_Z2LATLON(ST_GEOMFROMWKT("LINESTRING (0 0, 1 2)"))
-- SELECT ST_Z2LATLON(ST_GEOMFROMWKT("LINESTRING (0 0, 1 2)"))
```
