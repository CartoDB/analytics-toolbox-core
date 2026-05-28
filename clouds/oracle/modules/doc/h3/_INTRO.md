---
badges:
---
# h3

[H3](https://eng.uber.com/h3/) is Uber's Hexagonal Hierarchical Spatial Index. Full documentation of the project can be found at [h3geo](https://h3geo.org/docs). You can also learn more about H3 in the [Spatial Indexes section](https://docs.carto.com/data-and-analysis/analytics-toolbox-for-oracle/key-concepts/spatial-indexes#h3) of this documentation.

## Oracle output conventions

Array-returning H3 functions in Oracle are **pipelined** and return nested-table types — `H3_INDEX_ARRAY` for cell IDs, `H3_DISTANCE_ARRAY` for `(h3, distance)` pairs. Consume them with `TABLE(...)`:

```sql
SELECT COLUMN_VALUE AS h3
FROM TABLE(carto.H3_TOCHILDREN('83390cfffffffff', 4));
```

`H3_COMPACT` and `H3_UNCOMPACT` accept the same `H3_INDEX_ARRAY` type as input — pass cell IDs with `carto.H3_INDEX_ARRAY('a', 'b', ...)` or by piping another nested-table result through `CAST(MULTISET(...) AS carto.H3_INDEX_ARRAY)`.

Boolean-style functions (`H3_ISVALID`, `H3_ISPENTAGON`) return `NUMBER` constrained to 1/0, since Oracle SQL has no `BOOLEAN`. Compare with `= 1` rather than using truthy predicates.
