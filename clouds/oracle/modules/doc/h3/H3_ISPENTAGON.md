## H3_ISPENTAGON

```sql:signature
H3_ISPENTAGON(index)
```

**Description**

Returns `1` if the given H3 index is a pentagon. Returns `0` otherwise, even on invalid input.

**Input parameters**

* `index`: `VARCHAR2(16)` The H3 cell index as hexadecimal.

**Return type**

`NUMBER` (1/0). Oracle has no SQL `BOOLEAN`; callers compare with `= 1`.

**Examples**

```sql
SELECT carto.H3_ISPENTAGON('84390cbffffffff') FROM DUAL;
-- 0
```

```sql
SELECT carto.H3_ISPENTAGON('8075fffffffffff') FROM DUAL;
-- 1
```
