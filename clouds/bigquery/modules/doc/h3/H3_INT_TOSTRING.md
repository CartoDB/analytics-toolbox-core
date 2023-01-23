## H3_INT_TOSTRING

```sql:signature
carto.H3_INT_TOSTRING(index)
```

**Description**

Converts the integer representation of the H3 index to the string representation.

* `index`: `INT64` The H3 cell index.

**Return type**

`STRING`

**Example**

```sql
SELECT `carto-os`.carto.H3_INT_TOSTRING(596645165859340287);
-- 847b59dffffffff
```
