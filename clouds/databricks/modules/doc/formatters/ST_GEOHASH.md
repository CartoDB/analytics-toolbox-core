### ST_GEOHASH

{{% bannerNote type="code" %}}
carto.ST_GEOHASH(geom, prec)
{{%/ bannerNote %}}

**Description**

Returns the Geohash (in base-32 representation) of an interior point of `Geometry` _geom_. See [Geohash](https://www.geomesa.org/documentation/stable/user/appendix/utils.html#geohash) for more information on Geohashes.

* `geom`: `Geometry` input geom.
* `prec`: `Int` input precision.

**Return type**

`Point`

**Example**

```sql
SELECT carto.ST_GEOHASH(carto.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)'), 8);
-- d4
```
