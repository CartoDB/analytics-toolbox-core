## H3_ISVALID

```sql:signature
carto.H3_ISVALID(index)
```

**Description**

Returns `true` when the given index is a valid H3 index, `false` otherwise.

* `index`: `STRING` The H3 cell index.

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
