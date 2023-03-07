## ST_CENTROID

```sql:signature
ST_CENTROID(geom)
```

**Description**

Takes any Feature or a FeatureCollection as input and returns its centroid. It is equivalent to [`ST_CENTEROFMASS`](transformations#st_centerofmass).

* `geom`: `GEOMETRY` for which to compute the centroid.

**Return type**

`GEOMETRY`

**Example**

```sql
SELECT carto.ST_CENTROID(ST_GEOMFROMTEXT('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))'));
-- POINT (25.4545454545 26.9696969697)
```
