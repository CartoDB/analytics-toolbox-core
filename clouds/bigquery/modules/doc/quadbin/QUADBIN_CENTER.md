## QUADBIN_CENTER

```sql:signature
QUADBIN_CENTER(quadbin)
```

**Description**

Returns the center of a given Quadbin. The center is the intersection point of the four immediate children Quadbins.

* `quadbin`: `INT64` Quadbin to get the center from.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.QUADBIN_CENTER(5207251884775047167);
-- POINT(-11.25 31.952162238025)
```
