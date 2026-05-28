## QUADBIN_FROMZXY

```sql:signature
QUADBIN_FROMZXY(z, x, y)
```

**Description**

Returns a Quadbin from `z`, `x`, `y` [tile coordinates](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames).

**Input parameters**

* `z`: `NUMBER` zoom level.
* `x`: `NUMBER` horizontal position of a tile.
* `y`: `NUMBER` vertical position of a tile.

**Constraints**

Tile coordinates `x` and `y` depend on the zoom level `z`. For both coordinates, the minimum value is 0, and the maximum value is two to the power of `z`, minus one (`2^z - 1`).

**Return type**

`NUMBER`

**Example**

```sql
SELECT carto.QUADBIN_FROMZXY(4, 7, 6) FROM DUAL;
-- 5207251884775047167
```
