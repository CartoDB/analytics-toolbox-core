## ST_DESTINATION

```sql:signature
ST_DESTINATION(startPoint, distance, bearing, units)
```

**Description**

Takes a Point and calculates the location of a destination point given a distance in degrees, radians, miles, or kilometers; and a bearing in degrees. This uses the Haversine formula to account for global curvature.

* `origin`: `GEOGRAPHY` starting point.
* `distance`: `FLOAT64` distance from the origin point in the units specified.
* `bearing`: `FLOAT64` ranging from -180 to 180 (e.g. 0 is North, 90 is East, 180 is South, -90 is West).
* `units`: `STRING`|`NULL` units of length, the supported options are: `miles`, `kilometers`, `degrees` or `radians`. If `NULL`the default value `kilometers` is used.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.ST_DESTINATION(
  ST_GEOGPOINT(-3.70325,40.4167),
  10,
  45,
  "miles"
);
-- POINT(-3.56862505487045 40.5189626777536)
```
