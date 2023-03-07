## ST_MAKEELLIPSE

```sql:signature
ST_MAKEELLIPSE(geog, xSemiAxis, ySemiAxis [, angle] [, units] [, steps])
```

**Description**

Takes a Point and calculates the ellipse polygon given two semi-axes expressed in variable units and steps for precision.

* `center`: `GEOGRAPHY` center point.
* `xSemiAxis`: `DOUBLE` semi (major) axis of the ellipse along the x-axis.
* `ySemiAxis`: `DOUBLE` semi (minor) axis of the ellipse along the y-axis.
* `angle` (optional): `DOUBLE` angle of rotation (along the vertical axis), from North in decimal degrees, negative clockwise. By default `angle` is `0`.
* `units` (optional): `STRING` units of length, the supported options are: miles, kilometers, and degrees. By default `units` is `kilometers`.
* `steps` (optional): `INT` number of steps. By default `steps` is `64`.

**Return type**

`GEOGRAPHY`

**Examples**

```sql
SELECT carto.ST_MAKEELLIPSE(ST_Point(-73.9385,40.6643), 5, 3);
-- { "coordinates": [ [ [ -73.87922034627275, 40.6643 ], [ -73.88056149301754, 40.67000644486112 ], ...
```

```sql
SELECT carto.ST_MAKEELLIPSE(ST_Point(-73.9385,40.6643), 5, 3, -30);
-- { "coordinates": [ [ [ -73.88715365786175, 40.68678300909311 ], [ -73.89207802212195, 40.691215338152176 ], ...
```

```sql
SELECT carto.ST_MAKEELLIPSE(ST_Point(-73.9385,40.6643), 5, 3, -30, 'miles');
-- { "coordinates": [ [ [ -73.85585757866869, 40.700482895785946 ], [ -73.8637839804274, 40.70761511598624 ], ...
```

```sql
SELECT carto.ST_MAKEELLIPSE(ST_Point(-73.9385,40.6643), 5, 3, -30, 'miles', 80);
-- { "coordinates": [ [ [ -73.85585757866869, 40.700482895785946 ], [ -73.86194538052666, 40.70635901954343 ], ...
```
