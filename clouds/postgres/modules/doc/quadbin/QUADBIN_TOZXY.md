## QUADBIN_TOZXY

```sql:signature
carto.QUADBIN_TOZXY(quadbin)
```

**Description**

Returns the zoom level `z` and coordinates `x`, `y` for a given Quadbin.

* `quadbin`: `BIGINT` Quadbin from which to obtain the coordinates.

**Return type**

`JSON`

**Example**

```sql
SELECT carto.QUADBIN_TOZXY(5209574053332910079);
-- {"z" : 4, "x" : 9, "y" : 8}
```
