### QUADBIN_TOQUADKEY

{{% bannerNote type="code" %}}
carto.QUADBIN_TOQUADKEY(quadbin)
{{%/ bannerNote %}}

**Description**

Compute a quadkey from a quadbin index.

* `quadbin`: `INT64` Quadbin index.

**Return type**

`STRING`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.QUADBIN_TOQUADKEY(5233974874938015743);
-- '0231001222'
```
