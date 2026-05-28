## H3_CENTER

```sql:signature
H3_CENTER(index)
```

**Description**

Returns the center of the H3 cell as a point geometry. It will return `null` on error (invalid input).

**Input parameters**

* `index`: `VARCHAR2(16)` The H3 cell index.

**Return type**

`SDO_GEOMETRY` (point, SRID 4326)

**Example**

```sql
SELECT SDO_UTIL.TO_WKTGEOMETRY(carto.H3_CENTER('84390cbffffffff'))
FROM DUAL;
-- POINT (-3.6176032466282892 40.37254058216577)
```
