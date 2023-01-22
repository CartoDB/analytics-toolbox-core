## ST_WITHIN

```sql:signature
carto.ST_WITHIN(geomA, geomB)
```

**Description**

Returns _true_ if geometry _a_ is completely inside geometry _b_.

* `geomA`: `Geometry` input geom A.
* `geomB`: `Geometry` input geom B.

**Return type**

`Boolean`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_POINT(1, 1) AS geomA,
  carto.ST_MAKEBBOX(0, 0, 2, 2) AS geomB
)
SELECT carto.ST_WITHIN(geomA, geomB) FROM t;
-- true
```