### ST_DELAUNAYLINES

{{% bannerNote type="code" %}}
carto.ST_DELAUNAYLINES(points)
{{%/ bannerNote %}}

**Description**

Calculates the Delaunay triangulation of the points provided. An array of linestrings in GeoJSON format is returned.

* `points`: `ARRAY` array of points in GeoJSON format casted to STRING.

**Return type**

`ARRAY`

**Example**

``` sql
SELECT carto.ST_DELAUNAYLINES(ARRAY_CONSTRUCT(ST_ASGEOJSON(ST_POINT(-75.833, 39.284))::STRING, ST_ASGEOJSON(ST_POINT(-75.6, 39.984))::STRING, ST_ASGEOJSON(ST_POINT(-75.221, 39.125))::STRING, ST_ASGEOJSON(ST_POINT(-75.521, 39.325))::STRING));
--  "{\"coordinates\":[[-75.833,39.284],[-75.221,39.125],[-75.6,39.984],[-75.833,39.284]],\"type\":\"LineString\"}",
--  "{\"coordinates\":[[-75.833,39.284],[-75.521,39.325],[-75.6,39.984],[-75.833,39.284]],\"type\":\"LineString\"}",
--  "{\"coordinates\":[[-75.833,39.284],[-75.521,39.325],[-75.221,39.125],[-75.833,39.284]],\"type\":\"LineString\"}",
--  "{\"coordinates\":[[-75.521,39.325],[-75.221,39.125],[-75.6,39.984],[-75.521,39.325]],\"type\":\"LineString\"}"
```
