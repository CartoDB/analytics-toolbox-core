### H3_TOCHILDREN

{{% bannerNote type="code" %}}
carto.H3_TOCHILDREN(index, resolution)
{{%/ bannerNote %}}

**Description**

Returns an array with the indexes of the children/descendents of the given hexagon at the given resolution.

* `index`: `STRING` The H3 cell index.
* `resolution`: `INT64` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`ARRAY<STRING>`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto-os.carto.H3_TOCHILDREN('837b59fffffffff', 4);
-- 847b591ffffffff
-- 847b593ffffffff
-- 847b595ffffffff
-- 847b597ffffffff
-- 847b599ffffffff
-- 847b59bffffffff
-- 847b59dffffffff
```