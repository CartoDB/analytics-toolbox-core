### ST_ASID_POLYFILL_BBOX

{{% bannerNote type="code" %}}
s2.ST_ASID_POLYFILL_BBOX(id, resolution)
{{%/ bannerNote %}}

**Description**

Returns a SUPER containing an array of s2 cell IDs that cover a planar bounding box. Note that this is
a compact coverage (polyfill), so the bounding box is covered with the least amount of cells 
by using the largest cells possible.

Two optional arguments can be passed with the minimum and maximum resolution for cogerage. If you desire a
coverage at a single resolution level, simply set the maximum and minimum longitude to be of equal value.

* `min_latitude`: `FLOAT` minimum latitude of the bounding box.
* `min_longitude`: `FLOAT` minimum longitude of the bounding box.
* `max_latitude`: `FLOAT` maximum latitude of the bounding box.
* `max_lonitude`: `FLOAT` maximum longitude of the bounding box.

Optional arguments:

* `min_resolution`: `INT` minimum resolution level for cells covering the bounding box. Defaults to 0.
* `max_resolution`: `INT` maximum resolution level for cells covering the bounding box. Defaults to 30.

**Return type**

`ARRAY`

**Example**

```sql
SELECT ST_ASID_POLYFILL_BBOX(-3.688531, 40.409771,-3.680077, 40.421501);
-- [955367986615549952,955367988763033600,955367994131742720,955368019096240128,955368020975288320,955370721435975680,955370742910812160,955370751500746752]

SELECT ST_ASID_POLYFILL_BBOX(-3.688531, 40.409771,-3.680077, 40.421501, 4, 8);
-- [955378847514099712]

-- Single level coverage
SELECT ST_ASID_POLYFILL_BBOX(-3.688531, 40.409771,-3.680077, 40.421501, 12, 12);
-- [955367921117298688,955368058556252160,955370669896368128,955370807335321600]
```
