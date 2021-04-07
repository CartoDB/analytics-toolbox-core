## h3

[H3](https://eng.uber.com/h3/) is Uber’s Hexagonal Hierarchical Spatial Index. Full documentation of the project can be found at [h3geo](https://h3geo.org/docs). You can also learn more about H3 in the [Overview section](/spatial-extension-bq/spatial-indexes/overview/#h3) of this documentation.

### ST_ASH3

{{% bannerNote type="code" %}}
h3.ST_ASH3(point, resolution)
{{%/ bannerNote %}}

**Description**

Returns the H3 cell index that the point belongs to in the required `resolution`. It will return `null` on error (invalid geography type or resolution out of bounds).

* `point`: `GEOGRAPHY` point to get the H3 cell from.
* `resolution`: `INT64` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.h3.ST_ASH3(ST_GEOGPOINT(40.4168, -3.7038), 4);
-- 847b59dffffffff
```

{{% bannerNote type="note" title="tip"%}}
If you want the cells covered by a POLYGON see [ST_ASH3_POLYFILL](#st_ash3_polyfill).
{{%/ bannerNote %}}

### LONGLAT_ASH3

{{% bannerNote type="code" %}}
h3.LONGLAT_ASH3(longitude, latitude, resolution)
{{%/ bannerNote %}}

**Description**

Returns the H3 cell index that the point belongs to in the required `resolution`. It will return `null` on error (resolution out of bounds).

* `longitude`: `FLOAT64` horizontal coordinate of the map.
* `latitude`: `FLOAT64` vertical coordinate of the map.
* `resolution`: `INT64` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`INT64`

**Example**

```sql
SELECT bqcarto.h3.LONGLAT_ASH3(40.4168, -3.7038, 4);
-- 847b59dffffffff
```

### ST_ASH3_POLYFILL

{{% bannerNote type="code" %}}
h3.ST_ASH3_POLYFILL(geography, resolution)
{{%/ bannerNote %}}

**Description**

Returns an array with all the H3 cell indexes **with centers** contained in a given polygon. It will return `null` on error (invalid geography type or resolution out of bounds).

* `geography`: `GEOGRAPHY` **polygon** or **multipolygon** representing the area to cover.
* `resolution`: `INT64` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`ARRAY<STRING>`

**Example**

```sql
SELECT bqcarto.h3.ST_ASH3_POLYFILL(
    ST_GEOGFROMTEXT("POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))"), 4);
-- 846b26bffffffff
-- 843e8b1ffffffff
-- 842d1e5ffffffff
-- 843ece5ffffffff
-- ...
```

### ST_BOUNDARY

{{% bannerNote type="code" %}}
h3.ST_BOUNDARY(index)
{{%/ bannerNote %}}

**Description**

Returns a geography representing the H3 cell. It will return `null` on error (invalid input).

* `index`: `STRING` The H3 cell index.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT bqcarto.h3.ST_BOUNDARY("847b59dffffffff");
-- POLYGON((40.4650636223452 -3.9352772457965, 40.5465406026705 ...
```

### ISVALID

{{% bannerNote type="code" %}}
h3.ISVALID(index)
{{%/ bannerNote %}}

**Description**

Returns `true` when the given index is valid, `false` otherwise.

* `index`: `STRING` The H3 cell index.

**Return type**

`BOOLEAN`

**Examples**

```sql
SELECT bqcarto.h3.ISVALID("847b59dffffffff");
-- true
```

```sql
SELECT bqcarto.h3.ISVALID("1");
-- false
```

### COMPACT

{{% bannerNote type="code" %}}
h3.COMPACT(indexArray)
{{%/ bannerNote %}}

**Description**

Returns an array with the indexes of a set of hexagons across multiple resolutions that represent the same area as the input set of hexagons.

* `indexArray`: `ARRAY<STRING>` of H3 cell indices of the same resolution.

**Return type**

`ARRAY<STRING>`

**Example**

```sql
SELECT bqcarto.h3.COMPACT(["857b59c3fffffff", "857b59c7fffffff", "857b59cbfffffff","857b59cffffffff", "857b59d3fffffff", "857b59d7fffffff", "857b59dbfffffff"]);
-- 847b59dffffffff
```

### UNCOMPACT

{{% bannerNote type="code" %}}
h3.UNCOMPACT(indexArray, resolution)
{{%/ bannerNote %}}

**Description**

Returns an array with the indexes of a set of hexagons of the same `resolution` that represent the same area as the [compacted](#h3compact) input hexagons.

* `indexArray`: `ARRAY<STRING>` of H3 cell indices.
* `resolution`: `INT64` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`ARRAY<STRING>`

**Example**

```sql
SELECT bqcarto.h3.UNCOMPACT(["847b59dffffffff"], 5);
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
h3.TOPARENT(index, resolution)
{{%/ bannerNote %}}

**Description**

Returns the H3 cell index of the parent of the given hexagon at the given resolution.

* `index`: `STRING` The H3 cell index.
* `resolution`: `INT64` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.h3.TOPARENT("847b59dffffffff", 3);
-- 837b59fffffffff
```

### TOCHILDREN

{{% bannerNote type="code" %}}
h3.TOCHILDREN(index, resolution)
{{%/ bannerNote %}}

**Description**

Returns an array with the indexes of the children/descendents of the given hexagon at the given resolution.

* `index`: `STRING` The H3 cell index.
* `resolution`: `INT64` number between 0 and 15 with the [H3 resolution](https://h3geo.org/docs/core-library/restable).

**Return type**

`ARRAY<STRING>`

**Example**

```sql
SELECT bqcarto.h3.TOCHILDREN("837b59fffffffff", 4);
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
h3.ISPENTAGON(index)
{{%/ bannerNote %}}

**Description**

Returns `true` if given H3 index is a pentagon. Returns `false` otherwise, even on invalid input.

* `index`: `STRING` The H3 cell index.

**Return type**

`BOOLEAN`

**Example**

```sql
SELECT bqcarto.h3.ISPENTAGON("837b59fffffffff");
-- false
```

### DISTANCE

{{% bannerNote type="code" %}}
h3.DISTANCE(origin, destination)
{{%/ bannerNote %}}

**Description**

Returns the **grid distance** between two hexagon indexes. This function may fail to find the distance between two indexes if they are very far apart or on opposite sides of a pentagon. Returns `null` on failure or invalid input.

* `origin`: `STRING` origin H3 cell index.
* `destination`: `STRING` destination H3 cell index.

**Return type**

`INT64`

**Example**

```sql
SELECT bqcarto.h3.DISTANCE("847b591ffffffff", "847b59bffffffff");
-- 1
```

{{% bannerNote type="note" title="tip"%}}
If you want the distance in meters use [ST_DISTANCE](https://cloud.google.com/bigquery/docs/reference/standard-sql/geography_functions#st_distance) between the cells ([ST_BOUNDARY](#st_boundary)) or their centroid.
{{%/ bannerNote %}}

### KRING

{{% bannerNote type="code" %}}
h3.KRING(index, distance)
{{%/ bannerNote %}}

**Description**

Returns an array with the indexes of all hexagons within `distance` of the given input hexagon. The order of the hexagons is undefined. Returns `null` on invalid input.

* `index`: `STRING` The H3 cell index.
* `distance`: `INT64` distance (in number of cells) to the source.

**Return type**

`ARRAY<STRING>`

**Example**

```sql
SELECT bqcarto.h3.KRING("837b59fffffffff", 1);
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
h3.HEXRING(index, distance)
{{%/ bannerNote %}}

**Description**

Get all hexagons in a **hollow hexagonal ring** centered at origin with sides of a given length. Unlike KRING, this function will return `null` if there is a pentagon anywhere in the ring.

* `index`: `STRING` The H3 cell index.
* `distance`: `INT64` distance (in cells) to the source.

**Return type**

`ARRAY<STRING>`

**Example**

```sql
SELECT bqcarto.h3.HEXRING("837b59fffffffff", 1);
-- 837b5dfffffffff
-- 837b58fffffffff
-- 837b5bfffffffff
-- 837a66fffffffff
-- 837a64fffffffff
-- 837b4afffffffff
```

### VERSION

{{% bannerNote type="code" %}}
h3.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the H3 module.

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.h3.VERSION();
-- 3.7.0.1
```
