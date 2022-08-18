### ST_TOUCHES

{{% bannerNote type="code" %}}
carto.ST_TOUCHES(geomA, geomB)
{{%/ bannerNote %}}

**Description**

Returns `true` if the geometries have at least one `Point` in common, but their interiors do not intersect.

* `geomA`: `Geometry` input geom A.
* `geomB`: `Geometry` input geom B.

**Return type**

`Boolean`

**Example**

```sql
WITH t AS (
  select ST_MAKEBBOX(0, 0, 2, 2) as geomA,
  ST_GEOMFROMWKT("LINESTRING (3 1, 1 3)") as geomB
)
SELECT ST_TOUCHES(geomA, geomB) FROM t
-- true
```