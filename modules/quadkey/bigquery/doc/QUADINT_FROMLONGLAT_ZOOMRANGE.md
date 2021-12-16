### QUADINT_FROMLONGLAT_ZOOMRANGE

{{% bannerNote type="code" %}}
carto.QUADINT_FROMLONGLAT_ZOOMRANGE(longitude, latitude, zoom_min, zoom_max, zoom_step, resolution)
{{%/ bannerNote %}}

**Description**

Returns the quadint index for the given point for each zoom level requested, at the specified resolution (computed as the current zoom level + the value of `resolution`). The output is an array of structs with the following elements: quadint `id`, zoom level (`z`), and horizontal (`x`) and vertical (`y`) position of the tile. These quadint indexes can be used for grouping and generating aggregations of points throughout the zoom range requested. Notice the use of an additional variable `resolution` for adjusting the desired level of granularity.

* `longitude`: `FLOAT64` horizontal coordinate of the map.
* `latitude`: `FLOAT64` vertical coordinate of the map.
* `zoom_min`: `INT64` minimum zoom to get the quadints from.
* `zoom_max`: `INT64` maximum zoom to get the quadints from.
* `zoom_step`: `INT64` used for skipping levels of zoom.
* `resolution`: `INT64` resolution added to the current zoom to extract the quadints.

**Return type**

`ARRAY<STRUCT<INT64, INT64, INT64>>`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

```sql
SELECT `carto-os`.carto.QUADINT_FROMLONGLAT_ZOOMRANGE(40.4168, -3.7038, 3, 6, 1, 4);
-- id        z  x   y
-- 268743    3  4   4
-- 1069960   4  9   8
-- 4286249   5  19  16
-- 17124938  6  39  32
```