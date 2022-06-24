### QUADBIN_STRING_TOINT

{{% bannerNote type="code" %}}
carto.QUADBIN_STRING_TOINT(quadbin)
{{%/ bannerNote %}}

**Description**

Converts the string representation of the index to the integer representation.

* `quadbin`: `STRING` quadbin string to be converted to integer.

**Return type**

`INT`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto.QUADBIN_STRING_TOINT('484c1fffffffffff');
-- 5209574053332910079
```