## ST_IDLSAFEGEOM

```sql:signature
ST_IDLSAFEGEOM(geom)
```

**Description**

Alias of `st_antimeridianSafeGeom`.

* `geom`: `Geometry` input geom.

**Return type**

`Geometry`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_MAKEBBOX(178, 0, 190, 5) AS geom
)
SELECT carto.ST_ASTEXT(carto.ST_IDLSAFEGEOM(geom)) AS geom FROM t;
-- MULTIPOLYGON (((-180 0, -180 5, -170 5, -170 0, -180 0)), ((180 5, 180 0, 178 0, 178 5, 180 5)))
```
