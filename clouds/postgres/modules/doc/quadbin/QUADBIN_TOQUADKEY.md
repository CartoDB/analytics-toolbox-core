## QUADBIN_TOQUADKEY

```sql:signature
QUADBIN_TOQUADKEY(quadbin)
```

**Description**

Compute a quadkey from a quadbin index.

* `quadbin`: `BIGINT` Quadbin index.

**Return type**

`TEXT`

**Example**

```sql
SELECT carto.QUADBIN_TOQUADKEY(5233974874938015743);
-- '0231001222'
```
