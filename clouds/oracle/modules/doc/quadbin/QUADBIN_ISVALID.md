## QUADBIN_ISVALID

```sql:signature
QUADBIN_ISVALID(quadbin)
```

**Description**

Returns `1` when the given index is a valid Quadbin, `0` otherwise. Oracle has no native SQL `BOOLEAN`, so the function uses the conventional 1/0 shape — callers test with `= 1`.

**Input parameters**

* `quadbin`: `NUMBER` Quadbin index.

**Return type**

`NUMBER` (1 or 0)

**Examples**

```sql
SELECT carto.QUADBIN_ISVALID(5207251884775047167) FROM DUAL;
-- 1
```

```sql
SELECT carto.QUADBIN_ISVALID(1234) FROM DUAL;
-- 0
```
