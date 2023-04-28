## H3_BOUNDARY

```sql:signature
H3_BOUNDARY(index)
```

**Description**

Returns a geography representing the H3 cell. It will return `null` on error (invalid input).

* `index`: `STRING` The H3 cell index.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.H3_BOUNDARY('84390cbffffffff');
-- POLYGON((-3.57692743539573 40.6134385959352, -3.85975632308016 ...
```
