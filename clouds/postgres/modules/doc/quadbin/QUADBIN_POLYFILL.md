## QUADBIN_POLYFILL

```sql:signature
QUADBIN_POLYFILL(geom, resolution [, mode])
```

**Description**

Returns an array of quadbin cell indexes that intersect with the given geometry at a given level of detail. This function allows control on how quadbin cells are computed. It can operates on three modes: intersects, contains, center.

* `geom`: `GEOMETRY` representing the area to cover.
* `resolution`: `INT` level of detail. The value must be between 0 and 26.
* `mode` (optional): `VARCHAR`
  * `intersects` (default) returns the indexes of the quadbin cells that intersect the input geometry. The resulting quadbin set will completely cover the input geometry (point, line, polygon).
  * `contains` returns the indexes of the quadbin cells that are entirely contained inside the input geometry (polygon). This mode is not compatible with points or lines.
  * `center` returns the indexes of the quadbin cells which centers intersect the input geometry (polygon). The resulting quadbin set does not fully cover the input geometry, however this is significantly faster that the other modes. This mode is not compatible with points or lines.

Mode `intersects`:

![intersects](./images/QUADBIN_POLYFILL_MODE_intersects.png)

Mode `contains`:

![contains](./images/QUADBIN_POLYFILL_MODE_contains.png)

Mode `center`:

![center](./images/QUADBIN_POLYFILL_MODE_center.png)

**Return type**

`BIGINT[]`

**Examples**

```sql
SELECT carto.QUADBIN_POLYFILL(
  ST_GEOMFROMTEXT('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'),
  17
);
-- [5265786693153193983, 5265786693163941887, 5265786693164466175, 5265786693164204031, 5265786693164728319, 5265786693165514751]
```

```sql
SELECT quadbin
FROM UNNEST(carto.QUADBIN_POLYFILL(
  ST_GEOMFROMTEXT('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'),
  17
)) AS quadbin;
-- 5265786693153193983
-- 5265786693163941887
-- 5265786693164466175
-- 5265786693164204031
-- 5265786693164728319
-- 5265786693165514751
```

```sql
SELECT carto.QUADBIN_POLYFILL(
  ST_GEOMFROMTEXT('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'),
  17, 'center'
);
-- [5265786693163941887, 5265786693164466175, 5265786693164728319]
```

```sql
SELECT quadbin
FROM UNNEST(carto.QUADBIN_POLYFILL(
  ST_GEOMFROMTEXT('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'),
  17, 'center'
)) AS quadbin;
-- 5265786693163941887
-- 5265786693164466175
-- 5265786693164728319
```
