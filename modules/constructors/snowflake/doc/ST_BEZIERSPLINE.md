### ST_BEZIERSPLINE

{{% bannerNote type="code" %}}
constructors.ST_BEZIERSPLINE(geog [, resolution] [, sharpness])
{{%/ bannerNote %}}

**Description**

Takes a line and returns a curved version by applying a Bezier spline algorithm. https://turfjs.org/docs/#bezierSpline

* `geog`: `GEOGRAPHY` input LineString.
* `resolution` (optional): `INT` time in milliseconds between points. By default `resolution` is `10000`.
* `sharpness` (optional): `DOUBLE` a measure of how curvy the path should be between splines. By default `sharpness` is `0.85`.

**Return type**

`GEOGRAPHY`

**Examples**

```sql
SELECT sfcarto.constructors.ST_BEZIERSPLINE(TO_GEOGRAPHY('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'));
-- { "coordinates": [ [ -76.091308, 18.427501 ], [ -76.09134585033101, 18.427508082543092 ], ... 
```

```sql
SELECT sfcarto.constructors.ST_BEZIERSPLINE(TO_GEOGRAPHY('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'), 10000);
-- { "coordinates": [ [ -76.091308, 18.427501 ], [ -76.09134585033101, 18.427508082543092 ], ... 
```

```sql
SELECT sfcarto.constructors.ST_BEZIERSPLINE(TO_GEOGRAPHY('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'), 10000, 0.9);
-- { "coordinates": [ [ -76.091308, 18.427501 ], [ -76.09134541990707, 18.42750717125151 ], ... 
```