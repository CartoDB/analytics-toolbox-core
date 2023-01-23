## S2_BOUNDARY

```sql:signature
carto.S2_BOUNDARY(id)
```

**Description**

Returns the boundary for a given S2 Cell ID as a WKT string. Note that S2 cell vertices should be joined with geodesic edges (great circles), not straight lines in a planar projection.

* `id`: `INT8` id to get the boundary geography from.

**Return type**

`VARCHAR(MAX)`

**Example**

```sql
SELECT carto.S2_BOUNDARY(1733885856537640960);
-- POLYGON ((-3.88131218692 39.9812346589, -3.58252176617 45.0, 0.0 45.0, 0.0 39.9812346589, -3.88131218692 39.9812346589))
```
