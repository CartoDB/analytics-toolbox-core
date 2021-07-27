### ST_DESTINATION

{{% bannerNote type="code" %}}
transformations.ST_DESTINATION(startPoint, distance, bearing [, units])
{{%/ bannerNote %}}

**Description**

Takes a Point and calculates the location of a destination point given a distance in degrees, radians, miles, or kilometers; and bearing in degrees. This uses the Haversine formula to account for global curvature.

* `origin`: `GEOGRAPHY` starting point.
* `distance`: `DOUBLE` distance from the origin point.
* `bearing`: `DOUBLE` ranging from -180 to 180.
* `units` (optional): `STRING` units of length, the supported options are: miles, kilometers, degrees or radians. By default `units` is `kilometers`.

**Return type**

`GEOGRAPHY`

**Examples**

``` sql
SELECT sfcarto.transformations.ST_DESTINATION(ST_POINT(-3.70325,40.4167), 10, 45);
-- { "coordinates": [ -3.6196461743569053, 40.48026145975517 ], "type": "Point" }
```

``` sql
SELECT sfcarto.transformations.ST_DESTINATION(ST_POINT(-3.70325,40.4167), 10, 45, 'miles');
-- { "coordinates": [ -3.56862505487045, 40.518962677753585 ], "type": "Point" }
```