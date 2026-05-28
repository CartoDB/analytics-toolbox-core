## QUADBIN_BBOX

```sql:signature
QUADBIN_BBOX(quadbin)
```

**Description**

Returns an object with the boundary box of a given Quadbin. This boundary box contains the minimum and maximum longitude and latitude. The output object exposes the named fields `west`, `south`, `east`, `north` (i.e. [West-South, East-North], or [min long, min lat, max long, max lat]).

**Input parameters**

* `quadbin`: `NUMBER` Quadbin to get the bbox from.

**Return type**

`QUADBIN_BBOX_OBJ` (object with `west`, `south`, `east`, `north` of type `BINARY_DOUBLE`)

**Example**

```sql
SELECT t.bbox.west, t.bbox.south, t.bbox.east, t.bbox.north
FROM (
    SELECT carto.QUADBIN_BBOX(5207251884775047167) AS bbox FROM DUAL
) t;
-- WEST                    SOUTH                  EAST  NORTH
-- -2.250000000000000e+01  2.194304553343818e+01  0     4.097989806962013e+01
```
