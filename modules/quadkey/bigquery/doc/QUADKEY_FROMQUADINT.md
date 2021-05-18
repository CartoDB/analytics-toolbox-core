### QUADKEY_FROMQUADINT

{{% bannerNote type="code" %}}
quadkey.QUADKEY_FROMQUADINT(quadint)
{{%/ bannerNote %}}

**Description**

Returns the quadkey equivalent to the input quadint.

* `quadint`: `INT64` quadint to be converted to quadkey.

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.quadkey.QUADKEY_FROMQUADINT(4388);
-- 3001
```