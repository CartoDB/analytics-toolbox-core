## H3_CENTER

```sql:signature
H3_CENTER(index)
```

**Description**

Returns the center of the H3 cell as a GEOGRAPHY point. It will return `null` on error (invalid input).

* `index`: `STRING` The H3 cell index.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.H3_CENTER('84390cbffffffff');
-- POINT(-3.61760324662829 40.3725405821658)
```
