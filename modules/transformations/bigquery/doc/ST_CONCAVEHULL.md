### ST_CONCAVEHULL

{{% bannerNote type="code" %}}
transformations.ST_CONCAVEHULL(geog, maxEdge FLOAT64, units STRING)
{{%/ bannerNote %}}

**Description**

Takes a set of points and returns a concave hull Polygon or MultiPolygon. Internally, this uses turf-tin to generate geometries. https://turfjs.org/docs/#concave

* `geog`: `ARRAY<GEOGRAPHY>` input points.
* `maxEdge`: `FLOAT64` the length (in 'units') of an edge necessary for part of the hull to become concave. If `NULL`the default value `infinity` is used.
* `units`: `STRING`|`NULL` any of the options supported by turf units: miles, kilometers, degrees or radians. If `NULL`the default value `kilometers` is used.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.transformations.ST_CONCAVEHULL([ST_GEOGPOINT(-75.833, 39.284),ST_GEOGPOINT(-75.6, 39.984),ST_GEOGPOINT(-75.221, 39.125),ST_GEOGPOINT(-75.521, 39.325)], 100, 'kilometers');
-- POLYGON((-75.68 39.24425, -75.527 39.2045 ...
```