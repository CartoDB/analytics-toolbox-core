### QUADBIN_TOZXY

{{% bannerNote type="code" %}}
carto.QUADBIN_TOZXY(quadbin)
{{%/ bannerNote %}}

**Description**

Returns the zoom level `z` and coordinates `x`, `y` for a given quadbin.

* `quadbin`: `BIGINT` quadbin we want to extract tile information from.

**Return type**

`SUPER`

**Example**

```sql
SELECT carto.QUADBIN_TOZXY(4388);
-- z  x  y
-- 4  9  8
```