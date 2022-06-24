### QUADBIN_SIBLING

{{% bannerNote type="code" %}}
carto.QUADBIN_SIBLING(quadbin, direction)
{{%/ bannerNote %}}

**Description**

Returns the quadbin directly next to the given quadbin at the same zoom level. The direction must be sent as argument and currently only horizontal/vertical movements are allowed.

* `quadbin`: `BIGINT` quadbin to get the sibling from.
* `direction`: `STRING` <code>'right'|'left'|'up'|'down'</code> direction to move in to extract the next sibling.

**Return type**

`BIGINT`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto.QUADBIN_SIBLING(5209574053332910079, 'up');
-- 5208061125333090303
```