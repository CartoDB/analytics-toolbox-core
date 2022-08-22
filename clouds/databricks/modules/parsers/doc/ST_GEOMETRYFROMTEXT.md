### ST_GEOMETRYFROMTEXT
{{% bannerNote type="code" %}}
carto.ST_GEOMETRYFROMTEXT(wkt)
{{%/ bannerNote %}}

**Description**

Alias of st_geomFromWKT.

* `wkt`: `String` WKT text.

**Return type**

`Geometry`

**Example**

```sql
SELECT carto.ST_ASGEOJSON(carto.ST_GEOMETRYFROMTEXT('POINT(-76.09130 18.42750)'));
-- {"type":"Point","coordinates":[-76.0913,18.4275,0.0]}
```