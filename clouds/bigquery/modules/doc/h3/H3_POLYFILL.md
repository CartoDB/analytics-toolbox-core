## H3_POLYFILL

```sql:signature
H3_POLYFILL(geog, resolution)
```

**Description**

Returns an array of H3 cell indexes contained in the given geography (Polygon, MultiPolygon) at a given level of detail. Containment is determined by the cells' center. This function is equivalent to [`H3_POLYFILL_MODE`](h3#h3_polyfill_mode) with mode `center`.

* `geog`: `GEOGRAPHY` representing the shape to cover.
* `resolution`: `INT64` level of detail. The value must be between 0 and 15 ([H3 resolution table](https://h3geo.org/docs/core-library/restable)).

```hint:warning
Use [`H3_POLYFILL_MODE`](h3#h3_polyfill_mode) with mode `intersects` in the following cases:
- You want to provide the minimum covering set of a Polygon, MultiPolygon.
- The input geography type is Point, MultiPoint, LineString, MultiLineString.
```

**Return type**

`ARRAY<STRING>`

**Examples**

```sql
SELECT carto.H3_POLYFILL(
  ST_GEOGFROMTEXT('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'),
  9
);
-- [89390cb1b4bffff]
```

```sql
SELECT h3
FROM UNNEST(carto.H3_POLYFILL(
  ST_GEOGFROMTEXT('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'),
  9
)) AS h3;
-- 89390cb1b4bffff
```

```sql
SELECT h3
FROM <project>.<dataset>.<table>,
  UNNEST(carto.H3_POLYFILL(geog, 9)) AS h3;
```
