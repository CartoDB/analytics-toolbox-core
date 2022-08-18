### ST_POINTFROMGEOHASH
{{% bannerNote type="code" %}}
carto.ST_POINTFROMGEOHASH(geohash, prec)
{{%/ bannerNote %}}

**Description**

Return the `Point` at the geometric center of the bounding box defined by the Geohash string _geohash_ (base-32 encoded) with a precision of prec bits. See [Geohash](https://www.geomesa.org/documentation/stable/user/appendix/utils.html#geohash) for more information on Geohashes.

* `geomHash`: `String` Geohash code.
* `prec`: `Geometry` precison.

**Return type**

`Point`

**Example**

```sql
WITH t AS (
  SELECT ST_ASGEOHASH(ST_GEOMFROMWKT('POINT(-76.09130 18.42750)'), 8) AS geohash
)
SELECT ST_ASTEXT(ST_POINTFROMGEOHASH(geohash, 5)) FROM t;
-- POINT (-67.5 22.5)
```