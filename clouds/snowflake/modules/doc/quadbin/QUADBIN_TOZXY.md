## QUADBIN_TOZXY

```sql:signature
carto.QUADBIN_TOZXY(quadbin)
```

**Description**

Returns the zoom level `z` and coordinates `x`, `y` for a given Quadbin.

* `quadbin`: `BIGINT` Quadbin from which to obtain the coordinates.

**Return type**

`STRUCT<INT, INT, INT>`

**Example**

```sql
SELECT carto.QUADBIN_TOZXY(5209574053332910079);
-- z  x  y
-- 4  9  8
```