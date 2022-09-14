### ST_ASLATLONTEXT

{{% bannerNote type="code" %}}
carto.ST_ASLATLONTEXT(p)
{{%/ bannerNote %}}

**Description**

Returns a `String` describing the latitude and longitude of `Point` _p_ in degrees, minutes, and seconds. (This presumes that the units of the coordinates of _p_ are latitude and longitude).

* `p`: `Point` input point.

**Return type**

`String`

**Example**

```sql
SELECT carto.ST_ASLATLONTEXT(carto.ST_GEOMFROMWKT('POINT(-76.09130 18.42750)'));
-- 18°25'39.000"N 77°54'31.320"W
```