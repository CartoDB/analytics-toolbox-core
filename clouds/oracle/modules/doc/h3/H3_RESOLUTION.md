## H3_RESOLUTION

```sql:signature
H3_RESOLUTION(index)
```

**Description**

Returns the resolution (0–15) of the given H3 cell. Returns `null` for invalid input.

**Input parameters**

* `index`: `VARCHAR2(16)` The H3 cell index as hexadecimal.

**Return type**

`NUMBER`

**Example**

```sql
SELECT carto.H3_RESOLUTION('84390cbffffffff') FROM DUAL;
-- 4
```
