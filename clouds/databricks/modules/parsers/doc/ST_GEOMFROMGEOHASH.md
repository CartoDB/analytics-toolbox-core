### ST_GEOMFROMGEOHASH

{{% bannerNote type="code" %}}
carto.ST_GEOMFROMGEOHASH(geomHash, prec)
{{%/ bannerNote %}}

**Description**

Returns the `Geometry` of the bounding box corresponding to the Geohash string _geohash_ (base-32 encoded) with a precision of prec bits. See [Geohash](https://www.geomesa.org/documentation/stable/user/appendix/utils.html#geohash) for more information on GeoHashes.

* `geomHash`: `String` Geohash code.
* `prec`: `Geometry` precison.

**Return type**

`Geometry`

**Example**

```sql
WITH t AS (
  SELECT carto.ST_ASGEOHASH(carto.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)'), 8) AS geohash
)
SELECT carto.ST_ASTEXT(carto.ST_GEOMFROMGEOHASH(geohash, 8)) FROM t;
-- POLYGON ((-90 11.25, -90 22.5, -67.5 22.5, -67.5 11.25, -90 11.25))
```