## H3_STRING_TOINT

```sql:signature
H3_STRING_TOINT(index)
```

**Description**

Converts the string representation of the H3 index to the integer representation.

**Input parameters**

* `index`: `VARCHAR2(16)` The H3 cell index.

**Return type**

`NUMBER`

**Example**

```sql
SELECT carto.H3_STRING_TOINT('84390cbffffffff') FROM DUAL;
-- 595478781590765567
```
