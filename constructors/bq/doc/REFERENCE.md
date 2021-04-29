## constructors

<div class="badge core"></div>

This module contains functions that create geographies from coordinates or already existing geographies.

### ST_BEZIERSPLINE

{{% bannerNote type="code" %}}
constructors.ST_BEZIERSPLINE(geog, resolution, sharpness)
{{%/ bannerNote %}}

**Description**

Takes a line and returns a curved version by applying a Bezier spline algorithm. https://turfjs.org/docs/#bezierSpline

* `geog`: `GEOGRAPHY` input LineString.
* `resolution`: `INT64`|`NULL` time in milliseconds between points. If `NULL` the default value `10000` is used.
* `sharpness`: `FLOAT64`|`NULL` a measure of how curvy the path should be between splines. If `NULL` the default value `0.85` is used.

```
SELECT bqcarto.constructors.ST_BEZIERSPLINE(ST_GEOGFROMTEXT("LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)"), 10000, 0.9);
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
* `angle`: `FLOAT64`|`NULL` angle of rotation (along the vertical axis), from North in decimal degrees, negative clockwise. If `NULL` the default value `0` is used.
* `units`: `STRING`|`NULL` any of the options supported by turf units: miles, kilometers, and degrees. If `NULL`the default value `kilometers` is used.
* `steps`: `INT64`|`NULL` number of steps. If `NULL` the default value `64` is used.

```
SELECT bqcarto.constructors.ST_MAKEELLIPSE(ST_GEOGPOINT(-73.9385,40.6643), 5, 3, -30, "miles", 80);
-- POLYGON((-73.8558575786687 40.7004828957859 ... 
```

### ST_MAKEENVELOPE

{{% bannerNote type="code" %}}
constructors.ST_MAKEENVELOPE(xmin, ymin, xma, ymax)
{{%/ bannerNote %}}

**Description**
Creates a rectangular Polygon from the minimum and maximum values for X and Y.


* `xmin`: `FLOAT64` minimum value for X.
* `ymin`: `FLOAT64` minimum value for Y.
* `xmax`: `FLOAT64` maximum value for X.
* `ymax`: `FLOAT64` maximum value for Y.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.constructors.ST_MAKEENVELOPE(0,0,1,1);
-- POLYGON((1 0, 1 1, 0 1, 0 0, 1 0)) 
```

### ST_TILEENVELOPE

{{% bannerNote type="code" %}}
constructors.ST_TILEENVELOPE(zoomLevel, xTile, yTile)
{{%/ bannerNote %}}

**Description**
Returns the boundary polygon of a tile given its zoom level and its X and Y indices.

* `zoomLevel`: `INT64` zoom level of the tile.
* `xTile`: `INT64` X index of the tile.
* `yTile`: `INT64` Y index of the tile.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.constructors.ST_TILEENVELOPE(10,384,368);
-- POLYGON((-45 45.089035564831, -45 44.840290651398, -44.82421875 44.840290651398, -44.6484375 44.840290651398, -44.6484375 45.089035564831, -44.82421875 45.089035564831, -45 45.089035564831))
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
-- 1.1.0
```