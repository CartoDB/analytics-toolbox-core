### ST_ANGLE

{{% bannerNote type="code" %}}
measurements.ST_ANGLE(startPoint, midPoint, endPoint)
{{%/ bannerNote %}}

**Description**

Finds the angle formed by two adjacent segments defined by 3 points. The result will be the (positive clockwise) angle with origin on the startPoint-midPoint segment, or its explementary angle if required. https://github.com/Turfjs/turf/tree/master/packages/turf-angle

* `startPoint`: `GEOGRAPHY` start Point Coordinates.
* `midPoint`: `GEOGRAPHY` mid Point Coordinates.
* `endPoint`: `GEOGRAPHY` end Point Coordinates.

**Return type**

`DOUBLE`

**Example**

``` sql
SELECT sfcarto.measurements.ST_ANGLE(ST_POINT(-3.70325 ,40.4167), ST_POINT(-4.70325 ,10.4167), ST_POINT(-5.70325 ,40.4167));
-- 3.933094586
```