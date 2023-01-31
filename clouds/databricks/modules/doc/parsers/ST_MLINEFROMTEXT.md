## ST_MLINEFROMTEXT

```sql:signature
carto.ST_MLINEFROMTEXT(wkt)
```

**Description**

Creates a `MultiLineString` corresponding to the given WKT representation.

* `wkt`: `String` geom in WKT format.

**Return type**

`MultiLineString`

**Example**

```sql
SELECT carto.ST_ASGEOJSON(carto.ST_MLINEFROMTEXT('MULTILINESTRING((1 1, 3 5), (-5 3, -8 -2))'));
-- {"type":"MultiLineString","coordinates":[[[1,1,0.0],[3,5,0.0]],[[-5,3,0.0],[-8,-2,0.0]]]}
```
