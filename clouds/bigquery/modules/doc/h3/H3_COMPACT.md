## H3_COMPACT

```sql:signature
carto.H3_COMPACT(indexArray)
```

**Description**

Returns an array with the indexes of a set of hexagons across multiple resolutions that represent the same area as the input set of hexagons.

* `indexArray`: `ARRAY<STRING>` of H3 cell indices of the same resolution.

**Return type**

`ARRAY<STRING>`


**Example**


```sql
SELECT `carto-os`.carto.H3_COMPACT(['857b59c3fffffff', '857b59c7fffffff', '857b59cbfffffff', '857b59cffffffff', '857b59d3fffffff', '857b59d7fffffff', '857b59dbfffffff']);
-- 847b59dffffffff
```