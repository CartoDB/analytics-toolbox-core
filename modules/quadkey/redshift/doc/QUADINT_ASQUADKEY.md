### QUADINT_ASQUADKEY

{{% bannerNote type="code" %}}
quadkey.QUADINT_ASQUADKEY(quadint)
{{%/ bannerNote %}}

**Description**

Returns the quadkey equivalent to the input quadint.

* `quadint`: `BIGINT` quadint to be converted to quadkey.

**Return type**

`VARCHAR`

**Example**

```sql
SELECT quadkey.QUADINT_ASQUADKEY(4388);
-- 3001
```