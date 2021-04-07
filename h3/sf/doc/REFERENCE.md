## h3

[H3](https://eng.uber.com/h3/) is Uber’s Hexagonal Hierarchical Spatial Index. Full documentation of the project can be found at [h3geo](https://h3geo.org/docs). You can also learn more about H3 in the [Overview section](/spatial-extension-bq/spatial-indexes/overview/#h3) of this documentation.

### ST_ASH3

{{% bannerNote type="code" %}}
H3.ST_ASH3(point, resolution)
{{%/ bannerNote %}}

**Description**

Returns the H3 cell index that the point belongs to in the required `resolution`. It will return `null` on error (invalid geography type or resolution out of bounds).

* `point`: `GEOGRAPHY` point to get the H3 cell from.
* `resolution`: `INT` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`STRING`

**Example**

```sql
SELECT SFCARTO.H3.ST_ASH3(ST_POINT(40.4168, -3.7038), 4);
-- 847b59dffffffff
```

{{% bannerNote type="note" title="tip"%}}
If you want the cells covered by a POLYGON see [ST_ASH3_POLYFILL](#st_ash3_polyfill).
{{%/ bannerNote %}}

### LONGLAT_ASH3

{{% bannerNote type="code" %}}
H3.LONGLAT_ASH3(longitude, latitude, resolution)
{{%/ bannerNote %}}

**Description**

Returns the H3 cell index that the point belongs to in the required `resolution`. It will return `null` on error (resolution out of bounds).

* `longitude`: `DOUBLE` horizontal coordinate of the map.
* `latitude`: `DOUBLE` vertical coordinate of the map.
* `resolution`: `INT` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`STRING`

**Example**

```sql
SELECT SFCARTO.H3.LONGLAT_ASH3(40.4168, -3.7038, 4);
-- 847b59dffffffff
```

### ST_ASH3_POLYFILL

{{% bannerNote type="code" %}}
H3.ST_ASH3_POLYFILL(geography, resolution)
{{%/ bannerNote %}}

**Description**

Returns an array with all the H3 cell indexes **with centers** contained in a given polygon. It will return `null` on error (invalid geography type or resolution out of bounds).

* `geography`: `GEOGRAPHY` **polygon** or **multipolygon** representing the area to cover.
* `resolution`: `INT` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`ARRAY`

**Example**

```sql
SELECT SFCARTO.H3.ST_ASH3_POLYFILL(
    TO_GEOGRAPHY('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'), 4);
-- 842da29ffffffff
-- 843f725ffffffff
-- 843eac1ffffffff
-- 8453945ffffffff
-- ...
```

### ST_BOUNDARY

{{% bannerNote type="code" %}}
H3.ST_BOUNDARY(index)
{{%/ bannerNote %}}

**Description**

Returns a geography representing the H3 cell. It will return `null` on error (invalid input).

* `index`: `STRING` The H3 cell index as hexadecimal.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT SFCARTO.H3.ST_BOUNDARY('847b59dffffffff');
-- { "coordinates": [ [ [ 40.46506362234518, -3.9352772457964957 ], [ 40.546540602670504, -3.706115055436962 ], ...
```

### ISVALID

{{% bannerNote type="code" %}}
H3.ISVALID(index)
{{%/ bannerNote %}}

**Description**

Returns `true` when the given index is valid, `false` otherwise.

* `index`: `STRING` The H3 cell index as hexadecimal.

**Return type**

`BOOLEAN`

**Examples**

```sql
SELECT SFCARTO.H3.ISVALID('847b59dffffffff');
-- true
```

```sql
SELECT SFCARTO.H3.ISVALID('1');
-- false
```

### COMPACT

{{% bannerNote type="code" %}}
H3.COMPACT(indexArray)
{{%/ bannerNote %}}

**Description**

Returns an array with the indexes of a set of hexagons across multiple resolutions that represent the same area as the input set of hexagons.

* `indexArray`: `ARRAY` of H3 cell indices of the same resolution as hexadecimal.

**Return type**

`ARRAY`

**Example**

```sql
SELECT SFCARTO.H3.COMPACT(ARRAY_CONSTRUCT('857b59c3fffffff', '857b59c7fffffff', '857b59cbfffffff','857b59cffffffff', '857b59d3fffffff', '857b59d7fffffff', '857b59dbfffffff'));
-- 847b59dffffffff
```

### UNCOMPACT

{{% bannerNote type="code" %}}
H3.UNCOMPACT(indexArray, resolution)
{{%/ bannerNote %}}

**Description**

Returns an array with the indexes of a set of hexagons of the same `resolution` that represent the same area as the [compacted](#h3compact) input hexagons.

* `indexArray`: `ARRAY` of H3 cell indices as hexadecimal.
* `resolution`: `INT` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`ARRAY`

**Example**

```sql
SELECT SFCARTO.H3.UNCOMPACT(ARRAY_CONSTRUCT('847b59dffffffff'), 5);
-- 857b59c3fffffff
-- 857b59c7fffffff
-- 857b59cbfffffff
-- 857b59cffffffff
-- 857b59d3fffffff
-- 857b59d7fffffff
-- 857b59dbfffffff
```

### TOPARENT

{{% bannerNote type="code" %}}
H3.TOPARENT(index, resolution)
{{%/ bannerNote %}}

**Description**

Returns the H3 cell index of the parent of the given hexagon at the given resolution.

* `index`: `STRING` The H3 cell index as hexadecimal.
* `resolution`: `INT` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`STRING`

**Example**

```sql
SELECT SFCARTO.H3.TOPARENT('847b59dffffffff', 3);
-- 837b59fffffffff
```

### TOCHILDREN

{{% bannerNote type="code" %}}
H3.TOCHILDREN(index, resolution)
{{%/ bannerNote %}}

**Description**

Returns an array with the indexes of the children/descendents of the given hexagon at the given resolution.

* `index`: `STRING` The H3 cell index as hexadecimal.
* `resolution`: `INT` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`ARRAY`

**Example**

```sql
SELECT SFCARTO.H3.TOCHILDREN('837b59fffffffff', 4);
-- 847b591ffffffff
-- 847b593ffffffff
-- 847b595ffffffff
-- 847b597ffffffff
-- 847b599ffffffff
-- 847b59bffffffff
-- 847b59dffffffff
```

### ISPENTAGON

{{% bannerNote type="code" %}}
H3.ISPENTAGON(index)
{{%/ bannerNote %}}

**Description**

Returns `true` if given H3 index is a pentagon. Returns `false` otherwise, even on invalid input.

* `index`: `STRING` The H3 cell index as hexadecimal.

**Return type**

`BOOLEAN`

**Example**

```sql
SELECT SFCARTO.H3.ISPENTAGON('837B59FFFFFFFFF');
-- false
```

### DISTANCE

{{% bannerNote type="code" %}}
H3.DISTANCE(origin, destination)
{{%/ bannerNote %}}

**Description**

Returns the **grid distance** between two hexagon indexes. This function may fail to find the distance between two indexes if they are very far apart or on opposite sides of a pentagon. Returns `null` on failure or invalid input.

* `origin`: `STRING` The H3 cell index as hexadecimal.
* `destination`: `STRING` The H3 cell index as hexadecimal.

**Return type**

`BIGINT`

**Example**

```sql
SELECT SFCARTO.H3.DISTANCE('847b591ffffffff', '847b59bffffffff');
-- 1
```

{{% bannerNote type="note" title="tip"%}}
If you want the distance in meters use [ST_DISTANCE](https://cloud.google.com/bigquery/docs/reference/standard-sql/geography_functions#st_distance) between the cells ([ST_BOUNDARY](#st_boundary)) or their centroid.
{{%/ bannerNote %}}

### KRING

{{% bannerNote type="code" %}}
H3.KRING(index, distance)
{{%/ bannerNote %}}

**Description**

Returns an array with the indexes of all hexagons within `distance` of the given input hexagon. The order of the hexagons is undefined. Returns `null` on invalid input.

* `index`: `STRING` The H3 cell index as hexadecimal.
* `distance`: `INT` distance (in number of cells) to the source.

**Return type**

`ARRAY`

**Example**

```sql
SELECT SFCARTO.H3.KRING('837b59fffffffff', 1);
-- 837b59fffffffff
-- 837b58fffffffff
-- 837b5bfffffffff
-- 837a66fffffffff
-- 837a64fffffffff
-- 837b4afffffffff
-- 837b5dfffffffff
```

### HEXRING

{{% bannerNote type="code" %}}
H3.HEXRING(index, distance)
{{%/ bannerNote %}}

**Description**

Get all hexagons in a **hollow hexagonal ring** centered at origin with sides of a given length. Unlike KRING, this function will return `null` if there is a pentagon anywhere in the ring.

* `index`: `STRING` The H3 cell index as hexadecimal.
* `distance`: `INT` distance (in cells) to the source.

**Return type**

`ARRAY`

**Example**

```sql
SELECT SFCARTO.H3.HEXRING('837b59fffffffff', 1);
-- 837b5dfffffffff
-- 837b58fffffffff
-- 837b5bfffffffff
-- 837a66fffffffff
-- 837a64fffffffff
-- 837b4afffffffff
```

### VERSION

{{% bannerNote type="code" %}}
H3.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the H3 module.

**Return type**

`STRING`

**Example**

```sql
SELECT SFCARTO.H3.VERSION();
-- 3.7.0.1
```
