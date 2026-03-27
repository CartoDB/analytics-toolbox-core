## QUADBIN_ISVALID

```sql:signature
QUADBIN_ISVALID(quadbin)
```

**Description**

Returns `true` when the given index is valid, `false` otherwise.

**Input parameters**

* `quadbin`: `BIGINT` Quadbin index.

**Return type**

`BOOLEAN`

**Examples**

```sql
SELECT carto.QUADBIN_ISVALID(5207251884775047167);
-- TRUE
```

```sql
SELECT carto.QUADBIN_ISVALID(1234);
-- FALSE
```
