### QUADINT_BBOX

{{% bannerNote type="code" %}}
quadkey.QUADINT_BBOX(quadint)
{{%/ bannerNote %}}

**Description**

Returns an array with the boundary box of a given quadint. This boundary box contains the minimum and maximum longitude and latitude. The output format is [West-South, East-North] or [min long, min lat, max long, max lat].

* `quadint`: `BIGINT` quadint to get the bbox from.

**Return type**

`ARRAY`

**Example**

```sql
SELECT sfcarto.quadkey.QUADINT_BBOX(4388);
-- 22.5
-- -21.943045533438177
-- 45.0
-- 0.0
```