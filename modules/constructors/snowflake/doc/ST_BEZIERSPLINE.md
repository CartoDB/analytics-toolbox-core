### ST_BEZIERSPLINE

[Signature 1](#Signature 1)
[Signature 2](#Signature 2)
[Signature 3](#Signature 3)

#### Signature 1

{{% bannerNote type="code" %}}
constructors.ST_BEZIERSPLINE(geog)
{{%/ bannerNote %}}

**Description**

Takes a line and returns a curved version by applying a Bezier spline algorithm. https://turfjs.org/docs/#bezierSpline

* `geog`: `GEOGRAPHY` input LineString.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT sfcarto.constructors.ST_BEZIERSPLINE(TO_GEOGRAPHY('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'));
-- { "coordinates": [ [ -76.091308, 18.427501 ], [ -76.09134585033101, 18.427508082543092 ], ... 
```

#### Signature 2

{{% bannerNote type="code" %}}
constructors.ST_BEZIERSPLINE(geog, resolution)
{{%/ bannerNote %}}

**Description**

Takes a line and returns a curved version by applying a Bezier spline algorithm. https://turfjs.org/docs/#bezierSpline

* `geog`: `GEOGRAPHY` input LineString.
* `resolution`: `INT`|`NULL` time in milliseconds between points. If `NULL` the default value `10000` is used.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT sfcarto.constructors.ST_BEZIERSPLINE(TO_GEOGRAPHY('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'), 10000);
-- { "coordinates": [ [ -76.091308, 18.427501 ], [ -76.09134585033101, 18.427508082543092 ], ... 
```

#### Signature 3

{{% bannerNote type="code" %}}
constructors.ST_BEZIERSPLINE(geog, resolution, sharpness)
{{%/ bannerNote %}}

**Description**

Takes a line and returns a curved version by applying a Bezier spline algorithm. https://turfjs.org/docs/#bezierSpline

* `geog`: `GEOGRAPHY` input LineString.
* `resolution`: `INT`|`NULL` time in milliseconds between points. If `NULL` the default value `10000` is used.
* `sharpness`: `DOUBLE`|`NULL` a measure of how curvy the path should be between splines. If `NULL` the default value `0.85` is used.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT sfcarto.constructors.ST_BEZIERSPLINE(TO_GEOGRAPHY('LINESTRING (-76.091308 18.427501,-76.695556 18.729501,-76.552734 19.40443,-74.61914 19.134789,-73.652343 20.07657,-73.157958 20.210656)'), 10000, 0.9);
-- { "coordinates": [ [ -76.091308, 18.427501 ], [ -76.09134541990707, 18.42750717125151 ], ... 
```