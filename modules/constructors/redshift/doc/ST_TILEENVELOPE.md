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

`GEOMETRY`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT carto.ST_TILEENVELOPE(10, 384, 368);
-- POLYGON ((-45 44.8402906514, -45 45.0890355648, -44.6484375 45.0890355648, -44.6484375 44.8402906514, -45 44.8402906514))
```