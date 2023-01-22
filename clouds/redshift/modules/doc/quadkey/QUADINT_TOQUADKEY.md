## QUADINT_TOQUADKEY

```sql:signature
carto.QUADINT_TOQUADKEY(quadint)
```

**Description**

Returns the quadkey equivalent to the input quadint.

* `quadint`: `BIGINT` quadint to be converted into quadkey.

**Return type**

`VARCHAR`

**Example**

```sql
SELECT carto.QUADINT_TOQUADKEY(4388);
-- 3001
```