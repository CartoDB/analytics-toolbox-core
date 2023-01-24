## GEOMREPROJECT

```sql:signature
carto.ST_GEOMREPROJECT(geom, crsA, crsB)
```

**Description**

Transform a `Geometry` from The Common Reference System _crsA_ to _crsB_.

* `geom`: `Geometry` input geom.
* `crsA`: `CRS` input crsA.
* `crsB`: `CRS` input crsB.

**Return type**

`Geometry`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_POINT(3, 5) AS point,
  carto.ST_CRSFROMTEXT('+proj=merc +lat_ts=56.5 +ellps=GRS80') AS crsa,
  carto.ST_CRSFROMTEXT('+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs') AS crsb
)
SELECT carto.ST_ASTEXT(carto.ST_GEOMREPROJECT(point, crsa, crsb)) FROM t;
-- POINT (0.00003 0.00005)
```
