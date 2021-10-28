### QUADINT_FROMQUADKEY

{{% bannerNote type="code" %}}
carto.QUADINT_FROMQUADKEY(quadkey)
{{%/ bannerNote %}}

**Description**

Returns the quadint equivalent to the input quadkey.

* `quadkey`: `STRING` quadkey to be converted to quadint.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADINT_FROMQUADKEY("3001");
-- 4388
```