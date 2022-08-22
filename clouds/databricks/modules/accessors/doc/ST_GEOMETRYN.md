### ST_GEOMETRYN

{{% bannerNote type="code" %}}
carto.ST_GEOMETRYN(geom, n)
{{%/ bannerNote %}}

**Description**

Returns the _n_-th `Geometry` (1-based index) of _geom_ if the `Geometry` is a `GeometryCollection`, or _geom_ if it is not.

* `geom`: `Geometry` input geom.
* `n`: `Int` input number of geom to take.

**Return type**

`Geometry`

**Example**

``` sql
SELECT carto.ST_ASTEXT(carto.ST_GEOMETRYN(carto.ST_GEOMFROMWKT("GEOMETRYCOLLECTION(LINESTRING(1 1, 2 3), POINT(0 4), LINESTRING EMPTY)"), 2));
-- POINT (0 4)
```