## ST_MPOLYFROMTEXT

```sql:signature
carto.ST_MPOLYFROMTEXT(wkt)
```

**Description**

Creates a `MultiPolygon` corresponding to the given WKT representation.

* `wkt`: `String` geom in WKT format.

**Return type**

`MultiPolygon`

**Example**

```sql
SELECT carto.ST_ASGEOJSON(
  carto.ST_MPOLYFROMTEXT(
    'MULTIPOLYGON (((30 20, 45 40, 10 40, 30 20)),((15 5, 40 10, 10 20, 5 10, 15 5)))'
  )
);
-- {"type":"MultiPolygon","coordinates":[[[[30,20,0.0],[45,40,0.0],[10,40,0.0],[30,20,0.0]]]...
```
