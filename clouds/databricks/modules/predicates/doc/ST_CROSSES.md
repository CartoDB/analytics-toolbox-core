### ST_CROSSES

{{% bannerNote type="code" %}}
carto.ST_CROSSES(geomA, geomB)
{{%/ bannerNote %}}

**Description**

Returns `true` if the supplied geometries have some, but not all, interior points in common.

* `geomA`: `Geometry` input geom A.
* `geomB`: `Geometry` input geom B.

**Return type**

`Boolean`

**Example**

```sql
WITH t AS (
  select ST_GEOMFROMWKT("LINESTRING (1 0, 1 2)") as lineA,
  ST_GEOMFROMWKT("LINESTRING (0 1, 2 1)") as lineB
)
SELECT ST_CROSSES(lineA, lineB) FROM t
-- true
```