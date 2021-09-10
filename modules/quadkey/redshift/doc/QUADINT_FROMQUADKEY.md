### QUADINT_FROMQUADKEY

{{% bannerNote type="code" %}}
quadkey.QUADINT_FROMQUADKEY(quadkey)
{{%/ bannerNote %}}

**Description**

Returns the quadint equivalent to the input quadkey.

* `quadkey`: `VARCHAR` quadkey to be converted to quadint.

**Return type**

`BIGINT`

**Example**

```sql
SELECT quadkey.QUADINT_FROMQUADKEY('3001');
-- 4388
```