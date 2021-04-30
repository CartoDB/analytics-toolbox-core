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
* `bbox`: `ARRAY<FLOAT64>` clipping bounding box. If `null` a default [-180,-85,180,-85] bbox will be used.

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
* `bbox`: `ARRAY<FLOAT64>` clipping bounding box. If `null` a default [-180,-85,180,-85] bbox will be used.

**Return type**

`ARRAY<GEOGRAPHY>`

**Example**

``` sql
SELECT bqcarto.processing.ST_VORONOILINES([ST_GEOGPOINT(-75.833, 39.284),ST_GEOGPOINT(-75.6, 39.984),ST_GEOGPOINT(-75.221, 39.125)], [-76.0, 39.0, -75.0, 40.0]);
-- LINESTRING(-76 39.728365, -75.8598447436013 39.6817133217987, ...
-- LINESTRING(-75 39.7356169965076, -75.2196894872026 39.6386876418512, ...
-- LINESTRING(-75.5801299019608 39, -75.509754438183 39.2708791435974, ...
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