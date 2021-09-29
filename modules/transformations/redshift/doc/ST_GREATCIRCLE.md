### ST_GREATCIRCLE

{{% bannerNote type="code" %}}
transformations.ST_GREATCIRCLE(start_point, end_point, n_points)
{{%/ bannerNote %}}

**Description**

Calculate great circles routes as LineString.

* `start_point`: `GEOMETRY` source point feature.
* `end_point`: `GEOMETRY` destination point feature.
* `n_points` (optional): `INT` number of points. If `NULL` the default value `100` is used.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT transformations.ST_GREATCIRCLE(start_point, end_point, n_points);
-- LINESTRING (-3.70325 40.4167 ...
```