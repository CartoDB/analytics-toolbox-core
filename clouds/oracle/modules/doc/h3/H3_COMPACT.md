## H3_COMPACT

```sql:signature
H3_COMPACT(indexArray)
```

**Description**

Returns a set of hexagons across multiple resolutions that represent the same area as the input set of hexagons.

**Input parameters**

* `indexArray`: `H3_INDEX_ARRAY` of H3 cell indices as hexadecimal.

**Return type**

`H3_INDEX_ARRAY` (pipelined; `TABLE OF VARCHAR2(16)`).

**Example**

```sql
SELECT COLUMN_VALUE AS h3
FROM TABLE(carto.H3_COMPACT(carto.H3_INDEX_ARRAY(
    '85390ca3fffffff', '85390ca7fffffff', '85390cabfffffff',
    '85390caffffffff', '85390cb3fffffff', '85390cb7fffffff',
    '85390cbbfffffff'
)));
-- 84390cbffffffff
```

To pipe the output of another nested-table function into `H3_COMPACT`, cast it via `MULTISET`:

```sql
SELECT COLUMN_VALUE AS h3
FROM TABLE(carto.H3_COMPACT(
    CAST(MULTISET(
        SELECT COLUMN_VALUE
        FROM TABLE(carto.H3_TOCHILDREN('84390cbffffffff', 5))
    ) AS carto.H3_INDEX_ARRAY)
));
-- 84390cbffffffff
```
