## H3_POLYFILL

```sql:signature
H3_POLYFILL(geog, resolution)
```

**Description**

Returns an array of H3 cell indexes that intersect with the given geography at a given level of detail.

* `geog`: `GEOGRAPHY` representing the area to cover.
* `resolution`: `INT64` level of detail. The value must be between 0 and 15 ([H3 resolution table](https://h3geo.org/docs/core-library/restable)).

```hint:info
This function is equivalent to using [`H3_POLYFILL_MODE`](h3#h3_polyfill_mode) with mode `intersects`. If the input geography is a polygon check that function for more options and better performance.
```

**Return type**

`ARRAY<STRING>`

**Examples**

```sql
SELECT carto.H3_POLYFILL(
  ST_GEOGFROMTEXT('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'),
  9
);
-- [89390cb1b5bffff, 89390ca34b3ffff, 89390ca3487ffff, 89390ca3497ffff, 89390cb1b4bffff, 89390cb1b4fffff]
```

```sql
SELECT h3
FROM UNNEST(carto.H3_POLYFILL(
  ST_GEOGFROMTEXT('POLYGON ((-3.71219873428345 40.413365349070865, -3.7144088745117 40.40965661286395, -3.70659828186035 40.409525904775634, -3.71219873428345 40.413365349070865))'),
  9
)) AS h3;
-- 89390cb1b5bffff
-- 89390ca34b3ffff
-- 89390ca3487ffff
-- 89390ca3497ffff
-- 89390cb1b4bffff
-- 89390cb1b4fffff
```
