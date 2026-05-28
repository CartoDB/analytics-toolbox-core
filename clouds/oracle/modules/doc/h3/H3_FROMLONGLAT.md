## H3_FROMLONGLAT

```sql:signature
H3_FROMLONGLAT(longitude, latitude, resolution)
```

**Description**

Returns the H3 cell index that the point belongs to in the required `resolution`. Inputs are interpreted as WGS84 (SRID 4326). Coordinates outside the valid range are normalized. Returns `null` on error (resolution out of bounds).

**Input parameters**

* `longitude`: `NUMBER` horizontal coordinate of the map.
* `latitude`: `NUMBER` vertical coordinate of the map.
* `resolution`: `NUMBER` between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`VARCHAR2(16)`

**Example**

```sql
SELECT carto.H3_FROMLONGLAT(-3.7038, 40.4168, 4) FROM DUAL;
-- 84390cbffffffff
```
