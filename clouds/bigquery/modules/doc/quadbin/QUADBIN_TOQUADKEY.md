## QUADBIN_TOQUADKEY

```sql:signature
QUADBIN_TOQUADKEY(quadbin)
```

**Description**

Compute a quadkey from a quadbin index.

* `quadbin`: `INT64` Quadbin index.

**Return type**

`STRING`

**Example**

```sql
SELECT carto.QUADBIN_TOQUADKEY(5233974874938015743);
-- '0231001222'
```
