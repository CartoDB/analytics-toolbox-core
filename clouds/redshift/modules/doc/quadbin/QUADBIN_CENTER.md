## QUADBIN_CENTER

```sql:signature
carto.QUADBIN_CENTER(quadbin)
```

**Description**

Returns the center for a given Quadbin. The center is the intersection point of the four immediate children Quadbin.

* `quadbin`: `BIGINT` Quadbin to get the center from.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT carto.QUADBIN_CENTER(5209574053332910079);
-- POINT (33.75 -10.9715227667)
```