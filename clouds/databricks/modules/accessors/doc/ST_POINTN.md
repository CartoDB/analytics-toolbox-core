### ST_POINTN

{{% bannerNote type="code" %}}
carto.ST_POINTN(geom)
{{%/ bannerNote %}}

**Description**

If _geom_ is a `LineString`, returns the _n_-th vertex of _geom_ as a `Point`. Negative values are counted backwards from the end of the `LineString`. Returns `null` if _geom_ is not a `LineString`.

* `geom`: `Geometry` input geom.
* `n`: `Int` input number of vertex to take.

**Return type**

`Point`

**Example**

``` sql
SELECT ST_ASTEXT(ST_POINTN(ST_GEOMFROMWKT("LINESTRING(1 1, 2 3, 4 4, 3 4)"), 3))
-- POINT (4 4)
```