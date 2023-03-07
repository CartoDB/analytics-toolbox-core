## H3_UNCOMPACT

```sql:signature
H3_UNCOMPACT(indexArray, resolution)
```

**Description**

Returns an array with the indexes of a set of hexagons of the same `resolution` that represent the same area as the [compacted](h3#h3_compact) input hexagons.

* `indexArray`: `ARRAY` of H3 cell indices as hexadecimal.
* `resolution`: `INT` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`ARRAY`

**Example**

```sql
SELECT carto.H3_UNCOMPACT(ARRAY_CONSTRUCT('847b59dffffffff'), 5);
-- 857b59c3fffffff
-- 857b59c7fffffff
-- 857b59cbfffffff
-- 857b59cffffffff
-- 857b59d3fffffff
-- 857b59d7fffffff
-- 857b59dbfffffff
```
