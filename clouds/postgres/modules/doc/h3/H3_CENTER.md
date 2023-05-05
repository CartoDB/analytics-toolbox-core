## H3_CENTER

```sql:signature
H3_CENTER(index)
```

**Description**

Returns the center of the H3 cell as a GEOMETRY point. It will return `null` on error (invalid input).

* `index`: `VARCHAR(16)` The H3 cell index.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT carto.H3_CENTER('84390cbffffffff');
-- POINT (-3.6176032466282892 40.37254058216577)
```
