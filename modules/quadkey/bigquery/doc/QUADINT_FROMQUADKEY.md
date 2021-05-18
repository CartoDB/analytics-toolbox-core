### QUADINT_FROMQUADKEY

{{% bannerNote type="code" %}}
quadkey.QUADINT_FROMQUADKEY(quadkey)
{{%/ bannerNote %}}

**Description**

Returns the quadint equivalent to the input quadkey.

* `quadkey`: `STRING` quadkey to be converted to quadint.

**Return type**

`INT64`

**Example**

```sql
SELECT bqcarto.quadkey.QUADINT_FROMQUADKEY("3001");
-- 4388
```