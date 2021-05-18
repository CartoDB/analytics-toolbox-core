### ST_MINKOWSKIDISTANCE


[Signature 1](#signature-1)
[Signature 2](#signature-2)

#### Signature 1

{{% bannerNote type="code" %}}
measurements.ST_MINKOWSKIDISTANCE(geog)
{{%/ bannerNote %}}

**Description**

Calculate the Minkowski p-norm distance between two features. https://github.com/Turfjs/turf/tree/master/packages/turf-distance-weight

* `geog`: `ARRAY` Array of features in GeoJSON format casted to STRING.

**Return type**

`ARRAY`

**Example**

``` sql
SELECT sfcarto.measurements.ST_MINKOWSKIDISTANCE(ARRAY_CONSTRUCT(ST_ASGEOJSON(ST_POINT(10,10))::STRING, ST_ASGEOJSON(ST_POINT(13,10))::STRING));
-- [ [ 0, 3.333333333333333e-01 ], [ 3.333333333333333e-01, 0 ] ]
```

#### Signature 2

{{% bannerNote type="code" %}}
measurements.ST_MINKOWSKIDISTANCE(geog, p)
{{%/ bannerNote %}}

**Description**

Calculate the Minkowski p-norm distance between two features. https://github.com/Turfjs/turf/tree/master/packages/turf-distance-weight

* `geog`: `ARRAY` Array of features in GeoJSON format casted to STRING.

**Return type**

`ARRAY`

**Example**

``` sql
SELECT sfcarto.measurements.ST_MINKOWSKIDISTANCE(ARRAY_CONSTRUCT(ST_ASGEOJSON(ST_POINT(10,10))::STRING, ST_ASGEOJSON(ST_POINT(13,10))::STRING), 2);
-- [ [ 0, 3.333333333333333e-01 ], [ 3.333333333333333e-01, 0 ] ]
```