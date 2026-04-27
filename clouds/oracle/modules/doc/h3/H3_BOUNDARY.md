## H3_BOUNDARY

```sql:signature
H3_BOUNDARY(index)
```

**Description**

Returns a geometry representing the H3 cell. It will return `null` on error (invalid input).

**Input parameters**

* `index`: `VARCHAR2(16)` The H3 cell index as hexadecimal.

**Return type**

`SDO_GEOMETRY` (polygon, SRID 4326)

**Example**

```sql
SELECT SDO_UTIL.TO_WKTGEOMETRY(carto.H3_BOUNDARY('84390cbffffffff'))
FROM DUAL;
-- POLYGON ((-3.5769274353957314 40.613438595935165, -3.85975632308016 40.525472355369885, ...
```
