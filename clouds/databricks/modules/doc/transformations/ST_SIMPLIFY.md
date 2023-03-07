## ST_SIMPLIFY

```sql:signature
ST_SIMPLIFY(geom, tolerance)
```

**Description**

Returns a simplified version of the given `Geometry` using the Douglas-Peucker algorithm. This function does not preserve topology - e.g. polygons can be split, collapse to lines or disappear holes can be created or disappear, and lines can cross. To simplify geometry while preserving topology use ST_SIMPLIFYPRESERVETOPOLOGY.

* `geom`: `Geometry` input geom.
* `tolerance`: `Double` input distance tolerance.
double

**Return type**

`Geometry`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_BUFFERPOINT(carto.ST_POINT(0, 0), 10) AS geom
)
SELECT
  carto.ST_ASTEXT(carto.ST_SIMPLIFY(geom, 0.00001)) AS simplifiedGeom,
  carto.ST_NUMPOINTS(carto.ST_SIMPLIFY(geom, 0.00001)) AS simplifiedNumpoints,
  carto.ST_NUMPOINTS(geom) AS numPoints
FROM t;
-- POLYGON ((0.0000899 0, 0.0000656 0.0000616, 0 0.0000899, -0.0000616 0.0000656, -0.0000899 0, -0.0000656 -0.0000616, 0 -0.0000899, 0.0000616 -0.0000656, 0.0000899 0)) | 9 | 101
```
