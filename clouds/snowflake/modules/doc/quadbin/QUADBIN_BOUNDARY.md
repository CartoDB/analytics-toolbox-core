## QUADBIN_BOUNDARY

```sql:signature
QUADBIN_BOUNDARY(quadbin)
```

**Description**

Returns the boundary for a given Quadbin as a polygon GEOMETRY with the same coordinates as given by the [QUADBIN_BBOX](quadbin#quadbin_bbox) function.

* `quadbin`: `BIGINT` Quadbin to get the boundary geography from.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.QUADBIN_BOUNDARY(5207251884775047167);
-- { "coordinates": [ [ [ 0, 40.97989806962013 ], [ 0, 21.94304553343818 ], ...
```
