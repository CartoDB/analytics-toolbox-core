## constructors

<div class="badge core"></div>

### ST_BEZIERSPLINE

{{% bannerNote type="code" %}}
constructors.ST_BEZIERSPLINE(geog, sharpness)
{{%/ bannerNote %}}

**Description**

Takes a line and returns a curved version by applying a Bezier spline algorithm. https://turfjs.org/docs/#bezierSpline

* `geog`: `GEOGRAPHY` input LineString.
* `sharpness`: `FLOAT64`|`NULL` a measure of how curvy the path should be between splines. If `NULL` the default value 0.85 is used.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.constructors.ST_BEZIERSPLINE(ST_GEOGFROMTEXT("LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)"), 0.9);
-- LINESTRING(-76.091308 18.427501, -76.0916216712943 ... 
```

### ST_MAKEELLIPSE

{{% bannerNote type="code" %}}
constructors.ST_MAKEELLIPSE(geog, xSemiAxis, ySemiAxis, angle, units, steps)
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
SELECT bqcarto.constructors.ST_MAKEELLIPSE(ST_GEOGPOINT(-73.9385,40.6643), 5, 3, -30, "miles", 80);
-- POLYGON((-73.8558575786687 40.7004828957859 ... 
```

### VERSION

{{% bannerNote type="code" %}}
constructors.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the constructors module.

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.constructors.VERSION();
-- 1.0.0
```