## QUADBIN_FROMGEOGPOINT

```sql:signature
QUADBIN_FROMGEOGPOINT(longitude, latitude, resolution)
```

**Description**

Returns the Quadbin of a given point at a requested resolution. This function is an alias for `QUADBIN_FROMLONGLAT`.

* `longitude`: `DOUBLE` longitude (WGS84) of the point.
* `latitude`: `DOUBLE` latitude (WGS84) of the point.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADBIN_FROMGEOGPOINT(-3.7038, 40.4168, 4);
-- 5207251884775047167
```
