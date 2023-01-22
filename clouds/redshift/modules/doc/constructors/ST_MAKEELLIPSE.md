## ST_MAKEELLIPSE

```sql:signature
carto.ST_MAKEELLIPSE(center, xSemiAxis, ySemiAxis [, angle] [, units] [, steps])
```

**Description**

Takes a Point as input and calculates the ellipse polygon given two semi-axes expressed in variable units and steps for precision.

* `center`: `GEOMETRY` center point.
* `xSemiAxis`: `FLOAT8` semi (major) axis of the ellipse along the x-axis.
* `ySemiAxis`: `FLOAT8` semi (minor) axis of the ellipse along the y-axis.
* `angle` (optional): `FLOAT8` angle of rotation (along the vertical axis), from North in decimal degrees, negative clockwise. If not specified, the default value of `0` will be used.
* `units` (optional): `VARCHAR(10)` units of length. The supported options are: miles, kilometers, meters, and degrees. If not specified, `kilometers` will be used.
* `steps` (optional): `INT` number of steps. If not specified, the default value of `64` will be used.

**Return type**

`VARCHAR(MAX)`

**Examples**

```sql
SELECT carto.ST_MAKEELLIPSE(ST_POINT(-73.9385,40.6643), 5, 3);
-- {"type": "Polygon", "coordinates": [[[-73.87922034627275, 40.6643], [-73.88056149301754, 40.67000644486112], ...
```

```sql
SELECT carto.ST_MAKEELLIPSE(ST_POINT(-73.9385,40.6643), 5, 3, -30);
-- {"type": "Polygon", "coordinates": [[[-73.88703173808466, 40.68643711664552], [-73.89195608204625, 40.69086946050236], ...
```

```sql
SELECT carto.ST_MAKEELLIPSE(ST_Point(-73.9385,40.6643), 5, 3, -30, 'miles');
-- {"type": "Polygon", "coordinates": [[[-73.85566162723387, 40.69992623586439], [-73.86358797643032, 40.707058494394765], ...
```

```sql
SELECT carto.ST_MAKEELLIPSE(ST_Point(-73.9385,40.6643), 5, 3, -30, 'miles', 80);
-- {"type": "Polygon", "coordinates": [[[-73.8557003345262, 40.70003619338248], [-73.86178810440265, 40.705912341919415], ...
```