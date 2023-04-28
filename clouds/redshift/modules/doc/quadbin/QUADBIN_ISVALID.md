## QUADBIN_ISVALID

```sql:signature
QUADBIN_ISVALID(quadbin)
```

**Description**

Returns `true` when the given index is a valid Quadbin, `false` otherwise.

* `quadbin`: `BIGINT` Quadbin index.

**Return type**

`BOOLEAN`

**Examples**

```sql
SELECT carto.QUADBIN_ISVALID(5207251884775047167);
-- true
```

```sql
SELECT carto.QUADBIN_ISVALID(1234);
-- false
```
