## ST_LENGTH

```sql:signature
carto.ST_LENGTH(line)
```

**Description**

Returns the 2D path length of linear geometries, or perimeter of areal geometries, in units of the the coordinate reference system (e.g. degrees for EPSG:4236). Returns `0.0` for other geometry types (e.g. `Point`).

* `line`: `LineString` input line.

**Return type**

`Double`

**Example**

```sql
SELECT carto.ST_LENGTH(carto.ST_GEOMFROMWKT('LINESTRING(0 0, 0 3, 5 3)'));
-- 8
```
