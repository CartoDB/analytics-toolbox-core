## H3_POLYFILL

```sql:signature
H3_POLYFILL(geom, resolution [, mode])
```

**Description**

Returns an array of H3 cell indexes contained in the given geometry at a given level of detail. Containment is determined by the mode: center, intersects, contains.

* `geom`: `GEOMETRY` representing the shape to cover.
* `resolution`: `INT` level of detail. The value must be between 0 and 15 ([H3 resolution table](https://h3geo.org/docs/core-library/restable)).
* `mode` (optional): `VARCHAR`
  * `center` (default) returns the indexes of the H3 cells which centers intersect the input geometry (polygon). The resulting H3 set does not fully cover the input geometry, however, this is **significantly faster** that the other modes. This mode is not compatible with points or lines. Equivalent to [`H3_POLYFILL`](h3#h3_polyfill).
  * `intersects` returns the indexes of the H3 cells that intersect the input geometry. The resulting H3 set will completely cover the input geometry (point, line, polygon).
  * `contains` returns the indexes of the H3 cells that are entirely contained inside the input geometry (polygon). This mode is not compatible with points or lines.

Mode `center`:

![](h3_polyfill_mode_center.png)

Mode `intersects`:

![](h3_polyfill_mode_intersects.png)

Mode `contains`:

![](h3_polyfill_mode_contains.png)

**Return type**

`VARCHAR(16)[]`

**Examples**

```sql
SELECT carto.H3_POLYFILL(
  ST_GEOMFROMTEXT('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'),
  9
);
-- [89390cb1b4bffff]
```

```sql
SELECT h3
FROM UNNEST(carto.H3_POLYFILL(
  ST_GEOMFROMTEXT('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'),
  9
)) AS h3;
-- 89390cb1b4bffff
```

```sql
SELECT carto.H3_POLYFILL(
  ST_GEOMFROMTEXT('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'),
  9, 'intersects'
);
-- [89390ca3497ffff, 89390ca34b3ffff, 89390cb1b4bffff, 89390cb1b5bffff]
```

```sql
SELECT h3
FROM UNNEST(carto.H3_POLYFILL(
  ST_GEOMFROMTEXT('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'),
  9, 'intersects'
)) AS h3;
-- 89390ca3497ffff
-- 89390ca34b3ffff
-- 89390cb1b4bffff
-- 89390cb1b5bffff
```
