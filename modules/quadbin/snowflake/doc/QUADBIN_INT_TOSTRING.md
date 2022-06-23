### QUADBIN_INT_TOSTRING

{{% bannerNote type="code" %}}
carto.QUADBIN_INT_TOSTRING(quadbin)
{{%/ bannerNote %}}

**Description**

Converts the integer representation of the index to the string representation.

* `quadbin`: `INT` quadbin integer to be converted to string.

**Return type**

`STRING`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto.QUADBIN_INT_TOSTRING(5209574053332910079);
-- 484c1fffffffffff
```