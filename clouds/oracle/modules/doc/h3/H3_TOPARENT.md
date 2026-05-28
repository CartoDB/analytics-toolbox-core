## H3_TOPARENT

```sql:signature
H3_TOPARENT(index, resolution)
```

**Description**

Returns the H3 cell index of the parent of the given hexagon at the given resolution. Returns `null` if the requested resolution is not strictly coarser than the cell's resolution, or for invalid input.

**Input parameters**

* `index`: `VARCHAR2(16)` The H3 cell index as hexadecimal.
* `resolution`: `NUMBER` between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`VARCHAR2(16)`

**Example**

```sql
SELECT carto.H3_TOPARENT('84390cbffffffff', 3) FROM DUAL;
-- 83390cfffffffff
```
