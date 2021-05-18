### ST_LINE_INTERPOLATE_POINT

[Signature 1](#signature-1)
[Signature 2](#signature-2)

#### Signature 1

{{% bannerNote type="code" %}}
transformations.ST_LINE_INTERPOLATE_POINT(geog, distance)
{{%/ bannerNote %}}

**Description**

Takes a LineString and returns a Point at a specified distance along the line. https://turfjs.org/docs/#along

* `geog`: `GEOGRAPHY` input line.
* `distance`: `DOUBLE` distance along the line.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT sfcarto.transformations.ST_LINE_INTERPOLATE_POINT(TO_GEOGRAPHY('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'), 250);
-- { "coordinates": [ -75.5956489839589, 19.273615818183988 ], "type": "Point" } 
```

#### Signature 2

{{% bannerNote type="code" %}}
transformations.ST_LINE_INTERPOLATE_POINT(geog, distance, units)
{{%/ bannerNote %}}

**Description**

Takes a LineString and returns a Point at a specified distance along the line. https://turfjs.org/docs/#along

* `geog`: `GEOGRAPHY` input line.
* `distance`: `DOUBLE` distance along the line.
* `units`: `STRING`|`NULL` any of the options supported by turf units: miles, kilometers, degrees and radians. If `NULL`the default value `kilometers` is used.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT sfcarto.transformations.ST_LINE_INTERPOLATE_POINT(TO_GEOGRAPHY('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'), 250, 'miles');
-- { "coordinates": [ -74.297592068938, 19.449810710315635 ], "type": "Point" } 
```