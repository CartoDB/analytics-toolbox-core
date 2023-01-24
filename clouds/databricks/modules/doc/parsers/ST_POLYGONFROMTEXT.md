## ST_POLYGONFROMTEXT

```sql:signature
carto.ST_POLYGONFROMTEXT(wkt)
```

**Description**

Creates a `Polygon` corresponding to the given WKT representation.

* `wkt`: `String` geom in WKT format.

**Return type**

`Polygon`

**Example**

```sql
SELECT carto.ST_ASGEOJSON(
  carto.ST_POLYGONFROMTEXT(
    'POLYGON((-73.98955 40.71278, -73.98958 40.71299, -73.98955 40.71278))'
  )
);
-- {"type":"Polygon","coordinates":[[[-73.98955,40.71278,0.0],[-73.98958,40.71299,0.0],[-73.98955,40.71278,0.0]...
```
