### ST_VORONOIPOLYGONS

{{% bannerNote type="code" %}}
processing.ST_VORONOIPOLYGONS(points [, bbox])
{{%/ bannerNote %}}

**Description**

Calculates the Voronoi diagram of the points provided. An array of polygons in GeoJSON format is returned. https://turfjs.org/docs/#voronoi

* `points`: `ARRAY` array of points in GeoJSON format casted to STRING.
* `bbox` (optional): `ARRAY` clipping bounding box. By default the [-180,-85,180,-85] bbox will be used.

**Return type**

`ARRAY`

**Example**

``` sql
SELECT sfcarto.processing.ST_VORONOIPOLYGONS(ARRAY_CONSTRUCT(ST_ASGEOJSON(ST_POINT(-75.833, 39.284))::STRING, ST_ASGEOJSON(ST_POINT(-75.6, 39.984))::STRING, ST_ASGEOJSON(ST_POINT(-75.221, 39.125))::STRING, ST_ASGEOJSON(ST_POINT(-75.521, 39.325))::STRING), ARRAY_CONSTRUCT(-76.0, 35.0, -70.0, 45.0));
-- [ "{\"type\":\"Polygon\",\"coordinates\":[[[-76,39.728365000000004],[-75.72047348298037,39.63532260219203],[-75.6178875502008,38.854668674698786],[-76,37.38389622641511],[-76,39.728365000000004]]]}", "{\"type\":\"Polygon\",\"coordinates\":[[[-70,41....
```

``` sql
SELECT sfcarto.processing.ST_VORONOIPOLYGONS(ARRAY_CONSTRUCT(ST_ASGEOJSON(ST_POINT(-75.833, 39.284))::STRING, ST_ASGEOJSON(ST_POINT(-75.6, 39.984))::STRING, ST_ASGEOJSON(ST_POINT(-75.221, 39.125))::STRING, ST_ASGEOJSON(ST_POINT(-75.521, 39.325))::STRING));
-- [ "{\"type\":\"Polygon\",\"coordinates\":[[[-180,74.34550785714367],[-75.72047348298037,39.63532260219203],[-75.6178875502008,38.854668674698786],[-107.79581617647065,-85],[-180,-85],[-180,74.34550785714367]]]}", "{\"type\":\"Polygon\",\"coordinates...
```