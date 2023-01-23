## QUADBIN_FROMZXY

```sql:signature
carto.QUADBIN_FROMZXY(z, x, y)
```

**Description**

Returns a Quadbin from `z`, `x`, `y` [tile coordinates](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames).

* `z`: `INT64` zoom level.
* `x`: `INT64` horizontal position of a tile.
* `y`: `INT64` vertical position of a tile.

**Constraints**

Tile coordinates `x` and `y` depend on the zoom level `z`. For both coordinates, the minimum value is 0, and the maximum value is two to the power of `z`, minus one (`2^z - 1`).

Note that the `y` coordinate increases from North to South, and the `y` coordinate from West to East.

**Return type**

`INT64`

**Example**

```sql
SELECT `carto-os`.carto.QUADBIN_FROMZXY(4, 9, 8);
-- 5209574053332910079
```
