### ST_GEOMFROMWKT

{{% bannerNote type="code" %}}
carto.ST_GEOMFROMWKT(wkt)
{{%/ bannerNote %}}

**Description**

Creates a `Geometry` from the given Well-Known Text representation (WKT).

* `wkt`: `String` WKT text.

**Return type**

`Geometry`

**Example**

```sql
SELECT carto.ST_ASGEOJSON(carto.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)'));
-- {"type":"Point","coordinates":[-76.0913,18.4275,0.0]}
```