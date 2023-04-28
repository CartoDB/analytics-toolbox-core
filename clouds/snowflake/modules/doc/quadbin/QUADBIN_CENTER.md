## QUADBIN_CENTER

```sql:signature
QUADBIN_CENTER(quadbin)
```

**Description**

Returns the center for a given Quadbin. The center is the intersection point of the four immediate children Quadbin.

* `quadbin`: `BIGINT` Quadbin to get the center from.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.QUADBIN_CENTER(5207251884775047167);
-- { "coordinates": [ -1.125000000000000e+01, 3.195216223802496e+01 ], "type": "Point" }
```
