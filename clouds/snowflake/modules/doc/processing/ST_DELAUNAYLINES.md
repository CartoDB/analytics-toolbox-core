### ST_DELAUNAYLINES

{{% bannerNote type="code" %}}
carto.ST_DELAUNAYLINES(points)
{{%/ bannerNote %}}

**Description**

Calculates the Delaunay triangulation of the points provided. An array of linestrings in GeoJSON format is returned.

* `points`: `ARRAY` array of points in GeoJSON format casted to STRING.

Due to technical limitations of the underlying libraries used, the input points' coordinates are truncated to 5 decimal places in order to avoid problems that happen with close but distinct input points. This limits the precision of the results and can alter slightly the position of the resulting polygons (about 1 meter). This can also result in some points being merged together, so that fewer polygons than expected may result.

**Return type**

`ARRAY`

**Examples**

``` sql
SELECT carto.ST_DELAUNAYLINES(
  ARRAY_CONSTRUCT(
    ST_ASGEOJSON(ST_POINT(-75.833, 39.284))::STRING,
    ST_ASGEOJSON(ST_POINT(-75.6, 39.984))::STRING,
    ST_ASGEOJSON(ST_POINT(-75.221, 39.125))::STRING,
    ST_ASGEOJSON(ST_POINT(-75.521, 39.325))::STRING
  )
);
--  "{\"coordinates\":[[-75.833,39.284],[-75.221,39.125],[-75.6,39.984],[-75.833,39.284]],\"type\":\"LineString\"}",
--  "{\"coordinates\":[[-75.833,39.284],[-75.521,39.325],[-75.6,39.984],[-75.833,39.284]],\"type\":\"LineString\"}",
--  "{\"coordinates\":[[-75.833,39.284],[-75.521,39.325],[-75.221,39.125],[-75.833,39.284]],\"type\":\"LineString\"}",
--  "{\"coordinates\":[[-75.521,39.325],[-75.221,39.125],[-75.6,39.984],[-75.521,39.325]],\"type\":\"LineString\"}"
```

Note that if some points are very close together (about 1 meter) they may be merged and the result may have fewer lines than expected, for example these four points result in two lines:

```sql
SELECT carto.ST_DELAUNAYLINES(
  ARRAY_CONSTRUCT(
    '{"coordinates":[4.1829523,43.6347910],"type":"Point"}',
    '{"coordinates":[4.1829967,43.6347137],"type":"Point"}',
    '{"coordinates":[4.1829955,43.6347143],"type":"Point"}',
    '{"coordinates":[4.1829321,43.6347500],"type":"Point"}'
  )
);
-- [
--   "{\"coordinates\":[[4.18293,43.63475],[4.183,43.63471],[4.18295,43.63479],[4.18293,43.63475]],\"type\":\"LineString\"}"
-- ]
```