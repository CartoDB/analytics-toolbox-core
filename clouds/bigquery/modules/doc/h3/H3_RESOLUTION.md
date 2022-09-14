### H3_RESOLUTION

{{% bannerNote type="code" %}}
carto.H3_RESOLUTION(index)
{{%/ bannerNote %}}

**Description**

Returns the H3 cell resolution as an integer. It will return `null` on error (invalid input).

* `index`: `STRING` The H3 cell index.

**Return type**

`INT64`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.H3_RESOLUTION('847b59dffffffff');
-- 4
```