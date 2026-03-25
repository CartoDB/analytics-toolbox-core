## QUADBIN_FROMGEOGPOINT

```sql:signature
QUADBIN_FROMGEOGPOINT(point, resolution)
```

**Description**

Returns the Quadbin of a given point at a requested resolution.

**Input parameters**

* `point`: `GEOMETRY(4326)` geographic point.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADBIN_FROMGEOGPOINT(ST_POINT(-3.7038, 40.4168, 4326), 4);
-- 5207251884775047167
```
