## QUADBIN_POLYFILL

```sql:signature
QUADBIN_POLYFILL(geog, resolution)
```

**Description**

Returns an array of quadbin cell indexes contained in the given geography (Polygon, MultiPolygon) at a given level of detail. Containment is determined by the cells' center. This function is equivalent to [`QUADBIN_POLYFILL_MODE`](quadbin#quadbin_polyfill_mode) with mode `center`.

* `geog`: `GEOGRAPHY` representing the shape to cover.
* `resolution`: `INT64` level of detail. The value must be between 0 and 26.

````hint:warning
Use [`QUADBIN_POLYFILL_MODE`](quadbin#quadbin_polyfill_mode) with mode `intersects` in the following cases:
- You want to provide the minimum covering set of a Polygon, MultiPolygon.
- The input geography type is Point, MultiPoint, LineString, MultiLineString.
````

**Return type**

`ARRAY<INT64>`

**Examples**

```sql
SELECT carto.QUADBIN_POLYFILL(
  ST_GEOGFROMTEXT('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'),
  17
);
-- [5265786693163941887, 5265786693164466175 ,5265786693164728319]
```

```sql
SELECT quadbin
FROM UNNEST(carto.QUADBIN_POLYFILL(
  ST_GEOGFROMTEXT('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'),
  17
)) AS quadbin;
-- 5265786693163941887
-- 5265786693164466175
-- 5265786693164728319
```

```sql
SELECT quadbin
FROM <project>.<dataset>.<table>,
  UNNEST(carto.QUADBIN_POLYFILL(geog, 17)) AS quadbin;
```
