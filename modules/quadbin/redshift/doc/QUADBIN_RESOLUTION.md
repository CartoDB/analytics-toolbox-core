### QUADBIN_RESOLUTION

{{% bannerNote type="code" %}}
carto.QUADBIN_RESOLUTION(quadbin)
{{%/ bannerNote %}}

**Description**

Returns the resolution of the input quadbin.

* `quadbin`: `INT64` quadbin from which to get resolution.

**Return type**

`BIGINT`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto.QUADBIN_RESOLUTION(5209574053332910079);
-- 4
```