### S2_RESOLUTION

{{% bannerNote type="code" %}}
carto.S2_RESOLUTION(index)
{{%/ bannerNote %}}

**Description**

Returns the S2 cell resolution as an integer.

* `index`: `STRING` The S2 cell index.

**Return type**

`INT64`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.S2_RESOLUTION(-6432928348669739008);
-- 11
```
