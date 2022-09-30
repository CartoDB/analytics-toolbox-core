### QUADBIN_BBOX

{{% bannerNote type="code" %}}
carto.QUADBIN_BBOX(quadbin)
{{%/ bannerNote %}}

**Description**

Returns an array with the boundary box of a given Quadbin. This boundary box contains the minimum and maximum longitude and latitude. The output format is [West-South, East-North] or [min long, min lat, max long, max lat].

* `quadbin`: `BIGINT` Quadbin to get the boundary box from.

**Return type**

`SUPER`

**Example**

```sql
SELECT carto.QUADBIN_BBOX(5209574053332910079);
-- 22.5
-- -21.943045533438177
-- 45.0
-- 0.0
```
