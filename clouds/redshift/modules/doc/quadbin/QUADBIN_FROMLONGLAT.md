## QUADBIN_FROMLONGLAT

```sql:signature
carto.QUADBIN_FROMLONGLAT(longitude, latitude, resolution)
```

**Description**

Returns the Quadbin representation of a point for a given level of detail and geographic coordinates.

* `longitude`: `FLOAT8` longitude (WGS84) of the point.
* `latitude`: `FLOAT8` latitude (WGS84) of the point.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADBIN_FROMLONGLAT(40.4168, -3.7038, 4);
-- 5209574053332910079
```
