### ST_POINTFROMWKB
{{% bannerNote type="code" %}}
carto.ST_POINTFROMWKB(wkb)
{{%/ bannerNote %}}

**Description**

Creates a `Point` corresponding to the given WKB representation.

* `wkb`: `Array[Byte]` geom in WKB format.

**Return type**

`Point`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_ASBINARY(carto.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)')) AS wkb
)
SELECT carto.ST_POINTFROMWKB(wkb) FROM t;
-- 4QgBz/HU1QXwwN6vAQA=
```