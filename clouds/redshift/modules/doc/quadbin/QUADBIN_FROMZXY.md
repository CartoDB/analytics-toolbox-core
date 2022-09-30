### QUADBIN_FROMZXY

{{% bannerNote type="code" %}}
carto.QUADBIN_FROMZXY(z, x, y)
{{%/ bannerNote %}}

**Description**

Returns a Quadbin from `z`, `x`, `y` coordinates.

* `z`: `BIGINT` zoom level.
* `x`: `BIGINT` horizontal position of a tile.
* `y`: `BIGINT` vertical position of a tile.

**Constraints**

Tile coordinates `x` and `y` depend on the zoom level `z`. For both coordinates, the minimum value is 0, and the maximum value is two to the power of `z`, minus one (`2^z - 1`).

**Return type**

`BIGINT`

**Example**

```sql
SELECT carto.QUADBIN_FROMZXY(4, 9, 8);
-- 5209574053332910079
```
