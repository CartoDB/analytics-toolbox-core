### ST_NUMGEOMETRIES

{{% bannerNote type="code" %}}
carto.ST_NUMGEOMETRIES(geom)
{{%/ bannerNote %}}

**Description**

If _geom_ is a `GeometryCollection`, returns the number of geometries. For single geometries, returns `1`,

* `geom`: `Geometry` input geom.

**Return type**

`Int`

**Example**

``` sql
SELECT ST_NUMGEOMETRIES(ST_GEOMFROMWKT("GEOMETRYCOLLECTION(LINESTRING(1 1, 2 3), POINT(0 4), LINESTRING EMPTY)"))
-- 3
```