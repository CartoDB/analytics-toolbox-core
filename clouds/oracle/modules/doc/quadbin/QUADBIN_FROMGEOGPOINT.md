## QUADBIN_FROMGEOGPOINT

```sql:signature
QUADBIN_FROMGEOGPOINT(point, resolution)
```

**Description**

Returns the Quadbin of a given point at a requested resolution. The input point is interpreted as WGS84 (EPSG:4326).

**Input parameters**

* `point`: `SDO_GEOMETRY` point to get the Quadbin from.
* `resolution`: `NUMBER` level of detail or zoom.

**Return type**

`NUMBER`

**Example**

```sql
SELECT carto.QUADBIN_FROMGEOGPOINT(
    SDO_GEOMETRY(2001, 4326, SDO_POINT_TYPE(-3.7038, 40.4168, NULL), NULL, NULL),
    4
) FROM DUAL;
-- 5207251884775047167
```
