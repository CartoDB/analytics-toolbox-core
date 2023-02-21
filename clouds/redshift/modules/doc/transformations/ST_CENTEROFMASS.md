## ST_CENTEROFMASS

```sql:signature
carto.ST_CENTEROFMASS(geom)
```

**Description**

Takes any Feature or a FeatureCollection and returns its center of mass. It is equivalent to [`ST_CENTROID`](transformations#st_centroid).

* `geom`: `GEOMETRY` for which to compute the center of mass.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT carto.ST_CENTEROFMASS(ST_GEOMFROMTEXT('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'));
-- POINT (25.4545454545 26.9696969697)
```
