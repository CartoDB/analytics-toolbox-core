## QUADBIN_FROMQUADKEY

```sql:signature
QUADBIN_FROMQUADKEY(quadkey)
```

**Description**

Compute a quadbin index from a quadkey.

**Input parameters**

* `quadkey`: `VARCHAR2` Quadkey representation of the index.

**Return type**

`NUMBER`

**Example**

```sql
SELECT carto.QUADBIN_FROMQUADKEY('0331110121') FROM DUAL;
-- 5234261499580514303
```

````hint:info
**Note**

In Oracle `''` is `NULL`, so the empty-string quadkey for zoom 0 cannot be passed directly. Use `QUADBIN_FROMZXY(0, 0, 0)` for zoom level 0.
````
