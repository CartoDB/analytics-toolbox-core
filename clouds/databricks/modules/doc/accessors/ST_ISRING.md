## ST_ISRING

```sql:signature
carto.ST_ISRING(geom)
```

**Description**

Returns `true` if _geom_ is a `LineString` or a `MultiLineString` and is both closed and simple.

* `geom`: `Geometry` input geom.

**Return type**

`Boolean`

**Example**

```sql
SELECT carto.ST_ISRING(carto.ST_GEOMFROMWKT("LINESTRING(1 1, 2 3, 4 3, 1 1)"));
-- true
```
