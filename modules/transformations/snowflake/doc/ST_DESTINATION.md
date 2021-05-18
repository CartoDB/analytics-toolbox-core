### ST_DESTINATION

{{% bannerNote type="code" %}}
transformations.ST_DESTINATION(startPoint, distance, bearing, units)
{{%/ bannerNote %}}

**Description**

Takes a Point and calculates the location of a destination point given a distance in degrees, radians, miles, or kilometers; and bearing in degrees. This uses the Haversine formula to account for global curvature. https://turfjs.org/docs/#destination

* `origin`: `GEOGRAPHY` starting point.
* `distance`: `DOUBLE` distance from the origin point.
* `bearing`: `DOUBLE` ranging from -180 to 180.
* `units`: `STRING`|`NULL` any of the options supported by turf units: miles, kilometers, degrees or radians. If `NULL`the default value `kilometers` is used.

**Return type**

`GEOGRAPHY`

**Example**

``` sql
SELECT sfcarto.transformations.ST_DESTINATION(ST_GEOGPOINT(-3.70325,40.4167), 10, 45, "miles");
-- POINT(-3.56862505487045 40.5189626777536)
```