### QUADBIN_SIBLING

{{% bannerNote type="code" %}}
carto.QUADBIN_SIBLING(quadbin, direction)
{{%/ bannerNote %}}

**Description**

Returns the quadbin directly next to the given quadbin at the same zoom level. The direction must be included as an argument and currently only horizontal/vertical movements are allowed.

* `quadbin`: `BIGINT` quadbin to get the sibling from.
* `direction`: `VARCHAR` <code>'right'|'left'|'up'|'down'</code> direction to move in to extract the next sibling. 

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADBIN_SIBLING(4388, 'up');
-- 3876
```