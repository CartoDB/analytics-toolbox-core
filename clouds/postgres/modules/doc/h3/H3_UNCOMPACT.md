## H3_UNCOMPACT

```sql:signature
H3_UNCOMPACT(indexArray, resolution)
```

**Description**

Returns an array with the indexes of a set of hexagons of the same `resolution` that represent the same area as the [compacted](h3#h3_compact) input hexagons.

* `indexArray`: `VARCHAR(16)` of H3 cell indices as hexadecimal.
* `resolution`: `INT` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`VARCHAR(16)[]`

**Example**

```sql
SELECT carto.H3_UNCOMPACT(ARRAY['84390cbffffffff'], 5);
-- { 85390ca3fffffff,
--   85390ca7fffffff,
--   85390cabfffffff,
--   85390caffffffff,
--   85390cb3fffffff,
--   85390cb7fffffff,
--   85390cbbfffffff }
```
