## QUADBIN_FROMLONGLAT

```sql:signature
QUADBIN_FROMLONGLAT(longitude, latitude, resolution)
```

**Description**

Returns the Quadbin representation of a point for a given level of detail and geographic coordinates.

* `longitude`: `FLOAT64` longitude (WGS84) of the point.
* `latitude`: `FLOAT64` latitude (WGS84) of the point.
* `resolution`: `INT64` level of detail or zoom.

**Return type**

`INT64`

**Example**

```sql
SELECT carto.QUADBIN_FROMLONGLAT(40.4168, -3.7038, 4);
-- 5209574053332910079
```
