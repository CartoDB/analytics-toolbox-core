## processing

<div class="badge core"></div>

On this module are contained functions that create geographies from already existing geographies by computing a prior processing.

### ST_VORONOIPOLYGONS

{{% bannerNote type="code" %}}
processing.ST_VORONOIPOLYGONS(points, bbox)
{{%/ bannerNote %}}

**Description**

Calculates the Voronoi diagram of the points provided. An array of polygons is returned. https://turfjs.org/docs/#voronoi

* `points`: `ARRAY<GEOGRAPHY>` input to the Voronoi diagram.
* `bbox`: `ARRAY<FLOAT64>|NULL` clipping bounding box. If `NULL` a default [-180,-85,180,-85] bbox will be used.

**Return type**

`ARRAY<GEOGRAPHY>`

**Example**

``` sql
SELECT bqcarto.processing.ST_VORONOIPOLYGONS([ST_GEOGPOINT(-75.833, 39.284),ST_GEOGPOINT(-75.6, 39.984),ST_GEOGPOINT(-75.221, 39.125)], [-76.0, 39.0, -75.0, 40.0]);
-- POLYGON((-76 39, -75.7900649509804 39, -75.5801299019608 39, ...
-- POLYGON((-75 40, -75.25 40, -75.5 40, -75.75 40, -76 40, ...
-- POLYGON((-75.4350974264706 39, -75.2900649509804 39, ... 
```

### ST_VORONOILINES

{{% bannerNote type="code" %}}
processing.ST_VORONOILINES(points, bbox)
{{%/ bannerNote %}}

**Description**

Calculates the Voronoi diagram of the points provided. An array of lines is returned. https://turfjs.org/docs/#voronoi

* `points`: `ARRAY<GEOGRAPHY>` input to the Voronoi diagram.
* `bbox`: `ARRAY<FLOAT64>|NULL` clipping bounding box. If `NULL` a default [-180,-85,180,-85] bbox will be used.

**Return type**

`ARRAY<GEOGRAPHY>`

**Example**

``` sql
SELECT bqcarto.processing.ST_VORONOILINES([ST_GEOGPOINT(-75.833, 39.284),ST_GEOGPOINT(-75.6, 39.984),ST_GEOGPOINT(-75.221, 39.125)], [-76.0, 39.0, -75.0, 40.0]);
-- LINESTRING(-76 39.728365, -75.8598447436013 39.6817133217987, ...
-- LINESTRING(-75 39.7356169965076, -75.2196894872026 39.6386876418512, ...
-- LINESTRING(-75.5801299019608 39, -75.509754438183 39.2708791435974, ...
```

### ST_DELAUNAYPOLYGONS

{{% bannerNote type="code" %}}
processing.ST_DELAUNAYPOLYGONS(points)
{{%/ bannerNote %}}

**Description**

Calculates the Delaunay triangulation of the points provided. An array of polygons is returned.

* `points`: `ARRAY<GEOGRAPHY>` input to the Delaunay triangulation.

**Return type**

`ARRAY<GEOGRAPHY>`

**Example**

``` sql
SELECT bqcarto.processing.ST_DELAUNAYPOLYGONS([ST_GEOGPOINT(-74.5366825512491, 43.6889777784079), ST_GEOGPOINT(-74.4821382017478, 43.3096147774153), ST_GEOGPOINT(-70.7632814028801, 42.9679602005825), ST_GEOGPOINT(-73.3262122666779, 41.2706174323278), ST_GEOGPOINT(-70.2005131676838, 43.8455720129728), ST_GEOGPOINT(-73.9704330709753, 35.3953164724094), ST_GEOGPOINT(-72.3402283537205, 35.8941454568627), ST_GEOGPOINT(-72.514071762468, 36.5823995124737)]);
-- POLYGON((-74.5366825512491 43.6889777784079, -70.7632814028801 ...
-- POLYGON((-70.7632814028801 42.9679602005825, -74.5366825512491 ...
-- POLYGON((-70.7632814028801 42.9679602005825, -74.4821382017478 ... 
-- POLYGON((-73.9704330709753 35.3953164724094, -72.3402283537205 ...
-- POLYGON((-73.9704330709753 35.3953164724094, -72.514071762468 ...
-- POLYGON((-70.7632814028801 42.9679602005825, -73.3262122666779 ...
```

### ST_DELAUNAYLINES

{{% bannerNote type="code" %}}
processing.ST_DELAUNAYLINES(points)
{{%/ bannerNote %}}

**Description**

Calculates the Delaunay triangulation of the points provided. An array of linestring is returned.

* `points`: `ARRAY<GEOGRAPHY>` input to the Delaunay triangulation.

**Return type**

`ARRAY<GEOGRAPHY>`

**Example**

``` sql
SELECT bqcarto.processing.ST_DELAUNAYLINES([ST_GEOGPOINT(-74.5366825512491, 43.6889777784079), ST_GEOGPOINT(-74.4821382017478, 43.3096147774153), ST_GEOGPOINT(-70.7632814028801, 42.9679602005825), ST_GEOGPOINT(-73.3262122666779, 41.2706174323278), ST_GEOGPOINT(-70.2005131676838, 43.8455720129728), ST_GEOGPOINT(-73.9704330709753, 35.3953164724094), ST_GEOGPOINT(-72.3402283537205, 35.8941454568627), ST_GEOGPOINT(-72.514071762468, 36.5823995124737)]);
-- LINESTRING(-74.5366825512491 43.6889777784079, -70.7632814028801 ...
-- LINESTRING(-74.4821382017478 43.3096147774153, -74.5366825512491  ...
-- LINESTRING(-73.3262122666779 41.2706174323278, -74.4821382017478 ... 
-- LINESTRING(-73.9704330709753 35.3953164724094, -72.3402283537205 ...
-- LINESTRING(-73.9704330709753 35.3953164724094, -72.514071762468 ...
-- LINESTRING(-72.514071762468 36.5823995124737, -73.3262122666779 ...
```

### ST_POLYGONIZE

{{% bannerNote type="code" %}}
processing.ST_POLYGONIZE(lines)
{{%/ bannerNote %}}

**Description**

Creates a set of polygons from geographies which contain lines that represent the their edges.

* `lines`: `ARRAY<GEOGRAPHY>` array of lines which represent the polygons edges.

**Return type**

`ARRAY<GEOGRAPHY>`

**Example**

``` sql
SELECT bqcarto.processing.ST_POLYGONIZE([ST_GEOGFROMTEXT('LINESTRING(-74.5366825512491 43.6889777784079, -70.7632814028801 42.9679602005825, -70.2005131676838 43.8455720129728, -74.5366825512491 43.6889777784079)'), 
ST_GEOGFROMTEXT('LINESTRING(-73.9704330709753 35.3953164724094, -72.514071762468 36.5823995124737, -73.3262122666779 41.2706174323278, -73.9704330709753 35.3953164724094)')]);
-- POLYGON((-74.5366825512491 43.6889777784079, -70.7632814028801 42.9679602005825, -70.2005131676838 43.8455720129728, -74.5366825512491 43.6889777784079))
-- POLYGON((-73.9704330709753 35.3953164724094, -72.514071762468 36.5823995124737, -73.3262122666779 41.2706174323278, -73.9704330709753 35.3953164724094))
```

### VERSION

{{% bannerNote type="code" %}}
processing.VERSION()
{{%/ bannerNote %}}

**Description**

Returns the current version of the processing module.

**Return type**

`STRING`

**Example**

```sql
SELECT bqcarto.processing.VERSION();
-- 1.0.0
```
