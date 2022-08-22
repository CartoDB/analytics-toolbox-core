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
SELECT carto.ST_ASBINARY(carto.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)'));
-- AIAAAAHAUwXX2/SH/UAybXCj1wo9AAAAAAAAAAA=
```
