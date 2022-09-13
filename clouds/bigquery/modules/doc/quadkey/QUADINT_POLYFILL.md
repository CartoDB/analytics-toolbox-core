### QUADINT_POLYFILL

{{% bannerNote type="code" %}}
carto.QUADINT_POLYFILL(geography, resolution)
{{%/ bannerNote %}}

**Description**

Returns an array of quadints that intersect with the given geography at a given level of detail.

* `geography`: `GEOGRAPHY` geography to extract the quadints from.
* `resolution`: `INT64` level of detail or zoom.

**Return type**

`ARRAY<INT64>`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.QUADINT_POLYFILL(
    ST_MAKEPOLYGON(ST_MAKELINE([ST_GEOGPOINT(-363.71219873428345, 40.413365349070865), ST_GEOGPOINT(-363.7144088745117, 40.40965661286395), ST_GEOGPOINT(-363.70659828186035, 40.409525904775634), ST_GEOGPOINT(-363.71219873428345, 40.413365349070865)])), 
    17);
-- 207301334801
-- 207305529105
-- 207305529073
-- 207305529137
-- 207305529169
-- 207301334833
```