### QUADBIN_FROMZXY

{{% bannerNote type="code" %}}
carto.QUADBIN_FROMZXY(z, x, y)
{{%/ bannerNote %}}

**Description**

Returns a quadbin from `z`, `x`, `y` coordinates.

* `z`: `INT64` zoom level.
* `x`: `INT64` horizontal position of a tile.
* `y`: `INT64` vertical position of a tile.

**Constraints**

Tile coordinates `x` and `y` depend on the zoom level `z`. For both coordinates, the minimum value is 0, and the maximum value is two to the power of `z`, minus one (`2^z - 1`).

**Return type**

`INT64`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.QUADBIN_FROMZXY(4, 9, 8);
-- 5209574053332910079
```
