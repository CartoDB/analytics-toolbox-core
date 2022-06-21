### QUADBIN_TOQUADKEY

{{% bannerNote type="code" %}}
carto.QUADBIN_TOQUADKEY(quadbin)
{{%/ bannerNote %}}

**Description**

Returns the quadkey equivalent to the input quadbin.

* `quadbin`: `BIGINT` quadbin to be converted into quadkey.

**Return type**

`VARCHAR`

**Example**

```sql
SELECT carto.QUADBIN_TOQUADKEY(4388);
-- 3001
```