## QUADBIN_FROMGEOGPOINT

```sql:signature
QUADBIN_FROMGEOGPOINT(point, resolution)
```

**Description**

Returns the Quadbin of a given point at a given level of detail. This function is an alias for `QUADBIN_FROMGEOPOINT`.

* `point`: `GEOGRAPHY` point to get the Quadbin from.
* `resolution`: `INT64` level of detail or zoom.

**Return type**

`INT64`

**Example**

```sql
SELECT carto.QUADBIN_FROMGEOGPOINT(ST_GEOGPOINT(-3.7038, 40.4168), 4);
-- 5207251884775047167
```
