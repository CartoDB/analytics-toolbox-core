### QUADBIN_RESOLUTION

{{% bannerNote type="code" %}}
carto.QUADBIN_RESOLUTION(quadbin)
{{%/ bannerNote %}}

**Description**

Returns the resolution of the input quadbin.

* `quadbin`: `INT` quadbin from which to get resolution.

**Return type**

`INT`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto.QUADBIN_RESOLUTION(5209574053332910079);
-- 4
```