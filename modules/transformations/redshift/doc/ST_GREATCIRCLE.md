### ST_GREATCIRCLE

{{% bannerNote type="code" %}}
transformations.ST_GREATCIRCLE(start_point, end_point, n_points)
{{%/ bannerNote %}}

**Description**

Calculate great circles routes as LineString.

* `start_point`: `GEOMETRY` source point feature.
* `end_point`: `GEOMETRY` destination point feature.
* `n_points` (optional): `INT` number of points. By default `npoints` is `100`.

**Return type**

`GEOMETRY`

**Examples**

```sql
SELECT transformations.ST_GREATCIRCLE(ST_MakePoint(-3.70325,40.4167), ST_MakePoint(-73.9385,40.6643));
-- LINESTRING (-3.70325 40.4167, -4.329698 40.635553, ...
```

```sql
SELECT transformations.ST_GREATCIRCLE(ST_MakePoint(-3.70325,40.4167), ST_MakePoint(-73.9385,40.6643), 20);
-- LINESTRING (-3.70325 40.4167, -7.011932 41.518867, ...
```