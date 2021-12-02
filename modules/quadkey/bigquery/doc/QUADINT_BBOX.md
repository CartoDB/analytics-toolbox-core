### QUADINT_BBOX

{{% bannerNote type="code" %}}
carto.QUADINT_BBOX(quadint)
{{%/ bannerNote %}}

**Description**

Returns an array with the boundary box of a given quadint. This boundary box contains the minimum and maximum longitude and latitude. The output format is [West-South, East-North] or [min long, min lat, max long, max lat].

* `quadint`: `INT64` quadint to get the bbox from.

**Return type**

`ARRAY<FLOAT64>`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.carto.QUADINT_BBOX(4388);
-- 22.5
-- -21.943045533438177
-- 45.0
-- 0.0
```