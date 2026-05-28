## QUADBIN_POLYFILL

```sql:signature
QUADBIN_POLYFILL(geometry, resolution)
```

**Description**

Returns the Quadbins that intersect with the given geometry at a requested resolution. The function is pipelined; each row is one Quadbin.

**Input parameters**

* `geometry`: `SDO_GEOMETRY` geometry to extract the Quadbins from. Interpreted as WGS84 (EPSG:4326).
* `resolution`: `NUMBER` level of detail or zoom.

**Return type**

`QUADBIN_INDEX_ARRAY` (pipelined `TABLE OF NUMBER`)

**Example**

```sql
SELECT COLUMN_VALUE
FROM TABLE(carto.QUADBIN_POLYFILL(
    SDO_UTIL.FROM_WKTGEOMETRY('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'),
    17));
-- 5265786693153193983
-- 5265786693163941887
-- 5265786693164466175
-- 5265786693164204031
-- 5265786693164728319
-- 5265786693165514751
```
