## QUADBIN_CENTER

```sql:signature
QUADBIN_CENTER(quadbin)
```

**Description**

Returns the center of a given Quadbin as an array `[longitude, latitude]`. The center is the intersection point of the four immediate children Quadbin.

* `quadbin`: `BIGINT` Quadbin to get the center from.

**Return type**

`ARRAY<DOUBLE>`

**Example**

```sql
SELECT carto.QUADBIN_CENTER(5207251884775047167);
-- [-11.25, 31.952162238024955]
```
