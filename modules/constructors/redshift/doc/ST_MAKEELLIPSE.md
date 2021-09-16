### ST_MAKEELLIPSE

{{% bannerNote type="code" %}}
constructors.ST_MAKEELLIPSE(geog, xSemiAxis, ySemiAxis [, angle] [, units] [, steps])
{{%/ bannerNote %}}

**Description**

Takes a Point and calculates the ellipse polygon given two semi-axes expressed in variable units and steps for precision.

* `center`: `GEOMETRY` center point.
* `xSemiAxis`: `FLOAT8` semi (major) axis of the ellipse along the x-axis.
* `ySemiAxis`: `FLOAT8` semi (minor) axis of the ellipse along the y-axis.
* `angle` (optional): `FLOAT8` angle of rotation (along the vertical axis), from North in decimal degrees, negative clockwise. By default `angle` is `0`.
* `units` (optional): `VARCHAR(10)` units of length, the supported options are: miles, kilometers, meters, and degrees. By default `units` is `kilometers`.
* `steps` (optional): `INT` number of steps. By default `steps` is `64`.

**Return type**

`VARCHAR(MAX)`

**Examples**

```sql
SELECT constructors.ST_MAKEELLIPSE(ST_Point(-73.9385,40.6643), 5, 3);
-- {"coordinates": [[[-73.87922, 40.6643], [-73.88074, 40.670371], ... 
```

```sql
SELECT constructors.ST_MAKEELLIPSE(ST_Point(-73.9385,40.6643), 5, 3, -30);
-- {"coordinates": [[[-73.887031, 40.686437], [-73.892351, 40.691117], ... 
```

```sql
SELECT constructors.ST_MAKEELLIPSE(ST_Point(-73.9385,40.6643), 5, 3, -30, 'miles');
-- {"coordinates": [[[-73.855662, 40.699926], [-73.864225, 40.707456], ... 
```

```sql
SELECT constructors.ST_MAKEELLIPSE(ST_Point(-73.9385,40.6643), 5, 3, -30, 'miles', 80);
-- {"coordinates": [[[-73.855701, 40.700036], [-73.862591, 40.706481], ... 
```