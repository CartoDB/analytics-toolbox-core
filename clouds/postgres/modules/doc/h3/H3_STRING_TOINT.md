## H3_STRING_TOINT

```sql:signature
H3_STRING_TOINT(index)
```

**Description**

Converts the string representation of the H3 index to the integer representation.

* `index`: `VARCHAR(16)` The H3 cell index.

**Return type**

`INT`

**Example**

```sql
SELECT carto.H3_STRING_TOINT('84390cbffffffff');
-- 595478781590765567
```
