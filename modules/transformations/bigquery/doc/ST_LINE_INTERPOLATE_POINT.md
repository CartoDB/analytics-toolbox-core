### ST_LINE_INTERPOLATE_POINT

{{% bannerNote type="code" %}}
transformations.ST_LINE_INTERPOLATE_POINT(geog, distance, units)
{{%/ bannerNote %}}

**Description**

Takes a LineString and returns a Point at a specified distance along the line. https://turfjs.org/docs/#along

* `geog`: `GEOGRAPHY` input line.
* `distance`: `FLOAT64` distance along the line.
* `units`: `STRING`|`NULL` any of the options supported by turf units: miles, kilometers, degrees and radians. If `NULL`the default value `kilometers` is used.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.transformations.ST_LINE_INTERPOLATE_POINT(ST_GEOGFROMTEXT("LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)"), 250, 'miles');
-- POINT(-74.297592068938 19.4498107103156) 
```