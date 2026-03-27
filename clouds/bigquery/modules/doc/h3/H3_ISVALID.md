## H3_ISVALID

```sql:signature
H3_ISVALID(index)
```

**Description**

Returns `true` when the given index is a valid H3 index, `false` otherwise.

**Input parameters**

* `index`: `STRING` The H3 cell index.

**Return type**

`BOOL`

**Examples**

```sql
SELECT carto.H3_ISVALID('84390cbffffffff');
-- TRUE
```

```sql
SELECT carto.H3_ISVALID('1');
-- FALSE
```
