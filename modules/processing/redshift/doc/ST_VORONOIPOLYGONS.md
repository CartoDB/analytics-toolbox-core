### ST_VORONOIPOLYGONS

{{% bannerNote type="code" %}}
processing.ST_VORONOIPOLYGONS(points)
{{%/ bannerNote %}}

**Description**

Calculates the Voronoi diagram of the points provided. A MultiPolygon object is returned.

* `points`: `GEOMETRY` MultiPoint input to the Voronoi diagram.

**Return type**

`VARCHAR(MAX)`

**Example**

```sql
SELECT processing.ST_VORONOIPOLYGONS(ST_GEOMFROMTEXT('MULTIPOINT((-74.5366825512491 43.6889777784079),(-74.4821382017478 43.3096147774153),(-70.7632814028801 42.9679602005825))'));
-- {"coordinates": [[[[-72.56389, 43.779024], [-22.619594, 305.159335], [-141.766048, 33.829104], [-72.56389, 43.779024]], [[-72.56389, 43.779024], [-82.019114, -59.13949], [-0.0, -126.520376], [67.087798, 0.0], [-0.0, 357.695653], [-22.619594, 305.159335], [-72.56389, 43.779024]], [[-72.56389, 43.779024], [-82.019114, -59.13949], [-156.73502, 0.0], [-141.766048, 33.829104], [-72.56389, 43.779024]]]], "type": "MultiPolygon"}
```