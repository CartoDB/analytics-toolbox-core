## ST_MAKEELLIPSE

```sql:signature
ST_MAKEELLIPSE(geog, xSemiAxis, ySemiAxis, angle, units, steps)
```

**Description**

Takes a Point and calculates the ellipse polygon given two semi-axes expressed in variable units and steps for precision.

* `center`: `GEOGRAPHY` center point.
* `xSemiAxis`: `FLOAT64` semi (major) axis of the ellipse along the x-axis.
* `ySemiAxis`: `FLOAT64` semi (minor) axis of the ellipse along the y-axis.
* `angle`: `FLOAT64`|`NULL` angle of rotation (along the horizontal axis), from East in decimal degrees, positive clockwise. If `NULL` the default value `0` is used.
* `units`: `STRING`|`NULL` units of length, the supported options are: miles, kilometers, and degrees. If `NULL`the default value `kilometers` is used.
* `steps`: `INT64`|`NULL` number of steps. If `NULL` the default value `64` is used.

**Example**

```sql
SELECT carto.ST_MAKEELLIPSE(
  ST_GEOGPOINT(-73.9385,40.6643),
  5,
  3,
  -30,
  "miles",
  80
);
-- POLYGON((-73.8558575786687 40.7004828957859 ...
```
