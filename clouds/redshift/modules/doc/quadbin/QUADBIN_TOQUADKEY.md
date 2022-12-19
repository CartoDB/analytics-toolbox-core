### QUADBIN_TOQUADKEY

{{% bannerNote type="code" %}}
carto.QUADBIN_TOQUADKEY(quadbin)
{{%/ bannerNote %}}

**Description**

Compute a quadkey from a quadbin index.

* `quadbin`: `BIGINT` Quadbin index.

**Return type**

`VARCHAR(MAX)`

**Example**

```sql
SELECT carto.QUADBIN_TOQUADKEY(5233974874938015743);
-- '0231001222'
```