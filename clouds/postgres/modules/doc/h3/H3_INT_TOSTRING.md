## H3_INT_TOSTRING

```sql:signature
H3_INT_TOSTRING(index)
```

**Description**

Converts the integer representation of the H3 index to the string representation.

* `index`: `INT` The H3 cell index.

**Return type**

`VARCHAR(16)`

**Example**

```sql
SELECT carto.H3_INT_TOSTRING(596645165859340287);
-- 847b59dffffffff
```