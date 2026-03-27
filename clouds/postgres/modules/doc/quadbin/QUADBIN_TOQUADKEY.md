## QUADBIN_TOQUADKEY

```sql:signature
QUADBIN_TOQUADKEY(quadbin)
```

**Description**

Compute a quadkey from a quadbin index.

**Input parameters**

* `quadbin`: `BIGINT` Quadbin index.

**Return type**

`TEXT`

**Example**

```sql
SELECT carto.QUADBIN_TOQUADKEY(5234261499580514303);
-- '0331110121'
```
