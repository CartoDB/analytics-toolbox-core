## S2_FROMLONGLAT

```sql:signature
S2_FROMLONGLAT(longitude, latitude, resolution)
```

**Description**

Returns the S2 cell ID for a given longitude, latitude and zoom resolution.

* `longitude`: `FLOAT64` horizontal coordinate on the map.
* `latitude`: `FLOAT64` vertical coordinate on the map.
* `resolution`: `INT64` level of detail or zoom.

**Return type**

`INT64`

**Example**

```sql
SELECT carto.S2_FROMLONGLAT(-3.7038, 40.4168, 8);
-- 955378847514099712
```
