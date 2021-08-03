### ST_AZIMUTH

{{% bannerNote type="code" %}}
measurements.ST_AZIMUTH(startPoint, endPoint)
{{%/ bannerNote %}}

**Description**

Takes two points and finds the geographic bearing between them, i.e. the angle measured in degrees from the north line (0 degrees).

* `startPoint`: `GEOGRAPHY` starting Point.
* `endPoint`: `GEOGRAPHY` ending Point.

**Return type**

`FLOAT64`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

``` sql
SELECT carto-os.measurements.ST_AZIMUTH(ST_GEOGPOINT(-3.70325 ,40.4167), ST_GEOGPOINT(-4.70325 ,41.4167));
-- -36.75052908494255
```