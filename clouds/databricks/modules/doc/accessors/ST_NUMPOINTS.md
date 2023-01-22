## ST_NUMPOINTS

```sql:signature
carto.ST_NUMPOINTS(geom)
```

**Description**

Returns the number of vertices in `Geometry` _geom_.

* `geom`: `Geometry` input geom.

**Return type**

`Int`

**Example**

```sql
SELECT carto.ST_NUMPOINTS(carto.ST_GEOMFROMWKT("LINESTRING(1 1, 2 3, 4 4)"));
-- 3
```