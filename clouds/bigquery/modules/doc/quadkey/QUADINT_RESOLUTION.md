### QUADINT_RESOLUTION

{{% bannerNote type="code" %}}
carto.QUADINT_RESOLUTION(quadint)
{{%/ bannerNote %}}

**Description**

Returns the resolution of the input quadint.

* `quadint`: `INT64` quadint from which to get resolution.

**Return type**

`INT64`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.QUADINT_RESOLUTION(4388);
-- 4
```
