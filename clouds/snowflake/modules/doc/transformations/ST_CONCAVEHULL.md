## ST_CONCAVEHULL

```sql:signature
ST_CONCAVEHULL(geojsons [, maxEdge] [, units])
```

**Description**

Takes a set of points and returns a concave hull Polygon or MultiPolygon. In case that a single or a couple of points are passed as input, the function will return that point or a segment respectively.

* `geojsons`: `ARRAY` array of features in GeoJSON format casted to STRING.
* `maxEdge` (optional): `DOUBLE` the length (in 'units') of an edge necessary for part of the hull to become concave. By default `maxEdge` is `infinity`.
* `units` (optional): `STRING` units of length, the supported options are: miles, kilometers, degrees or radians. By default `units` is `kilometers`.

**Return type**

`GEOGRAPHY`

**Examples**

```sql
SELECT carto.ST_CONCAVEHULL(
  ARRAY_CONSTRUCT(
    ST_ASGEOJSON(ST_POINT(-75.833, 39.284))::STRING,
    ST_ASGEOJSON(ST_POINT(-75.6, 39.984))::STRING,
    ST_ASGEOJSON(ST_POINT(-75.221, 39.125))::STRING,
    ST_ASGEOJSON(ST_POINT(-75.521, 39.325))::STRING
  )
);
-- { "coordinates": [ [ [ -75.221, 39.125 ], [ -75.833, 39.284 ], [ -75.6, 39.984 ], [ -75.221, 39.125 ] ] ], "type": "Polygon" }
```

```sql
SELECT carto.ST_CONCAVEHULL(
  ARRAY_CONSTRUCT(
    ST_ASGEOJSON(ST_POINT(-75.833, 39.284))::STRING,
    ST_ASGEOJSON(ST_POINT(-75.6, 39.984))::STRING,
    ST_ASGEOJSON(ST_POINT(-75.221, 39.125))::STRING,
    ST_ASGEOJSON(ST_POINT(-75.521, 39.325))::STRING
  ),
  100
);
-- { "coordinates": [ [ [ -75.833, 39.284 ], [ -75.6, 39.984 ], ...
```

```sql
SELECT carto.ST_CONCAVEHULL(
  ARRAY_CONSTRUCT(
    ST_ASGEOJSON(ST_POINT(-75.833, 39.284))::STRING,
    ST_ASGEOJSON(ST_POINT(-75.6, 39.984))::STRING,
    ST_ASGEOJSON(ST_POINT(-75.221, 39.125))::STRING,
    ST_ASGEOJSON(ST_POINT(-75.521, 39.325))::STRING
  ),
  100,
  'kilometers'
);
-- { "coordinates": [ [ [ -75.833, 39.284 ], [ -75.6, 39.984 ], ...
```

```sql
SELECT carto.ST_CONCAVEHULL(
  ARRAY_CONSTRUCT(
    ST_ASGEOJSON(
      ST_POINT(-75.833, 39.284))::STRING,
      ST_ASGEOJSON(ST_POINT(-75.6, 39.984))::STRING
    )
  );
--  { "coordinates": [ -75.833, 39.284 ], "type": "Point" }
```

If points are stored in a table, a query like the one below can be used (multiple polygons are generated in this case, one for each `cluster_id` value):

```sql
WITH _array AS (
    SELECT
        cluster_id,
        ARRAY_AGG(ST_ASGEOJSON(geom)::STRING) as geomarray
    from mytable
    group by cluster_id
)
SELECT
    carto.ST_CONCAVEHULL(geomarray) as geom,
    cluster_id
from _array
```