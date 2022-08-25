### st_covers
`Boolean st_covers(Geometry a, Geometry b)`

Returns `true` if no `Point` in `Geometry` _b_ is outside `Geometry` _a_.
### ST_COVERS

{{% bannerNote type="code" %}}
carto.ST_COVERS(geomA, geomB)
{{%/ bannerNote %}}

**Description**

Returns `true` if no `Point` in `Geometry` _b_ is outside `Geometry` _a_.

* `geomA`: `Geometry` input geom A.
* `geomB`: `Geometry` input geom B.

**Return type**

`Boolean`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_MAKEBBOX(0, 0, 3, 3) AS geomA,
  carto.ST_MAKEBBOX(1, 1, 2, 2) as geomB
)
SELECT carto.ST_COVERS(geomA, geomB) FROM t;
-- true
```