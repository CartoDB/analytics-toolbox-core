### H3_TOPARENT

{{% bannerNote type="code" %}}
carto.H3_TOPARENT(index, resolution)
{{%/ bannerNote %}}

**Description**

Returns the H3 cell index of the parent of the given hexagon at the given resolution.

* `index`: `STRING` The H3 cell index as hexadecimal.
* `resolution`: `INT` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`STRING`

**Example**

```sql
SELECT carto.H3_TOPARENT('847b59dffffffff', 3);
-- 837b59fffffffff
```
