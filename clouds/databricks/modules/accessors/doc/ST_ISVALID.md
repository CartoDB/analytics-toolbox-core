### ST_ISVALID

{{% bannerNote type="code" %}}
carto.ST_ISVALID(geom)
{{%/ bannerNote %}}

**Description**

Returns `true` if the `Geometry` is topologically valid according to the OGC SFS specification.

* `geom`: `Geometry` input geom.

**Return type**

`Boolean`

**Example**

``` sql
SELECT ST_ISVALID(ST_GEOMFROMWKT("POLYGON((0 0, 1 1, 1 2, 1 1, 0 0))"))
-- false
```