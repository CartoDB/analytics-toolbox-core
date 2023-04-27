## H3_ISVALID

```sql:signature
H3_ISVALID(index)
```

**Description**

Returns `true` when the given index is valid, `false` otherwise.

* `index`: `VARCHAR(16)` The H3 cell index as hexadecimal.

**Return type**

`BOOLEAN`

**Examples**

```sql
SELECT carto.H3_ISVALID('847b59dffffffff');
-- true
```

```sql
SELECT carto.H3_ISVALID('1');
-- false
```
