## QUADBIN_TOZXY

```sql:signature
QUADBIN_TOZXY(quadbin)
```

**Description**

Returns the zoom level `z` and coordinates `x`, `y` for a given Quadbin.

**Input parameters**

* `quadbin`: `NUMBER` Quadbin from which to obtain the coordinates.

**Return type**

`QUADBIN_ZXY` (object with `z`, `x`, `y` of type `NUMBER`)

**Example**

```sql
SELECT t.zxy.z, t.zxy.x, t.zxy.y
FROM (SELECT carto.QUADBIN_TOZXY(5207251884775047167) AS zxy FROM DUAL) t;
-- z  x  y
-- 4  7  6
```
