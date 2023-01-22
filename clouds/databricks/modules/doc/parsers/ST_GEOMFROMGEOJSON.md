## ST_GEOMFROMGEOJSON

```sql:signature
carto.ST_GEOMFROMGEOJSON(geojson)
```

**Description**

Creates a `Geometry` from the given GeoJSON.

* `geojson`: `String` geojson text.

**Return type**

`Geometry`

**Example**

```sql
SELECT carto.ST_ASTEXT(
  carto.ST_GEOMFROMGEOJSON('{"type":"Point","coordinates":[-76.0913,18.4275,0.0]}')
);
-- POINT (-76.0913 18.4275)
```