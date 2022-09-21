### ST_VORONOILINES

{{% bannerNote type="code" %}}
carto.ST_VORONOILINES(points, bbox)
{{%/ bannerNote %}}

**Description**

Calculates the Voronoi diagram of the points provided. An array of lines is returned.

* `points`: `ARRAY<GEOGRAPHY>` input to the Voronoi diagram.
* `bbox`: `ARRAY<FLOAT64>|NULL` clipping bounding box. If `NULL` a default [-180,-85,180,-85] bbox will be used.

**Return type**

`ARRAY<GEOGRAPHY>`

{{% customSelector %}}
**Example**
{{%/ customSelector %}}

``` sql
SELECT `carto-os`.carto.ST_VORONOILINES([ST_GEOGPOINT(-75.833, 39.284),ST_GEOGPOINT(-75.6, 39.984),ST_GEOGPOINT(-75.221, 39.125)], [-76.0, 39.0, -75.0, 40.0]);
-- LINESTRING(-76 39.728365, -75.8598447436013 39.6817133217987, ...
-- LINESTRING(-75 39.7356169965076, -75.2196894872026 39.6386876418512, ...
-- LINESTRING(-75.5801299019608 39, -75.509754438183 39.2708791435974, ...
```
