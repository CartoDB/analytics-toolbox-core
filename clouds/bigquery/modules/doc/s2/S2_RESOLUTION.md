## S2_RESOLUTION

```sql:signature
S2_RESOLUTION(index)
```

**Description**

Returns the S2 cell resolution as an integer.

* `index`: `STRING` The S2 cell index.

**Return type**

`INT64`

**Example**

```sql
SELECT carto.S2_RESOLUTION(955378847514099712);
-- 9
```
