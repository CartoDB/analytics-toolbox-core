## quadkey

You can learn more about quadkeys and quandints in the [Overview section](/spatial-extension-bq/overview/spatial-indexes/#quadkey) of the documentation.

### QUADINT_FROMZXY

{{% bannerNote type="code" %}}
quadkey.QUADINT_FROMZXY(z, x, y)
{{%/ bannerNote %}}

**Description**

Returns a quadint from `z`, `x`, `y` coordinates.

* `z`: `INT` zoom level.
* `x`: `INT` horizontal position of a tile.
* `y`: `INT` vertical position of a tile.

**Constraints**

Tile coordinates `x` and `y` depend on the zoom level `z`. For both coordinates, the minimum value is 0, and the maximum value is two to the power of `z`, minus one (`2^z - 1`).

**Return type**

`BIGINT`

**Example**

```sql
SELECT sfcarto.quadkey.QUADINT_FROMZXY(4, 9, 8);
-- 4388
```

### ZXY_FROMQUADINT

{{% bannerNote type="code" %}}
quadkey.ZXY_FROMQUADINT(quadint)
{{%/ bannerNote %}}

**Description**

Returns the zoom level `z` and coordinates `x`, `y` for a given quadint.

* `quadint`: `BIGINT` quadint we want to extract tile information from.

**Return type**

`OBJECT`

**Example**

```sql
SELECT sfcarto.quadkey.ZXY_FROMQUADINT(4388);
-- z  x  y
-- 4  9  8
```

### LONGLAT_ASQUADINT

{{% bannerNote type="code" %}}
quadkey.LONGLAT_ASQUADINT(longitude, latitude, resolution)
{{%/ bannerNote %}}

**Description**

Returns the quadint representation for a given level of detail and geographic coordinates.

* `longitude`: `DOUBLE` horizontal coordinate of the map.
* `latitude`: `DOUBLE` vertical coordinate of the map.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`BIGINT`

**Example**

```sql
SELECT sfcarto.quadkey.LONGLAT_ASQUADINT(40.4168, -3.7038, 4);
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

`BIGINT`

**Example**

```sql
SELECT sfcarto.quadkey.QUADINT_FROMQUADKEY("3001");
-- 4388
```

### QUADKEY_FROMQUADINT

{{% bannerNote type="code" %}}
quadkey.QUADKEY_FROMQUADINT(quadint)
{{%/ bannerNote %}}

**Description**

Returns the quadkey equivalent to the input quadint.

* `quadint`: `BIGINT` quadint to be converted to quadkey.

**Return type**

`STRING`

**Example**

```sql
SELECT sfcarto.quadkey.QUADKEY_FROMQUADINT(4388);
-- 3001
```

### TOPARENT

{{% bannerNote type="code" %}}
quadkey.TOPARENT(quadint, resolution)
{{%/ bannerNote %}}

**Description**

Returns the parent quadint of a given quadint for a specific resolution. A parent quadint is the smaller resolution containing quadint.

* `quadint`: `BIGINT` quadint to get the parent from.
* `resolution`: `INT` resolution of the desired parent.

**Return type**

`BIGINT`

**Example**

```sql
SELECT sfcarto.quadkey.TOPARENT(4388, 3);
-- 1155
```

### TOCHILDREN

{{% bannerNote type="code" %}}
quadkey.TOCHILDREN(quadint, resolution)
{{%/ bannerNote %}}

**Description**

Returns an array with the children quadints of a given quadint for a specific resolution. A children quadint is a quadint of higher level of detail that is contained by the current quadint. Each quadint has four children by definition.

* `quadint`: `BIGINT` quadint to get the children from.
* `resolution`: `INT` resolution of the desired children.

**Return type**

`ARRAY`

**Example**

```sql
SELECT sfcarto.quadkey.TOCHILDREN(1155, 4);
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

* `quadint`: `BIGINT` quadint to get the sibling from.
* `direction`: `STRING` <code>'right'|'left'|'up'|'down'</code> direction to move in to extract the next sibling. 

**Return type**

`BIGINT`

**Example**

```sql
SELECT sfcarto.quadkey.SIBLING(4388, 'up');
-- 3876
```

### KRING

{{% bannerNote type="code" %}}
quadkey.KRING(quadint, distance)
{{%/ bannerNote %}}

**Description**

Returns an array containing all the quadints directly next to the given quadint at the same level of zoom. Diagonal, horizontal and vertical nearby quadints plus the current quadint are considered, so KRING always returns `(distance*2 + 1)^2` quadints.

* `quadint`: `BIGINT` quadint to get the KRING from.
* `distance`: `INT` distance (in cells) to the source.

**Return type**

`ARRAY`

**Example**

```sql
SELECT sfcarto.quadkey.KRING(4388, 1);
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

* `quadint`: `BIGINT` quadint to get the bbox from.

**Return type**

`ARRAY`

**Example**

```sql
SELECT sfcarto.quadkey.BBOX(4388);
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
* `resolution`: `INT` level of detail or zoom.

**Return type**

`BIGINT`

**Example**

```sql
SELECT sfcarto.quadkey.ST_ASQUADINT(ST_POINT(40.4168, -3.7038), 4);
-- 4388
```

### ST_ASQUADINT_POLYFILL

{{% bannerNote type="code" %}}
quadkey.ST_ASQUADINT_POLYFILL(geography, resolution)
{{%/ bannerNote %}}

**Description**

Returns an array of quadints that intersect with the given geography at a given level of detail.

* `geography`: `GEOGRAPHY` geography to extract the quadints from.
* `resolution`: `INT` level of detail or zoom.

**Return type**

`ARRAY`

**Example**

```sql
SELECT sfcarto.quadkey.ST_ASQUADINT_POLYFILL(ST_MAKEPOLYGON(TO_GEOGRAPHY('LINESTRING(-3.71219873428345 40.4133653490709, -3.71440887451172 40.4096566128639, -3.70659828186035 40.4095259047756, -3.71219873428345 40.4133653490709)')), 17);
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

* `quadint`: `BIGINT` quadint to get the boundary geography from.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT sfcarto.quadkey.ST_BOUNDARY(4388);
-- POLYGON((22.5 0, 22.5 -21.9430455334382, 22.67578125 ...
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
SELECT sfcarto.quadkey.VERSION();
-- 1
```
