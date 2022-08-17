### ST_ISCOLLECTION

{{% bannerNote type="code" %}}
carto.ST_ISCOLLECTION(geom)
{{%/ bannerNote %}}

**Description**

Returns `true` if _geom_ is a `GeometryCollection`.

* `geom`: `Geometry` input geom.

**Return type**

`Boolean`

**Example**

``` sql
SELECT ST_ISCOLLECTION(ST_GEOMFROMWKT("GEOMETRYCOLLECTION(LINESTRING(1 1, 2 3), POINT(0 4)), LINESTRING EMPTY"))
-- true
```