### ST_SIMPLIFYPRESERVETOPOLOGY

{{% bannerNote type="code" %}}
carto.ST_SIMPLIFYPRESERVETOPOLOGY(geom, tolerance)
{{%/ bannerNote %}}

**Description**

Simplifies a `Geometry` and ensures that the result is a valid geometry having the same dimension and number of components as the input, and with the components having the same topological relationship.


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
SELECT carto.ST_ASTEXT(carto.ST_SIMPLIFYPRESERVETOPOLOGY(geom, 1)) AS simplifiedGeom, 
    carto.ST_NUMPOINTS(carto.ST_SIMPLIFYPRESERVETOPOLOGY(geom, 1)) AS simplifiedNumpoints, 
    carto.ST_NUMPOINTS(geom) AS numPoints FROM t;
-- POLYGON ((0.0000899 0, 0 0.0000899, -0.0000899 0, 0 -0.0000899, 0.0000899 0)) | 5 | 101
```