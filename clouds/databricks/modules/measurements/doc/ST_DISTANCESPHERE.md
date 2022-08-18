### ST_DISTANCESPHERE

{{% bannerNote type="code" %}}
carto.ST_DISTANCESPHERE(geomA, geomB)
{{%/ bannerNote %}}

**Description**

Approximates the minimum distance (in meters) between two longitude/latitude geometries assuming a spherical earth.

* `geomA`: `Geometry` input geom A.
* `geomB`: `Geometry` input geom B.

**Return type**

`Double`

**Example**

```sql
SELECT ST_DISTANCESPHERE(ST_POINT(0, 0), ST_POINT(0, 5)) / 1000
-- 555.9753986718438 (distance in km)
```