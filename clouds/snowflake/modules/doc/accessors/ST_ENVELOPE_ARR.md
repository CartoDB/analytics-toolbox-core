## ST_ENVELOPE_ARR

```sql:signature
carto.ST_ENVELOPE_ARR(geojsons)
```

**Description**

Takes any number of features and returns a rectangular Polygon that encompasses all vertices.

* `geojsons`: `ARRAY` array of features in GeoJSON format casted to STRING.

**Return type**

`GEOGRAPHY`

**Example**

```sql
SELECT carto.ST_ENVELOPE_ARR(
  ARRAY_CONSTRUCT(
    ST_ASGEOJSON(ST_POINT(-75.833, 39.284))::STRING,
    ST_ASGEOJSON(ST_POINT(-75.6, 39.984))::STRING,
    ST_ASGEOJSON(ST_POINT(-75.221, 39.125))::STRING
  )
);
-- { "coordinates": [ [ [ -75.833, 39.125 ], [ -75.221, 39.125 ], [ -75.221, 39.984 ], ...
```
