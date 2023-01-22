## QUADINT_FROMLONGLAT

```sql:signature
carto.QUADINT_FROMLONGLAT(longitude, latitude, resolution)
```

**Description**

Returns the quadint representation for a given level of detail and geographic coordinates.

* `longitude`: `DOUBLE` horizontal coordinate of the map.
* `latitude`: `DOUBLE` vertical coordinate of the map.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADINT_FROMLONGLAT(40.4168, -3.7038, 4);
-- 4388
```