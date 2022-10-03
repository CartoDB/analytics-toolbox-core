### ST_BEZIERSPLINE

{{% bannerNote type="code" %}}
carto.ST_BEZIERSPLINE(geog [, resolution] [, sharpness])
{{%/ bannerNote %}}

**Description**

Takes a line and returns a curved version of it by applying a Bezier spline algorithm. Note that the resulting geography will be a LineString with additional points inserted.

* `geog`: `GEOGRAPHY` input LineString.
* `resolution` (optional): `INT` total time in milliseconds assigned to the line. By default `resolution` is `10000`. Internal curve vertices are generated in 10 ms increments, so the maximum number of resulting points will be `resolution/10` (close points may be merged resulting in less points). A higher number will increase the accuracy of the result but will increase the computation time and number of points.
* `sharpness` (optional): `DOUBLE` a measure of how curvy the path should be between splines. By default `sharpness` is `0.85`.

**Return type**

`GEOGRAPHY`

**Examples**

```sql
SELECT carto.ST_BEZIERSPLINE(
  TO_GEOGRAPHY(
    'LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'
  )
);
-- { "coordinates": [ [ -76.091308, 18.427501 ], [ -76.09134585033101, 18.427508082543092 ], ...
```

```sql
SELECT carto.ST_BEZIERSPLINE(
  TO_GEOGRAPHY(
    'LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'
  ),
  10000
);
-- { "coordinates": [ [ -76.091308, 18.427501 ], [ -76.09134585033101, 18.427508082543092 ], ...
```

```sql
SELECT carto.ST_BEZIERSPLINE(
  TO_GEOGRAPHY(
    'LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'
  ),
  10000,
  0.9
);
-- { "coordinates": [ [ -76.091308, 18.427501 ], [ -76.09134541990707, 18.42750717125151 ], ...
```
