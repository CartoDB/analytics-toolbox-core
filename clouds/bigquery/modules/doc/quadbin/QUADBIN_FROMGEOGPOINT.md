## QUADBIN_FROMGEOGPOINT

```sql:signature
QUADBIN_FROMGEOGPOINT(point, resolution)
```

**Description**

Returns the Quadbin of a given point at a given level of detail.

* `point`: `GEOGRAPHY` point to get the Quadbin from.
* `resolution`: `INT64` level of detail or zoom.

**Return type**

`INT64`

**Example**

```sql
SELECT carto.QUADBIN_FROMGEOGPOINT(ST_GEOGPOINT(40.4168, -3.7038), 4);
-- 5209574053332910079
```
