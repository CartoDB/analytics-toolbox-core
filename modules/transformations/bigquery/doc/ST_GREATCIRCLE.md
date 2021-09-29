### ST_GREATCIRCLE

{{% bannerNote type="code" %}}
transformations.ST_GREATCIRCLE(startPoint, endPoint, npoints)
{{%/ bannerNote %}}

**Description**

Calculate great circles routes as LineString or MultiLineString. If the start and end points span the antimeridian, the resulting feature will be split into a MultiLineString.

* `startPoint`: `GEOGRAPHY` source point feature.
* `endPoint`: `GEOGRAPHY` destination point feature.
* `npoints`: `INT64`|`NULL` number of points. If `NULL` the default value `100` is used.

**Return type**

`GEOGRAPHY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

``` sql
SELECT carto-os.transformations.ST_GREATCIRCLE(ST_GEOGPOINT(-3.70325,40.4167), ST_GEOGPOINT(-73.9385,40.6643), 20);
-- LINESTRING(-3.70325 40.4167 ... 
```