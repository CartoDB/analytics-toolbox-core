### st_x
`Float st_X(Geometry geom)`

If _geom_ is a `Point`, return the X coordinate of that point.

### ST_X

{{% bannerNote type="code" %}}
carto.ST_X(geom)
{{%/ bannerNote %}}

**Description**

--TODO
If _geom_ is a `Point`, return the X coordinate of that point.

* `geom`: `Geometry` input LineString.

**Return type**

`Float`

**Example**

```sql
SELECT carto.ST_X(ST_POINT(-76.091308, 18.427501));
-- -76.091308
```
