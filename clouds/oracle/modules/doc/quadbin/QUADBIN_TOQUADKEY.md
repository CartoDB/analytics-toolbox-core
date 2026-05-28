## QUADBIN_TOQUADKEY

```sql:signature
QUADBIN_TOQUADKEY(quadbin)
```

**Description**

Compute a quadkey from a quadbin index.

**Input parameters**

* `quadbin`: `NUMBER` Quadbin index.

**Return type**

`VARCHAR2`

**Example**

```sql
SELECT carto.QUADBIN_TOQUADKEY(5234261499580514303) FROM DUAL;
-- '0331110121'
```

````hint:info
**Note**

In Oracle `''` is `NULL`, so the zoom-0 quadbin's quadkey is returned as `NULL` rather than as an empty string.
````
