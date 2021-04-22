## measurement

<div class="badge core"></div>

### ST_ANGLE

{{% bannerNote type="code" %}}
measurement.ST_ANGLE(startPoint, midPoint, endPoint, mercator)
{{%/ bannerNote %}}

**Description**

Finds the angle formed by two adjacent segments defined by 3 points. The result will be the (positive clockwise) angle with origin on the startPoint-midPoint segment, or its explementary angle if required. https://github.com/Turfjs/turf/tree/master/packages/turf-angle

* `startPoint`: `GEOGRAPHY` Start Point Coordinates.
* `midPoint`: `GEOGRAPHY` Mid Point Coordinates.
* `endPoint`: `GEOGRAPHY` End Point Coordinates.
* `mercator`: `BOOLEAN`|`NULL` if calculations should be performed over Mercator or WGS84 projection. If `NULL` the default value false is used.

**Return type**

`FLOAT64`

**Example**

``` sql
SELECT bqcarto.measurement.ST_ANGLE(ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-4.70325 ,10.4167), ST_GEOGPOINT(-5.70325 ,40.4167), false);
-- 3.933094586038578
```

### ST_BEARING

{{% bannerNote type="code" %}}
measurement.ST_BEARING(startPoint, endPoint)
{{%/ bannerNote %}}

**Description**

Takes two points and finds the geographic bearing between them, i.e. the angle measured in degrees from the north line (0 degrees). https://turfjs.org/docs/#bearing

* `startPoint`: `GEOGRAPHY` starting Point.
* `endPoint`: `GEOGRAPHY` ending Point.

**Return type**

`FLOAT64`

**Example**

``` sql
SELECT bqcarto.measurement.ST_BEARING(ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-4.70325 ,41.4167));
-- -36.75052908494255
```

### ST_CENTERMEAN

{{% bannerNote type="code" %}}
measurement.ST_CENTERMEAN(geog)
{{%/ bannerNote %}}

**Description**

Takes a Feature or FeatureCollection and returns the mean center. https://github.com/Turfjs/turf/tree/master/packages/turf-center-mean

* `geog`: `GEOGRAPHY` feature to be centered.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.measurement.ST_CENTERMEAN(ST_GEOGFROMTEXT("POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))"));
-- POINT(25.3890912155939 29.7916831655627)
```

### ST_CENTEROFMASS

{{% bannerNote type="code" %}}
measurement.ST_CENTEROFMASS(geog)
{{%/ bannerNote %}}

**Description**

Takes any Feature or a FeatureCollection and returns its center of mass using this formula: Centroid of Polygon. https://turfjs.org/docs/#centerOfMass

* `geog`: `GEOGRAPHY` feature to be centered.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT bqcarto.measurement.ST_CENTEROFMASS(ST_GEOGFROMTEXT("POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))"));
-- POINT(25.1730977433239 27.2789529273059) 
```

### VERSION

{{% bannerNote type="code" %}}
measurement.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the measurement module.

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.measurement.VERSION();
-- 1.0.0
```
