## H3_ISPENTAGON

```sql:signature
H3_ISPENTAGON(index)
```

**Description**

Returns `true` if given H3 index is a pentagon. Returns `false` otherwise, even on invalid input.

* `index`: `VARCHAR(16)` The H3 cell index as hexadecimal.

**Return type**

`BOOLEAN`

**Example**

```sql
SELECT carto.H3_ISPENTAGON('84390cbffffffff');
-- false
```

```sql
SELECT carto.H3_ISPENTAGON('8075fffffffffff');
-- true
```
