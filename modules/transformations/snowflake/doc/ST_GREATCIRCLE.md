### ST_GREATCIRCLE

{{% bannerNote type="code" %}}
transformations.ST_GREATCIRCLE(startPoint, endPoint, npoints)
{{%/ bannerNote %}}

**Description**

Calculate great circles routes as LineString or MultiLineString. If the start and end points span the antimeridian, the resulting feature will be split into a MultiLineString. https://turfjs.org/docs/#greatCircle

* `startPoint`: `GEOGRAPHY` source point feature.
* `endPoint`: `GEOGRAPHY` destination point feature.
* `npoints`: `INT`|`NULL` number of points. If `NULL` the default value `100` is used.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT sfcarto.transformations.ST_GREATCIRCLE(ST_POINT(-3.70325,40.4167), ST_POINT(-73.9385,40.6643), 20);
-- { "coordinates": [ [ -3.7032499999999993, 40.4167 ], ... 
```