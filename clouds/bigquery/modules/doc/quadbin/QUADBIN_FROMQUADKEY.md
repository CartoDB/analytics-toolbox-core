## QUADBIN_FROMQUADKEY

```sql:signature
QUADBIN_FROMQUADKEY(quadkey)
```

**Description**

Compute a quadbin index from a quadkey.

* `quadkey`: `STRING` Quadkey representation of the index.

**Return type**

`INT64`

**Example**

```sql
SELECT carto.QUADBIN_FROMQUADKEY('0331110121');
-- 5234261499580514303
```
