### QUADBIN_RESOLUTION

{{% bannerNote type="code" %}}
carto.QUADBIN_RESOLUTION(quadbin)
{{%/ bannerNote %}}

**Description**

Returns the resolution of the input Quadbin.

* `quadbin`: `INT64` Quadbin from which to get resolution.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADBIN_RESOLUTION(5209574053332910079);
-- 4
```
