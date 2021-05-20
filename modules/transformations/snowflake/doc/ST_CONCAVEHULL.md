### ST_CONCAVEHULL

{{% bannerNote type="code" %}}
transformations.ST_CONCAVEHULL(geojsons [, maxEdge] [, units])
{{%/ bannerNote %}}

**Description**

Takes a set of points and returns a concave hull Polygon or MultiPolygon. Internally, this uses turf-tin to generate geometries. https://turfjs.org/docs/#concave

* `geojsons`: `ARRAY` array of features in GeoJSON format casted to STRING.
* `maxEdge` (optional): `DOUBLE` the length (in 'units') of an edge necessary for part of the hull to become concave. By default `maxEdge` is `infinity`.
* `units` (optional): `STRING` any of the options supported by turf units: miles, kilometers, degrees or radians. By default `units` is `kilometers`.

**Return type**

`GEOGRAPHY`

**Examples**

``` sql
SELECT sfcarto.transformations.ST_CONCAVEHULL(ARRAY_CONSTRUCT(ST_ASGEOJSON(ST_POINT(-75.833, 39.284))::STRING, ST_ASGEOJSON(ST_POINT(-75.6, 39.984))::STRING, ST_ASGEOJSON(ST_POINT(-75.221, 39.125))::STRING, ST_ASGEOJSON(ST_POINT(-75.521, 39.325))::STRING));
-- { "coordinates": [ [ [ -75.221, 39.125 ], [ -75.833, 39.284 ], [ -75.6, 39.984 ], [ -75.221, 39.125 ] ] ], "type": "Polygon" }
```

``` sql
SELECT sfcarto.transformations.ST_CONCAVEHULL(ARRAY_CONSTRUCT(ST_ASGEOJSON(ST_POINT(-75.833, 39.284))::STRING, ST_ASGEOJSON(ST_POINT(-75.6, 39.984))::STRING, ST_ASGEOJSON(ST_POINT(-75.221, 39.125))::STRING, ST_ASGEOJSON(ST_POINT(-75.521, 39.325))::STRING), 100);
-- { "coordinates": [ [ [ -75.833, 39.284 ], [ -75.6, 39.984 ], ...
```

``` sql
SELECT sfcarto.transformations.ST_CONCAVEHULL(ARRAY_CONSTRUCT(ST_ASGEOJSON(ST_POINT(-75.833, 39.284))::STRING, ST_ASGEOJSON(ST_POINT(-75.6, 39.984))::STRING, ST_ASGEOJSON(ST_POINT(-75.221, 39.125))::STRING, ST_ASGEOJSON(ST_POINT(-75.521, 39.325))::STRING), 100, 'kilometers');
-- { "coordinates": [ [ [ -75.833, 39.284 ], [ -75.6, 39.984 ], ...
```