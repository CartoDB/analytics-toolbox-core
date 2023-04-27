## H3_CENTER

```sql:signature
H3_CENTER(index)
```

**Description**

Returns the center of the H3 cell as a GEOMETRY point. It will return `null` on error (invalid input).

* `index`: `VARCHAR(16)` The H3 cell index.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT carto.H3_CENTER('847b59dffffffff');
-- POINT (40.30547642317431 -3.743203325561684)
```
