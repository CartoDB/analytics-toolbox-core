### ST_RELATEBOOL

{{% bannerNote type="code" %}}
carto.ST_RELATEBOOL(geomA, geomB, mask)
{{%/ bannerNote %}}

**Description**

Returns `true` if the DE-9IM interaction matrix mask matches the interaction matrix pattern obtained from `st_relate(a, b)`.

* `geomA`: `Geometry` input geom A.
* `geomB`: `Geometry` input geom B.
* `mask`: `String` DE-9IM interaction matrix mask.

**Return type**

`Boolean`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_MAKEBBOX(0, 0, 2, 2) AS geomA,
  carto.ST_MAKEBBOX(1, 1, 3, 3) AS geomB
)
SELECT carto.ST_RELATEBOOL(geomA, geomB, "212101212") FROM t;
-- true
```
