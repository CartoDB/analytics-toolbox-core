## S2_POLYFILL_BBOX

```sql:signature
carto.S2_POLYFILL_BBOX(min_longitude, max_longitude, min_latitude, max_latitude [, min_resolution, max_resolution])
```

**Description**

Returns a SUPER containing an array of S2 cell IDs that cover a planar bounding box. Note that this is
a compact coverage (polyfill), so the bounding box is covered with the least amount of cells
by using the largest cells possible.

Two optional arguments can be passed with the minimum and maximum resolution for coverage. If you desire a
coverage at a single resolution level, simply set the maximum and minimum longitude to be of equal value.

* `min_longitude`: `FLOAT8` minimum longitude of the bounding box.
* `max_longitude`: `FLOAT8` maximum longitude of the bounding box.
* `min_latitude`: `FLOAT8` minimum latitude of the bounding box.
* `max_latitude`: `FLOAT8` maximum latitude of the bounding box.
* `min_resolution` (optional): `INT4` minimum resolution level for cells covering the bounding box. Defaults to `0`.
* `max_resolution` (optional): `INT4` maximum resolution level for cells covering the bounding box. Defaults to `30`.

**Return type**

`SUPER`

**Example**

```sql
SELECT carto.S2_POLYFILL_BBOX(-3.688531, -3.680077, 40.409771, 40.421501);
-- [955367986615549952,955367988763033600,955367994131742720,955368019096240128,
--  955368020975288320,955370721435975680,955370742910812160,955370751500746752]

SELECT carto.S2_POLYFILL_BBOX(-3.688531, -3.680077, 40.409771, 40.421501, 4, 8);
-- [955378847514099712]

-- Single level coverage
SELECT carto.S2_POLYFILL_BBOX(-3.688531, -3.680077, 40.409771, 40.421501, 12, 12);
-- [955367921117298688,955368058556252160,955370669896368128,955370807335321600]
```
