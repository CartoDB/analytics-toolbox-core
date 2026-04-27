## H3_ISVALID

```sql:signature
H3_ISVALID(index)
```

**Description**

Returns `1` when the given index is valid, `0` otherwise.

**Input parameters**

* `index`: `VARCHAR2(16)` The H3 cell index as hexadecimal.

**Return type**

`NUMBER(1)` (1/0). Oracle has no SQL `BOOLEAN`; callers compare with `= 1`.

**Examples**

```sql
SELECT carto.H3_ISVALID('84390cbffffffff') FROM DUAL;
-- 1
```

```sql
SELECT carto.H3_ISVALID('1') FROM DUAL;
-- 0
```
