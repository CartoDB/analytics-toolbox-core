### H3_INT_TOSTRING

{{% bannerNote type="code" %}}
carto.H3_INT_TO_STRING(index)
{{%/ bannerNote %}}

**Description**

Converts the integer representation of the H3 index to the string representation.

* `index`: `INT64` The H3 cell index.

**Return type**

`STRING`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.H3_INT_TO_STRING(596645165859340287);
-- 847b59dffffffff
```
