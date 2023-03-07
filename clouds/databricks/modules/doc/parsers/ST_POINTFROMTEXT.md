## ST_POINTFROMTEXT

```sql:signature
ST_POINTFROMTEXT(wkt)
```

**Description**

Creates a `Point` corresponding to the given WKT representation.

* `wkt`: `String` geom in WKT format.

**Return type**

`Point`

**Example**

```sql
SELECT carto.ST_ASGEOJSON(carto.ST_POINTFROMTEXT('POINT(-76.09130 18.42750)'));
-- {"type":"Point","coordinates":[-76.0913,18.4275,0.0]}
```
