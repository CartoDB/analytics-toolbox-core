## ST_LINEFROMTEXT

```sql:signature
carto.ST_LINEFROMTEXT(wkt)
```

**Description**

Creates a `LineString` from the given WKT representation.

* `wkt`: `String` geom in WKT format.

**Return type**

`LineString`

**Example**

```sql
SELECT carto.ST_ASGEOJSON(carto.ST_LINEFROMTEXT('LINESTRING(0 0, 0 3, 5 3)'));
-- {"type":"LineString","coordinates":[[0.0,0.0,0.0],[0.0,3,0.0],[5,3,0.0]]}
```