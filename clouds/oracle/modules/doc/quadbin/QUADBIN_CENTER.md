## QUADBIN_CENTER

```sql:signature
QUADBIN_CENTER(quadbin)
```

**Description**

Returns the center for a given Quadbin. The center is the intersection point of the four immediate children Quadbin.

**Input parameters**

* `quadbin`: `NUMBER` Quadbin to get the center from.

**Return type**

`SDO_GEOMETRY`

**Example**

```sql
SELECT carto.QUADBIN_CENTER(5207251884775047167) FROM DUAL;
-- SDO_GEOMETRY(2001, 4326,
--   SDO_POINT_TYPE(-1.125000000000000e+01, 3.195216223802496e+01, NULL),
--   NULL, NULL)
```
