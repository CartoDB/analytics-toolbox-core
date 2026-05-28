## QUADBIN_BOUNDARY

```sql:signature
QUADBIN_BOUNDARY(quadbin)
```

**Description**

Returns the boundary for a given Quadbin as a polygon `SDO_GEOMETRY` (SRID 4326) with the same coordinates as given by the [QUADBIN_BBOX](quadbin#quadbin_bbox) function.

**Input parameters**

* `quadbin`: `NUMBER` Quadbin to get the boundary geometry from.

**Return type**

`SDO_GEOMETRY`

**Example**

```sql
SELECT carto.QUADBIN_BOUNDARY(5207251884775047167) FROM DUAL;
-- SDO_GEOMETRY(2003, 4326, NULL,
--   SDO_ELEM_INFO_ARRAY(1, 1003, 1),
--   SDO_ORDINATE_ARRAY(0, 40.97989806962013, 0, 21.94304553343818, ...))
```
