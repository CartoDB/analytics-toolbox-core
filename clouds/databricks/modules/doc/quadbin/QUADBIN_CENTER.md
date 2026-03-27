## QUADBIN_CENTER

```sql:signature
QUADBIN_CENTER(quadbin)
```

**Description**

Returns the center of a given Quadbin as a `GEOMETRY(4326)` POINT. The center is the intersection point of the four immediate children Quadbin.

**Input parameters**

* `quadbin`: `BIGINT` Quadbin to get the center from.

**Return type**

`GEOMETRY(4326)`

**Example**

```sql
SELECT ST_ASTEXT(carto.QUADBIN_CENTER(5207251884775047167));
-- POINT(-11.25 31.952162238024955)
```
