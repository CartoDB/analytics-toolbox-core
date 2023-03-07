## QUADBIN_FROMGEOGPOINT

```sql:signature
QUADBIN_FROMGEOGPOINT(point, resolution)
```

**Description**

Returns the Quadbin of a given point at a given level of detail.

* `point`: `GEOMETRY` point to get the Quadbin from.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADBIN_FROMGEOGPOINT(ST_POINT(40.4168, -3.7038), 4);
-- 5209574053332910079
```
