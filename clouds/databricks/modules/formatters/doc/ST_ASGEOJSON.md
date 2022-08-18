### ST_ASGEOJSON

{{% bannerNote type="code" %}}
carto.ST_ASGEOJSON(geom)
{{%/ bannerNote %}}

**Description**

Returns `Geometry` _geom_ in GeoJSON representation.

* `geom`: `Geometry` input geom.

**Return type**

`Point`

**Example**

```sql
SELECT ST_ASGEOJSON(ST_GEOMFROMWKT('POINT(-76.09130 18.42750)'), 8)
-- {"type":"Point","coordinates":[-76.0913,18.4275,0.0]}
```