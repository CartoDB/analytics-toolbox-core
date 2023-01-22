## ST_CASTTOPOINT

```sql:signature
carto.ST_CASTTOPOINT(geom)
```

**Description**

Casts `Geometry` _g_ to a `Point`.

* `geom`: `Geometry` input geom.

**Return type**

`Point`

**Example**

```sql
SELECT carto.ST_CASTTOPOINT(carto.ST_GEOMFROMWKT('POINT(75 29)'));
-- 4QgBgN6gywWAssiUAgA=
```