### ST_MPOINTFROMTEXT

{{% bannerNote type="code" %}}
carto.ST_MPOINTFROMTEXT(wkt)
{{%/ bannerNote %}}

**Description**

Creates a `MultiPoint` corresponding to the given WKT representation.

* `wkt`: `String` geom in WKT format.

**Return type**

`MultiPoint`

**Example**

```sql
SELECT carto.ST_ASGEOJSON(carto.ST_MPOINTFROMTEXT('MULTIPOINT (10 40, 40 30, 20 20, 30 10)'));
-- {"type":"MultiPoint","coordinates":[[10,40,0.0],[40,30,0.0],[20,20,0.0],[30,10,0.0]]}
```