## QUADBIN_POLYFILL

```sql:signature
QUADBIN_POLYFILL(geog, resolution)
```

**Description**

Returns an array of quadbin cell indexes that intersect with the given geography at a given level of detail.

* `geog`: `GEOGRAPHY` representing the area to cover.
* `resolution`: `INT64` level of detail. The value must be between 0 and 26.

```hint:info
This function is equivalent to using [`QUADBIN_POLYFILL_MODE`](quadbin#quadbin_polyfill_mode) with mode `intersects`. If the input geography is a polygon check that function for more options and better performance.
```

**Return type**

`ARRAY<INT64>`

**Examples**

```sql
SELECT carto.QUADBIN_POLYFILL(
  ST_GEOGFROMTEXT('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'),
  17
);
-- [5265786693153193983, 5265786693163941887, 5265786693164466175, 5265786693164204031, 5265786693164728319, 5265786693165514751]
```

```sql
SELECT quadbin
FROM UNNEST(carto.QUADBIN_POLYFILL(
  ST_GEOGFROMTEXT('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'),
  17
)) AS quadbin;
-- 5265786693153193983
-- 5265786693163941887
-- 5265786693164466175
-- 5265786693164204031
-- 5265786693164728319
-- 5265786693165514751
```
