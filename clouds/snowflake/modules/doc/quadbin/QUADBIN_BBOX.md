## QUADBIN_BBOX

```sql:signature
QUADBIN_BBOX(quadbin)
```

**Description**

Returns an array with the boundary box of a given Quadbin. This boundary box contains the minimum and maximum longitude and latitude. The output format is [West-South, East-North] or [min long, min lat, max long, max lat].

* `quadbin`: `BIGINT` Quadbin to get the bbox from.

**Return type**

`ARRAY<FLOAT64>`

**Example**

```sql
SELECT carto.QUADBIN_BBOX(5207251884775047167);
-- -2.250000000000000e+01,
-- 2.194304553343818e+01,
-- 0,
-- 4.097989806962013e+01
```
