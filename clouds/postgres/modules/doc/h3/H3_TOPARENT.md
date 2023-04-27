## H3_TOPARENT

```sql:signature
H3_TOPARENT(index, resolution)
```

**Description**

Returns the H3 cell index of the parent of the given hexagon at the given resolution.

* `index`: `VARCHAR(16)` The H3 cell index as hexadecimal.
* `resolution`: `INT` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`VARCHAR`

**Example**

```sql
SELECT carto.H3_TOPARENT('847b59dffffffff', 3);
-- 837b59fffffffff
```
