## QUADINT_TOZXY

```sql:signature
carto.QUADINT_TOZXY(quadint)
```

**Description**

Returns the zoom level `z` and coordinates `x`, `y` for a given quadint.

* `quadint`: `BIGINT` quadint we want to extract tile information from.

**Return type**

`OBJECT`

**Example**

```sql
SELECT carto.QUADINT_TOZXY(4388);
-- z  x  y
-- 4  9  8
```