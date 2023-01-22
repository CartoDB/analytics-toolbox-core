## ST_GREATCIRCLE

```sql:signature
carto.ST_GREATCIRCLE(start_point, end_point, n_points)
```

**Description**

Calculates a great circle route as a LineString.

* `start_point`: `GEOMETRY` source point feature.
* `end_point`: `GEOMETRY` destination point feature.
* `n_points` (optional): `INT` number of points. Defaults to `100`.

**Return type**

`GEOMETRY`

**Examples**

```sql
SELECT carto.ST_GREATCIRCLE(ST_MAKEPOINT(-3.70325,40.4167), ST_MAKEPOINT(-73.9385,40.6643));
-- LINESTRING (-3.70325 40.4167, -4.32969777937 40.6355528695, ...
```

```sql
SELECT carto.ST_GREATCIRCLE(ST_MAKEPOINT(-3.70325,40.4167), ST_MAKEPOINT(-73.9385,40.6643), 20);
-- LINESTRING (-3.70325 40.4167, -7.01193184681 41.5188665219, ...
```