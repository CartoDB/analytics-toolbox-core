### ST_CONCAVEHULL

{{% bannerNote type="code" %}}
carto.ST_CONCAVEHULL(geog, maxEdge, units)
{{%/ bannerNote %}}

**Description**

Takes a set of points and returns a concave hull Polygon or MultiPolygon.

* `geog`: `ARRAY<GEOGRAPHY>` input points.
* `maxEdge`: `FLOAT64`|`NULL` the length (in 'units') of an edge necessary for part of the hull to become concave. If `NULL`the default value `infinity` is used.
* `units`: `STRING`|`NULL` units of length, the supported options are: miles, kilometers, degrees or radians. If `NULL`the default value `kilometers` is used.

**Return type**

`GEOGRAPHY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

``` sql
SELECT carto-os.carto.ST_CONCAVEHULL([ST_GEOGPOINT(-75.833, 39.284),ST_GEOGPOINT(-75.6, 39.984),ST_GEOGPOINT(-75.221, 39.125),ST_GEOGPOINT(-75.521, 39.325)], 100, 'kilometers');
-- POLYGON((-75.68 39.24425, -75.527 39.2045 ...
```