## ST_CENTERMEDIAN

```sql:signature
carto.ST_CENTERMEDIAN(geom)
```

**Description**

Takes a FeatureCollection of points and computes the median center. The median center is understood as the point that requires the least total travel from all other points.

* `geog`: `GEOMETRY` for which to compute the center.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT carto.ST_CENTERMEDIAN(ST_GEOMFROMTEXT('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'));
-- POINT (26.3841869726 19.0088147377)
```