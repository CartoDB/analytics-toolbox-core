## H3_RESOLUTION

```sql:signature
H3_RESOLUTION(index)
```

**Description**

Returns the H3 cell resolution as an integer. It will return `null` on error (invalid input).

* `index`: `STRING` The H3 cell index.

**Return type**

`INT`

**Example**

```sql
SELECT carto.H3_RESOLUTION('84390cbffffffff');
-- 4
```
