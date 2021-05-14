### ST_ASQUADINT_POLYFILL

{{% bannerNote type="code" %}}
quadkey.ST_ASQUADINT_POLYFILL(geography, resolution)
{{%/ bannerNote %}}

**Description**

Returns an array of quadints that intersect with the given geography at a given level of detail.

* `geography`: `GEOGRAPHY` geography to extract the quadints from.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`ARRAY`

**Example**

```sql
SELECT sfcarto.quadkey.ST_ASQUADINT_POLYFILL(ST_MAKEPOLYGON(TO_GEOGRAPHY('LINESTRING(-3.71219873428345 40.4133653490709, -3.71440887451172 40.4096566128639, -3.70659828186035 40.4095259047756, -3.71219873428345 40.4133653490709)')), 17);
-- 207301334801
-- 207305529105
-- 207305529073
-- 207305529137
-- 207305529169
-- 207301334833
```