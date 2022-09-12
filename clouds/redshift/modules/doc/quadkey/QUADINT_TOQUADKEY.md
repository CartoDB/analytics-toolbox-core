### QUADINT_TOQUADKEY

{{% bannerNote type="code" %}}
carto.QUADINT_TOQUADKEY(quadint)
{{%/ bannerNote %}}

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
