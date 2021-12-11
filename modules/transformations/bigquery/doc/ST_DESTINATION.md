### ST_DESTINATION

{{% bannerNote type="code" %}}
transformations.ST_DESTINATION(startPoint, distance, bearing, units)
{{%/ bannerNote %}}

**Description**

Takes a Point and calculates the location of a destination point given a distance in degrees, radians, miles, or kilometers; and bearing in degrees. This uses the Haversine formula to account for global curvature.

* `origin`: `GEOGRAPHY` starting point.
* `distance`: `FLOAT64` distance from the origin point.
* `bearing`: `FLOAT64` ranging from -180 to 180.
* `units`: `STRING`|`NULL` units of length, the supported options are: miles, kilometers, degrees or radians. If `NULL`the default value `kilometers` is used.

**Return type**

`GEOGRAPHY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

``` sql
SELECT `carto-os`.transformations.ST_DESTINATION(ST_GEOGPOINT(-3.70325,40.4167), 10, 45, "miles");
-- POINT(-3.56862505487045 40.5189626777536)
```