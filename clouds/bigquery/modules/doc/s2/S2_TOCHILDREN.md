### S2_TOCHILDREN

{{% bannerNote type="code" %}}
carto.S2_TOCHILDREN(index, resolution)
{{%/ bannerNote %}}

**Description**

Returns an array with the S2 indexes of the children/descendents of the given hexagon at the given resolution.

* `index`: `STRING` The S2 cell index.
* `resolution`: `INT64` number between 0 and 30 with the [S2 resolution](https://S2geo.org/docs/core-library/restable).

**Return type**

`ARRAY<STRING>`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.S2_TOCHILDREN(-6432928348669739008, 12);
-- 6432928554828169216
-- 6432928417389215744
-- 6432928279950262272
-- 6432928142511308800
```