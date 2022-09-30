### QUADBIN_SIBLING

{{% bannerNote type="code" %}}
carto.QUADBIN_SIBLING(quadbin, direction)
{{%/ bannerNote %}}

**Description**

Returns the Quadbin directly next to the given Quadbin at the same zoom level. The direction must be included as an argument and currently only horizontal/vertical movements are allowed.

* `quadbin`: `BIGINT` Quadbin to get the sibling from.
* `direction`: `VARCHAR` <code>'right'|'left'|'up'|'down'</code> direction to move in to extract the next sibling.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADBIN_SIBLING(5209574053332910079, 'up');
-- 5208061125333090303
```
