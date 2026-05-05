## H3_DISTANCE

```sql:signature
H3_DISTANCE(origin, destination)
```

**Description**

Returns the **grid distance** between two hexagon indexes. This function may fail to find the distance between two indexes if they are very far apart or on opposite sides of a pentagon. Returns `null` on failure or invalid input. The two cells must share the same resolution.

**Input parameters**

* `origin`: `VARCHAR2(16)` The H3 cell index as hexadecimal.
* `destination`: `VARCHAR2(16)` The H3 cell index as hexadecimal.

**Return type**

`NUMBER`

**Example**

```sql
SELECT carto.H3_DISTANCE('84390c1ffffffff', '84390cbffffffff') FROM DUAL;
-- 1
```

````hint:info
**tip**

If you want the distance in meters use [SDO_GEOM.SDO_DISTANCE](https://docs.oracle.com/en/database/oracle/oracle-database/23/spatl/SDO_GEOM-reference.html) between the cell boundaries ([H3_BOUNDARY](h3#h3_boundary)) or their centroids ([H3_CENTER](h3#h3_center)).

````
