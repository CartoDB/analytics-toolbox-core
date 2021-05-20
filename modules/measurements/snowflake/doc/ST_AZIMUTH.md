### ST_AZIMUTH

{{% bannerNote type="code" %}}
measurements.ST_AZIMUTH(startPoint, endPoint)
{{%/ bannerNote %}}

**Description**

Takes two points and finds the geographic bearing between them, i.e. the angle measured in degrees from the north line (0 degrees). https://turfjs.org/docs/#bearing

* `startPoint`: `GEOGRAPHY` starting Point.
* `endPoint`: `GEOGRAPHY` ending Point.

**Return type**

`DOUBLE`

**Example**

``` sql
SELECT sfcarto.measurements.ST_AZIMUTH(ST_POINT(-3.70325 ,40.4167), ST_POINT(-4.70325 ,41.4167));
-- -36.750529085
```