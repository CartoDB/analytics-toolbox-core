## measurements

<div class="badge core"></div>

### ST_ANGLE

{{% bannerNote type="code" %}}
measurements.ST_ANGLE(startPoint, midPoint, endPoint, mercator)
{{%/ bannerNote %}}

**Description**

Finds the angle formed by two adjacent segments defined by 3 points. The result will be the (positive clockwise) angle with origin on the startPoint-midPoint segment, or its explementary angle if required. https://github.com/Turfjs/turf/tree/master/packages/turf-angle

* `startPoint`: `GEOGRAPHY` Start Point Coordinates.
* `midPoint`: `GEOGRAPHY` Mid Point Coordinates.
* `endPoint`: `GEOGRAPHY` End Point Coordinates.
* `mercator`: `BOOLEAN`|`NULL` if calculations should be performed over Mercator or WGS84 projection. If `NULL` the default value `false` is used.

**Return type**

`FLOAT64`

**Example**

``` sql
SELECT bqcarto.measurements.ST_ANGLE(ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-4.70325 ,10.4167), ST_GEOGPOINT(-5.70325 ,40.4167), false);
-- 3.933094586038578
```

### ST_AZIMUTH

{{% bannerNote type="code" %}}
measurements.ST_AZIMUTH(startPoint, endPoint)
{{%/ bannerNote %}}

**Description**

Takes two points and finds the geographic bearing between them, i.e. the angle measured in degrees from the north line (0 degrees). https://turfjs.org/docs/#bearing

* `startPoint`: `GEOGRAPHY` starting Point.
* `endPoint`: `GEOGRAPHY` ending Point.

**Return type**

`FLOAT64`

**Example**

``` sql
SELECT bqcarto.measurements.ST_AZIMUTH(ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-4.70325 ,41.4167));
-- -36.75052908494255
```

### ST_MINKOWSKIDISTANCE

{{% bannerNote type="code" %}}
measurements.ST_MINKOWSKIDISTANCE(geog, p)
{{%/ bannerNote %}}

**Description**

Calculate the Minkowski p-norm distance between two features. https://github.com/Turfjs/turf/tree/master/packages/turf-distance-weight

* `geog`: `ARRAY<GEOGRAPHY>` FeatureCollection.
* `p`: `FLOAT64` Minkowski p-norm distance parameter. 1: Manhattan distance. 2: Euclidean distance. 1 =< p <= infinity. If `NULL` the default value `2` is used.

**Return type**

`ARRAY<STRING>`

**Example**

``` sql
SELECT bqcarto.measurements.ST_MINKOWSKIDISTANCE([ST_GEOGPOINT(10,10),ST_GEOGPOINT(13,10)],2);
-- ["0,0.3333333333333333","0.3333333333333333,0"]
```


### VERSION

{{% bannerNote type="code" %}}
measurements.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the measurements module.

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.measurements.VERSION();
-- 1.0.0
```
