## QUADBIN_FROMQUADKEY

```sql:signature
QUADBIN_FROMQUADKEY(quadkey)
```

**Description**

Compute a quadbin index from a quadkey.

* `quadkey`: `TEXT` Quadkey representation of the index.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADBIN_FROMQUADKEY('0231001222');
-- 5233974874938015743
```
