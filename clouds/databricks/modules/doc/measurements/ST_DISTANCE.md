## ST_DISTANCE

```sql:signature
ST_DISTANCE(geomA, geomB)
```

**Description**

Returns the 2D Cartesian distance between the two geometries in units of the coordinate reference system (e.g. degrees for EPSG:4236).

* `geomA`: `Geometry` input geom A.
* `geomB`: `Geometry` input geom B.

**Return type**

`Double`

**Example**

```sql
SELECT carto.ST_DISTANCE(carto.ST_POINT(0, 0), carto.ST_POINT(0, 5));
-- 5
```
