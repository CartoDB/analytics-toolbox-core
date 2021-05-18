### ST_MAKEELLIPSE

[Signature 1](#Signature 1)
[Signature 2](#Signature 2)
[Signature 3](#Signature 3)
[Signature 4](#Signature 4)

#### Signature 1

{{% bannerNote type="code" %}}
constructors.ST_MAKEELLIPSE(geog, xSemiAxis, ySemiAxis)
{{%/ bannerNote %}}

**Description**

Takes a Point and calculates the ellipse polygon given two semi-axes expressed in variable units and steps for precision. https://github.com/Turfjs/turf/tree/master/packages/turf-ellipse

* `center`: `GEOGRAPHY` center point.
* `xSemiAxis`: `DOUBLE` semi (major) axis of the ellipse along the x-axis.
* `ySemiAxis`: `DOUBLE` semi (minor) axis of the ellipse along the y-axis.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT sfcarto.constructors.ST_MAKEELLIPSE(ST_Point(-73.9385,40.6643), 5, 3);
-- { "coordinates": [ [ [ -73.87922034627275, 40.6643 ], [ -73.88056149301754, 40.67000644486112 ], ... 
```

#### Signature 2

{{% bannerNote type="code" %}}
constructors.ST_MAKEELLIPSE(geog, xSemiAxis, ySemiAxis, angle)
{{%/ bannerNote %}}

**Description**

Takes a Point and calculates the ellipse polygon given two semi-axes expressed in variable units and steps for precision. https://github.com/Turfjs/turf/tree/master/packages/turf-ellipse

* `center`: `GEOGRAPHY` center point.
* `xSemiAxis`: `DOUBLE` semi (major) axis of the ellipse along the x-axis.
* `ySemiAxis`: `DOUBLE` semi (minor) axis of the ellipse along the y-axis.
* `angle`: `DOUBLE`|`NULL` angle of rotation (along the vertical axis), from North in decimal degrees, negative clockwise. If `NULL` the default value `0` is used.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT sfcarto.constructors.ST_MAKEELLIPSE(ST_Point(-73.9385,40.6643), 5, 3, -30);
-- { "coordinates": [ [ [ -73.88715365786175, 40.68678300909311 ], [ -73.89207802212195, 40.691215338152176 ], ... 
```

#### Signature 3

{{% bannerNote type="code" %}}
constructors.ST_MAKEELLIPSE(geog, xSemiAxis, ySemiAxis, angle, units)
{{%/ bannerNote %}}

**Description**

Takes a Point and calculates the ellipse polygon given two semi-axes expressed in variable units and steps for precision. https://github.com/Turfjs/turf/tree/master/packages/turf-ellipse

* `center`: `GEOGRAPHY` center point.
* `xSemiAxis`: `DOUBLE` semi (major) axis of the ellipse along the x-axis.
* `ySemiAxis`: `DOUBLE` semi (minor) axis of the ellipse along the y-axis.
* `angle`: `DOUBLE`|`NULL` angle of rotation (along the vertical axis), from North in decimal degrees, negative clockwise. If `NULL` the default value `0` is used.
* `units`: `STRING`|`NULL` any of the options supported by turf units: miles, kilometers, and degrees. If `NULL`the default value `kilometers` is used.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT sfcarto.constructors.ST_MAKEELLIPSE(ST_Point(-73.9385,40.6643), 5, 3, -30, 'miles');
-- { "coordinates": [ [ [ -73.85585757866869, 40.700482895785946 ], [ -73.8637839804274, 40.70761511598624 ], ... 
```

#### Signature 4

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