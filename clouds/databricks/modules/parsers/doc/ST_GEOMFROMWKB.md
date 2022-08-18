### ST_GEOMFROMWKB
{{% bannerNote type="code" %}}
carto.ST_GEOMFROMWKB(wkb)
{{%/ bannerNote %}}

**Description**

Creates a `Geometry` from the given Well-Known Binary representation (WKB).

* `wkb`: `Array[Byte]` geom in WKB format.

**Return type**

`Geometry`

**Example**

```sql
WITH t AS (
  SELECT ST_ASBINARY(ST_GEOMFROMWKT('POINT(-76.09130 18.42750)')) AS wkb
)
SELECT ST_GEOMFROMWKB(wkb) FROM t;
-- 4QgBz/HU1QXwwN6vAQA=
```