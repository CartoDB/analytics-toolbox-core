### ST_WITHIN

{{% bannerNote type="code" %}}
carto.ST_WITHIN(geomA, geomB)
{{%/ bannerNote %}}

**Description**

Returns _true_ if geometry _a_ is completely inside geometry _b_.

* `geomA`: `Geometry` input geom A.
* `geomB`: `Geometry` input geom B.

**Return type**

`Boolean`

**Example**

```sql
WITH t AS (
  select ST_POINT(1, 1) as geomA,
  ST_MAKEBBOX(0, 0, 2, 2) as geomB
)
SELECT ST_WITHIN(geomA, geomB) FROM t
-- true
```