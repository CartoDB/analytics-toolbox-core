## H3_BOUNDARY

```sql:signature
H3_BOUNDARY(index)
```

**Description**

Returns a geography representing the H3 cell. It will return `null` on error (invalid input).

* `index`: `STRING` The H3 cell index.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.H3_BOUNDARY('847b59dffffffff');
-- POLYGON((40.4650636223452 -3.9352772457965, 40.5465406026705 ...
```
