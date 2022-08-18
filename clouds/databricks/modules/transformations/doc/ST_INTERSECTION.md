### ST_INTERSECTION

{{% bannerNote type="code" %}}
carto.ST_INTERSECTION(geomA, geomB)
{{%/ bannerNote %}}

**Description**

Returns the intersection of the input `Geometries`.

* `geomA`: `Geometry` input geom A.
* `geomB`: `Geometry` input geom B.

**Return type**

`Geometry`

**Example**

```sql
WITH t AS (
  select ST_MAKEBBOX(0, 0, 2, 2) as geomA,
  ST_MAKEBBOX(1, 1, 3, 3) as geomB
)
SELECT ST_ASTEXT(ST_INTERSECTION(geomA, geomB)) as intersection FROM t
-- POLYGON ((1 2, 2 2, 2 1, 1 1, 1 2))

```