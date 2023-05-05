## H3_BOUNDARY

```sql:signature
H3_BOUNDARY(index)
```

**Description**

Returns a geography representing the H3 cell. It will return `null` on error (invalid input).

* `index`: `VARCHAR(16)` The H3 cell index as hexadecimal.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT carto.H3_BOUNDARY('84390cbffffffff');
-- POLYGON ((-3.5769274353957314 40.613438595935165, -3.85975632308016 40.525472355369885, -3.899552298996668 40.28411330409504, ...
```
