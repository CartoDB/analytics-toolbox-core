## QUADBIN_ISVALID

```sql:signature
carto.QUADBIN_ISVALID(quadbin)
```

**Description**

Returns `true` when the given index is valid, `false` otherwise.

* `quadbin`: `BIGINT` Quadbin index.

**Return type**

`BOOLEAN`

**Examples**

```sql
SELECT carto.QUADBIN_ISVALID(5209574053332910079);
-- true
```

```sql
SELECT carto.QUADBIN_ISVALID(1234);
-- false
```