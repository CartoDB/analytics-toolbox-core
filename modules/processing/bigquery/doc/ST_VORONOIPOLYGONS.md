### ST_VORONOIPOLYGONS

{{% bannerNote type="code" %}}
processing.ST_VORONOIPOLYGONS(points, bbox)
{{%/ bannerNote %}}

**Description**

Calculates the Voronoi diagram of the points provided. An array of polygons is returned.

* `points`: `ARRAY<GEOGRAPHY>` input to the Voronoi diagram.
* `bbox`: `ARRAY<FLOAT64>|NULL` clipping bounding box. If `NULL` a default [-180,-85,180,-85] bbox will be used.

**Return type**

`ARRAY<GEOGRAPHY>`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

``` sql
SELECT `carto-os`.processing.ST_VORONOIPOLYGONS([ST_GEOGPOINT(-75.833, 39.284),ST_GEOGPOINT(-75.6, 39.984),ST_GEOGPOINT(-75.221, 39.125)], [-76.0, 39.0, -75.0, 40.0]);
-- POLYGON((-76 39, -75.7900649509804 39, -75.5801299019608 39, ...
-- POLYGON((-75 40, -75.25 40, -75.5 40, -75.75 40, -76 40, ...
-- POLYGON((-75.4350974264706 39, -75.2900649509804 39, ... 
```