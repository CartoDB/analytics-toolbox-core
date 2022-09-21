### ST_BEZIERSPLINE

{{% bannerNote type="code" %}}
carto.ST_BEZIERSPLINE(linestring [, resolution] [, sharpness])
{{%/ bannerNote %}}

**Description**

Takes a line as input and returns a curved version by applying a Bezier spline algorithm.

* `linestring`: `GEOMETRY` input LineString.
* `resolution` (optional): `INT` time in milliseconds between points. If not specified, the default value of `10000` will be used.
* `sharpness` (optional): `FLOAT8` a measure of how curvy the path should be between splines. If not specified, the default value of `0.85` will be used.

**Return type**

`VARCHAR(MAX)`

**Examples**

```sql
SELECT carto.ST_BEZIERSPLINE(ST_GEOMFROMTEXT('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'));
-- {"type": "LineString", "coordinates": [[-76.091308, 18.427501], [-76.09134585033101, 18.427508082543092], ...
```

```sql
SELECT carto.ST_BEZIERSPLINE(ST_GEOMFROMTEXT('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'), 10000);
-- {"type": "LineString", "coordinates": [[-76.091308, 18.427501], [-76.09134585033101, 18.427508082543092], ...
```

```sql
SELECT carto.ST_BEZIERSPLINE(ST_GEOMFROMTEXT('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'), 10000, 0.9);
-- {"type": "LineString", "coordinates": [[-76.091308, 18.427501], [-76.09134541990707, 18.42750717125151], ...
```
