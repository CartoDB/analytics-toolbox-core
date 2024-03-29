## QUADBIN_SIBLING

```sql:signature
QUADBIN_SIBLING(quadbin, direction)
```

**Description**

Returns the Quadbin directly next to the given Quadbin at the same resolution. The direction must be set in the corresponding argument and currently only horizontal/vertical neigbours are supported. It will return `NULL` if the sibling does not exist.

* `quadbin`: `BIGINT` Quadbin to get the sibling from.
* `direction`: `VARCHAR` <code>'right'|'left'|'up'|'down'</code> direction to move in to extract the next sibling.

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADBIN_SIBLING(5207251884775047167, 'up');
-- 5207146331658780671
```
