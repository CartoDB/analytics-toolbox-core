## H3_COMPACT

```sql:signature
H3_COMPACT(indexArray)
```

**Description**

Returns an array with the indexes of a set of hexagons across multiple resolutions that represent the same area as the input set of hexagons.

* `indexArray`: `VARCHAR(16)[]` of H3 cell indices of the same resolution as hexadecimal.

**Return type**

`VARCHAR(16)[]`

**Example**

```sql
SELECT carto.H3_COMPACT(ARRAY['85390ca3fffffff', '85390ca7fffffff', '85390cabfffffff','85390caffffffff', '85390cb3fffffff', '85390cb7fffffff', '85390cbbfffffff']);
-- { 84390cbffffffff }
```
