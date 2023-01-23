## QUADBIN_CENTER

```sql:signature
carto.QUADBIN_CENTER(quadbin)
```

**Description**

Returns the center of a given Quadbin. The center is the intersection point of the four immediate children Quadbins.

* `quadbin`: `INT64` Quadbin to get the center from.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT `carto-os`.carto.QUADBIN_CENTER(5209574053332910079);
-- POINT(33.75 -11.1784018737118)
```
