## H3_UNCOMPACT

```sql:signature
H3_UNCOMPACT(indexArray, resolution)
```

**Description**

Returns the cells of `indexArray` expanded to the requested target `resolution`, representing the same area as the [compacted](h3#h3_compact) input. Cells already at the target resolution pass through unchanged; coarser cells are expanded to their descendants; cells finer than the target are skipped.

**Input parameters**

* `indexArray`: `H3_INDEX_ARRAY` of H3 cell indices as hexadecimal.
* `resolution`: `NUMBER` between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`H3_INDEX_ARRAY` (pipelined; `TABLE OF VARCHAR2(16)`).

**Example**

```sql
SELECT COLUMN_VALUE AS h3
FROM TABLE(carto.H3_UNCOMPACT(
    carto.H3_INDEX_ARRAY('84390cbffffffff'), 5
));
-- 85390ca3fffffff
-- 85390ca7fffffff
-- 85390cabfffffff
-- 85390caffffffff
-- 85390cb3fffffff
-- 85390cb7fffffff
-- 85390cbbfffffff
```
