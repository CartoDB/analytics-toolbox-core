## QUADBIN_FROMGEOGPOINT

```sql:signature
QUADBIN_FROMGEOGPOINT(point, resolution)
```

**Description**

Returns the Quadbin of a given point at a requested resolution. This function is an alias for `QUADBIN_FROMGEOPOINT`.

* `point`: `GEOGRAPHY` point to get the Quadbin from.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADBIN_FROMGEOGPOINT(ST_POINT(-3.7038, 40.4168), 4);
-- 5207251884775047167
```
