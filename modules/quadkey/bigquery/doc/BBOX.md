### BBOX

{{% bannerNote type="code" %}}
quadkey.BBOX(quadint)
{{%/ bannerNote %}}

**Description**

Returns an array with the boundary box of a given quadint. This boundary box contains the minimum and maximum longitude and latitude. The output format is [West-South, East-North] or [min long, min lat, max long, max lat].

* `quadint`: `INT64` quadint to get the bbox from.

**Return type**

`ARRAY<FLOAT64>`

**Example**

```sql
SELECT bqcarto.quadkey.BBOX(4388);
-- 22.5
-- -21.943045533438177
-- 45.0
-- 0.0
```