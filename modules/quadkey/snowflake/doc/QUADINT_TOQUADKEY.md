### QUADINT_TOQUADKEY

{{% bannerNote type="code" %}}
quadkey.QUADINT_TOQUADKEY(quadint)
{{%/ bannerNote %}}

**Description**

Returns the quadkey equivalent to the input quadint.

* `quadint`: `BIGINT` quadint to be converted to quadkey.

**Return type**

`STRING`

**Example**

```sql
SELECT sfcarto.quadkey.QUADINT_TOQUADKEY(4388);
-- 3001
```