## QUADBIN_TOZXY

```sql:signature
QUADBIN_TOZXY(quadbin)
```

**Description**

Returns the zoom level `z` and coordinates `x`, `y` for a given Quadbin.

* `quadbin`: `BIGINT` Quadbin from which to obtain the coordinates.

**Return type**

`JSON`

**Example**

```sql
SELECT carto.QUADBIN_TOZXY(5207251884775047167);
-- {"z" : 4, "x" : 7, "y" : 6}
```
