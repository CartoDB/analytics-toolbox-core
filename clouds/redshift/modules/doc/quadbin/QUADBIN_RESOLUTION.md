### QUADBIN_RESOLUTION

{{% bannerNote type="code" %}}
carto.QUADBIN_RESOLUTION(quadbin)
{{%/ bannerNote %}}

**Description**

Returns the resolution of the input Quadbin.

* `quadbin`: `BIGINT` Quadbin from which to get the resolution.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADBIN_RESOLUTION(5209574053332910079);
-- 4
```
