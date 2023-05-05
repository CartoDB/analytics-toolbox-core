## QUADBIN_BOUNDARY

```sql:signature
QUADBIN_BOUNDARY(quadbin)
```

**Description**

Returns the boundary for a given Quadbin as a polygon GEOMETRY with the same coordinates as given by the [QUADBIN_BBOX](quadbin#quadbin_bbox) function.

* `quadbin`: `BIGINT` Quadbin to get the boundary geometry from.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.QUADBIN_BOUNDARY(5207251884775047167);
-- POLYGON ((-22.5 21.943045533438188, -22.5 40.97989806962013, 0 40.97989806962013, 0 21.943045533438188, -22.5 21.943045533438188))
```
