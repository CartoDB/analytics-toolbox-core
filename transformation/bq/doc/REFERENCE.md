## transformation

<div class="badge core"></div>

### ST_BEZIERSPLINE

{{% bannerNote type="code" %}}
transformation.ST_BEZIERSPLINE(geog, sharpness)
{{%/ bannerNote %}}

**Description**

Takes a line and returns a curved version by applying a Bezier spline algorithm. https://turfjs.org/docs/#bezierSpline

* `geog`: `GEOGRAPHY` input LineString.
* `sharpness`: `FLOAT64`|`NULL` a measure of how curvy the path should be between splines. If `NULL` the default value 0.85 is used.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.transformation.ST_BEZIERSPLINE(ST_GEOGFROMTEXT("LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)"),0.9);
-- LINESTRING(-76.091308 18.427501, -76.0916216712943 ... 
```

### ST_BUFFER

{{% bannerNote type="code" %}}
transformation.ST_BUFFER(geog, radius, units, steps)
{{%/ bannerNote %}}

**Description**

Calculates a Geography buffer for input features for a given radius. Units supported are miles, kilometers, and degrees. https://turfjs.org/docs/#buffer

* `geog`: `GEOGRAPHY` input to be buffered.
* `radius`: `FLOAT64` distance to draw the buffer (negative values are allowed).
* `units`: `STRING`|`NULL` any of the options supported by turf units: miles, kilometers, and degrees. If `NULL`the default value kilometers is used.
* `steps`: `INT64`|`NULL` number of steps. If `NULL` the default value 8 is used.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.transformation.ST_BUFFER(ST_GEOGPOINT(-74.00, 40.7128), 1, "kilometers", 10);
-- POLYGON((-73.9881354374691 40.7127993926494 ... 
```

### ST_DESTINATION

{{% bannerNote type="code" %}}
transformation.ST_DESTINATION(startPoint, distance, bearing, units)
{{%/ bannerNote %}}

**Description**

Takes a Point and calculates the location of a destination point given a distance in degrees, radians, miles, or kilometers; and bearing in degrees. This uses the Haversine formula to account for global curvature. https://turfjs.org/docs/#destination

* `origin`: `GEOGRAPHY` starting point.
* `distance`: `FLOAT64` distance from the origin point.
* `bearing`: `FLOAT64` ranging from -180 to 180.
* `units`: `STRING`|`NULL` any of the options supported by turf units: miles, kilometers, degrees or radians. If `NULL`the default value kilometers is used.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.transformation.ST_DESTINATION(ST_GEOGPOINT(-3.70325,40.4167), 10, 45, "miles");
-- POINT(-3.56862505487045 40.5189626777536)
```

### ST_GREATCIRCLE

{{% bannerNote type="code" %}}
transformation.ST_GREATCIRCLE(startPoint, endPoint, npoints)
{{%/ bannerNote %}}

**Description**

Calculate great circles routes as LineString or MultiLineString. If the start and end points span the antimeridian, the resulting feature will be split into a MultiLineString. https://turfjs.org/docs/#greatCircle

* `startPoint`: `GEOGRAPHY` source point feature.
* `endPoint`: `GEOGRAPHY` destination point feature.
* `npoints`: `INT64`|`NULL` number of points. If `NULL` the default value 100 is used.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.transformation.ST_GREATCIRCLE(ST_GEOGPOINT(-3.70325,40.4167),ST_GEOGPOINT(-73.9385,40.6643), 20);
-- LINESTRING(-3.70325 40.4167 ... 
```

### ST_MAKEELLIPSE

{{% bannerNote type="code" %}}
transformation.ST_MAKEELLIPSE(geog, xSemiAxis, ySemiAxis, angle, units, steps)
{{%/ bannerNote %}}

**Description**

Takes a Point and calculates the ellipse polygon given two semi-axes expressed in variable units and steps for precision. https://github.com/Turfjs/turf/tree/master/packages/turf-ellipse

* `center`: `GEOGRAPHY` center point.
* `xSemiAxis`: `FLOAT64` semi (major) axis of the ellipse along the x-axis.
* `ySemiAxis`: `FLOAT64` semi (minor) axis of the ellipse along the y-axis.
* `angle`: `FLOAT64`|`NULL` angle of rotation (along the vertical axis), from North in decimal degrees, negative clockwise. If `NULL` the default value 0 is used.
* `units`: `STRING`|`NULL` any of the options supported by turf units: miles, kilometers, and degrees. If `NULL`the default value kilometers is used.
* `steps`: `INT64`|`NULL` number of steps. If `NULL` the default value 64 is used.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.transformation.ST_MAKEELLIPSE(ST_GEOGPOINT(-73.9385,40.6643), 5, 3, -30, "miles", 80);
-- POLYGON((-73.8558575786687 40.7004828957859 ... 
```

### VERSION

{{% bannerNote type="code" %}}
transformation.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the transformation module.

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.transformation.VERSION();
-- 1.0.0
```
