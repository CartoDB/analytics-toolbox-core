### ST_BOUNDARY

{{% bannerNote type="code" %}}
s2.ST_BOUNDARY(id)
{{%/ bannerNote %}}

**Description**

Returns the boundary for a given S2 Cell ID as a WKT string. Note that S2 cell vertices should be joined with geodesic edges (great circles), not straight lines in a planar projection.

* `id`: `VARCHAR` id to get the boundary geography from.

**Return type**

`VARCHAR`

**Example**

```sql
SELECT s2.ST_BOUNDARY(4388);
--POLYGON ((-3.88131218692 39.9812346589, -3.58252176617 45.0, 0.0 45.0, 0.0 39.9812346589, -3.88131218692 39.9812346589))
```