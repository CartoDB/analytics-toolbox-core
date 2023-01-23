## QUADBIN_TOZXY

```sql:signature
carto.QUADBIN_TOZXY(quadbin)
```

**Description**

Returns the zoom level `z` and coordinates `x`, `y` for a given Quadbin.

* `quadbin`: `INT64` Quadbin from which to obtain the coordinates.

**Return type**

`STRUCT<INT64, INT64, INT64>`

**Example**

```sql
SELECT `carto-os`.carto.QUADBIN_TOZXY(5209574053332910079);
-- z  x  y
-- 4  9  8
```
