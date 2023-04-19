## H3_BOUNDARY

```sql:signature
H3_BOUNDARY(index)
```

**Description**

Returns a geography representing the H3 cell. It will return `null` on error (invalid input).

* `index`: `VARCHAR(16)` The H3 cell index as hexadecimal.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT carto.H3_BOUNDARY('847b59dffffffff');
-- POLYGON ((40.46506362234518 -3.9352772457964957, 40.546540602670504 -3.706115055436962, 40.387130040966305 -3.5142476508226355, ...
```
