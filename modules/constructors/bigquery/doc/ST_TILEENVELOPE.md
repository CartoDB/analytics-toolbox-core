### ST_TILEENVELOPE

{{% bannerNote type="code" %}}
constructors.ST_TILEENVELOPE(zoomLevel, xTile, yTile)
{{%/ bannerNote %}}

**Description**
Returns the boundary polygon of a tile given its zoom level and its X and Y indices.

* `zoomLevel`: `INT64` zoom level of the tile.
* `xTile`: `INT64` X index of the tile.
* `yTile`: `INT64` Y index of the tile.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT bqcarto.constructors.ST_TILEENVELOPE(10,384,368);
-- POLYGON((-45 45.089035564831, -45 44.840290651398, -44.82421875 44.840290651398, -44.6484375 44.840290651398, -44.6484375 45.089035564831, -44.82421875 45.089035564831, -45 45.089035564831))
```
