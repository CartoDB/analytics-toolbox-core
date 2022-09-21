### ST_Y

{{% bannerNote type="code" %}}
carto.ST_Y(geom)
{{%/ bannerNote %}}

**Description**

If _geom_ is a `Point`, return the Y coordinate of that point.

* `geom`: `Geometry` input Point.

**Return type**

`Double`

**Example**

```sql
SELECT carto.ST_Y(carto.ST_POINT(-76.09130, 18.42750));
-- 18.4275
```
