## ST_DESTINATION

```sql:signature
ST_DESTINATION(startPoint, distance, bearing [, units])
```

**Description**

Takes a Point and calculates the location of a destination point given a distance in degrees, radians, miles, or kilometers; and a bearing in degrees. This uses the Haversine formula to account for global curvature.

* `origin`: `GEOGRAPHY` starting point.
* `distance`: `DOUBLE` distance from the origin point in the units specified.
* `bearing`: `DOUBLE` counter-clockwise angle from East, ranging from -180 to 180 (e.g. 0 is East, 90 is North, 180 is West, -90 is South).
* `units` (optional): `STRING` units of length, the supported options are: `miles`, `kilometers`, `degrees` or `radians`. If `NULL`the default value `kilometers` is used.

**Return type**

`GEOGRAPHY`

**Examples**

```sql
SELECT carto.ST_DESTINATION(ST_POINT(-3.70325,40.4167), 10, 45);
-- { "coordinates": [ -3.6196461743569053, 40.48026145975517 ], "type": "Point" }
```

```sql
SELECT carto.ST_DESTINATION(ST_POINT(-3.70325,40.4167), 10, 45, 'miles');
-- { "coordinates": [ -3.56862505487045, 40.518962677753585 ], "type": "Point" }
```
