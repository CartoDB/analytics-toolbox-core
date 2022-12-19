### H3_INT_TOSTRING

{{% bannerNote type="code" %}}
carto.H3_INT_TOSTRING(index)
{{%/ bannerNote %}}

**Description**

Converts the integer representation of the H3 index to the string representation.

* `index`: `INT` The H3 cell index.

**Return type**

`STRING`

**Example**

```sql
SELECT carto.H3_INT_TOSTRING(596645165859340287);
-- 847b59dffffffff
```