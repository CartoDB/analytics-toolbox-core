### QUADINT_TOZXY

{{% bannerNote type="code" %}}
quadkey.QUADINT_TOZXY(quadint)
{{%/ bannerNote %}}

**Description**

Returns the zoom level `z` and coordinates `x`, `y` for a given quadint.

* `quadint`: `BIGINT` quadint we want to extract tile information from.

**Return type**

`OBJECT`

**Example**

```sql
SELECT sfcarto.quadkey.QUADINT_TOZXY(4388);
-- z  x  y
-- 4  9  8
```