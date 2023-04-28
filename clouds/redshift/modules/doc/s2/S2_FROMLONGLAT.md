## S2_FROMLONGLAT

```sql:signature
S2_FROMLONGLAT(longitude, latitude, resolution)
```

**Description**

Returns the S2 cell ID representation for a given level of detail and geographic coordinates.

* `longitude`: `FLOAT8` horizontal coordinate of the map.
* `latitude`: `FLOAT8` vertical coordinate of the map.
* `resolution`: `INT4` level of detail or zoom.

**Return type**

`INT8`

**Example**

```sql
SELECT carto.S2_FROMLONGLAT(-3.7038, 40.4168, 8);
-- 955378847514099712
```
