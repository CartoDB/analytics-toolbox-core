## ST_CONVEXHULL

```sql:signature
ST_CONVEXHULL(geog)
```

**Description**

Computes the convex hull of the input geography. The convex hull is the smallest convex geography that covers the input. It returns NULL if there is no convex hull.

This is not an aggregate function. To compute the convex hull of a set of geography, use [ST_COLLECT](https://docs.snowflake.com/en/sql-reference/functions/st_collect) to aggregate them into a collection.

* `geog`: `GEOGRAPHY` input to compute the convex hull.

**Return type**

`GEOGRAPHY`

**Examples**

```sql
SELECT carto.ST_CONVEXHULL(
  TO_GEOGRAPHY('LINESTRING (-3.5938 41.0403, -4.4006 40.3266, -3.14655 40.1193, -3.7205 40.4743)')
);
-- { "coordinates": [ [ [ -3.14655, 40.1193 ], [ -4.4006, 40.3266 ], [ -3.5938, 41.0403 ], [ -3.14655, 40.1193 ] ] ], "type": "Polygon" }
```

```sql
SELECT carto.ST_CONVEXHULL(ST_COLLECT(geog))
FROM <database>.<schema>.<table>;
```

````hint:warning
**warning**

The aggregate function [ST_COLLECT](https://docs.snowflake.com/en/sql-reference/functions/st_collect) has an output limit of 16 MB. This is equivalent, approximately, to 300K points.
````
