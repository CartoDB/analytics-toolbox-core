### QUADBIN_RESOLUTION

{{% bannerNote type="code" %}}
carto.QUADBIN_RESOLUTION(quadbin)
{{%/ bannerNote %}}

**Description**

Returns the resolution of the input quadbin.

* `quadbin`: `INT64` quadbin from which to get resolution.

**Return type**

`INT64`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.QUADBIN_RESOLUTION(5209574053332910079);
-- 4
```
