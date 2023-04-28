## S2_BOUNDARY

```sql:signature
S2_BOUNDARY(id)
```

**Description**

Returns the boundary for a given S2 Cell ID as a WKT string. Note that S2 cell vertices should be joined with geodesic edges (great circles), not straight lines in a planar projection.

* `id`: `INT8` id to get the boundary geography from.

**Return type**

`VARCHAR(MAX)`

**Example**

```sql
SELECT carto.S2_BOUNDARY(955378847514099712);
-- POLYGON ((-3.74350899127 40.2485011413, -3.41955272426 40.2585007122, -3.41955272426 40.5842313862, -3.74350899127 40.5742134506, -3.74350899127 40.2485011413))
```
