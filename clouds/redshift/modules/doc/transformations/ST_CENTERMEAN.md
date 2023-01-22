## ST_CENTERMEAN

```sql:signature
carto.ST_CENTERMEAN(geom)
```

**Description**

Takes a Feature or FeatureCollection and returns the mean center (average of its vertices).

* `geom`: `GEOMETRY` for which to compute the mean center.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT carto.ST_CENTERMEAN(ST_GEOMFROMTEXT('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'));
-- POINT (25 27.5)
```