### SIBLING

{{% bannerNote type="code" %}}
quadkey.SIBLING(quadint, direction)
{{%/ bannerNote %}}

**Description**

Returns the quadint directly next to the given quadint at the same zoom level. The direction must be sent as argument and currently only horizontal/vertical movements are allowed.

* `quadint`: `BIGINT` quadint to get the sibling from.
* `direction`: `STRING` <code>'right'|'left'|'up'|'down'</code> direction to move in to extract the next sibling. 

**Return type**

`BIGINT`

**Example**

```sql
SELECT sfcarto.quadkey.SIBLING(4388, 'up');
-- 3876
```