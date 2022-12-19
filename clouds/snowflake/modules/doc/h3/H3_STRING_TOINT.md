### H3_STRING_TOINT

{{% bannerNote type="code" %}}
carto.H3_STRING_TOINT(index)
{{%/ bannerNote %}}

**Description**

Converts the string representation of the H3 index to the integer representation.

* `index`: `STRING` The H3 cell index.

**Return type**

`INT`

**Example**

```sql
SELECT carto.H3_STRING_TOINT('847b59dffffffff');
-- 596645165859340287
```