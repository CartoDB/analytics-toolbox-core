## H3_FROMGEOGPOINT

```sql:signature
H3_FROMGEOGPOINT(point, resolution)
```

**Description**

Returns the H3 cell index that the point belongs to in the requested `resolution`. It will return `null` on error (non-point geometry, resolution out of bounds, or non-WGS84 SRID).

The point must be a 2D `SDO_GEOMETRY` in **WGS84 (SRID 4326)**. The function does not auto-transform: a point with an explicit SRID other than 4326 returns `null`. A `null` SRID is accepted and treated as WGS84 (matching the convention used by `SDO_UTIL.FROM_WKTGEOMETRY`).

**Input parameters**

* `point`: `SDO_GEOMETRY` 2D point in WGS84.
* `resolution`: `NUMBER` between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`VARCHAR2(16)`

**Example**

```sql
SELECT carto.H3_FROMGEOGPOINT(
    SDO_GEOMETRY(2001, 4326,
                 SDO_POINT_TYPE(-3.7038, 40.4168, NULL),
                 NULL, NULL),
    4
) FROM DUAL;
-- 84390cbffffffff
```

````hint:info
**tip**

If you want the cells covered by a polygon see [H3_POLYFILL](h3#h3_polyfill).
````
