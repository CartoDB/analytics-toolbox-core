### ST_MAKEPOINT

{{% bannerNote type="code" %}}
carto.ST_MAKEPOINT(x, y)
{{%/ bannerNote %}}

**Description**

Creates a `Point` with an _x_ and _y_ coordinate.

* `x`: `Double` input x value of the point.
* `y`: `Double` input y value of the point.

**Return type**

`Point`

**Example**

```sql
SELECT carto.ST_ASTEXT(carto.ST_MAKEPOINT(-91.85548, 29.50603));
-- POINT (-91.85548 29.50603)
```
