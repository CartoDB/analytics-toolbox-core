### QUADBIN_FROMQUADKEY

{{% bannerNote type="code" %}}
carto.QUADBIN_FROMQUADKEY(quadkey)
{{%/ bannerNote %}}

**Description**

Returns the quadbin equivalent to the input quadkey.

* `quadkey`: `VARCHAR` quadkey to be converted to quadbin.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADBIN_FROMQUADKEY('3001');
-- 4388
```