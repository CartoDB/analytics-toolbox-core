### ST_X

{{% bannerNote type="code" %}}
carto.ST_X(geom)
{{%/ bannerNote %}}

**Description**

If _geom_ is a `Point`, return the X coordinate of that point.

* `geom`: `Geometry` input Point.

**Return type**

`Float`

**Example**

```sql
SELECT carto.ST_X(ST_POINT(-76.091308, 18.427501));
-- -76.091308
```
