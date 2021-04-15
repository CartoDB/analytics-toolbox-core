## quadkey

<div class="badge core"></div>

You can learn more about quadkeys and quandints in the [Overview section](/spatial-extension-bq/overview/spatial-indexes/#quadkey) of the documentation.

### QUADINT_FROMZXY

{{% bannerNote type="code" %}}
quadkey.QUADINT_FROMZXY(z, x, y)
{{%/ bannerNote %}}

**Description**

Returns a quadint from `z`, `x`, `y` coordinates.

* `z`: `INT64` zoom level.
* `x`: `INT64` horizontal position of a tile.
* `y`: `INT64` vertical position of a tile.

**Constraints**

Tile coordinates `x` and `y` depend on the zoom level `z`. For both coordinates, the minimum value is 0, and the maximum value is two to the power of `z`, minus one (`2^z - 1`).

**Return type**

`INT64`

**Example**

```sql
SELECT bqcarto.quadkey.QUADINT_FROMZXY(4, 9, 8);
-- 4388
```

### ZXY_FROMQUADINT

{{% bannerNote type="code" %}}
quadkey.ZXY_FROMQUADINT(quadint)
{{%/ bannerNote %}}

**Description**

Returns the zoom level `z` and coordinates `x`, `y` for a given quadint.

* `quadint`: `INT64` quadint we want to extract tile information from.

**Return type**

`STRUCT<INT64, INT64, INT64>`

**Example**

```sql
SELECT bqcarto.quadkey.ZXY_FROMQUADINT(4388);
-- z  x  y
-- 4  9  8
```

### LONGLAT_ASQUADINT

{{% bannerNote type="code" %}}
quadkey.LONGLAT_ASQUADINT(longitude, latitude, resolution)
{{%/ bannerNote %}}

**Description**

Returns the quadint representation for a given level of detail and geographic coordinates.

* `longitude`: `FLOAT64` horizontal coordinate of the map.
* `latitude`: `FLOAT64` vertical coordinate of the map.
* `resolution`: `INT64` level of detail or zoom.

**Return type**

`INT64`

**Example**

```sql
SELECT bqcarto.quadkey.LONGLAT_ASQUADINT(40.4168, -3.7038, 4);
-- 4388
```

### QUADINT_FROMQUADKEY

{{% bannerNote type="code" %}}
quadkey.QUADINT_FROMQUADKEY(quadkey)
{{%/ bannerNote %}}

**Description**

Returns the quadint equivalent to the input quadkey.

* `quadkey`: `STRING` quadkey to be converted to quadint.

**Return type**

`INT64`

**Example**

```sql
SELECT bqcarto.quadkey.QUADINT_FROMQUADKEY("3001");
-- 4388
```

### QUADKEY_FROMQUADINT

{{% bannerNote type="code" %}}
quadkey.QUADKEY_FROMQUADINT(quadint)
{{%/ bannerNote %}}

**Description**

Returns the quadkey equivalent to the input quadint.

* `quadint`: `INT64` quadint to be converted to quadkey.

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.quadkey.QUADKEY_FROMQUADINT(4388);
-- 3001
```

### TOPARENT

{{% bannerNote type="code" %}}
quadkey.TOPARENT(quadint, resolution)
{{%/ bannerNote %}}

**Description**

Returns the parent quadint of a given quadint for a specific resolution. A parent quadint is the smaller resolution containing quadint.

* `quadint`: `INT64` quadint to get the parent from.
* `resolution`: `INT64` resolution of the desired parent.

**Return type**

`INT64`

**Example**

```sql
SELECT bqcarto.quadkey.TOPARENT(4388, 3);
-- 1155
```

### TOCHILDREN

{{% bannerNote type="code" %}}
quadkey.TOCHILDREN(quadint, resolution)
{{%/ bannerNote %}}

**Description**

Returns an array with the children quadints of a given quadint for a specific resolution. A children quadint is a quadint of higher level of detail that is contained by the current quadint. Each quadint has four children by definition.

* `quadint`: `INT64` quadint to get the children from.
* `resolution`: `INT64` resolution of the desired children.

**Return type**

`ARRAY<INT64>`

**Example**

```sql
SELECT bqcarto.quadkey.TOCHILDREN(1155, 4);
-- 4356
-- 4868
-- 4388
-- 4900
```

### SIBLING

{{% bannerNote type="code" %}}
quadkey.SIBLING(quadint, direction)
{{%/ bannerNote %}}

**Description**

Returns the quadint directly next to the given quadint at the same zoom level. The direction must be sent as argument and currently only horizontal/vertical movements are allowed.

* `quadint`: `INT64` quadint to get the sibling from.
* `direction`: `STRING` <code>'right'|'left'|'up'|'down'</code> direction to move in to extract the next sibling. 

**Return type**

`INT64`

**Example**

```sql
SELECT bqcarto.quadkey.SIBLING(4388, 'up');
-- 3876
```

### KRING

{{% bannerNote type="code" %}}
quadkey.KRING(quadint, distance)
{{%/ bannerNote %}}

**Description**

Returns an array containing all the quadints directly next to the given quadint at the same level of zoom. Diagonal, horizontal and vertical nearby quadints plus the current quadint are considered, so KRING always returns `(distance*2 + 1)^2` quadints.

* `quadint`: `INT64` quadint to get the KRING from.
* `distance`: `INT64` distance (in cells) to the source.

**Return type**

`ARRAY<INT64>`

**Example**

```sql
SELECT bqcarto.quadkey.KRING(4388, 1);
-- 3844
-- 3876
-- 3908
-- 4356
-- 4388
-- 4420
-- 4868
-- 4900
-- 4932
```

### BBOX

{{% bannerNote type="code" %}}
quadkey.BBOX(quadint)
{{%/ bannerNote %}}

**Description**

Returns an array with the boundary box of a given quadint. This boundary box contains the minimum and maximum longitude and latitude. The output format is [West-South, East-North] or [min long, min lat, max long, max lat].

* `quadint`: `INT64` quadint to get the bbox from.

**Return type**

`ARRAY<FLOAT64>`

**Example**

```sql
SELECT bqcarto.quadkey.BBOX(4388);
-- 22.5
-- -21.943045533438177
-- 45.0
-- 0.0
```

### ST_ASQUADINT

{{% bannerNote type="code" %}}
quadkey.ST_ASQUADINT(point, resolution)
{{%/ bannerNote %}}

**Description**

Returns the quadint of a given point at a given level of detail.

* `point`: `GEOGRAPHY` point to get the quadint from.
* `resolution`: `INT64` level of detail or zoom.

**Return type**

`INT64`

**Example**

```sql
SELECT bqcarto.quadkey.ST_ASQUADINT(ST_GEOGPOINT(40.4168, -3.7038), 4);
-- 4388
```

### ST_ASQUADINT_POLYFILL

{{% bannerNote type="code" %}}
quadkey.ST_ASQUADINT_POLYFILL(geography, resolution)
{{%/ bannerNote %}}

**Description**

Returns an array of quadints that intersect with the given geography at a given level of detail.

* `geography`: `GEOGRAPHY` geography to extract the quadints from.
* `resolution`: `INT64` level of detail or zoom.

**Return type**

`ARRAY<INT64>`

**Example**

```sql
SELECT bqcarto.quadkey.ST_ASQUADINT_POLYFILL(
    ST_MAKEPOLYGON(ST_MAKELINE([ST_GEOGPOINT(-363.71219873428345, 40.413365349070865), ST_GEOGPOINT(-363.7144088745117, 40.40965661286395), ST_GEOGPOINT(-363.70659828186035, 40.409525904775634), ST_GEOGPOINT(-363.71219873428345, 40.413365349070865)])), 
    17);
-- 207301334801
-- 207305529105
-- 207305529073
-- 207305529137
-- 207305529169
-- 207301334833
```

### ST_BOUNDARY

{{% bannerNote type="code" %}}
quadkey.ST_BOUNDARY(quadint)
{{%/ bannerNote %}}

**Description**

Returns the boundary for a given quadint. We extract the boundary in the same way as when we calculate its [BBOX](#bbox), then enclose it in a GeoJSON and finally transform it into a geography.

* `quadint`: `INT64` quadint to get the boundary geography from.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT bqcarto.quadkey.ST_BOUNDARY(4388);
-- POLYGON((22.5 0, 22.5 -21.9430455334382, 22.67578125 ...
```

### LONGLAT_ASQUADINTLIST_RESOLUTION

{{% bannerNote type="code" %}}
quadkey.LONGLAT_ASQUADINTLIST_RESOLUTION(longitude, latitude, zoom_min, zoom_max, zoom_step, resolution)
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

**Example**

```sql
SELECT bqcarto.quadkey.LONGLAT_ASQUADINTLIST_RESOLUTION(40.4168, -3.7038, 3, 6, 1, 4);
-- id        z  x   y
-- 268743    3  4   4
-- 1069960   4  9   8
-- 4286249   5  19  16
-- 17124938  6  39  32
```

### VERSION

{{% bannerNote type="code" %}}
quadkey.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the quadkey module.

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.quadkey.VERSION();
-- 1.0.0
```
