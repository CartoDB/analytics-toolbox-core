### ST_RELATE

{{% bannerNote type="code" %}}
carto.### ST_RELATE(geomA, geomB)
{{%/ bannerNote %}}

**Description**

Returns the DE-9IM 3x3 interaction matrix pattern describing the dimensionality of the intersections between the interior, boundary and exterior of the two geometries.


* `geomA`: `Geometry` input geom A.
* `geomB`: `Geometry` input geom B.

**Return type**

`String`

**Example**

```sql
WITH t AS (
  select ST_MAKEBBOX(0, 0, 2, 2) as geomA,
  ST_MAKEBBOX(1, 1, 3, 3) as geomB
)
SELECT ST_RELATE(geomA, geomB) FROM t
-- true
```