## Reference

### SPHERICALMERCATOR

#### BBOX

{{% bannerNote type="code" %}}
sphericalmercator.(x NUMERIC, y NUMERIC, zoom NUMERIC, tileSize NUMERIC )
{{%/ bannerNote %}}

Returns bbox array of values in form [w, s, e, n].

* `x`: `NUMERIC` x (longitude) number.
* `y`: `NUMERIC` y (latitude) number.
* `zoom`: `NUMERIC` zoom level.
* `tileSize`: `NUMERIC` size of the tiles we want to use.

#### XYZ

{{% bannerNote type="code" %}}
sphericalmercator.XYZ(bbox ARRAY<FLOAT64>, zoom NUMERIC, tileSize NUMERIC)
{{%/ bannerNote %}}

Convert bbox to xyz bounds. Returns a struct containing minX, maxX, minY, maxY.

* `bbox`: `ARRAY<FLOAT64>` bbox in the form [w, s, e, n].
* `zoom`: `NUMERIC` zoom level.
* `tileSize`: `NUMERIC` size of the tiles we want to use.