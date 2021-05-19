### ST_MINKOWSKIDISTANCE

{{% bannerNote type="code" %}}
measurements.ST_MINKOWSKIDISTANCE(geog [, p])
{{%/ bannerNote %}}

**Description**

Calculate the Minkowski p-norm distance between two features. https://github.com/Turfjs/turf/tree/master/packages/turf-distance-weight

* `geojsons`: `ARRAY` array of features in GeoJSON format casted to STRING.
* `p` (optional): `FLOAT64` minkowski p-norm distance parameter. 1: Manhattan distance. 2: Euclidean distance. 1 =< p <= infinity. By default `p` is `2`.

**Return type**

`ARRAY`

**Examples**

``` sql
SELECT sfcarto.measurements.ST_MINKOWSKIDISTANCE(ARRAY_CONSTRUCT(ST_ASGEOJSON(ST_POINT(10,10))::STRING, ST_ASGEOJSON(ST_POINT(13,10))::STRING));
-- [ [ 0, 3.333333333333333e-01 ], [ 3.333333333333333e-01, 0 ] ]
```

``` sql
SELECT sfcarto.measurements.ST_MINKOWSKIDISTANCE(ARRAY_CONSTRUCT(ST_ASGEOJSON(ST_POINT(10,10))::STRING, ST_ASGEOJSON(ST_POINT(13,10))::STRING), 2);
-- [ [ 0, 3.333333333333333e-01 ], [ 3.333333333333333e-01, 0 ] ]
```