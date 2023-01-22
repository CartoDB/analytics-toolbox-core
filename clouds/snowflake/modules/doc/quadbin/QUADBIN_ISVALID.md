## QUADBIN_ISVALID

```sql:signature
carto.QUADBIN_ISVALID(quadbin)
```

**Description**

Returns `true` when the given index is a valid Quadbin, `false` otherwise.

* `quadbin`: `BIGINT` Quadbin index.

**Return type**

`BOOLEAN`

**Example**

```sql
SELECT carto.QUADBIN_ISVALID(5209574053332910079);
-- true
```

```sql
SELECT carto.QUADBIN_ISVALID(1234);
-- false
```