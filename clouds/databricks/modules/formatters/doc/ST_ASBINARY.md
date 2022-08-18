### ST_ASBINARY

{{% bannerNote type="code" %}}
carto.ST_ASBINARY(geom)
{{%/ bannerNote %}}

**Description**

Returns `Geometry` _geom_ in WKB representation.

* `geom`: `Geometry` input geom.

**Return type**

`Array[Byte]`

**Example**

```sql
SELECT ST_ASBINARY( ST_GEOMFROMWKT('POINT(-76.09130 18.42750)'))
-- AIAAAAHAUwXX2/SH/UAybXCj1wo9AAAAAAAAAAA=
```