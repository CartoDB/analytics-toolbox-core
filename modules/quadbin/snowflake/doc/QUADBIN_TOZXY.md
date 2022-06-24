### QUADBIN_TOZXY

{{% bannerNote type="code" %}}
carto.QUADBIN_TOZXY(quadbin)
{{%/ bannerNote %}}

**Description**

Returns the zoom level `z` and coordinates `x`, `y` for a given quadbin.

* `quadbin`: `BIGINT` quadbin we want to extract tile information from.

**Return type**

`STRUCT<INT, INT, INT>`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto.QUADBIN_TOZXY(5209574053332910079);
-- z  x  y
-- 4  9  8
```