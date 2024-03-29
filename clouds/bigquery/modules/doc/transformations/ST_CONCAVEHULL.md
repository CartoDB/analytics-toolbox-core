## ST_CONCAVEHULL

```sql:signature
ST_CONCAVEHULL(geog, maxEdge, units)
```

**Description**

Takes a set of points and returns a concave hull Polygon or MultiPolygon. In case that a single or a couple of points are passed as input, the function will return that point or a segment respectively.

* `geog`: `ARRAY<GEOGRAPHY>` input points.
* `maxEdge`: `FLOAT64`|`NULL` the maximum length allowed for an edge of the concave hull. Higher `maxEdge` values will produce more convex-like hulls. If `NULL`, the default value `infinity` is used and it would be equivalent to a Convex Hull.
* `units`: `STRING`|`NULL` units of length, the supported options are: miles, kilometers, degrees or radians. If `NULL`the default value `kilometers` is used.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.ST_CONCAVEHULL(
  [
    ST_GEOGPOINT(-75.833, 39.284),
    ST_GEOGPOINT(-75.6, 39.984),
    ST_GEOGPOINT(-75.221, 39.125),
    ST_GEOGPOINT(-75.521, 39.325)
  ],
  100,
  'kilometers'
);
-- POLYGON((-75.68 39.24425, -75.527 39.2045 ...
```

```sql
SELECT carto.ST_CONCAVEHULL(
  [
    ST_GEOGPOINT(-75.833, 39.284)
  ],
  100, 'kilometers'
);
-- POINT(-75.833 39.284)
```
