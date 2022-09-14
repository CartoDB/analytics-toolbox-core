### ST_BOX2DFROMGEOHASH

{{% bannerNote type="code" %}}
carto.ST_BOX2DFROMGEOHASH(geomHash, prec)
{{%/ bannerNote %}}

**Description**

Alias of st_geomFromGeoHash.

* `geomHash`: `String` Geohash code.
* `prec`: `Geometry` precison.

**Return type**

`Geometry`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_ASGEOHASH(carto.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)'), 8) AS geohash
)
SELECT carto.ST_ASTEXT(carto.ST_BOX2DFROMGEOHASH(geohash, 5)) FROM t;
-- POLYGON ((-90 11.25, -90 22.5, -67.5 22.5, -67.5 11.25, -90 11.25))
```
