## QUADINT_FROMQUADKEY

```sql:signature
carto.QUADINT_FROMQUADKEY(quadkey)
```

**Description**

Returns the quadint equivalent to the input quadkey.

* `quadkey`: `STRING` quadkey to be converted to quadint.

**Return type**

`INT64`

**Example**

```sql
SELECT `carto-os`.carto.QUADINT_FROMQUADKEY("3001");
-- 4388
```
