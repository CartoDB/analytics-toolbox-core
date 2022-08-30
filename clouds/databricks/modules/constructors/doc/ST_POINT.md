### ST_POINT

{{% bannerNote type="code" %}}
carto.ST_POINT(x, y)
{{%/ bannerNote %}}

**Description**

Returns a `Point` with the given coordinate values. This is an OGC alias for st_makePoint.

* `x`: `Double` input x value of the point.
* `y`: `Double` input y value of the point.

**Return type**

`Point`

**Example**

```sql
SELECT carto.ST_ASTEXT(carto.ST_POINT(-91.8554869, 29.5060349));
-- POINT (-91.8554869 29.5060349)
```
