### QUADBIN_FROMQUADKEY

{{% bannerNote type="code" %}}
carto.QUADBIN_FROMQUADKEY(quadkey)
{{%/ bannerNote %}}

**Description**

Compute a quadbin index from a quadkey.

* `quadkey`: `TEXT` Quadkey representation of the index.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADBIN_FROMQUADKEY('0231001222');
-- 5233974874938015743
```
