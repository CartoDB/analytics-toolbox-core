## H3_ISPENTAGON

```sql:signature
H3_ISPENTAGON(index)
```

**Description**

Returns `true` if given H3 index is a pentagon. Returns `false` otherwise, even on invalid input.

**Input parameters**

* `index`: `STRING` The H3 cell index.

**Return type**

`BOOL`

**Examples**

```sql
SELECT carto.H3_ISPENTAGON('84390cbffffffff');
-- FALSE
```

```sql
SELECT carto.H3_ISPENTAGON('8075fffffffffff');
-- TRUE
```
