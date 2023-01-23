## QUADBIN_SIBLING

```sql:signature
carto.QUADBIN_SIBLING(quadbin, direction)
```

**Description**

Returns the Quadbin directly next to the given Quadbin at the same resolution. The direction must be set in the corresponding argument and currently only horizontal/vertical neigbours are supported. It will return `NULL` if the sibling does not exist.

* `quadbin`: `INT64` Quadbin to get the sibling from.
* `direction`: `STRING` <code>'right'|'left'|'up'|'down'</code> direction to move in to extract the next sibling.

**Return type**

`INT64`

**Example**

```sql
SELECT `carto-os`.carto.QUADBIN_SIBLING(5209574053332910079, 'up');
-- 5208061125333090303
```
