### ST_TILEENVELOPE

{{% bannerNote type="code" %}}
constructors.ST_TILEENVELOPE(zoomLevel, xTile, yTile)
{{%/ bannerNote %}}

**Description**
Returns the boundary polygon of a tile given its zoom level and its X and Y indices.

* `zoomLevel`: `INT` zoom level of the tile.
* `xTile`: `INT` X index of the tile.
* `yTile`: `INT` Y index of the tile.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT sfcarto.constructors.ST_TILEENVELOPE(10,384,368);
-- {"coordinates": [[[-45,45.08903556483103], [-45, 44.840290651397986], ...
```