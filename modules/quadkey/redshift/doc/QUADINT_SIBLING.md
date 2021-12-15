### QUADINT_SIBLING

{{% bannerNote type="code" %}}
carto.QUADINT_SIBLING(quadint, direction)
{{%/ bannerNote %}}

**Description**

Returns the quadint directly next to the given quadint at the same zoom level. The direction must be included as an argument and currently only horizontal/vertical movements are allowed.

* `quadint`: `BIGINT` quadint to get the sibling from.
* `direction`: `VARCHAR` <code>'right'|'left'|'up'|'down'</code> direction to move in to extract the next sibling. 

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADINT_SIBLING(4388, 'up');
-- 3876
```