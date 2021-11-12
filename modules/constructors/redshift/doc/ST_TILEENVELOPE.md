### ST_TILEENVELOPE

{{% bannerNote type="code" %}}
carto.ST_TILEENVELOPE(zoomLevel, xTile, yTile)
{{%/ bannerNote %}}

**Description**
Returns the boundary polygon of a tile given its zoom level and its X and Y indices.

* `zoomLevel`: `INT` zoom level of the tile.
* `xTile`: `INT` X index of the tile.
* `yTile`: `INT` Y index of the tile.

**Return type**

`VARCHAR`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto.ST_TILEENVELOPE(10, 384, 368);
-- {'type': 'Polygon', 'coordinates': [[[-45.0, 44.84029065139799], [-45.0, 45.089035564831015], ...
```