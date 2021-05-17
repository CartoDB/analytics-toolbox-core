### ST_MAKEELLIPSE

{{% bannerNote type="code" %}}
constructors.ST_MAKEELLIPSE(geog, xSemiAxis, ySemiAxis)
{{%/ bannerNote %}}
{{% bannerNote type="code" %}}
constructors.ST_MAKEELLIPSE(geog, xSemiAxis, ySemiAxis, angle)
{{%/ bannerNote %}}
{{% bannerNote type="code" %}}
constructors.ST_MAKEELLIPSE(geog, xSemiAxis, ySemiAxis, angle, units)
{{%/ bannerNote %}}
{{% bannerNote type="code" %}}
constructors.ST_MAKEELLIPSE(geog, xSemiAxis, ySemiAxis, angle, units, steps)
{{%/ bannerNote %}}

**Description**

Takes a Point and calculates the ellipse polygon given two semi-axes expressed in variable units and steps for precision. https://github.com/Turfjs/turf/tree/master/packages/turf-ellipse

* `center`: `GEOGRAPHY` center point.
* `xSemiAxis`: `DOUBLE` semi (major) axis of the ellipse along the x-axis.
* `ySemiAxis`: `DOUBLE` semi (minor) axis of the ellipse along the y-axis.
* `angle`: `DOUBLE`|`NULL` angle of rotation (along the vertical axis), from North in decimal degrees, negative clockwise. If `NULL` the default value `0` is used.
* `units`: `STRING`|`NULL` any of the options supported by turf units: miles, kilometers, and degrees. If `NULL`the default value `kilometers` is used.
* `steps`: `INT`|`NULL` number of steps. If `NULL` the default value `64` is used.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT sfcarto.constructors.ST_MAKEELLIPSE(ST_Point(-73.9385,40.6643), 5, 3, -30, 'miles', 80);
-- { "coordinates": [ [ [ -73.85585757866869, 40.700482895785946 ], [ -73.86194538052666, 40.70635901954343 ], ... 
```