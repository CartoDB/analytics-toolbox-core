## ST_ASGEOJSON

```sql:signature
carto.ST_ASGEOJSON(geom)
```

**Description**

Returns `Geometry` _geom_ in GeoJSON representation.

* `geom`: `Geometry` input geom.

**Return type**

`Point`

**Example**

```sql
SELECT carto.ST_ASGEOJSON(carto.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)'));
-- {"type":"Point","coordinates":[-76.0913,18.4275,0.0]}
```
