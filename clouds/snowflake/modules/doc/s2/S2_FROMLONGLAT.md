## S2_FROMLONGLAT

```sql:signature
S2_FROMLONGLAT(longitude, latitude, resolution)
```

**Description**

Returns the S2 cell ID for a given longitude, latitude and zoom resolution.

* `longitude`: `DOUBLE` horizontal coordinate on the map.
* `latitude`: `DOUBLE` vertical coordinate on the map.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.S2_FROMLONGLAT(-3.7038, 40.4168, 8);
-- 955378847514099712
```
