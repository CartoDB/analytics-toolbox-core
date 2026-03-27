## QUADBIN_BOUNDARY

```sql:signature
QUADBIN_BOUNDARY(quadbin)
```

**Description**

Returns the boundary for a given Quadbin as a `GEOMETRY(4326)` POLYGON with the same coordinates as given by the [QUADBIN_BBOX](quadbin#quadbin_bbox) function.

**Input parameters**

* `quadbin`: `BIGINT` Quadbin to get the boundary from.

**Return type**

`GEOMETRY(4326)`

**Example**

```sql
SELECT ST_ASTEXT(carto.QUADBIN_BOUNDARY(5207251884775047167));
-- POLYGON((-22.5 21.9430455334,-22.5 40.9798980696,0.0 40.9798980696,0.0 21.9430455334,-22.5 21.9430455334))
```
