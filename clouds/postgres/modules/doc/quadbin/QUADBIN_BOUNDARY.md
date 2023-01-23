## QUADBIN_BOUNDARY

```sql:signature
carto.QUADBIN_BOUNDARY(quadbin)
```

**Description**

Returns the boundary for a given Quadbin as a polygon GEOMETRY with the same coordinates as given by the [QUADBIN_BBOX](#quadbin_bbox) function.

* `quadbin`: `BIGINT` Quadbin to get the boundary geometry from.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.QUADBIN_BOUNDARY(5209574053332910079);
-- POLYGON((22.5 0, 22.5 -21.943045533438166, 45 -21.943045533438166, 45 0, 22.5 0))
```
