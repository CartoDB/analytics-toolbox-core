## QUADBIN_POLYFILL

```sql:signature
QUADBIN_POLYFILL(geography, resolution)
```

**Description**

Returns an array of Quadbins that intersect with the given geography at a requested resolution.

* `geography`: `GEOMETRY` geography to extract the Quadbins from.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`SUPER`

**Example**

```sql
SELECT carto.QUADBIN_POLYFILL(ST_GEOMFROMTEXT('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'), 17);
-- 5265786693164204031
-- 5265786693163941887
-- 5265786693153193983
-- 5265786693164466175
-- 5265786693164728319
-- 5265786693165514751
```
