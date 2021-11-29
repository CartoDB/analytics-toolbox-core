### QUADINT_TOQUADKEY

{{% bannerNote type="code" %}}
quadkey.QUADINT_TOQUADKEY(quadint)
{{%/ bannerNote %}}

**Description**

Returns the quadkey equivalent to the input quadint.

* `quadint`: `INT64` quadint to be converted to quadkey.

**Return type**

`STRING`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.quadkey.QUADINT_TOQUADKEY(4388);
-- 3001
```