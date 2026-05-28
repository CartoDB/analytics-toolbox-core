## H3_TOCHILDREN

```sql:signature
H3_TOCHILDREN(index, resolution)
```

**Description**

Returns the indexes of the children/descendents of the given hexagon at the given resolution. Returns no rows when the requested resolution is coarser than the input cell, or for invalid input.

**Input parameters**

* `index`: `VARCHAR2(16)` The H3 cell index as hexadecimal.
* `resolution`: `NUMBER` between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`H3_INDEX_ARRAY` (pipelined; `TABLE OF VARCHAR2(16)`).

**Example**

```sql
SELECT COLUMN_VALUE AS h3
FROM TABLE(carto.H3_TOCHILDREN('83390cfffffffff', 4));
-- 84390c1ffffffff
-- 84390c3ffffffff
-- 84390c5ffffffff
-- 84390c7ffffffff
-- 84390c9ffffffff
-- 84390cbffffffff
-- 84390cdffffffff
```
