## QUADINT_TOGEOGPOINT

```sql:signature
carto.QUADINT_TOGEOGPOINT(quadint)
```

**Description**

Returns the centroid for a given quadint.

* `quadint`: `INT64` quadint to get the centroid geography from.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT `carto-os`.carto.QUADINT_TOGEOGPOINT(4388);
--  POINT(33.75 22.2982994295938)
```
